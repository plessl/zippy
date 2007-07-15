proc addcell {row col} {

    add wave -radix decimal -label "c_$row.$col.i0" "/tb_tstadpcm/dut/compeng/gen_rows__$row/row_i/gen_cells__$col/cell_i/procelement/opxd(0)"

    add wave -radix decimal -label "c_$row.$col.i1" "/tb_tstadpcm/dut/compeng/gen_rows__$row/row_i/gen_cells__$col/cell_i/procelement/opxd(1)"

    add wave -radix decimal -label "c_$row.$col.i2" "/tb_tstadpcm/dut/compeng/gen_rows__$row/row_i/gen_cells__$col/cell_i/procelement/opxd(2)"

    add wave -radix decimal -label "c_$row.$col.o" "/tb_tstadpcm/dut/compeng/gen_rows__$row/row_i/gen_cells__$col/cell_i/procelement/outxdo"

}

proc loopdebug {iter} {

  while {$iter > 0} {
   set iter [ expr $iter -1 ]
   step;
   puts [simtime];
   
  }

}
