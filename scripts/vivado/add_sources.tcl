set ROOT [file normalize [file dirname [info script]]/../..]
# This script was generated automatically by bender.
add_files -norecurse -fileset [current_fileset] [list \
    $ROOT/.bender/git/checkouts/common_verification-4b56526c61ed7318/src/clk_rst_gen.sv \
    $ROOT/.bender/git/checkouts/common_verification-4b56526c61ed7318/src/rand_id_queue.sv \
    $ROOT/.bender/git/checkouts/common_verification-4b56526c61ed7318/src/rand_stream_mst.sv \
    $ROOT/.bender/git/checkouts/common_verification-4b56526c61ed7318/src/rand_synch_holdable_driver.sv \
    $ROOT/.bender/git/checkouts/common_verification-4b56526c61ed7318/src/rand_verif_pkg.sv \
    $ROOT/.bender/git/checkouts/common_verification-4b56526c61ed7318/src/sim_timeout.sv \
    $ROOT/.bender/git/checkouts/common_verification-4b56526c61ed7318/src/rand_synch_driver.sv \
    $ROOT/.bender/git/checkouts/common_verification-4b56526c61ed7318/src/rand_stream_slv.sv \
]
add_files -norecurse -fileset [current_fileset] [list \
    $ROOT/src/deprecated/cluster_clk_cells_xilinx.sv \
    $ROOT/src/fpga/tc_clk_xilinx.sv \
    $ROOT/src/fpga/tc_sram_xilinx.sv \
]
add_files -norecurse -fileset [current_fileset] [list \
    $ROOT/test/tb_tc_sram.sv \
]

set_property verilog_define [list \
    TARGET_FPGA \
    TARGET_SIMULATION \
    TARGET_TEST \
    TARGET_VIVADO \
    TARGET_XILINX \
] [current_fileset]

set_property verilog_define [list \
    TARGET_FPGA \
    TARGET_SIMULATION \
    TARGET_TEST \
    TARGET_VIVADO \
    TARGET_XILINX \
] [current_fileset -simset]
