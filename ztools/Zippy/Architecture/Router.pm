package Zippy::Architecture::Router;

$VERSION = 0.01;

use strict;
use warnings "all";
use Carp;

use Graph;
use Graph::HeapElem;

use Data::Dumper;
use Zippy::Netlist::Netlist;
use Zippy::Architecture::RoutingGraph;

use Heap::Fibonacci 0.71;  # Fibonacci Heap for priority queue

use vars qw( @ISA );
@ISA = qw( Graph );

my $DEBUG=0;

our $ROUTER_SUCCESS = 1;               # routing succeded
our $ROUTER_FAILED_OVERUSAGE = -1;     # routing failed due to overusage of resources
our $ROUTER_FAILED_UNREACHABLE = -2;   # routing failed because under current placement, 
                                       # certain nodes are unreachable

our $ROUTER_UNROUTED = 1;              # net that is not routed (could be routable or unroutable)
our $ROUTER_ROUTED   = 2;              # net that is routed
our $ROUTER_UNROUTABLE = 3;            # net that could not be routed by router

############################################################################
# constructor:
# Zippy::Architecture::Router->new( routinggraph => $rg, netlist => $nl)
#   optional arguments:
#       maxiter     : maximum number of iterations router should perform
#                     in search for a valid routing
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
    $self->set_attribute('maxiter',10);  # maximum number of iterations
    
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

# FIXME: no criticality at the moment crit(i,j)=1 for all nets i and sinks j;
sub route_pathfinder {
    my $self = shift;

    my $iter = 0;    
    my $wireUnroutable = 0;       # set whenever a wire is not routable
    my $netUnroutable = 0;        # set whenever a net is not routable
    my $netlistUnroutable = 0;    # set if any part of netlist is unroutable
    
    my $netsTotal = $self->nl->netsTotal;
    my $netsRouted = 0;
    my $netsRoutedSuccess = 0;
    my $netsRoutedFailure = 0;

        
	############################################################################
	# initializations, reset resource usage and cost values
	############################################################################
	foreach my $v ($self->rg->vertices){
		$self->rg->resource_usage_init($v);
    }
    $self->rg->resource_init_cost_all();
	
    ROUTING_ITERATION: {
    do { 
		
        $netsRoutedSuccess = 0;
        $netsRoutedFailure = 0;
        
        print sprintf("XXX Pathfinder: routing iteration %d\n",$iter);
	
		#print sprintf("Netlist before at beginning of iteration %d\n",$iter);
		#print $self->nl->pp();
	
		foreach my $net ($self->nl->get_nets()) {
 
            $netUnroutable = 0;        # set whenever a new net is routed
 
			######################################################################
			# rip up and update p(n)
			######################################################################
			if ($self->rg->route_net_is_routed($net)) {
				#print sprintf("rip_up_and_update_p net %s;\n",$net->name);
				$self->rg->route_usage_remove_net($net);
				$self->rg->update_p_and_cost($net);
			} else {
				# no rip-up if net is not routed yet, i.e., at first routing iteration
				#print sprintf("net \"%s\" has never been routed, thus no rip_up_and_update\n",$net->name);
			}
			#print sprintf("routing net: \"%s\"\n",$net->name());
			#print $net->pp();
	    
			########################################################################
			# perform a minimum cost routing in the routing graph
			########################################################################
			#print "doing a priority queue based shortest path routing\n";
		
            ## FIXME: rename $source to $sourceName
			my $source = $net->source->get_attribute('placement');
            
            my $sourceType = $net->source->get_attribute('type');
            die ("sourceType for $source not defined!") if $DEBUG and (not defined $sourceType);
            
            ## FIXME: shouldn't the types of the nodes use the types defined in
            ## RoutingGraph (pro: consistency, con: device specific)

            if ($sourceType eq 'cell') {
                $source = Zippy::Architecture::RoutingGraph::cellNameToOutputName($source);
            }
            
            my $heap = Heap::Fibonacci->new;
            my ( %in_heap, %weight, %parent );
			my $G = $self->rg(); # routing graph

			# initialize heap
			$weight{$source} = 0;
			foreach my $v ( $G->vertices ) {
				my $e = Graph::HeapElem->new( $v, \%weight, \%parent );
				$heap->add( $e );
				$in_heap{$v} = $e;
			}
			# The other weights are by default undef (infinite).

            ## Performance improvement over plain Dijkstra SP for complete graph
            ## Early termination of algorithm if all the sinks of a net have been reached
            my @sinkList = $net->get_sinks;
            my %sinks;
            my $sinksToRoute = scalar(@sinkList);
            #printf sprintf("#sinks to be routed %d\n",$sinksToRoute);
            foreach my $sink (@sinkList) {
                my $placement = $sink->get_attribute('placement');
                $sinks{$placement} = 1;
                #print sprintf ("sink->name %s placement %s\n",$sink->name,$placement);
            }
                

            ## Tried to speed up the computation of Dijkstra Algorithm by manually
            ## inlining the accessor methods, i.e. ->vertex and ->weight access.
            ## This didn't clearly result in a yield in performance, so we stick with
            ## this version which is much more readable
            
			DISCOVER: while ( defined $heap->top ) {
				my $u = $heap->extract_top;                
                if (defined $sinks{$u->vertex}) {
                    delete $sinks{$u->vertex};
                    $sinksToRoute--;
                    last DISCOVER unless $sinksToRoute;
                }
                
				delete $in_heap{ $u->vertex };
				my $uw = $u->weight;

                foreach my $v ( $G->successors( $u->vertex ) ) {
					if ( defined( $v = $in_heap{ $v } ) ) {
						my $ow = $v->weight;
						my $nw = $G->get_attribute( 'weight', $u->vertex, $v->vertex ) +
							($uw || 0); # The || 0 helps for undefined $uw.
			
						# Relax the edge $u - $v.
						if ( not defined $ow or $ow > $nw ) {
							$v->weight( $nw );
							$v->parent( $u->vertex );
							$heap->decrease_key( $v );
						}
					}
				}
            }
                        
			# for each net: attribute 'rt' stores the routing tree (Graph object)
			# for each wire of net: attribute 'path' stores the routing path for this wire
            my $rt = Graph->new();
			
            foreach my $wire ($net->get_wires()) {
				my $sink = $wire->sink;
				my $sink_name = $sink->get_attribute('placement');
                my $sinkType = $sink->get_attribute('type');
                if (!defined $sinkType) {
                    die "sinkType for $sink_name not defined!";
                }

                if ($sinkType eq 'cell') {
                    $sink_name = Zippy::Architecture::RoutingGraph::cellNameToInputName($sink_name);
                }
                
                $wireUnroutable = 0;
                
                my @path = ( $sink_name );
                #print sprintf("source_name=%s sink_name=%s parent=%s\n",$source,$sink_name, $parent{$sink_name});
                if ( defined $parent{$sink_name} ) {
                    push @path, $parent{$sink_name};
                    if ( $parent{$sink_name} ne $source ) {
                        my $vv = $parent{$sink_name};
                        while ( $vv ne $source ) {
                            if (not defined $parent{$vv}){
                                $wireUnroutable = $netUnroutable =  $netlistUnroutable = 1;
                                last;
                            }
                            #print sprintf("source=%s vv=%s parent{vv}=%s\n",$source,$vv,$parent{$vv});
                            push @path, $parent{$vv};
                            $vv = $parent{$vv};
                        }
                    }
                    if ($wireUnroutable == 1) {
                        $wire->delete_attribute('path');
                        print sprintf("net %s: source %s --> sink %s is not routable\n",$net->name,
                            $source,$sink_name);
                        $wire->delete_attribute('pathcost');
                    } else {
                        #print sprintf("SP to sink %s is [%s]\n",$sink->name,join(',',@path));
                        @path = reverse (@path);
                        
                        $rt->add_path(@path);
                        $wire->set_attribute('path',\@path); # store path in path attr of wire
                        $wire->set_attribute('pathcost',$weight{$sink_name});
                    }
                }
                
			} ## foreach wire

            if ($netUnroutable == 0){
                $netsRoutedSuccess++;
                $net->set_attribute('rt',$rt); # store routing tree in rt attr of net
                $net->set_attribute('routingstatus',$ROUTER_ROUTED);
                $self->rg->route_usage_add_net($net);
                $self->rg->update_p_and_cost($net);
            } else {
                $netsRoutedFailure++;
                $net->delete_attribute('rt'); #
                $net->set_attribute('routingstatus',$ROUTER_UNROUTABLE);
            } 
            
            
            if (1) {
                print sprintf ("route: iter %d/%d  nets tot/suc/fail/rem (%d,%d,%d,%d) net: %s\n",
                $iter+1,$self->get_attribute('maxiter'),
                $netsTotal,$netsRoutedSuccess,$netsRoutedFailure,
                $netsTotal-($netsRoutedSuccess+$netsRoutedFailure),
                $net->name);
            
                #print $self->nl->pp;
            }
            
		} # foreach net

		#############################################################################
		# update historical cost after all nets have been routed in this iteration
		#############################################################################
		printf("update_historical_cost()\n");
		$self->rg->update_h_and_cost();
	
		#print $self->rg->all_resources_usage_pp();

        print "finished routing iteration";
        if ($self->rg->resource_total_overusage){
            print sprintf(" current overusage: %f\n",$self->rg->resource_total_overusage);
        } else {
            print "(no overusage)\n";
        }


		#############################################################################
		# iterate until a routing without congestion is found or the maximum 
		# iteration count is reached 
		#############################################################################
		
        # Sanity check. If a placement was determined to be routable (regardless of 
        #   congestion), the same placement can never be unroutable later on unless a 
        #   serious fault occured (e.g. routing architecture graph was broken etc.)
        if (($iter > 0) and $netlistUnroutable){
            print "X" x 80;
            print "X" x 80;
            print "FATAL ERROR: Netlist was routable (with congestion) before and is" .
            " now permanently unroutable!!\n";
            print "X" x 80;
            print "X" x 80;

        }
        
        $iter++;
        last ROUTING_ITERATION if $netlistUnroutable;
    } while ($self->resources_overused($self->rg) and ($iter < $self->get_attribute('maxiter')));
    }  ## ROUTING_ITERATION_LABEL
    
    my %res;
	if ($netlistUnroutable) {
        print "XXXX ROUTING FAILED: Couldn't find valid routing: graph disconnected!\n";
        return $ROUTER_FAILED_UNREACHABLE;
    } elsif ($self->resources_overused($self->rg)){
        print "XXXX ROUTING FAILED: Couldn't find valid routing: congestion!\n";
        $res{'ret'} = $ROUTER_FAILED_OVERUSAGE; 
        return $ROUTER_FAILED_OVERUSAGE;
    } else {
		print "ROUTING SUCCEDED: after $iter iterations\n";
		return $ROUTER_SUCCESS;
	}
}

sub resources_overused {
	my $self = shift;
    my $overused = 0;
	foreach my $resource ($self->rg->vertices){
		if ($self->rg->resource_overusage($resource) > 0) {
            my $overusage = $self->rg->resource_overusage($resource); 
			#print sprintf("====> resource %s is overused\n%s\n",$resource,$self->rg->resource_usage_pp($resource));
			print "\t" . $self->rg->resource_usage_pp($resource);
            $overused = 1;
		}
	}
	return $overused;
}


1;

__END__

###############################################################################
# Pathfinder pseudo-code
#
# crit(i,j)=1 for all nets i and sinks j;
#
# while (exist overused resources) {  // illegal routing
#
# 	foreach i (all nets) {
#		rip-up routing tree RT(i) and update affected p(n) values
#		RT(i) = NetSource(i)
#		
#		foreach j (sinks of net(i) in decreasing crit(i,j) order) {
#			PriorityQueue = RT(i) at PathCost(n) = crit(i,j)*delay(n)
#							for each node n in RT(i)
#			
#			while(sink(i,j) not found) {
#				remove lowest cost node, m, from PriorityQueue;
#				for (all fanout nodes n of node m) {
#					add n to priorityqueue at PathCost(n) = Cost(n) + PathCost(m);
#				}
#			}
#		
#			for (all nodes, n, in path from RT(i) to sink(i,j)) { // backtrace
#				Update p(n);
#				Add n to RT(i);
#			}
#		}
#	}
#	Update h(n) for all n
#	Perform timing analysis and update Crit(i,j) for all nets i and sinks j;
# } 
#
###############################################################################