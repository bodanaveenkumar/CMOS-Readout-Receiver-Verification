`ifndef SCOREBOARD_SVH
`define SCOREBOARD_SVH

class scoreboard;

    virtual cmos_if #(12) vif;
    mailbox #(frame_txn) exp_mbx;

    int total_pixels;
    int total_pixel_errors;
    int total_sof_errors;
    int total_eol_errors;
    int total_frame_errors;
    int frames_checked;
    int expected_frames;

    bit done;

    function new(
        virtual cmos_if #(12) vif,
        mailbox #(frame_txn) exp_mbx
    );
        this.vif = vif;
        this.exp_mbx = exp_mbx;

        total_pixels       = 0;
        total_pixel_errors = 0;
        total_sof_errors   = 0;
        total_eol_errors   = 0;
        total_frame_errors = 0;
        frames_checked     = 0;
        expected_frames    = 3;
        done               = 1'b0;
    endfunction

    task run();
        frame_txn txn;
        bit pixel_found;
        bit expected_sof;
        bit expected_eol;

        done = 1'b0;
        frames_checked = 0;

        while (frames_checked < expected_frames) begin

            exp_mbx.get(txn);

            $display(
                "\nSCOREBOARD: Checking frame %0d (%0dx%0d)",
                frames_checked + 1, txn.width, txn.height
            );

            for (int unsigned i = 0;
                 i < txn.width * txn.height;
                 i++) begin

                pixel_found = 1'b0;

                // Wait for the next valid output pixel.
                while (pixel_found == 1'b0) begin
                    @(posedge vif.pix_clk);
                    #1;

                    if (vif.vid_valid === 1'b1)
                        pixel_found = 1'b1;
                end

                total_pixels++;

                expected_sof = (i == 0);
                expected_eol = ((i % txn.width) == (txn.width - 1));

                // Check pixel data.
                if (vif.vid_data !== txn.pixels[i]) begin
                    total_pixel_errors++;

                    $error(
                        "SCOREBOARD: Pixel mismatch. Frame=%0d Pixel=%0d Expected=0x%03h Actual=0x%03h",
                        frames_checked + 1,
                        i,
                        txn.pixels[i],
                        vif.vid_data
                    );
                end

                // Check start-of-frame indication.
                if (vif.vid_sof !== expected_sof) begin
                    total_sof_errors++;

                    $error(
                        "SCOREBOARD: SOF mismatch. Frame=%0d Pixel=%0d Expected=%0b Actual=%0b",
                        frames_checked + 1,
                        i,
                        expected_sof,
                        vif.vid_sof
                    );
                end

                // Check end-of-line indication.
                if (vif.vid_eol !== expected_eol) begin
                    total_eol_errors++;

                    $error(
                        "SCOREBOARD: EOL mismatch. Frame=%0d Pixel=%0d Expected=%0b Actual=%0b",
                        frames_checked + 1,
                        i,
                        expected_eol,
                        vif.vid_eol
                    );
                end
            end

            frames_checked++;

            $display(
                "SCOREBOARD: Completed checking frame %0d",
                frames_checked
            );
        end

        done = 1'b1;

        $display(
            "\nSCOREBOARD: All %0d frames checked",
            frames_checked
        );
    endtask

    task report();
        $display("");
        $display("========== SCOREBOARD REPORT ==========");
        $display("Frames checked       : %0d", frames_checked);
        $display("Pixels checked       : %0d", total_pixels);
        $display("Pixel data errors    : %0d", total_pixel_errors);
        $display("SOF errors           : %0d", total_sof_errors);
        $display("EOL errors           : %0d", total_eol_errors);
        $display("Frame errors         : %0d", total_frame_errors);

        if ((frames_checked == expected_frames) &&
            (total_pixel_errors == 0) &&
            (total_sof_errors == 0) &&
            (total_eol_errors == 0) &&
            (total_frame_errors == 0)) begin

            $display("SCOREBOARD RESULT: PASS");

        end else begin

            $display("SCOREBOARD RESULT: FAIL");

        end

        $display("========================================");
        $display("");
    endtask

endclass

`endif