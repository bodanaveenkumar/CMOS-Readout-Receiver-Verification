`timescale 1ns/1ps

`include "frame_txn.svh"
`include "generator.svh"
`include "driver.svh"
`include "monitor.svh"
`include "scoreboard.svh"

module tb_driver_test;

    // Clock
    logic pix_clk = 1'b0;

    always #5 pix_clk = ~pix_clk;

    // Interface
    cmos_if #(12) vif(pix_clk);

    // Mailboxes
    mailbox #(frame_txn) gen2drv;
    mailbox #(frame_txn) gen2sb;

    // Verification components
    generator  gen;
    driver     drv;
    monitor    mon;
    scoreboard sb;

    bit test_finished = 1'b0;

    // DUT instantiation
    cmos_readout_rx #(
        .DW(12)
    ) dut (
        .pix_clk     (vif.pix_clk),
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

    // Main test
    initial begin

        $display("");
        $display("========================================");
        $display(" CMOS READOUT RECEIVER VERIFICATION");
        $display("========================================");
        $display("");

        // Create mailboxes.
        gen2drv = new();
        gen2sb  = new();

        // Construct verification components.
        gen = new(gen2drv, gen2sb);
        drv = new(vif, gen2drv);
        mon = new(vif);
        sb  = new(vif, gen2sb);

        $display("TESTBENCH: Components created");
        $display("TESTBENCH: Starting generator, driver, monitor and scoreboard");
        $display("");

        // Run components concurrently.
        fork
            gen.run();
            drv.run();
            mon.run();
            sb.run();
        join_none

        // Wait until all three frames have been driven.
        wait (drv.done == 1'b1);

        $display("");
        $display("TESTBENCH: Driver completed all frames");

        // Wait until scoreboard has checked every frame.
        wait (sb.done == 1'b1);

        // Allow the final monitor events to settle.
        repeat (3) @(negedge pix_clk);

        $display("");
        $display("TESTBENCH: All verification components completed");
        $display("");

        // Print final reports.
        sb.report();
        mon.report();

        $display("========================================");
        $display(" CMOS VERIFICATION TEST FINISHED");
        $display("========================================");
        $display("");

        test_finished = 1'b1;

        $finish;
    end

    // Watchdog: only report a timeout if the test is unfinished.
    initial begin : timeout_watchdog
        #100000;

        if (test_finished == 1'b0) begin
            $fatal(
                1,
                "TIMEOUT: Testbench did not finish within 100 us"
            );
        end
    end

endmodule