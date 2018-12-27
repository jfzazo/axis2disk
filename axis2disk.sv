//==================================================================================================
// -----------------------------------------------------------------------------
// Copyright (c) 2018 All rights reserved
// -----------------------------------------------------------------------------
//  Filename      : axis2disk.sv
//  Author        : Jose Fernando Zazo Rollon
//  Company       : Naudit
//  Email         : josefernando.zazo@naudit.es
//  Created On    : 2018-12-27 10:07:53
//  Last Modified : 2018-12-27 10:32:31
//
//  Revision      : 1.0
//
//  Description   : Utility to dump information from an AXI4 Stream interface to a file for its use
//  in test benches.
//==================================================================================================
`timescale 1ns / 1ps
`define NULL 0


module axis2disk #(
    parameter output_filename = "none"   ,
    parameter AXIS_WIDTH      = 64
) (
    input  wire                      clk   ,
    input  wire                      rst_n ,
    input  wire [    AXIS_WIDTH-1:0] tdata ,
    input  wire [(AXIS_WIDTH/8)-1:0] tstrb ,
    output wire                      tready,
    input  wire                      tvalid,
    input  wire                      tlast ,
    input  wire                      eos     // End of stream (close the file)
);

    assign tready = 1'b1;

    // buffer for the message
    reg [7:0] str_buffer[0:(AXIS_WIDTH/8)-1];

    integer file = 0;
    integer i       ;
    integer size = 0;

    initial begin

        // Open file
        if (output_filename == "none") begin
            $display("output_filename parameter not set");
            $finish;
        end

        file = $fopen(output_filename, "wb");
        if (file == `NULL) begin
            $display("can't open output %s", output_filename);
            $finish;
        end

        // Initialize Inputs
        $display("AXIS2FILE: %m writing to %s", output_filename);

        // Close file
        @(posedge eos) $fclose(file);
        $display("AXIS2FILE: %m closing file %s", output_filename);
        file = 0;
    end

    always_ff @(posedge clk) begin
        if(file != `NULL && tvalid && tready) begin
            for(i=0;i<AXIS_WIDTH/8;i++) begin
                if(tstrb[i]) begin
                    str_buffer[size] = tdata[8*i+:8];
                    $fwrite(file,"%c",str_buffer[size]);
                    size++;
                end
            end
            size = 0;
        end
    end
endmodule
