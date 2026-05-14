// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Riccardo Fiorani Gallotta <riccardo.fiorani3@unibo.it>
//
// Package with configuration and type definitions for behaviour model of generic io pads
//

package tc_pad_pkg;
    // Type for configuration of pads behaviour
    typedef struct packed {
        bit          av_bidir_cell;          // bidirectional io cell availability
        bit          av_in_cell;             // input cell availability
        bit          av_out_cell;            // output cell availability
        bit          in_en_latch;            // input enable is latched when retention is enabled
        bit          pu_pd_both_en;          // Both pull-up and pull-down can be enabled at the same time
        bit          rt_en_ah;               // retention enable internal signal active high
        int          ds_w;                   // drive strength level signal width
        int          n_int;                  // number of internal signals (in addition to retention LSB)
    } tc_pad_config_t;

    typedef enum bit {V, H} tc_pad_orientation_t; 

    localparam tc_pad_config_t default_tc_pad_config = '{
        1'b1,   //av_bidir_cell
        1'b1,   //av_in_cell
        1'b1,   //av_out_cell
        1'b1,   //in_en_latch
        1'b1,   //pu_pd_both_en
        1'b1,   //rt_en_ah
        2,      //ds_w
        1       //n_int
    };

endpackage
