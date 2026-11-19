`ifndef DRIVER_SVH
`define DRIVER_SVH

class driver;

    virtual cmos_if #(12) vif;
    mailbox #(frame_txn) gen2drv;

    bit done;
    int unsigned frames_driven;

    function new(
        virtual cmos_if #(12) vif,
        mailbox #(frame_txn) gen2drv
    );
        this.vif = vif;
        this.gen2drv = gen2drv;
        this.done = 1'b0;
        this.frames_driven = 0;
    endfunction

    // Initialize DUT inputs and apply reset.
    task reset_dut();
        $display("DRIVER: Applying reset");

        vif.rst_n      = 1'b0;
        vif.fval       = 1'b0;
        vif.lval       = 1'b0;
        vif.pix_data   = '0;
        vif.cfg_width  = '0;
        vif.cfg_height = '0;

        repeat (5) @(negedge vif.pix_clk);

        vif.rst_n = 1'b1;

        repeat (2) @(negedge vif.pix_clk);

        $display("DRIVER: Reset completed");
    endtask

    // Drive one complete frame.
    task drive_frame(frame_txn txn);
        int unsigned pixel_index;

        pixel_index = 0;

        $display(
            "DRIVER: Driving frame %0d x %0d",
            txn.width, txn.height
        );

        // Configure the expected frame geometry.
        vif.cfg_width  = txn.width;
        vif.cfg_height = txn.height;

        // Wait before asserting frame-valid.
        repeat (txn.front_porch) @(negedge vif.pix_clk);

        vif.fval = 1'b1;

        // Allow frame_start detection before the first line.
        repeat (1) @(negedge vif.pix_clk);

        for (int unsigned row = 0; row < txn.height; row++) begin

            // Start this line.
            vif.lval = 1'b1;

            for (int unsigned col = 0; col < txn.width; col++) begin
                vif.pix_data = txn.pixels[pixel_index];
                @(negedge vif.pix_clk);
                pixel_index++;
            end

            // End this line.
            vif.lval     = 1'b0;
            vif.pix_data = '0;

            // Horizontal blanking between lines.
            if (row < txn.height - 1)
                repeat (txn.hblank) @(negedge vif.pix_clk);
        end

        // Keep FVAL asserted during vertical blanking.
        repeat (txn.vblank) @(negedge vif.pix_clk);

        // End the frame.
        vif.fval     = 1'b0;
        vif.lval     = 1'b0;
        vif.pix_data = '0;

        // Allow the DUT to register frame_done.
        repeat (txn.back_porch) @(negedge vif.pix_clk);

        frames_driven++;

        $display(
            "DRIVER: Completed frame %0d x %0d",
            txn.width, txn.height
        );
    endtask

    // Consume and drive all generated transactions.
    task run();
        frame_txn txn;

        done = 1'b0;
        frames_driven = 0;

        reset_dut();

        forever begin
            // Blocks until the generator provides a frame.
            gen2drv.get(txn);

            drive_frame(txn);

            // This test uses three generated frames.
            if (frames_driven == 3) begin
                done = 1'b1;
                $display("DRIVER: All 3 frames driven");
                break;
            end
        end
    endtask

endclass

`endif