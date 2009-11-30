package Zippy::Architecture::Placer;

$VERSION = 0.01;

use strict;
use warnings "all";
use Carp;
use Storable;

use Graph;
use Graph::HeapElem;

use Data::Dumper;
use Zippy::Netlist::Netlist;
use Zippy::Netlist::Node;
use Zippy::Architecture::RoutingGraph;

use Tools::Attributable;
use Tools::Util;

use vars qw( @ISA );
@ISA = qw( Tools::Attributable );

$Data::Dumper::Sortkeys = 1;


############################################################################
# constructor:
# Zippy::Architecture::Placer->new( 
#       routinggraph => $rg,        Routing Graph
#       netlist => $nl,             Netlist
#       maxiter => $iter            Iterations (optional)
# );
############################################################################

sub new {
	my $proto = shift;
    my $class = ref($proto) || $proto;
	my %arg = @_;
	#my $id = shift;
	
	my $self = {};
	bless $self, $class;
    
	if (defined $arg{routinggraph}) {
		$self->rg($arg{routinggraph});
	} else {
		croak "constructor must be called with a routinggraph argument!\n";
	}
	
	if (defined $arg{netlist}) {
		$self->nl($arg{netlist});
	} else {
		croak "constructor must be called with a netlist argument!\n";
	} 
	
	# defaults, can be overridden in constructor
    $self->set_attribute('maxiter',5);
    
	my %attr = @_;
	foreach my $key (keys %attr){
		$self->set_attribute($key,$attr{$key});
	}
	return $self;
}


sub nl {
	my $self = shift;
	if (@_) {
		my $arg = shift;
		if ($arg->isa("Zippy::Netlist::Netlist")){
			$self->{'nl'} = $arg;
		} else {
			croak ("argument netlist is not a Zippy::Netlist::Netlist object!\n");
		}
	}
	return $self->{'nl'};
}

sub rg {
	my $self = shift;
	if (@_) {
		my $arg = shift;
		if ($arg->isa("Graph")){
			$self->{'rg'} = $arg;
		} else {
			croak ("argument routinggraph is not a Graph object!\n");
		}
	}
	return $self->{'rg'};
}


sub computeFeasibleRoutings {
    my $self = shift;
    my $reachabilitygraphfile = shift;
    
    my %Reachability;
    my $hrReachability = \%Reachability;
    
    if (-f $reachabilitygraphfile){
        $hrReachability = retrieve($reachabilitygraphfile);
        $self->{'routable'} = $hrReachability;
        return;
    }
    
    my @sites;
    my @cellSites = @{$self->rg->getResourcesOfType($Zippy::Architecture::RoutingGraph::NODETYPE_C)};
    my @primaryOutputSites = @{$self->rg->getResourcesOfType($Zippy::Architecture::RoutingGraph::NODETYPE_PO)}; 
    my @primaryInputSites = @{$self->rg->getResourcesOfType($Zippy::Architecture::RoutingGraph::NODETYPE_PI)};

    @sites = (@cellSites,@primaryOutputSites,@primaryInputSites);
    #print Dumper (@sites);

    my ($routable,$fromName,$toName);
    for(my $from=0; $from < scalar(@sites); $from++) {
        for(my $to=0; $to < scalar(@sites); $to++) {
            $fromName = $sites[$from];
            $toName = $sites[$to];
            #print "check for feasible route from:$fromName to:$toName\n";
            $routable = $self->rg->feasibleRoute($fromName,$toName);
            $hrReachability->{$fromName}->{$toName} = 1 if $routable;
        }
    }
    #print Dumper($self->{'routable'});
    $self->{'routable'}=$hrReachability;
    
    if ($reachabilitygraphfile ne ""){
        store(\%Reachability,$reachabilitygraphfile);
    }
    
    return;
}


############################################################################
# heuristic placer (based on neighborhood relations)
############################################################################

# potential for improvements:
#  if a node is a sucessor of one node and a predecessor of another node that
#    should be processed withing the same placement step, this node should be 
#    placed a a location that is a neighbor to the predecessor _and_ the succesor
#    node
#

## FIXME: %placed seems redundant, %placement is probably sufficient

## FIXME: place PIs and POs too
sub getHeuristicPlacement {
    my $self = shift;

    my %placement;
    my %archModel;
    
    ## FIXME: use getSiteName method of RoutingGraph to determine sitenames
    foreach my $r (0..$Zippy::Architecture::RoutingGraph::ROWS-1) {
        foreach my $c (0..$Zippy::Architecture::RoutingGraph::COLS-1) {
            my $cellName = sprintf("c_%d_%d",$r,$c);
            $archModel{$cellName}{'used'}=0;
            $archModel{$cellName}{'priority'}=$r*$Zippy::Architecture::RoutingGraph::ROWS+
                $c;
            $archModel{$cellName}{'prefin'}=$self->rg->getLocalNeighbors($r,$c,'in');
            $archModel{$cellName}{'prefout'}=$self->rg->getLocalNeighbors($r,$c,'in');
        }
    }
    #print Dumper \%archModel;
    
    
    ## FIXME: code doesnt work for virtualized circuits since there are nodes,
    ##  that have no successor but are not primary outputs, same is true for
    ##  primary inputs
    
    my $G=$self->nl->getGraph;  # netlist as a graph
    my $totalNodes = scalar ($G->vertices);

#    my @pi = grep { (scalar($G->predecessors($_)) == 0) } $G->vertices;
#    my @po = grep { (scalar($G->successors($_)) == 0) } $G->vertices;

    ## above definition of primary input and output doesnt work well for nodes
    ## that are terminals but neither PI nor POs
    
#    my @c = @{$self->nl->getNodesOfType('cell')};
    my @piNodes = @{$self->nl->getNodesOfType('in')};
    my @pi = map { $_->name} @piNodes;
    my @poNodes = @{$self->nl->getNodesOfType('out')};
    my @po = map { $_->name} @poNodes;
        
    
#    my @primaryInputNodes = $self->nl->getNodes
    
    print "primary inputs: " . join(",",@pi) ."\n";
    print "primary outputs: " . join(",",@po) ."\n";

    my %placed = map { $_ => 1 } (@pi,@po);  # assume that all PIs and POs are placed,
                                             # FIXME: later 
                                             
    my %isPIPO = map { $_ => 1 } (@pi,@po);  # hash containing all PIs and POs

    ############################################################################
    ## place all cells with fixed placement constraints first
    ############################################################################
    my @c = @{$self->nl->getNodesOfType('cell')};
    my @cellsWithoutFixedPlacement = grep { ($_->get_attribute('placementconstr') eq 'none') } @c;
    #FIXME: old version didn't support initial placement
    #my @cellsWithFixedPlacement = grep { ($_->get_attribute('placementconstr') eq 'fixed') } @c;
    
    my @cellsWithFixedPlacement = grep { ($_->get_attribute('placementconstr') eq 'fixed') or 
                                         ($_->get_attribute('placementconstr') eq 'initial') } @c;


    my %preplaced = map { $_->name => 1 } @cellsWithFixedPlacement;
    my @preplacedNames = map { $_->name } @cellsWithFixedPlacement;
    
    foreach my $cell (@cellsWithFixedPlacement){
        my $p = $cell->get_attribute('placement');
        $placement{$cell->name} = $p;
        $placed{$cell->name} = 1;
        $archModel{$p}{'used'} = 1;
    }

    # start netlist topology discovery starting from PIs and from the preplaced nodes
    my @lastPlacedOps = (@pi,@preplacedNames); 
    my @lastPlacedOpsNext;
    
    my ($curRow, $curCol, $curCellName);
    my ($candRow, $candCol, $candCellName);
    
    while (scalar(keys(%placed)) < $totalNodes){
        @lastPlacedOpsNext = ();
                
        foreach my $op (@lastPlacedOps){

            # get placement for current op
            if (defined $isPIPO{$op}){
                $curCellName = "c_0_0";
            } else  {
                $curCellName = $placement{$op};
            }

                
            # determine predecessors and successors of current operation
            my @suc = $G->successors($op);
            my @pre = $G->predecessors($op);

            my @prefPlacement;
            
            ### succesors: either a node has a single or a several (fanout) 
            ###   successors. treat these cases differently, since fanout can be
            ###   handled more effiently by using buses, instead of local wires 
            foreach my $s (@suc){
                if (not defined $placed{$s}){
                    print "scheduling successor $s of $op\n";
                    
                    ## net with with fan-out <=2 (try to used local interconnect)
                    if (scalar @suc <= 2){
                        # find location for @s and @p that are neighbors of $op
                        @prefPlacement = @{$archModel{$curCellName}{'prefout'}};
                    } else {

                        # placing a fan-out net. Use buses rather than local interconnect
                        # i.e. place successors not to neighbor nodes
                        #
                        print sprintf("placing a fanout net with fanout of %d\n",scalar @suc);
                        $curCellName =~ m/c_(\d*)_(\d*)/;
                        my ($r,$c) = ($1,$2);
                        my (@fanOutCellRow,@fanOutCellCol);

                        my @rows;
                        push @rows,$r; 
                        push @rows, $r-1 % $Zippy::Architecture::RoutingGraph::ROWS;
                        push @rows, $r+1 % $Zippy::Architecture::RoutingGraph::ROWS;
                        
                        foreach my $ir (@rows) {
                            for(my $ic=0;$ic<$Zippy::Architecture::RoutingGraph::ROWS;$ic++){
                                push @fanOutCellRow, ($ir % $Zippy::Architecture::RoutingGraph::ROWS);
                                push @fanOutCellCol, ($ic % $Zippy::Architecture::RoutingGraph::COLS);
                            }
                        }
                        #print Dumper (\@fanOutCellRow, \@fanOutCellCol);
                        
                        @prefPlacement = ();
                        for (my $i=0; $i<scalar(@fanOutCellRow);$i++) {
                            push @prefPlacement, sprintf("c_%d_%d",$fanOutCellRow[$i],$fanOutCellCol[$i]);  
                        }
                    }

                    # filter for unused sites
                    @prefPlacement = grep { ($archModel{$_}{'used'} == 0) } @prefPlacement;
                    
                    print "last op was placed to $curCellName,";
                    print "current op $op could be placed to:" . join(",",@prefPlacement) ."\n";
                    my $place;
                    if (scalar(@prefPlacement) > 0){
                        $place = shift @prefPlacement;
                    } else {
                        ## FIXME: make this smarter!
                        my @cands = grep { ($archModel{$_}{'used'} == 0) } keys(%archModel);
                        $place = Tools::Util::listChooseAny(\@cands);

                        print "=====>>>> heuristic Placer: no unused neighbors sites left!\n";
                        print "=====>>>> using a random location: $place\n\n";
                    }
                    
                    $archModel{$place}{'used'}=1;
                    $placement{$s}=$place;
                    # place @s and @p to these locations
                    # mark @s and @p as placed
                    # add @s and @p to lastPlacedOps (for next iteration)

                    $placed{$s} = 1;
                    push @lastPlacedOpsNext,$s;
                }
            }
            
            
            ### predecessors: place each predecessor to a neighbor place
            ###  
            foreach my $p (@pre){
                if (not defined $placed{$p}){
                    print "scheduling precessor $p of $op\n";

                    # find location for @s and @p that are neighbors of $op    
                    my @prefPlacement = @{$archModel{$curCellName}{'prefout'}};
                    @prefPlacement = grep { ($archModel{$_}{'used'} == 0) } @prefPlacement;
                    print "op $op could be placed to:" . join(",",@prefPlacement) ."\n";
                    my $place;
                    if (scalar(@prefPlacement) > 0){
                        $place = shift @prefPlacement;
                    } else {
                        ## FIXME: make this smarter!
                        my @cands = grep { ($archModel{$_}{'used'} == 0) } keys(%archModel);
                        $place = Tools::Util::listChooseAny(\@cands);

                        print "=====>>>> heuristic Placer: no unused neighbors sites left!\n";
                        print "=====>>>> using a random location: $place\n\n";
                    }
                    
                    $archModel{$place}{'used'}=1;
                    $placement{$p}=$place;

                    # place @s and @p to these locations
                    # mark @s and @p as placed
                    # add @s and @p to lastPlacedOps (for next iteration)

                    $placed{$p} = 1;
                    push @lastPlacedOpsNext,$p;
                }
            }
            
        }
    
        @lastPlacedOps = @lastPlacedOpsNext;
    }

    #print Dumper(\%placed);
    #print Dumper(\%placement); die;

    my (@retCells,@retPlacement,@retUnused);
    
    foreach my $opName (keys %placement) {
        push @retCells,$self->nl->getCellByName($opName);
        push @retPlacement,$placement{$opName};
    }

    my %usedSites = map { $_ => 1 } values %placement;
    
    foreach my $site (keys %archModel) {
        if (not defined $usedSites{$site}) {
            push @retUnused,$site;
        }
    }

    my %r;    
    $r{'cells'} = \@retCells;
    $r{'placement'} = \@retPlacement;
    $r{'unused'} = \@retUnused;
    
    #print Dumper(\%r);
    return %r;
}


## FIXME: place PIs and POs too
sub getRandomPlacement {
    my $self = shift;
    
    my @sitenames = @{$self->rg->getSiteNames};
    my @c = @{$self->nl->getNodesOfType('cell')};
    my @pi = @{$self->nl->getNodesOfType('in')};
    my @po = @{$self->nl->getNodesOfType('out')};
    
    my @cellsWithoutFixedPlacement = grep { ($_->get_attribute('placementconstr') eq 'none') } @c;
    # FIXME: previous version didnt support initial placement constraints.
    #my @cellsWithFixedPlacement = grep { ($_->get_attribute('placementconstr') eq 'fixed') } @c;
    
    my @cellsWithFixedPlacement = grep { ($_->get_attribute('placementconstr') eq 'fixed') or
                                         ($_->get_attribute('placementconstr') eq 'initial') } @c;
    my @piWithFixedPlacement = grep { ($_->get_attribute('placementconstr') eq 'fixed') } @pi;
    my @poWithFixedPlacement = grep { ($_->get_attribute('placementconstr') eq 'fixed') } @po;
    #print Dumper(\@cellsWithFixedPlacement, \@piWithFixedPlacement, \@poWithFixedPlacement);
    #die;

    my (@cells,@placement);
    
    foreach my $cell (@cellsWithFixedPlacement){
        my $place = $cell->get_attribute('placement');
        #print sprintf("cell %s has a fixed placement to %s\n",$cell->name,$place);
        push @cells,$cell;
        push @placement,$place;
        my @sitenames = @{Tools::Util::listRemoveElement($place,\@sitenames)};
    }
    
    foreach my $cell (@cellsWithoutFixedPlacement){
        push @cells,$cell;
        my ($randomSite,$ar) = Tools::Util::listRemoveAny(\@sitenames);
        @sitenames = @{$ar};
        push @placement,$randomSite;
    }
    
    #for(my $i=0; $i< scalar(@cells);$i++){
    #    print sprintf("%s --> %s\n",$cells[$i]->name,$placement[$i]);
    #}
    
    my %r;
    $r{'cells'} = \@cells;
    $r{'placement'} = \@placement;
    $r{'unused'} = \@sitenames;
    return %r;
}


## generate initial placement with simulated annealing
sub getInitialPlacementSA {
    my $self = shift;
    
    
    my $lowerBoundOfRoutingDistance = $self->lowerBoundOfRoutingDistance;
    my %initialPlacement = $self->getRandomPlacement;
    
    ### FIXME code copied from Placer->init
    #  change init function later on, updatePlacement should initilize
    #   all placement related data strctures.
    
    ## <toberemoved>
    my (%mapCellNameToSite,%mapSiteToCellName);
    my @placement = @{$initialPlacement{'placement'}};
    my @cellsInNetlist = @{$initialPlacement{'cells'}};
    my @unusedSites = @{$initialPlacement{'unused'}};
    
    foreach my $site (@placement) {
        my $c = shift @cellsInNetlist;
        $mapSiteToCellName{$site} = $c->name;
        $mapCellNameToSite{$c->name} = $site;
    }

    foreach my $site (@unusedSites) {
        $mapSiteToCellName{$site} = "unused";
    }
  
    $self->{mapCellNameToSite} = \%mapCellNameToSite;
    $self->{mapSiteToCellName} = \%mapSiteToCellName;

    # </toberemoved>

    $self->updatePlacement;

    my $cost = $self->getRoutingDistanceForPlacement;

    my $maxIterOuter = 80;
    my $maxIterInner = 200;
    my $temperature = 8;
    my $temperatureUpdate = 0.98;

    my %archive;
    $archive{bestCost} = 1000000; # FIXME find better initialization
    $archive{bestMapCellNameToSite} = $self->{mapCellNameToSite};
    $archive{bestMapSiteToCellName} = $self->{mapSiteToCellName};

    my $outer;       # iterations of placer in outer SA loop
    my $inner;       # inerations of placer in inner SA loop

    OUTERLOOP: for($outer=1; $outer<=$maxIterOuter; $outer++){

        INNERLOOP: for($inner=1; $inner<=$maxIterInner;$inner++){

            ### make random move ##################################
            $self->randomMove(1);

            ### evaluate objective function #######################
            my $newCost = $self->getRoutingDistanceForPlacement;

            ### compute cost delta ################################
            ## $deltaCost > 0  --> new solution is worse solution
            ## $deltaCost < 0  --> new solution is better soultion
            my $bestCost = $archive{bestCost};
            my $deltaCost = $newCost - $bestCost;
            
            ### simulated annealing step
            my $r = rand(1);
            my $ex = exp(-$deltaCost/$temperature);
            my $accept = ( $ex > $r) ? 1 : 0;
    
            if (($deltaCost < 0) and (not $accept)){
                die sprintf("dC=%d temp=%f exp(-dC/temp)=%f rand=%f",
                    $deltaCost,$temperature,$ex,$r);        
            }
        
            my $str;
            $str .= sprintf("%% Placer status  oi: %s/%s ii: %s/%s t: %f\n",
                $outer,$maxIterOuter,$inner,$maxIterInner,$temperature);

            my $status;
            $status = "ACCEPT and EQUAL   " if($accept and ($deltaCost == 0));
            $status = "ACCEPT and BETTER  " if($accept and ($deltaCost < 0)); 
            $status = "ACCEPT and WORSE   " if($accept and ($deltaCost > 0)); 
            $status = "NOTACCEPT and WORSE" if(not $accept); 

            $str .= sprintf ("%% %s\n",$status);
            $str .= sprintf ("%% cost       curr: %2.3f  best: %2.3f  delta: %2.3f  opt: %d\n",
            $newCost,$bestCost,$deltaCost,$lowerBoundOfRoutingDistance);
            $str .= sprintf ("%% sa        dcost: %2.3f  ex:   %2.3f  rand:  %2.3f\n",$deltaCost,$ex,$r);
            print $str;
    
            if ($accept){
                # store best solution
                $archive{bestCost} = $newCost;
                $archive{bestMapCellNameToSite} = $self->{mapCellNameToSite};
                $archive{bestMapSiteToCellName} = $self->{mapSiteToCellName};
            } else {
                # restore best solution found so far
                $self->{mapCellNameToSite} = $archive{bestMapCellNameToSite};
                $self->{mapSiteToCellName} = $archive{bestMapSiteToCellName};
            }
        }  ## inner loop
    
        # update temperature
        $temperature = $temperature * $temperatureUpdate;
    }

    # print $self->prettyPrintWithFormat('ZNF_initial');
    
}


## 
sub getRoutingDistanceForPlacement {
    my $self = shift;

    my $dist = 0;

    NET: foreach my $net ($self->nl->get_nets) {
        next NET if ($net->source->get_attribute('type') eq 'in');
        
        SINK: foreach my $sink ($net->get_sinks) {
            next SINK if ($sink->get_attribute('type') eq 'out');
        
            $dist += $self->rg->getRoutingDistance(
                $net->source->get_attribute('placement'),
                $sink->get_attribute('placement'));
        
        }
    }
    
    return $dist;
}


sub lowerBoundOfRoutingDistance {
    my $self = shift;
    my $dist = 0;
    
    NET: foreach my $net ($self->nl->get_nets) {
        next NET if ($net->source->get_attribute('type') eq 'in');
        
        SINK: foreach my $sink ($net->get_sinks) {
            next SINK if ($sink->get_attribute('type') eq 'out');
            $dist += 1;
        }
    }
    return $dist;
}


sub init {
    my $self = shift;
    
    my (%mapCellNameToSite,%mapSiteToCellName);
    
    print "SA placer: Creating initial placement for netlist\n";
    
    #print "xxxxx NEW NEW NEW NEW xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n";
    #$self->getInitialPlacementSA;
    
    #my %initialPlacement = $self->getRandomPlacement;
    my %initialPlacement = $self->getHeuristicPlacement;
    #print Dumper(\%initialPlacement); die;

    my @placement = @{$initialPlacement{'placement'}};
    my @cellsInNetlist = @{$initialPlacement{'cells'}};
    my @unusedSites = @{$initialPlacement{'unused'}};
    
    foreach my $site (@placement) {
        my $c = shift @cellsInNetlist;
        $mapSiteToCellName{$site} = $c->name;
        $mapCellNameToSite{$c->name} = $site;
    }

    foreach my $site (@unusedSites) {
        $mapSiteToCellName{$site} = "unused";
    }
  
    #print "mapSiteToCellName =========> " .Dumper(\%mapSiteToCellName) ."\n";
    #print "mapCellNameToSite =========> " .Dumper(\%mapCellNameToSite) ."\n";

    $self->{mapCellNameToSite} = \%mapCellNameToSite;
    $self->{mapSiteToCellName} = \%mapSiteToCellName;
     
    $self->updatePlacement();
    print $self->prettyPrintWithFormat('ZNF_initial');   
}


sub updatePlacement {
    my $self = shift;
    
    printf "updatePlacement\n";
    my $hrmapCellNameToSite = $self->{mapCellNameToSite};
    my ($cellName,$site,$cell);
    while (($cellName,$site) = each %{$hrmapCellNameToSite}) {
        $cell = $self->nl->getCellByName($cellName);
        #printf sprintf("update placement for cell %s to %s\n",$cell->name,$site);
        $cell->set_attribute('placement',$site);
    }
}


# pick random cell c in netlist
# pick random location l in netlist
# cl = cell currently placed at location l
# if (cl == undef)
#    place cell c to location l
# else
#    swap locations of cl and c
# endif

## cell= (name of) operator in netlist
## very confusing/inconsistent terminology throughout whole code
## FIXME FIXME
sub randomMove {
    my $self = shift;
    #print Dumper($self);
    # size of the neighborhood = number of cells whose placement is swapped
    my $size = shift;
    
    my $hrmapCellNameToSite = $self->{mapCellNameToSite};
    my $hrmapSiteToCellName = $self->{mapSiteToCellName};

    ## method returns an array reference whose entries (that are arry references
    ##  too) gives the history of swaps that have been performed. For each 
    ##  pair of cells Ca and Cb an array containing
    ##     [cellname Ca, sitename Ca, cellname Cb, sitename Cb]
    my $arSwapped;


    my @cellNames = keys %{$hrmapCellNameToSite};
    my @cells = map($self->nl->getCellByName($_),@cellNames);
    # FIXME: previous version didnt support initial placements
    #my @movableCells = grep { $_->get_attribute('placementconstr') eq 'none' } @cells;

    my @movableCells = grep { $_->get_attribute('placementconstr') ne 'fixed' } @cells;
    if (not scalar @movableCells > 0){
        die "placer: cannot perform a random move, all cells have fixed placement";
    }
    my @movableCellNames = map($_->name,@movableCells);
    
    ## find better variable names
    my @sites = keys %{$hrmapSiteToCellName};
    my @cellsAtSites = map($hrmapSiteToCellName->{$_},@sites);
    my @feasibleSites;
    
    foreach my $site (@sites){
        my $feasible = 0;
        my $cellName = $hrmapSiteToCellName->{$site};
        if ($cellName eq "unused"){
            push @feasibleSites,$site;
        } else {
            my $cell = $self->nl->getCellByName($cellName);
            #print Dumper($cell);
            if ($cell->get_attribute('placementconstr') ne 'fixed'){
                push @feasibleSites,$site;
                #print "-- no placement constraint for cell $cellName\n";
            }
            ## otherwise a netlist operator with fixed placement is 
            ## mapped to this site.
        }
    }
    
    print sprintf("randomMove: moving %d cells\n",$size);
    
    while ($size--){

        # choose a random cell, that is to be swapped
        my $cellName = Tools::Util::listChooseAny(\@movableCellNames);
        my $cellSite = $hrmapCellNameToSite->{$cellName};
        #print sprintf("randomMove: move cell %s @ placement %s\n",$cellName,$cellSite);
        
        # chose a random site, where to move the cell to
        my $randomSite = Tools::Util::listChooseAny(\@feasibleSites);
        my $cellAtRandomSiteName = $hrmapSiteToCellName->{$randomSite};
        
        my $swapped = [ $cellSite, $cellName, $randomSite, $cellAtRandomSiteName ];
        push @{$arSwapped},$swapped;
        
        if ($cellAtRandomSiteName eq "unused") {
            ## move cell to randomSite
            $hrmapCellNameToSite->{$cellName}=$randomSite;
            $hrmapSiteToCellName->{$randomSite}=$cellName;

            $hrmapSiteToCellName->{$cellSite} = "unused";
            my $cellNode=$self->nl->getCellByName($cellName);
            #print sprintf("randomMove: moved cell %s (%s) to site %s (previously unused)\n",
            #    $cellNode->name,$cellSite,$randomSite);
        } else {
            ## swap cell and cellAtRandomSite
            $hrmapCellNameToSite->{$cellName} = $randomSite;
            $hrmapSiteToCellName->{$randomSite} = $cellName;
            
            $hrmapCellNameToSite->{$cellAtRandomSiteName} = $cellSite;
            $hrmapSiteToCellName->{$cellSite} = $cellAtRandomSiteName;
            
            my $cellNode = $self->nl->getCellByName($cellName);
            my $cellAtRandomSiteNode = $self->nl->getCellByName($cellAtRandomSiteName);
            #print sprintf("randomMove: exchanged cells cell %s (%s) and %s (%s)\n",
            #    $cellNode->name,$cellSite,$cellAtRandomSiteNode->name,$randomSite);
        }
    }

    ## FIXME: slight overkill, updating changed placements is enough
    $self->updatePlacement;    
    #print $self->prettyPrintWithFormat('ZNF_initial');
    return $arSwapped;
}

sub prettyPrintWithFormat {
    my $self = shift;
    my $format = shift;
    
    my $r;
    my $fmt;
    
    if ($format eq 'ZNF_initial'){
    
        my $hrmapCellNameToSite = $self->{mapCellNameToSite};
        my $hrSiteToCellName = $self->{mapSiteToCellName};
    
        foreach my $netlistNodeName (sort(keys(%{$hrmapCellNameToSite}))){
            my $netlistNode = $self->nl->getCellByName($netlistNodeName);
            if($netlistNode->get_attribute('placementconstr') eq 'fixed'){
                $fmt = "c %s %s %s:f\n";
            } else {
                $fmt = "c %s %s %s:i\n";
            }
            $r .= sprintf($fmt, $netlistNodeName, 
                $netlistNode->get_attribute('type'),
                $hrmapCellNameToSite->{$netlistNodeName});
        }        
        return $r;
    }
    
    die "prettyPrintWithFormat: format \'$format\' not implemented!";
}

##############################################################################
# check whether the netlist has a valid placement for the architecture
#   valid means that:
#    a) every node in the netlist has a placement property, and that
#    b) the routing graph has a node that matches this placement constraint 
#
##############################################################################

sub valid_placement {
	my $self = shift;
    my %siteUser;

	foreach my $net ($self->nl->get_nets) {
		my $i = 0;
        print sprintf("checking if placement is valid for net %s\n",$net->name);
		foreach my $wire ($net->get_wires){
			my $placement_so = $wire->source->get_attribute('placement'); 
			if (! $self->rg->has_vertex($placement_so)) {
				die sprintf("%s is not a valid placement for source node %s: " .
                            "netname: %s wire:%d",
					$wire->source->name, $placement_so, $net->name,	$i);
				return 0;
			}
			
            if (not defined $siteUser{$placement_so}){
                $siteUser{$placement_so} = $wire->source->name;
            } else {
                if ($siteUser{$placement_so} ne $wire->source->name){
                    die sprintf("site %s used more the once and cannot be used " .
                                "by %s since already used by %s",
                                $placement_so,$wire->source->name,
                    $siteUser{$placement_so});
                }
            }
            
			my $placement_si = $wire->sink->get_attribute('placement'); 
			if (! $self->rg->has_vertex($placement_si)) {
                if ((not defined $placement_si) or ($placement_si eq "") ){
                    $placement_si = 'undefined';
                }
				die sprintf("\'%s\' is not a valid placement for sink node:%s " .
                            "netname:%s wire:%d",
					$placement_si, $wire->sink->name, $net->name, $i);
			}		
			
            if (not defined $siteUser{$placement_si}){
                $siteUser{$placement_si} = $wire->sink->name;
            } else {
                if ($siteUser{$placement_si} ne $wire->sink->name){
                    die sprintf("site %s used more the once. cannot be used by %s ".
                    "since already used by %s",$placement_si,$wire->sink->name,
                    $siteUser{$placement_si});
                }
            }
            
            $i++;
        }

	}
	return 1;
}

sub routablePlacement {
    my $self = shift;
    my $unroutableNets = 0;
    
	foreach my $net ($self->nl->get_nets()) {
        my $s;
        my $i=0;
        my $netIsUnroutable = 0;
    
		WIRE: foreach my $wire ($net->get_wires()){
			my $placement_so = $wire->source->get_attribute('placement'); 
			my $placement_si = $wire->sink->get_attribute('placement'); 

            $s = sprintf("net: %s   source: %s  sink: %s  wire: %d",
                    $net->name, $placement_so, $placement_si, $i);

            if (not $self->{'routable'}->{$placement_so}->{$placement_si}) {
                #print sprintf("******** placement not routable: %s\n",$s);
                #print "placement not routable, thus invalid placement!\n";
                $netIsUnroutable = 1;
                last WIRE;
            }
            #else
            #{
            #   print sprintf("----- placement is routable: %s\n",$s);
            #}
            $i++;
        }
        $unroutableNets++ if ($netIsUnroutable);
    }
	return ($unroutableNets == 0) ? 1 : -$unroutableNets;
}

return 1;
