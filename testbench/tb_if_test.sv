
`timescale 1ns/1ps

module tb_if_test;

    logic pix_clk = 0;
    always #5 pix_clk = ~pix_clk;

    cmos_if #(12) vif(pix_clk);

    cmos_readout_rx #(.DW(12)) dut (
        .pix_clk     (pix_clk),
        .rst_n       (vif.rst_n),
        .fval        (vif.fval),
        .lval        (vif.lval),
        .pix_data    (vif.pix_data),
        .cfg_width   (vif.cfg_width),
        .cfg_height  (vif.cfg_height),
        .vid_valid   (vif.vid_valid),
        .vid_data    (vif.vid_data),
        .vid_sof     (vif.vid_sof),
        .vid_eol     (vif.vid_eol),
        .frame_start (vif.frame_start),
        .frame_done  (vif.frame_done),
        .line_count  (vif.line_count),
        .pixel_count (vif.pixel_count),
        .err_width   (vif.err_width),
        .err_height  (vif.err_height)
    );

    initial begin
        vif.rst_n = 0;
        vif.fval = 0;
        vif.lval = 0;
        vif.pix_data = 0;
        vif.cfg_width = 3;
        vif.cfg_height = 2;

        repeat (3) @(negedge pix_clk);
        vif.rst_n = 1;

        repeat (3) @(negedge pix_clk);

        $display("INTERFACE TEST PASSED");
        $finish;
    end

endmodule
