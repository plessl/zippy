package Zippy::Architecture::RoutingGraph;

$VERSION = 0.01;

use strict;
use warnings;
use Carp;
use FileHandle;
#use Switch;
use Graph;
use Data::Dumper;
use Tools::Util;

use vars qw( @ISA );
@ISA = qw( Graph );

my $DEBUG = 0;
my $DEBUG_USAGE = 0;

my $GRAPHDEBUG = 1;

my $LOG2INV = 1/log(2);


our $COLS; # number of cells in a column
our $ROWS; # number of cells in a row
our $INPS; # number of inputs to horizontal (row) buses
our $OPS;  # number of outputs taken from horizontal (row) buses
our $HBUS_N; # number of horizontal north buses
our $HBUS_S; # number of horizontal south buses
our $VBUS_E; # number of vertical east buses

our $NODETYPE_PI = 1;  # primary input     prefix: p_i_
our $NODETYPE_PO = 2;  # primary output    prefix: p_o_
our $NODETYPE_C  = 3;  # cell              prefix: c_
our $NODETYPE_CI = 4;  # cell input        prefix: c_i_
our $NODETYPE_CO = 5;  # cell output       prefix: c_o_
our $NODETYPE_W  = 6;  # wire              prefix: w_
our $NODETYPE_B  = 7;  # bus               prefix: b_
our $NODETYPE_S  = 8;  # switch            prefix: s_
our $NODETYPE_M  = 9;  # multiplexer       prefix: m_

our $NODEUSAGE_IN  = 1;  
our $NODEUSAGE_OUT = 2;

sub new {
	my $proto = shift;
    my $class = ref($proto) || $proto;
    my %arg = @_;
                    	
	my $self = Graph::Directed->new();
	bless $self, $class;
    
    if (defined $arg{archfile}) {
        print "RoutingGraph: Using architecture description defined by $arg{archfile}\n";
		$self->setArchitecture($arg{archfile});
    } else {
        print "RoutingGraph: Using default device architecture\n";
        $self->setArchitecture("");
    }
            
	$self->create_RoutingGraph();		
    
    print "statistics:\n";
    print "routing graph has:\n";
    printf("  %d vertices\n", scalar($self->vertices));
    printf("  %d edges\n", scalar($self->edges));    
    print "=" x 70 . "\n";
	return $self;
}


sub setArchitecture {
    my $self = shift;
    my $archFile = shift;

    if ($archFile ne ""){
        my $fh = new FileHandle($archFile, "r");
        die "cannot read architecture definition file $archFile!" if (not defined $fh);

        my (%archConfig,$l);
        while ($l = $fh->getline){
            chomp($l);                # no newline
            $l =~ s/#.*//;            # no comments
            $l =~ s/^\s+//;           # no leading white-spaces
            $l =~ s/\s+$//;           # no trailing white-spaces
            next unless length $l;    # anything left
            my ($var,$value) = split(/\s*=\s*/, $l, 2);
            $archConfig{$var} = $value;
        }

        # works only for: use no strict 'refs' 
        #foreach my $key (keys %archConfig){
        #    $$key = $archConfig{$key};
        #}
        
        $COLS = $archConfig{COLS}; # number of cells in a column
        $ROWS = $archConfig{ROWS}; # number of cells in a row
        $INPS = $archConfig{INPS}; # number of inputs to horizontal (row) buses
        $OPS = $archConfig{OPS};  # number of outputs taken from horizontal (row) buses
        $HBUS_N = $archConfig{HBUS_N}; # number of horizontal north buses
        $HBUS_S = $archConfig{HBUS_S}; # number of horizontal south buses
        $VBUS_E = $archConfig{VBUS_E}; # number of vertical east buses
        
    } else {
    
        $COLS = 4; # number of cells in a column
        $ROWS = 4; # number of cells in a row
        $INPS = 2; # number of inputs to horizontal (row) buses
        $OPS = 2;  # number of outputs taken from horizontal (row) buses
        $HBUS_N = 2; # number of horizontal north buses
        $HBUS_S = 1; # number of horizontal south buses
        $VBUS_E = 2; # number of vertical east buses
    }

    my $s;
    $s .= "=" x 70 . "\n";
    $s .= sprintf ("Architecture definition: (%s)\n", 
        ($archFile eq '') ? 'default' : "from file $archFile");
    $s .= "=" x 70 . "\n";
    $s .= "ROWS=$ROWS COLS=$COLS\n";
    $s .= "INPS=$INPS OPS=$OPS\n";
    $s .= "HBUS_H=$HBUS_N HBUS_S=$HBUS_S VBUS_E=$VBUS_E\n";
    $s .= "=" x 70 . "\n";
    
    print $s;
}


##############################################################################
# create routing graph
##############################################################################

sub create_RoutingGraph {
	my $G = shift;

	# global interconnect
	#     - input buses
	#     - output buses
	#     - horizontal buses
	#
	# cell interconnect
	#     - connections to horizontal buses
	#     - local cell interconnect

	#################################################################################
	# global interconnect
	#################################################################################

	# add all primary inputs and input buses
	foreach my $inp (0..$INPS-1) {
		my $p_i_name = sprintf("p_i.%d",$inp);
		my $b_i_name = sprintf("b_i.%d",$inp);
	
		$G->add_vertex($p_i_name);
		$G->set_attribute('type',$p_i_name,$NODETYPE_PI);
		$G->add_vertex($b_i_name);
		$G->set_attribute('type',$b_i_name,$NODETYPE_B);
		$G->add_edge($p_i_name, $b_i_name);
	}	

	# add all primary outputs and output muxes
	foreach my $outp (0..$OPS-1) {
		my $p_o_name = sprintf("p_o.%d",$outp);
		my $w_o_name = sprintf("w_o.%d",$outp);
		my $m_o_name = sprintf("m_o.%d",$outp);
	
		$G->add_vertex($p_o_name);
		$G->set_attribute('type',$p_o_name,$NODETYPE_PO);
		$G->add_vertex($w_o_name);
		$G->set_attribute('type',$w_o_name,$NODETYPE_W);
		$G->add_vertex($m_o_name);
		$G->set_attribute('type',$m_o_name,$NODETYPE_M);
		$G->add_edge($m_o_name,$w_o_name);
		$G->add_edge($w_o_name,$p_o_name);
	}

	# add horizontal buses and switches that connect the horizontal buses to the 
	# input buses and the output muxes
	foreach my $r (0..$ROWS-1) {

		# horizontal north buses
		foreach my $hbus (0..$HBUS_N-1) {
			my $b_name = sprintf("b_hn.%d.%d",$r,$hbus);
			$G->add_vertex($b_name); # add b_hn (horizontal bus north)
			$G->set_attribute('type',$b_name,$NODETYPE_B);

			foreach my $inp (0..$INPS-1) {
				my $b_i_name = sprintf("b_i.%d",$inp);
				my $s_name = sprintf("s_%s-%s",$b_i_name,$b_name);
				$G->add_vertex($s_name); # add switch from inbus to b_hn
				$G->set_attribute('type',$s_name,$NODETYPE_S);
				$G->add_edge($b_i_name,$s_name); # connect inbus to switch
				$G->add_edge($s_name,$b_name); # connect switch to b_hn
			}
	
			foreach my $outp (0..$OPS-1){
				my $m_o_name = sprintf("m_o.%d",$outp);
				my $w_name = sprintf("w_%s-%s",$b_name,$m_o_name);
				$G->add_vertex($w_name);
				$G->set_attribute('type',$w_name,$NODETYPE_W);
				$G->add_edge($b_name,$w_name);
				$G->add_edge($w_name,$m_o_name);
			}
		}
  
		# horizontal south buses
		foreach my $hbus (0..$HBUS_S-1) {
			my $b_name = sprintf("b_hs.%d.%d",$r,$hbus);
			$G->add_vertex($b_name);
			$G->set_attribute('type',$b_name,$NODETYPE_B);
		}
	} # foreach $r


    ## add vertical buses and switches, that connect the vertical buses to the
    ## cells
    
    # vertical east buses
    foreach my $c (0..$COLS-1) {
        foreach my $ebus (0..$VBUS_E-1) {
            my $b_name = sprintf("b_ve.%d.%d",$c,$ebus);
            $G->add_vertex($b_name);
            $G->set_attribute('type',$b_name,$NODETYPE_B);
        }
    }


	#################################################################################
	# cell interconnect, direct to neighbors
	#################################################################################

	### create cells and all incoming connections
	foreach my $r (0..$ROWS-1){
		foreach my $c (0..$COLS-1){
	
			### create cell ####
			my $cellName = sprintf("c_%d_%d",$r,$c);
			$G->add_vertex($cellName);
			$G->set_attribute('type',$cellName,$NODETYPE_C);
			
            my $cellInputName = sprintf("c_i_%d_%d",$r,$c);
			$G->add_vertex($cellInputName);
			$G->set_attribute('type',$cellInputName,$NODETYPE_CI);
            
            my $cellOutputName = sprintf("c_o_%d_%d",$r,$c);
			$G->add_vertex($cellOutputName);
			$G->set_attribute('type',$cellOutputName,$NODETYPE_CO);
            
            # add feedthrough wire, but do not connect it per default
            my $cellFeedthroughName = sprintf("w_%s_%s",$cellInputName,$cellOutputName);
            $G->add_vertex($cellFeedthroughName);
            $G->set_attribute('type',$cellFeedthroughName,$NODETYPE_W);
            
            #print sprintf("added cell  %s\n",$c_name);
		
			### create channels and wires for all cells that are connected via direct local
			### interconnect. only look at the incoming connections, if done for every cell 
			### this makes sure that each connection is added exactly once.
			my (@neighbor_cols,@neighbor_rows);
		
			my ($nr,$nc);
			## NW neighbor
			$nr = ($r-1) % $ROWS; push @neighbor_rows,$nr;
			$nc = ($c-1) % $COLS; push @neighbor_cols,$nc;
			#print sprintf("cell($r,$c)  NW neighbor is cell(%d,%d)\n",$nr,$nc);
		
			# N neighbor
			$nr = ($r-1) % $ROWS; push @neighbor_rows,$nr; 
			$nc = ($c+0) % $COLS; push @neighbor_cols,$nc; 
			#print sprintf("cell($r,$c)  N neighbor is cell(%d,%d)\n",$nr,$nc);
		
			# NE neighbor
			$nr = ($r-1) % $ROWS; push @neighbor_rows, $nr;
			$nc = ($c+1) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  NE neighbor is cell(%d,%d)\n",$nr,$nc);
		
			# W neighbor
			$nr = ($r+0) % $ROWS; push @neighbor_rows, $nr;
			$nc = ($c-1) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  W neighbor is cell(%d,%d)\n",$nr,$nc);
		
			# S neighbor
			$nr = ($r+1) % $ROWS; push @neighbor_rows, $nr; 
			$nc = ($c+0) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  S neighbor is cell(%d,%d)\n",$nr,$nc);
				
                
            ######## TEST #### symmetrical routing architecture, every cell is
            ######## connected to _all_ neighbors with direct connections    

			# E neighbor
			$nr = ($r+0) % $ROWS; push @neighbor_rows, $nr; 
			$nc = ($c+1) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  E neighbor is cell(%d,%d)\n",$nr,$nc);

			# SE neighbor
			$nr = ($r+1) % $ROWS; push @neighbor_rows, $nr; 
			$nc = ($c+1) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  SE neighbor is cell(%d,%d)\n",$nr,$nc);

			# SW neighbor
			$nr = ($r+1) % $ROWS; push @neighbor_rows, $nr; 
			$nc = ($c-1) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  SW neighbor is cell(%d,%d)\n",$nr,$nc);

			# NW neighbor
			$nr = ($r-1) % $ROWS; push @neighbor_rows, $nr; 
			$nc = ($c-1) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  NW neighbor is cell(%d,%d)\n",$nr,$nc);


                
			for (my $i=0;$i<scalar(@neighbor_rows);$i++){
				my $neighbor_row = $neighbor_rows[$i];
				my $neighbor_col = $neighbor_cols[$i];
			
				#my $neighbor_name = sprintf('c_%d_%d',$neighbor_row,$neighbor_col);
                my $neighborOutputName = sprintf('c_o_%d_%d',$neighbor_row,$neighbor_col);
				my $w_name = sprintf('w_%s-%s',$neighborOutputName,$cellInputName);
				#print sprintf("added wire %s\n",$w_name);
				$G->add_vertex($w_name);
				$G->set_attribute('type',$w_name,$NODETYPE_W);
				$G->add_edge($neighborOutputName,$w_name); # connect neighbor to wire
				$G->add_edge($w_name,$cellInputName); # connect wire to current cell
			}
		} # foreach c
	} # foreach r


	#################################################################################
	# cell interconnect, from horizontal buses
	#################################################################################

	## input from horizontal buses
	foreach my $r (0..$ROWS-1){
		foreach my $c (0..$COLS-1){
			my $cellInputName = sprintf("c_i_%d_%d",$r,$c);
			foreach my $hbus (0..$HBUS_N-1){
				my $b_name = sprintf("b_hn.%d.%d",$r,$hbus);
				my $w_name = sprintf("w_%s-%s",$b_name,$cellInputName);
				$G->add_vertex($w_name);
				$G->set_attribute('type',$w_name,$NODETYPE_W);
				$G->add_edge($b_name,$w_name);
				$G->add_edge($w_name,$cellInputName);
			}
			foreach my $hbus (0..$HBUS_S-1){
				my $b_name = sprintf("b_hs.%d.%d",$r,$hbus);
				my $w_name = sprintf("w_%s-%s",$b_name,$cellInputName);
				$G->add_vertex($w_name);
				$G->set_attribute('type',$w_name,$NODETYPE_W);
				$G->add_edge($b_name,$w_name);
				$G->add_edge($w_name,$cellInputName);
			}
		}
	}

	## output to horizontal buses
	## ouput is always taken from the south output of the cell
	foreach my $r (0..$ROWS-1){
		foreach my $c (0..$COLS-1){
			# S neighbor
			my $southNeighborInputName = sprintf('c_i_%d_%d',($r+1) % $ROWS, ($c+0) % $COLS);
			my $cellOutputName = sprintf("c_o_%d_%d",$r,$c);
			my $southWireName = sprintf('w_%s-%s',$cellOutputName,$southNeighborInputName);
			
			# each cell can write to the horizontal north buses of the _south_ row
			# create and connect switches
			foreach my $hbusn (0..$HBUS_N-1){
				my $b_name = sprintf("b_hn.%d.%d",($r+1)%$ROWS,$hbusn);
				my $s_name = sprintf("s_%s-%s",$southWireName,$b_name);
				$G->add_vertex($s_name);
				$G->set_attribute('type',$s_name,$NODETYPE_S);
				$G->add_edge($southWireName,$s_name);
				$G->add_edge($s_name,$b_name);		
			}
			
			# each cell can write to the horizontal south buses of the _current_ row 
			# create and connect switches
			foreach my $hbuss (0..$HBUS_S-1){
				my $b_name = sprintf("b_hs.%d.%d",$r,$hbuss);
				my $s_name = sprintf("s_%s-%s",$southWireName,$b_name);
				$G->add_vertex($s_name);
				$G->set_attribute('type',$s_name,$NODETYPE_S);
				$G->add_edge($southWireName,$s_name);
				$G->add_edge($s_name,$b_name);		
			}
		}
	}

    
    #################################################################################
    # cell interconnect, to/from vertical buses
    #################################################################################

    ## output to vertical buses
    foreach my $r (0..$ROWS-1){
        foreach my $c (0..$COLS-1){
            # E neighbor
            my $eastNeighborInputName = sprintf('c_i_%d_%d',($r+0) % $ROWS, ($c+1) % $COLS);
            my $cellOutputName = sprintf("c_o_%d_%d",$r,$c);
            my $eastWireName = sprintf('w_%s-%s',$cellOutputName,$eastNeighborInputName);
            
            foreach my $vbuse (0..$VBUS_E-1){
                my $b_name = sprintf('b_ve.%d.%d',($c+0) % $COLS, $vbuse);
                my $s_name = sprintf("s_%s-%s",$eastWireName,$b_name);
                $G->add_vertex($s_name);
                $G->set_attribute('type',$s_name,$NODETYPE_S);
                $G->add_edge($eastWireName,$s_name);
                $G->add_edge($s_name,$b_name);		
            }
        }
    }
    
    ## input from vertical buses
    foreach my $r (0..$ROWS-1){
		foreach my $c (0..$COLS-1){
			my $cellInputName = sprintf("c_i_%d_%d",($r+0) % $ROWS,($c+0) % $COLS);

			foreach my $vbuse (0..$VBUS_E-1){
				my $b_name = sprintf("b_ve.%d.%d",($c-1) % $COLS, $vbuse);
				my $w_name = sprintf("w_%s-%s",$b_name,$cellInputName);
				$G->add_vertex($w_name);
				$G->set_attribute('type',$w_name,$NODETYPE_W);
				$G->add_edge($b_name,$w_name);
				$G->add_edge($w_name,$cellInputName);
			}
		}
	}


    
	return $G;
} #### create_RoutingGraph

sub feasibleRoute {
    my $self = shift;
    my $from = shift;
    my $to = shift;
    
    my $tc;
    my ($fromPort,$toPort);
    
    if ($self->has_attribute('reachability')) {
        $tc = $self->get_attribute('reachability');
    } else {
        $tc = $self->TransitiveClosure_Floyd_Warshall;
        $self->set_attribute('reachability',$tc);
    }
    #print Dumper($tc);
    
    #print sprintf ("from=%s type=%d to=%s type=%d\n",
    #    $from,$self->get_attribute('type',$from),
    #    $to,$self->get_attribute('type',$to)
    #);
     
    if ($self->get_attribute('type',$from) == $NODETYPE_C) {
        $fromPort = cellNameToOutputName($from);
    } else {
        $fromPort = $from;
    }
    
    if ($self->get_attribute('type',$to) == $NODETYPE_C) {
        $toPort = cellNameToInputName($to);
    } else {
        $toPort = $to;
    }
    
    if ($self->has_vertex($fromPort) and $self->has_vertex($toPort)){
        return $tc->has_edge($fromPort,$toPort);
    }
    carp "routing graph has no node named $fromPort\n (from node)" unless $self->has_vertex($fromPort);
    carp "routing graph has no node named $toPort\n (to node)"  unless $self->has_vertex($toPort);
}

my $ORIGIN_X = 30;
my $ORIGIN_Y = 30;

my $SPC_IOBUS_X = 10;
my $SZ_IOBUS_X = 20;
my $SZ_IOPORT_X = 20;
my $SZ_IOPORT_Y = 55;

my $OFF_ARR_X = 100;
my $OFF_ARR_Y = 150;
my $SZ_CELL_X = 100;
my $SZ_CELL_Y = 100;
my $SPC_CELL_X = 80;
my $SPC_CELL_Y = 80;
my $SPC_B2C = 12;
my $SPC_B2B = 10;
my $SPC_W2W = 5;

sub coordCell {
    my $r = shift;
    my $c = shift;

    my %cor;

    $cor{sX} = $OFF_ARR_X + $c * ($SZ_CELL_X + $SPC_CELL_X);
    $cor{sY} = $OFF_ARR_Y + $r * ($SZ_CELL_Y + $SPC_CELL_Y);
    $cor{eX} = $cor{sX} + $SZ_CELL_X;
    $cor{eY} = $cor{sY} + $SZ_CELL_Y;
    
    $cor{cX} = $cor{sX} + $SZ_CELL_X/2;
    $cor{cY} = $cor{sY} + $SZ_CELL_Y/2;

    $cor{wX} = $SZ_CELL_X;
    $cor{wY} = $SZ_CELL_Y;

    $cor{midNX} = $cor{sX} + $SZ_CELL_X/2;
    $cor{midNY} = $cor{sY};

    $cor{midEX} = $cor{eX};
    $cor{midEY} = $cor{sY} + $SZ_CELL_Y/2;
    
    $cor{midSX} = $cor{sX} + $SZ_CELL_X/2;
    $cor{midSY} = $cor{eY};
    
    $cor{midWX} = $cor{sX};
    $cor{midWY} = $cor{sY} + $SZ_CELL_Y/2;

    return \%cor;

}

sub bus_SVG {
    my $sX = shift;
    my $sY = shift;
    my $eX = shift;
    my $eY = shift;
    my $type = shift;  # h|v for horizontal/vertical bus
    my $class = shift;

    my $res;
    my $capWidth = 2;
 
    if ($type eq "h") {
        $res .= sprintf("<path d=\"M %d %d l %d 0\" class=\"%s\" style=\"stroke-width=2px;\" stroke=\"black\" />\n",
        $sX,$sY,$eX-$sX,$class);
    } elsif ($type eq "v") {
        $res .= sprintf("<path d=\"M %d %d l 0 %d\" class=\"%s\" style=\"stroke-width=2px;\" stroke=\"black\" />\n",
        $sX,$sY,$eY-$sY,$class);
    } else {
        die "invalid bus type";
    }
    return $res;
}

sub wire_SVG {
    my $sX = shift;
    my $sY = shift;
    my $eX = shift;
    my $eY = shift;
    my $type = shift;  # h|v for horizontal/vertical bus
    my $id = shift;

    my $res;

    if ($type eq "h") {
        $res .= sprintf("<path d=\"M %d %d l %d 0\" id=\"%s\" stroke=\"black\" />\n",
        $sX,$sY,$eX-$sX,$id);
    } elsif ($type eq "v") {
        $res .= sprintf("<path d=\"M %d %d l 0 %d\" id=\"%s\" stroke=\"black\" />\n",
        $sX,$sY,$eY-$sY,$id);
    } else {
        die "invalid wire type";
    }
    return $res;
}


sub port_SVG {
    my $x = shift;
    my $y = shift;
    my $label = shift;
    my $align = shift;  # "tip", "base" --> align to tip vs. align to middle of base
    my $class = shift;
 
    #<path d="M 50 50 l 20 0 l 0 40 l -10 5 l -10 -5 l 0 -40" fill="#EEEEEE" stroke="black" />
    #<text x="50" y="50" style="font-size:16px; font-family:Verdana,sans-serif;" transform="rotate(-90,50,50) translate(-35,17)">IP0</text>

    my ($sX,$sY,$res);
    if ($align eq "tip"){
        $sX = $x-10;
        $sY = $y-45;
    } elsif ($align eq "base"){
        $sX = $x-10;
        $sY = $y;
    } elsif ($align eq "tl"){ # top left corner
        $sX = $x;
        $sY = $y;
    } else {
        die "invalid value for alignment parameter!";
    }
    
    $res .= sprintf("<path d=\"M %d %d l 20 0 l 0 50 l -10 5 l -10 -5 l 0 -50\" fill=\"#EEEEEE\" stroke=\"black\" class=\"%s\" />\n",
    $sX,$sY,$class);
    $res .= sprintf("<text x=\"%d\" y=\"%d\" class=\"%s\" style=\"font-size:16px; font-family:Verdana,sans-serif;\" transform=\"rotate(-90,%d,%d) translate(-45,17)\">%s</text>\n",
    $sX,$sY,$class,$sX,$sY,$label);
    return $res;
}

sub progSwitch_SVG {
    my $x = shift;
    my $y = shift;
    my $id = shift;
    my $res;
    $res = sprintf("<path d=\"M %d %d m 0 -7 l 3.5 3.5 m 3.5 3.5 l -2 -5 l -3 3 l 5 2 m -1 -2.5 l 2 -2\" fill=\"none\" style=\"stroke-width=1px;\" stroke=\"black\" id=\"%s\" />\n",
    $x,$y,$id); 
    return $res;
}

sub create_RoutingGraph_SVG {
	my $res;
        
    $res .= svg_header();
    
	#################################################################################
	# global interconnect
	#################################################################################

    my $corLast = coordCell($ROWS-1,0);
    
	# add all primary inputs and input buses
	foreach my $inp (0..$INPS-1) {
		my $p_i_name = sprintf("p_i.%d",$inp);
		my $b_i_name = sprintf("b_i.%d",$inp);
	
        my $inpLabel = sprintf("INP%d",$inp);
        $res .= port_SVG($ORIGIN_X+ $inp * ($SZ_IOPORT_X + $SPC_IOBUS_X),$ORIGIN_Y,$inpLabel,"tl",$p_i_name);
        
        $res .= bus_SVG($ORIGIN_X+$SZ_IOPORT_X/2  + $inp * ($SZ_IOPORT_X + $SPC_IOBUS_X),
                        $ORIGIN_Y+$SZ_IOPORT_Y, 
                        $ORIGIN_X+$SZ_IOPORT_X/2  + $inp * ($SZ_IOPORT_X + $SPC_IOBUS_X),
                        $corLast->{eY},
                        "v",
                        ,$b_i_name);
        
		#$G->add_vertex($p_i_name);
		#$G->set_attribute('type',$p_i_name,$NODETYPE_PI);
		#$G->add_vertex($b_i_name);
		#$G->set_attribute('type',$b_i_name,$NODETYPE_B);
		#$G->add_edge($p_i_name, $b_i_name);
	}	

	# add all primary outputs and output muxes
	
    ## FIXME FIXME finish up this work ASAP.
    
    foreach my $outp (0..$OPS-1) {
		my $p_o_name = sprintf("p_o.%d",$outp);
		my $w_o_name = sprintf("w_o.%d",$outp);
		my $m_o_name = sprintf("m_o.%d",$outp);

        #my $x = $corLast->{ey} + 
        #$res .= port_SVG(

		#$G->add_vertex($p_o_name);
		#$G->set_attribute('type',$p_o_name,$NODETYPE_PO);
		#$G->add_vertex($w_o_name);
		#$G->set_attribute('type',$w_o_name,$NODETYPE_W);
		#$G->add_vertex($m_o_name);
		#$G->set_attribute('type',$m_o_name,$NODETYPE_M);
		#$G->add_edge($m_o_name,$w_o_name);
		#$G->add_edge($w_o_name,$p_o_name);
	}

	# add horizontal buses and switches that connect the horizontal buses to the 
	# input buses and the output muxes

	foreach my $r (0..$ROWS-1) {

        #my $corFirst = coordCell($r,0);
        my $corLast  = coordCell($r,$COLS-1);
        
		# horizontal north buses
		foreach my $hbus (0..$HBUS_N-1) {
			my $b_name = sprintf("b_hn.%d.%d",$r,$hbus);
    
            my $sX = $ORIGIN_X;
            my $eX = $corLast->{eX} + 80;
            my $sY = $corLast->{sY} - $SPC_B2C - $hbus*($SPC_B2B);
            $res .= bus_SVG($sX,$sY,$eX,$sY,"h",$b_name);
            #$res .= sprintf("b_name=%s, sX=%d sY=%d eX=%d\n",$b_name,$sX,$sY,$eX);
			#$G->add_vertex($b_name); # add b_hn (horizontal bus north)
			#$G->set_attribute('type',$b_name,$NODETYPE_B);

			foreach my $inp (0..$INPS-1) {
				my $b_i_name = sprintf("b_i.%d",$inp);
				my $s_name = sprintf("s_%s-%s",$b_i_name,$b_name);
                
                my $x = $ORIGIN_X+$SZ_IOPORT_X/2  + $inp * ($SZ_IOPORT_X + $SPC_IOBUS_X);
                my $y = $corLast->{sY} - $SPC_B2C - $hbus*($SPC_B2B);

                $res .= progSwitch_SVG($x,$y,$s_name);
                
                
                #$G->add_vertex($s_name); # add switch from inbus to b_hn
				#$G->set_attribute('type',$s_name,$NODETYPE_S);
				#$G->add_edge($b_i_name,$s_name); # connect inbus to switch
				#$G->add_edge($s_name,$b_name); # connect switch to b_hn
			}
	
			foreach my $outp (0..$OPS-1){
				my $m_o_name = sprintf("m_o.%d",$outp);
				my $w_name = sprintf("w_%s-%s",$b_name,$m_o_name);
                
                #$res .= wire_SVG
                
				#$G->add_vertex($w_name);
				#$G->set_attribute('type',$w_name,$NODETYPE_W);
				#$G->add_edge($b_name,$w_name);
				#$G->add_edge($w_name,$m_o_name);
			}
		}
  
		# horizontal south buses
		foreach my $hbus (0..$HBUS_S-1) {
			my $b_name = sprintf("b_hs.%d.%d",$r,$hbus);
			#$G->add_vertex($b_name);
			#$G->set_attribute('type',$b_name,$NODETYPE_B);
            my $corLast  = coordCell($r,$COLS-1);
            
            my $sX = $ORIGIN_X;
            my $eX = $corLast->{eX} + 80;
            my $sY = $corLast->{eY} + $SPC_B2C + $hbus*($SPC_B2B);
            $res .= bus_SVG($sX,$sY,$eX,$sY,"h",$b_name);

        
        }
	} # foreach $r

	#################################################################################
	# cell interconnect, direct to neighbors
	#################################################################################

	### create cells and all incoming connections
	foreach my $r (0..$ROWS-1){
		foreach my $c (0..$COLS-1){
	
			### create cell ####
			my $cellName = sprintf("c_%d_%d",$r,$c);
			#$G->add_vertex($cellName);
			#$G->set_attribute('type',$cellName,$NODETYPE_C);
			
            my $co = coordCell($r,$c);
            $res .= sprintf('<!-- cell %s -->',$cellName);
            $res .= sprintf("<rect x=\"%d\" y=\"%d\" width=\"%d\" height=\"%d\" fill=\"#FFFFCC\" stroke=\"black\" />\n",
                $co->{sX}, $co->{sY},$co->{wX},$co->{wY});
            $res .= sprintf("<circle cx=\"%d\" cy=\"%d\" r=\"%d\" fill=\"#AABBCC\" stroke=\"black\" />\n",
                $co->{cX}, $co->{cY},$co->{wY}/2-5);
            
            
            my $cellInputName = sprintf("c_i_%d_%d",$r,$c);
			#$G->add_vertex($cellInputName);
			#$G->set_attribute('type',$cellInputName,$NODETYPE_CI);
            
            my $cellOutputName = sprintf("c_o_%d_%d",$r,$c);
			#$G->add_vertex($cellOutputName);
			#$G->set_attribute('type',$cellOutputName,$NODETYPE_CO);
            
            # add feedthrough wire, but do not connect it per default
            my $cellFeedthroughName = sprintf("w_%s_%s",$cellInputName,$cellOutputName);
            #$G->add_vertex($cellFeedthroughName);
            #$G->set_attribute('type',$cellFeedthroughName,$NODETYPE_W);
            
            #print sprintf("added cell  %s\n",$c_name);
		
			### create channels and wires for all cells that are connected via direct local
			### interconnect. only look at the incoming connections, if done for every cell 
			### this makes sure that each connection is added exactly once.
			my (@neighbor_cols,@neighbor_rows);
		
			my ($nr,$nc);
			## NW neighbor
			$nr = ($r-1) % $ROWS; push @neighbor_rows,$nr;
			$nc = ($c-1) % $COLS; push @neighbor_cols,$nc;
			#print sprintf("cell($r,$c)  NW neighbor is cell(%d,%d)\n",$nr,$nc);
		
			# N neighbor
			$nr = ($r-1) % $ROWS; push @neighbor_rows,$nr; 
			$nc = ($c+0) % $COLS; push @neighbor_cols,$nc; 
			#print sprintf("cell($r,$c)  N neighbor is cell(%d,%d)\n",$nr,$nc);
		
			# NE neighbor
			$nr = ($r-1) % $ROWS; push @neighbor_rows, $nr;
			$nc = ($c+1) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  NE neighbor is cell(%d,%d)\n",$nr,$nc);
		
			# W neighbor
			$nr = ($r+0) % $ROWS; push @neighbor_rows, $nr;
			$nc = ($c-1) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  W neighbor is cell(%d,%d)\n",$nr,$nc);
		
			# S neighbor
			$nr = ($r+1) % $ROWS; push @neighbor_rows, $nr; 
			$nc = ($c+0) % $COLS; push @neighbor_cols, $nc;
			#print sprintf("cell($r,$c)  S neighbor is cell(%d,%d)\n",$nr,$nc);
				
			for (my $i=0;$i<scalar(@neighbor_rows);$i++){
				my $neighbor_row = $neighbor_rows[$i];
				my $neighbor_col = $neighbor_cols[$i];
			
				#my $neighbor_name = sprintf('c_%d_%d',$neighbor_row,$neighbor_col);
                my $neighborOutputName = sprintf('c_o_%d_%d',$neighbor_row,$neighbor_col);
				my $w_name = sprintf('w_%s-%s',$neighborOutputName,$cellInputName);
				#print sprintf("added wire %s\n",$w_name);
				#$G->add_vertex($w_name);
				#$G->set_attribute('type',$w_name,$NODETYPE_W);
				#$G->add_edge($neighborOutputName,$w_name); # connect neighbor to wire
				#$G->add_edge($w_name,$cellInputName); # connect wire to current cell
			}
		} # foreach c
	} # foreach r


	#################################################################################
	# cell interconnect, from horizontal buses
	#################################################################################

	## input from horizontal buses
	foreach my $r (0..$ROWS-1){
		foreach my $c (0..$COLS-1){
			my $cellInputName = sprintf("c_i_%d_%d",$r,$c);
			foreach my $hbus (0..$HBUS_N-1){
				my $b_name = sprintf("b_hn.%d.%d",$r,$hbus);
				my $w_name = sprintf("w_%s-%s",$b_name,$cellInputName);
				#$G->add_vertex($w_name);
				#$G->set_attribute('type',$w_name,$NODETYPE_W);
				#$G->add_edge($b_name,$w_name);
				#$G->add_edge($w_name,$cellInputName);
			}
			foreach my $hbus (0..$HBUS_S-1){
				my $b_name = sprintf("b_hs.%d.%d",$r,$hbus);
				my $w_name = sprintf("w_%s-%s",$b_name,$cellInputName);
				#$G->add_vertex($w_name);
				#$G->set_attribute('type',$w_name,$NODETYPE_W);
				#$G->add_edge($b_name,$w_name);
				#$G->add_edge($w_name,$cellInputName);
			}
		}
	}

	### FIXME: Re-check this code in a quite minute. 
	
	## output to horizontal buses
	## ouput is always taken from the south output of the cell
	foreach my $r (0..$ROWS-1){
		foreach my $c (0..$COLS-1){
			# S neighbor
			my $southNeighborInputName = sprintf('c_i_%d_%d',($r+1) % $ROWS, ($c+0) % $COLS);
			my $cellOutputName = sprintf("c_o_%d_%d",$r,$c);
			my $southWireName = sprintf('w_%s-%s',$cellOutputName,$southNeighborInputName);
			
			# each cell can write to the horizontal north buses of the _south_ row
			# create and connect switches
			foreach my $hbusn (0..$HBUS_N-1){
				my $b_name = sprintf("b_hn.%d.%d",($r+1)%$ROWS,$hbusn);
				my $s_name = sprintf("s_%s-%s",$southWireName,$b_name);
				#$G->add_vertex($s_name);
				#$G->set_attribute('type',$s_name,$NODETYPE_S);
				#$G->add_edge($southWireName,$s_name);
				#$G->add_edge($s_name,$b_name);		
			}
			
			# each cell can write to the horizontal south buses of the _current_ row 
			# create and connect switches
			foreach my $hbuss (0..$HBUS_S-1){
				my $b_name = sprintf("b_hs.%d.%d",$r,$hbuss);
				my $s_name = sprintf("s_%s-%s",$southWireName,$b_name);
				#$G->add_vertex($s_name);
				#$G->set_attribute('type',$s_name,$NODETYPE_S);
				#$G->add_edge($southWireName,$s_name);
				#$G->add_edge($s_name,$b_name);		
			}
		}
	}

    $res .= svg_footer();
	return $res;
} #### create_RoutingGraph_SVG


sub svg_header {
my $res = <<'EOF';
<?xml version="1.0" encoding="ISO-8859-1" standalone="no" ?>
<?xml-stylesheet type="text/css" href="style.css" ?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
  "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg width="1000" height="1000" xmlns="http://www.w3.org/2000/svg">
  <title>My very nice title</title>
  <desc>My wonderful decription</desc>

  <defs>
  <style type="text/css">
  <![CDATA[
  text {font-familiy:sans-serif}
  polyline {fill:none; stroke:black; stroke-width:1px;}
  line {fill:none; stroke:black; stroke-width:1px;}
  ]]>
  </style>

   <marker id="tri"
       viewBox="0 0 10 10" refX="0" refY="5"
        markerUnits="strokeWidth" markerWidth="8" markerHeight="8"
	 orient="auto">
	 <path d="M 0 0 L 10 5 L 0 10 z" />
    </marker>

   <marker id="tri_red"
       viewBox="0 0 10 10" refX="0" refY="5"
        markerUnits="strokeWidth" markerWidth="8" markerHeight="8"
	 orient="auto">
	 <path d="M 0 0 L 10 5 L 0 10 z" fill="red" />
    </marker>
  </defs>
EOF
return $res;

}

sub svg_footer {
my $res = <<'EOF';
</svg>
EOF
  return $res;
}


#pragma mark HELPERS

################################################################################
# dump the routing graph in the 'dot' file format.
#   the resulting 'dot' description can be visualized with the popular Graphviz
#   graph visualization software
################################################################################
sub dump_dot {
	my $self = shift;
	
	my ($node,@edges,$i,$shape);
	my $res .= "digraph routinggraph {\n";
	
	foreach $node ($self->vertices){
	
		my $attr = $self->get_attribute('type',$node);
		if ($attr == $NODETYPE_PI){
			$shape = 'shape=house';
		} elsif ($attr == $NODETYPE_PO) { 
			$shape = 'shape=invhouse';
		} elsif ($attr == $NODETYPE_C) { 
			$shape = 'shape=box';
		} elsif (($attr == $NODETYPE_CI) or ($attr == $NODETYPE_CO)) {
            $shape = 'shape=circle';
        } elsif ($attr == $NODETYPE_W) { 
			$shape = 'shape=ellipse';
		} elsif ($attr == $NODETYPE_B) { 
			$shape = 'shape=egg';
		} elsif ($attr == $NODETYPE_S) { 
			$shape = 'shape=diamond';
		} elsif ($attr == $NODETYPE_M) { 
			$shape = 'shape=invtrapezium';
		} else {
			$shape = 'shape=box';
			print STDERR "problem: no type defined for node $node!\n";
		}
		$res .= sprintf("  %s [%s,label=\"%s\"];\n",_dotquote($node),$shape,$node);
	}
	
	@edges = $self->edges();
	for($i=0;$i<scalar(@edges);$i+=2){
		$res .= sprintf("  %s -> %s;\n",_dotquote($edges[$i]),_dotquote($edges[$i+1]));
	}

	$res .= "}\n";
	return $res;
}

#pragma mark RESOURCE_MANAGEMENT

# resource management
#
# resource_usage_init($resource);
# resource_usage_add($resource, $net, $NODEUSAGE_IN);
# resource_usage_remove($resource, $net, $NODEUSAGE_IN);
# resource_usage_get($resource);
# resource_usage_count($resource);
# resource_usage_overused($resource);

# resource has attribute usage
#  usage is a hash of hashes  usage{nodetype}{net}
#     nodetype is one of {NODEUSAGE_IN, NODEUSAGE_OUT}
#     net is the name that uses the node

sub resource_usage_init {
	my $self = shift;
	my $resource = shift;
	
	my %users_init;
	$users_init{$NODEUSAGE_IN} = {};
	$users_init{$NODEUSAGE_OUT} = {};
	$self->set_attribute('usage',$resource,\%users_init);
}

#### FIXME: think about resource add and remove. How can a single net use the
# same resource multiple times?
sub resource_usage_add {
	my $self = shift;
	my $resource = shift;
	my $net = shift;
	my $usagetype = shift;
	
	carp "invalid usagetype!\n" unless (($usagetype == $NODEUSAGE_IN) or 
										($usagetype == $NODEUSAGE_OUT));
	my $users = $self->get_attribute('usage',$resource);
	
	if (! defined $users->{$usagetype}->{$net}) {
		$users->{$usagetype}->{$net} = 1;
	} else {
		#printf ("XXXX resource $resource was already used by net $net!");
        $users->{$usagetype}->{$net} = ($users->{$usagetype}->{$net})+1;
	}
	$self->set_attribute('usage',$resource,$users);
	#print Dumper($users);
	return $users;
}

sub resource_usage_remove {
	my $self = shift;
	my $resource = shift;
	my $net = shift;
	my $usagetype = shift;
	
	carp "invalid usagetype!\n" unless (($usagetype == $NODEUSAGE_IN) or 
										($usagetype == $NODEUSAGE_OUT));

	my $users = $self->get_attribute('usage',$resource);
	
	if (! defined $users->{$usagetype}->{$net}) {
		carp sprintf("tried to remove net \"%s\" that was not registered as a user of resource %s\n",$net,$resource);
	}
    
    if ($users->{$usagetype}->{$net} == 1){
        delete $users->{$usagetype}->{$net};
    } else {
		#carp sprintf("resource %s was added several times for same net %s",$resource,$net);
		$users->{$usagetype}->{$net} = $users->{$usagetype}->{$net} -1;
	}
	$self->set_attribute('usage',$resource,$users);
	#print Dumper($users);
	return $users;
}

sub resource_usage_get {
	my $self = shift;
	my $resource = shift;
	my $usagetype = shift;
	
	my $usage = $self->get_attribute('usage',$resource);
	return $usage->{$usagetype};
}

sub resource_usage_count {
	my $self = shift;
	my $resource = shift;
	my $usagetype = shift;
	
	my $usage = $self->get_attribute('usage',$resource);
	
	return  scalar ( keys %{$usage->{$usagetype}} ) || 0;
}


# compute the overusage of resource
#   no usage              -->  -1
#   no overusage          -->   0
#   used but no overusage -->   1
#   overusage             -->  >1  (larger number means increasing overusage)
#
# FIXME: determining whether a resource is used could be coded more elegant
sub resource_overusage {
	my $self = shift;
	my $resource = shift;
	
	my $type = $self->get_attribute('type',$resource);
	my $use_in = $self->resource_usage_count($resource,$NODEUSAGE_IN);
	my $use_out = $self->resource_usage_count($resource,$NODEUSAGE_OUT);
	
    my $usage = 0;
    
    ##### FIXME ###################################################
    # FIXME find a more elaborate way of dealing with cells
    # at the moment the code assumes, that placement will use each cell only 
    # once, and that a cell is corretly used in the netlist, ie. the number of 
    # in/out ports available to a cell is not violated.

    if (($use_in == 0) and ($use_out == 0)) {
        $usage = -1;
    } elsif (($type == $NODETYPE_CI) or ($type == $NODETYPE_CO) or
             ($type == $NODETYPE_C)) {
        # cell              prefix: c_
        $usage = 0;
	} elsif ($type == $NODETYPE_W) {
	    # wire              prefix: w_
        $usage = Tools::Util::limit_low($use_in-1,0) + 
        Tools::Util::limit_low($use_out-1,0);
	} elsif ($type == $NODETYPE_B) {
		# bus               prefix: b_
		$usage = Tools::Util::limit_low($use_in-1,0) + 
        Tools::Util::limit_low($use_out-1,0);
	} elsif ($type == $NODETYPE_S) {
		# switch            prefix: s_
		$usage = Tools::Util::limit_low($use_in-1,0) + 
        Tools::Util::limit_low($use_out-1,0);
	} elsif ($type == $NODETYPE_M) {
		# multiplexer       prefix: m_
		$usage = Tools::Util::limit_low($use_in-1,0) + 
        Tools::Util::limit_low($use_out-1,0);
	} elsif ($type == $NODETYPE_PI) {
		# primary input     prefix: p_i_
		$usage = $use_in + Tools::Util::limit_low($use_out-1,0);
	} elsif ($type == $NODETYPE_PO) {
		# primary output    prefix: p_o_
		$usage = $use_out + Tools::Util::limit_low($use_in-1,0);
    } else {
		my $warn = sprintf("Node:%s has unknown nodetype:%s, cannot determine" .
           "whether this node is overused!\nAssuming _no_ overusage", $resource,$type);
		carp $warn;
	}
    return $usage;
}

sub resource_total_overusage {
    my $self = shift;
    my $noOverused = 0;
    my $totalOverusage = 0;
    foreach my $rsc ($self->vertices){
        my $u = $self->resource_overusage($rsc);
        if ($u > 1) {
            $noOverused++;
            $totalOverusage += $u;
        }
    }
    return $totalOverusage;
}

sub resource_usage_pp {
    my $self = shift;
    my $r = shift; # resource

    my (@u_i,@u_o);

    my $users_in  = $self->resource_usage_get($r,$NODEUSAGE_IN);
    my $users_out = $self->resource_usage_get($r,$NODEUSAGE_OUT);

    my $res.= sprintf("rsrc %s ",$r);
    $res .= sprintf("COST=%.1f pn=%.1f hn=%.1f bn=%.1f ",
        $self->resource_cost($r),
        $self->resource_cost_p($r),
        $self->resource_cost_h($r),
        $self->resource_cost_b($r)
    );
    if ($self->resource_overusage($r) > 1) {
        $res .= sprintf("OVERUSAGE %.1f",$self->resource_overusage($r));
    }
    $res .= "[" . join(",",keys %{$users_in}) . "]" . "\n";
	return $res; 
}

#############################################################################
# displays usage information about all _overused_ resources
#############################################################################
sub all_resources_overused_pp {
	my $self = shift;
   my $res;
    
    my @r = grep {($self->resource_overusage($_) > 1)} $self->vertices;
    $res = join("\n", map ($self->resource_usage_pp($_),@r) );

	return $res;
}

#############################################################################
# displays usage information about all _used_ resources
#############################################################################
sub all_resources_usage_pp {
	my $self = shift;
	my $res = "resource usage:\n" ."=" x 79 . "\n";

	foreach my $r ($self->vertices){
        my $users_in  = $self->resource_usage_get($r,$NODEUSAGE_IN);
        my $users_out = $self->resource_usage_get($r,$NODEUSAGE_OUT);
        if (($users_in > 0) or ($users_out > 0)){
            $res .= $self->resource_usage_pp($r);
        }
	}
    return $res;
}


sub route_usage_add_net {
	my $self = shift;
	my $net = shift;   
	
	# net has the routing tree stored in attribute 'rt'
	my $rt = $net->get_attribute('rt');
	
    if (not defined $rt) {
        die sprintf("net %s has no routing tree defined!",$net->name);
    }
    # print sprintf("routing tree of net %s is %s\n",$net->name,$rt);
	
	# create depth-first-search iterator for routing tree of net
	my $trav = Graph::DFS->new($rt);
	
	print sprintf("## adding net %s to resource usage tracker\n",$net->name) if $DEBUG_USAGE; 
	foreach my $r ($trav->preorder) {
				
		if (scalar $rt->predecessors($r) == 0){
			# this is the root node
			print sprintf("##    adding _root_ node %s resource usage tracker\n",$r) if $DEBUG_USAGE;
			$self->resource_usage_add($r,$net->name,$NODEUSAGE_OUT);
		
		} elsif (scalar $rt->successors($r) == 0){
			# this is a leaf node
			print sprintf("##    adding _leaf_ node %s resource usage tracker\n",$r) if $DEBUG_USAGE;
			$self->resource_usage_add($r,$net->name,$NODEUSAGE_IN);

		} else {
			# this is an inner node
			print sprintf("##    adding _inner_ node %s resource usage tracker\n",$r) if $DEBUG_USAGE;
			$self->resource_usage_add($r,$net->name,$NODEUSAGE_IN);
			$self->resource_usage_add($r,$net->name,$NODEUSAGE_OUT);
		
		}
	}
	
}

sub route_net_is_routed {
	my $self = shift;
	my $net = shift;
    #print sprintf("route_net_is_routed: net = %s   name= %s\n",$net,$net->name);
    my $rt = $net->get_attribute('rt');
	if (defined $rt) {
		#print sprintf("route_net_is_routed: net %s is routed\n",$net->name);
        return 1;
	} else {
		#print sprintf("route_net_is_routed: net %s is __not__ routed\n",$net->name);
		return 0;
	}
}

### must be called when ripping of this net, i.e., before the rt attribute of this 
#   net is overwritten in a new routing iteration
sub route_usage_remove_net {
	my $self = shift;
	my $net = shift;   
	
	# net has the routing tree stored in attribute 'rt'
	my $rt = $net->get_attribute('rt');
	
    if (not defined $rt){
        printf sprintf("XXXXX route_usage_remove_net: no rt for net %s!\n",$net->name);
    }
    print sprintf("routing tree of net %s is %s\n",$net->name,$rt) if $DEBUG_USAGE;
	
	# create depth-firest-search iterator for routing tree of net
	my $trav = Graph::DFS->new($rt);
	
	print sprintf("## removing net %s to resource usage tracker\n",$net->name) if $DEBUG_USAGE; 
	foreach my $r ($trav->preorder) {
				
		if (scalar $rt->predecessors($r) == 0){
			# this is the root node
			print sprintf("##    removing _root_ node %s resource usage tracker\n",$r) if $DEBUG_USAGE;
			$self->resource_usage_remove($r,$net->name,$NODEUSAGE_OUT);
		
		} elsif (scalar $rt->successors($r) == 0){
			# this is a leaf node
			print sprintf("##    removing _leaf_ node %s resource usage tracker\n",$r) if $DEBUG_USAGE;
			$self->resource_usage_remove($r,$net->name,$NODEUSAGE_IN);

		} else {
			# this is an inner node
			print sprintf("##    removing _inner_ node %s resource usage tracker\n",$r) if $DEBUG_USAGE;
			$self->resource_usage_remove($r,$net->name,$NODEUSAGE_IN);
			$self->resource_usage_remove($r,$net->name,$NODEUSAGE_OUT);
		}
	}
}


sub update_p_and_cost {
	my $self = shift;
	my $net = shift;
	my ($old_pn,$pn);

	# net has the routing tree stored in attribute 'rt'
	my $rt = $net->get_attribute('rt');
	#print sprintf("routing tree of net %s is %s\n",$net->name,$rt);
	# create depth-firest-search iterator for routing tree of net
	my $trav = Graph::DFS->new($rt);
	
	foreach my $r ($trav->preorder) {
        $old_pn = $self->resource_cost_p($r);
        $pn = $self->resource_overusage($r);
        
        # -1 : unused resource
        #  0 : used resource but not overused
        # >0 : overused resource
        $pn = $pn + 1;
        if ($pn > 1) {
            #$pn = log($pn-1)*$LOG2INV + 1;
            $pn = log($pn-1)*0.5 + 1;
        }
        $self->resource_cost_p($r,$pn);   # update cost
			
        # attempt to fix the excessive recalculation of costs
        my @inEdges = $self->in_edges($r);
        for(my $i=0;$i<scalar(@inEdges);$i+=2) {
            my ($from,$to) = ($inEdges[$i],$inEdges[$i+1]);
            $self->set_attribute('weight',$from,$to,$self->resource_cost($to));
        }
        
        if ($DEBUG){
            my $str;
            if ($old_pn != $pn){
                $str = sprintf ("CHANGED old_pn: %d  --> new_pn: %d",$old_pn,$pn);
            }
            print sprintf("## updating p(n) for net:%s resource:%s %s\n",$net->name,$r,$str); 
        }
	}	
}



## PROPOSAL: factor out functionality of updating one node into a new function, 
##   that can be used for update_h_and_cost and update_p_and_cost

sub update_h_and_cost {
	my $self = shift;
    
    foreach my $res ($self->vertices){
		if ($self->resource_overusage($res) > 0) {
			$self->resource_cost_h($res,$self->resource_cost_h($res) + 0.2);
            
            # attempt to fix the excessive recalculation of costs
            my @inEdges = $self->in_edges($res);
            for(my $i=0;$i<scalar(@inEdges);$i+=2) {
                my ($from,$to) = ($inEdges[$i],$inEdges[$i+1]);
                $self->set_attribute('weight',$from,$to,$self->resource_cost($to));
            }
        }
	}
}

sub resource_cost_p {
	my $self = shift;
	my $res = shift;

	my $cost = $self->get_attribute('cost',$res);
	if (@_) {
		$cost->{'p'} = shift;
		$self->set_attribute('cost',$res,$cost);
	}
	return $cost->{'p'};	
}

sub resource_cost_h {
	my $self = shift;
	my $res = shift;

	my $cost = $self->get_attribute('cost',$res);
	if (@_) {
		$cost->{'h'} = shift;
		$self->set_attribute('cost',$res,$cost);
	}
	return $cost->{'h'};	
}

sub resource_cost_b {
	my $self = shift;
	my $res = shift;

	my $cost = $self->get_attribute('cost',$res);
	if (@_) {
		$cost->{'b'} = shift;
		$self->set_attribute('cost',$res,$cost);
	}
	return $cost->{'b'};	
}

sub resource_cost {
	my $self = shift;
	my $res = shift;
	my $cost;
	
	if (not defined $self->get_attribute('cost',$res)){
		croak sprintf("cost of resource %s is not initialized\n",$res) 
	}
	
	# since this code uses cost 0 for currently unsued resources, we need
	# to treat this case separately
    my $cb = $self->resource_cost_b($res);
    my $ch = $self->resource_cost_h($res);
    my $cp = $self->resource_cost_p($res);
    
	if ($cp != 0) {
		$cost = ($cb + $ch) * $cp;
	} else {
		$cost = ($cb + $ch);
	}
	#print sprintf("res=%s cost=%d cb=%d ch=%d cp=%d\n",$res,$cost,$cb,$ch,$cp);
	return $cost;
}

# nodetypes 
# $NODETYPE_PI, $NODETYPE_PO, $NODETYPE_C, $NODETYPE_CI, $NODETYPE_CO, 
# $NODETYPE_W, $NODETYPE_B, $NODETYPE_S , $NODETYPE_M

### FIXME make this code more modular
sub resource_init_cost_all {
	my $self = shift;
	
	foreach my $res ($self->vertices){
		my $type = $self->get_attribute('type',$res);
		my $baseCost;
		
		#switch ($type) {
		#	case $NODETYPE_C { $baseCost = 100000; }
		#	case 1 { $baseCost = 1; }
		#}	
		
		#if ($type == $NODETYPE_C) {
		#	$baseCost = 100000;
		#	print sprintf("resource: %s type %d baseCost %d\n",$res,$type,$baseCost);
		#} else {
			$baseCost = 1;
		#}
		my $cost = {
			'b' => $baseCost, # base cost 1
			'p' => 0,         # present congestion (0 means unused)
			'h' => 0,         # no historical congestion
		};
		$self->set_attribute('cost',$res,$cost);
	}
	$self->recalc_all_costs();
}

sub recalc_all_costs {
	my $self = shift;
	
	my @r_edges = $self->edges;
	for(my $i=0;$i<scalar(@r_edges);$i+=2){
		my ($from,$to) = ($r_edges[$i],$r_edges[$i+1]);
		$self->set_attribute('weight',$from,$to,$self->resource_cost($to));
	}
}


################################################################################
# return an arrayref containing the names of all resources of a given type
################################################################################
sub getResourcesOfType {
    my $self = shift;
    my $type = shift;
    
    my @res = grep {($self->get_attribute('type',$_)) == $type} $self->vertices;
    return \@res;
}

sub getSiteNames {
    my $self = shift;
    return $self->getResourcesOfType($NODETYPE_C);
}

################################################################################
# add/remove feedthrough capability to cells. Used to allow unused cells for 
# routing
################################################################################

sub enableLogicFeedthrough {

    my $self = shift;
    my $cellName = shift;
    
    my $inName = cellNameToInputName($cellName);
    my $outName = cellNameToOutputName($cellName);
    my $feedthroughName = sprintf("w_%s_%s",$inName,$outName);

    $self->add_edge($inName,$feedthroughName);
    $self->add_edge($feedthroughName,$outName);
    #print "enabled feedthrough routing for cell $cellName\n";
}

sub disableLogicFeedthrough {

    my $self = shift;
    my $cellName = shift;
    
    my $inName = cellNameToInputName($cellName);
    my $outName = cellNameToOutputName($cellName);
    my $feedthroughName = sprintf("w_%s_%s",$inName,$outName);

    $self->delete_edge($inName,$feedthroughName);
    $self->delete_edge($feedthroughName,$outName);
    #print "disabled feedthrough routing for cell $cellName\n";
}


################################################################################
# add/remove feedthrough capability to cells. Used to allow unused cells for 
# routing
################################################################################
sub cellNameToInputName {
    my $c = shift;
    $c =~ s/c_(.*)/c_i_$1/;
    return $c;
}

sub cellNameToOutputName {
    my $c = shift;
    $c =~ s/c_(.*)/c_o_$1/;
    return $c;
}

sub outputNameToCellName {
    my $c = shift;
    $c =~ s/c_o_(.*)/c_$1/;
    return $c;
}

sub inputNameToCellName {
    my $c = shift;
    $c =~ s/c_i_(.*)/c_$1/;
    return $c;
}


################################################################################
# dot is a bit picky about the names of the nodes in the graph
#   replace all special characters with letters, the name for the node in the 
#   dot graph needs to be passed with a lable argument
################################################################################
sub _dotquote{
	my $arg = shift;
	$arg =~ s/_/X/g;
	$arg =~ s/\./Y/g;
	$arg =~ s/-/Z/g;
	return $arg; 
}

###############################################################
# dump routing graph as text
###############################################################
sub dump_txt{
	my $self = shift;
	my (@vertices, @edges,@res_edges,$node,$i,$type,$ret);
	
	foreach $node ($self->vertices){
	
		my $attr = $self->get_attribute('type',$node);
		if ($attr == $NODETYPE_PI){
			$type = 'primary input';
		} elsif ($attr == $NODETYPE_PO) { 
			$type = 'primary output';
		} elsif ($attr == $NODETYPE_C) { 
			$type = 'cell';
		} elsif ($attr == $NODETYPE_CI) {
            $type = 'cell input';
        } elsif ($attr == $NODETYPE_CO) {
            $type = 'cell output';
        } elsif ($attr == $NODETYPE_W) { 
			$type = 'wire';
		} elsif ($attr == $NODETYPE_B) { 
			$type = 'bus';
		} elsif ($attr == $NODETYPE_S) { 
			$type = 'switch';
		} elsif ($attr == $NODETYPE_M) { 
			$type = 'multiplexer';
		} else {
			$type = '((((unknown type))))';
			carp "problem: no type defined for node $node!\n";
		}
		push @vertices, sprintf("  %s : $type",$node,$type);
	}
	@vertices = sort @vertices;
	
	@edges = $self->edges();
	for($i=0;$i<scalar(@edges);$i+=2){
		push @res_edges, sprintf("  %s -> %s",$edges[$i],$edges[$i+1]);
	}
	@res_edges = sort @res_edges;

	print join("\n",@vertices);
	print "\n";
	print join("\n",@res_edges);

}

###########################################################################
# helper functions to determine local neighborhood relations, used by placer
###########################################################################

sub getLocalNeighbors {
    my $self = shift;
    my $r = shift;
    my $c = shift;
    my $direction = shift;

    my (@neighborColumn,@neighborRow);
    my @neighborCells;
	
    if ($direction eq 'in'){

        push @neighborRow,    ($r-1) % $ROWS; # N neighbor
        push @neighborColumn, ($c+0) % $COLS;
        push @neighborRow,    ($r-1) % $ROWS; # NE neighbor
        push @neighborColumn, ($c+1) % $COLS;
        push @neighborRow,    ($r+0) % $ROWS; # E neighbor
        push @neighborColumn, ($c+1) % $COLS;
        push @neighborRow,    ($r+1) % $ROWS; # SE neighbor
        push @neighborColumn, ($c+1) % $COLS;
        push @neighborRow,    ($r+1) % $ROWS; # S neighbor
        push @neighborColumn, ($c+0) % $COLS;
        push @neighborRow,    ($r+1) % $ROWS; # SW neighbor
        push @neighborColumn, ($c-1) % $COLS;
        push @neighborRow,    ($r+0) % $ROWS; # W neighbor
        push @neighborColumn, ($c-1) % $COLS;
        push @neighborRow,    ($r-1) % $ROWS; # NW neighbor
        push @neighborColumn, ($c-1) % $COLS;

### FIXME remove latern on
### old, asymmetric routing
if (0) {
        ## NW neighbor
        push @neighborRow,    ($r-1) % $ROWS;
        push @neighborColumn, ($c-1) % $COLS;
        # W neighbor
        push @neighborRow,    ($r+0) % $ROWS;
        push @neighborColumn, ($c-1) % $COLS;
        # S neighbor
        push @neighborRow,    ($r+1) % $ROWS;
        push @neighborColumn, ($c+0) % $COLS;
        # NE neighbor
        push @neighborRow,    ($r-1) % $ROWS;
        push @neighborColumn, ($c+1) % $COLS;
        # N neighbor
        push @neighborRow,    ($r-1) % $ROWS;
        push @neighborColumn, ($c+0) % $COLS;
}

    } elsif ($direction eq 'out') {

        push @neighborRow,    ($r-1) % $ROWS; # N neighbor
        push @neighborColumn, ($c+0) % $COLS;
        push @neighborRow,    ($r-1) % $ROWS; # NE neighbor
        push @neighborColumn, ($c+1) % $COLS;
        push @neighborRow,    ($r+0) % $ROWS; # E neighbor
        push @neighborColumn, ($c+1) % $COLS;
        push @neighborRow,    ($r+1) % $ROWS; # SE neighbor
        push @neighborColumn, ($c+1) % $COLS;
        push @neighborRow,    ($r+1) % $ROWS; # S neighbor
        push @neighborColumn, ($c+0) % $COLS;
        push @neighborRow,    ($r+1) % $ROWS; # SW neighbor
        push @neighborColumn, ($c-1) % $COLS;
        push @neighborRow,    ($r+0) % $ROWS; # W neighbor
        push @neighborColumn, ($c-1) % $COLS;
        push @neighborRow,    ($r-1) % $ROWS; # NW neighbor
        push @neighborColumn, ($c-1) % $COLS;


### FIXME remove later on
### old, asymmetric routing
if (0) {
        ## N neighbor
        push @neighborRow,    ($r-1) % $ROWS;
        push @neighborColumn, ($c+0) % $COLS;
        # E neighbor
        push @neighborRow,    ($r+0) % $ROWS;
        push @neighborColumn, ($c+1) % $COLS;
        # SE neighbor
        push @neighborRow,    ($r+1) % $ROWS;
        push @neighborColumn, ($c+1) % $COLS;
        # S neighbor
        push @neighborRow,    ($r+1) % $ROWS;
        push @neighborColumn, ($c+0) % $COLS;
        # SW neighbor
        push @neighborRow,    ($r+1) % $ROWS;
        push @neighborColumn, ($c-1) % $COLS;
}
    
    } else {
        die "invalid direction";
    }
    
    for (my $i=0; $i<scalar(@neighborRow); $i++){
        push @neighborCells, sprintf("c_%d_%d",$neighborRow[$i],$neighborColumn[$i]);
    }
    
    #print "neighbor cells for cell $r/$c:\n";
    #print "\t" . join("\n\t",@neighborCells) . "\n";

    return \@neighborCells;
}

#sub getLocalHighFanoutNeighbors {
#}

sub getPosFromCellName {
    my $arg = shift;
    my ($row,$col) = $arg =~ m/c_(\d+)_(\d+)/;
    #print "getPostFromCellName: arg=$arg -> row=$row col=$col\n";
    return ($row,$col);
}

sub getRoutingDistance {
    my $self = shift;
    my $sourceName = shift;
    my $targetName = shift;

    my ($sRow,$sCol) = getPosFromCellName($sourceName);
    my ($tRow,$tCol) = getPosFromCellName($targetName);
    
    #print("sRow:$sRow sCol:$sCol -> tRow:$tRow tCol:$tCol\n");
    my $DIRECT_NEIGHBOR = 1;
    my $BUS_NEIGHBOR = 1;
    

    # direct neighbors
    if ( (abs($tRow-$sRow) <= 1) and (abs($tCol-$sCol) <= 1) ){
        return $DIRECT_NEIGHBOR;
    }
    
    
    # row bus interconnect
    # all cells of same row are connected via horizontal south bus (if present)
    if ( ($tRow == $sRow) and ($HBUS_S > 0) ){
        return $BUS_NEIGHBOR;
    }
    
    # row bus interconnect
    # all cells of south row are connected via horizontal north buses of the 
    #  south row (if present)
    if ( ($tRow == ($sRow+1) % $ROWS) and ($HBUS_N > 0) ){
        return $BUS_NEIGHBOR;
    }
    
    # column bus interconnect
    # all cells of east column are connected via vertical east bus of the 
    #  current column
    if ( ($tCol == ($sCol+1) % $COLS) ){
        return $BUS_NEIGHBOR;
    }
    
    # targetCell is connected only indirectly, use oterh distance metric 
    # (Manhattan distance)
    return abs($tRow-$sRow) + abs($tCol-$sCol);

}


1;

__END__

# class documentation template, see Damian Conways Book, p97

=pod

=head1 NAME

Zippy::Architecture::RoutingGraph - Routing Graph handling for Zippy array

=head1 VERSION

This document refers to version N.NN of Zippy::Netlist, released 
March, 24, 2004

=head1 SYNOPSIS

# some short examples how to use the class

=head1 DESCRIPTION

=head2 Overview

=head2 Constructor and initialization

=head2 Class and object methods

=head2 Methods

=head2 Instance variables

=head1 BUGS

None, hopefully

=head1 TODOs



=head1 FILES

=head1 SEE ALSO

=head1 AUTHOR

Christian Plessl <plessl@tik.ee.ethz.ch>

=head1 COPYRIGHT

Copyright (c) 2004, Christian Plessl, Computer Engineering and Networks Lab
ETH Zurich, Switzerland.

All Rights Reserverd. This module is free software. It may be used, redistributed 
and/or modified under the same terms as Perl itself.

=cut
