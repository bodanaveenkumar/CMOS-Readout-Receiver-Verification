
`timescale 1ns/1ps

class monitor;

    virtual cmos_if #(12) vif;

    int pixel_count_seen;
    int sof_count;
    int eol_count;
    int frame_start_count;
    int frame_done_count;
    int error_count;

    function new(virtual cmos_if #(12) vif);
        this.vif = vif;

        pixel_count_seen = 0;
        sof_count        = 0;
        eol_count        = 0;
        frame_start_count = 0;
        frame_done_count  = 0;
        error_count       = 0;
    endfunction

    task run();
        $display("MONITOR: Started observing DUT outputs");

        forever begin
            @(posedge vif.pix_clk);
            #1;

            if (vif.vid_valid === 1'b1) begin
                pixel_count_seen++;

                $display(
                    "MONITOR: Pixel %0d | Data=0x%03h | SOF=%0b | EOL=%0b",
                    pixel_count_seen,
                    vif.vid_data,
                    vif.vid_sof,
                    vif.vid_eol
                );
            end

            if (vif.vid_sof === 1'b1) begin
                sof_count++;
                $display("MONITOR: Start of frame detected");
            end

            if (vif.vid_eol === 1'b1) begin
                eol_count++;
                $display("MONITOR: End of line detected");
            end

            if (vif.frame_start === 1'b1) begin
                frame_start_count++;
                $display("MONITOR: frame_start detected");
            end

            if (vif.frame_done === 1'b1) begin
                frame_done_count++;
                $display("MONITOR: frame_done detected");
            end

            if ((vif.err_width === 1'b1) ||
                (vif.err_height === 1'b1)) begin
                error_count++;
                $display(
                    "MONITOR: ERROR FLAG | width=%0b height=%0b",
                    vif.err_width,
                    vif.err_height
                );
            end
        end
    endtask

    task report();
        $display("");
        $display("========== MONITOR REPORT ==========");
        $display("Valid pixels observed : %0d", pixel_count_seen);
        $display("SOF events            : %0d", sof_count);
        $display("EOL events            : %0d", eol_count);
        $display("Frame start events    : %0d", frame_start_count);
        $display("Frame done events     : %0d", frame_done_count);
        $display("Error flag samples    : %0d", error_count);
        $display("====================================");
    endtask

endclass
