`timescale 1ns/1ps
module tb_simple;

    // --------------------------------------------------
    // 1. DUT inputs
    // --------------------------------------------------
    reg         pix_clk = 0;
    reg         rst_n   = 0;
    reg         fval    = 0;
    reg         lval    = 0;
    reg  [11:0] pix_data = 0;

    reg  [11:0] cfg_width  = 3;
    reg  [11:0] cfg_height = 2;

    // --------------------------------------------------
    // 2. DUT outputs
    // --------------------------------------------------
    wire        vid_valid;
    wire [11:0] vid_data;
    wire        vid_sof;
    wire        vid_eol;

    wire        frame_start;
    wire        frame_done;

    wire [11:0] line_count;
    wire [23:0] pixel_count;

    wire        err_width;
    wire        err_height;

    // --------------------------------------------------
    // 3. Instantiate DUT
    // --------------------------------------------------
    cmos_readout_rx dut (.*);

    // --------------------------------------------------
    // 4. Clock: 10 ns period
    // --------------------------------------------------
    always #5 pix_clk = ~pix_clk;

    // --------------------------------------------------
    // 5. Expected output pixels
    // Decimal: 16,17,18,32,33,34
    // Hex:     010,011,012,020,021,022
    // --------------------------------------------------
    integer out_idx = 0;
    integer errors  = 0;
    reg [11:0] expected_data;

    // --------------------------------------------------
    // 6. Output monitor and checker
    // --------------------------------------------------
    always @(posedge pix_clk) begin
        if (rst_n && vid_valid) begin

            case (out_idx)
                0: expected_data = 12'h010;
                1: expected_data = 12'h011;
                2: expected_data = 12'h012;
                3: expected_data = 12'h020;
                4: expected_data = 12'h021;
                5: expected_data = 12'h022;
                default: expected_data = 12'hxxx;
            endcase

            $display(
                "%0t OUT[%0d] DATA=%h SOF=%b EOL=%b",
                $time, out_idx, vid_data, vid_sof, vid_eol
            );

            // Check pixel count and pixel data
            if (out_idx >= 6) begin
                $error("FAIL: Extra output pixel: %h", vid_data);
                errors = errors + 1;
            end
            else if (vid_data !== expected_data) begin
                $error(
                    "FAIL: Pixel %0d expected=%h actual=%h",
                    out_idx, expected_data, vid_data
                );
                errors = errors + 1;
            end

            // SOF must be asserted only for the first pixel
            if (vid_sof !== (out_idx == 0)) begin
                $error("FAIL: Incorrect SOF at pixel %0d", out_idx);
                errors = errors + 1;
            end

            // EOL must be asserted on pixels 2 and 5
            if (vid_eol !== (out_idx == 2 || out_idx == 5)) begin
                $error("FAIL: Incorrect EOL at pixel %0d", out_idx);
                errors = errors + 1;
            end

            out_idx = out_idx + 1;
        end
    end

    // --------------------------------------------------
    // 7. Drive one frame: 3 pixels x 2 lines
    // --------------------------------------------------
    integer l, p;

    initial begin

        $display("-----------------------------------");
        $display(" CMOS READOUT SIMPLE TEST");
        $display("-----------------------------------");

        // Release reset
        #23;
        rst_n = 1;

        // Wait before frame begins
        repeat (3) @(negedge pix_clk);

        // Start frame
        fval = 1;

        // Front porch
        repeat (2) @(negedge pix_clk);

        // Two lines, three pixels per line
        for (l = 0; l < 2; l = l + 1) begin

            for (p = 0; p < 3; p = p + 1) begin
                lval = 1;
                pix_data = (l + 1) * 16 + p;

                @(negedge pix_clk);
            end

            // End line
            lval = 0;

            // Horizontal blanking
            repeat (2) @(negedge pix_clk);
        end

        // End frame
        fval = 0;
        lval = 0;

        // Allow DUT outputs and counters to settle
        repeat (6) @(negedge pix_clk);

        // --------------------------------------------------
        // 8. Final checks
        // --------------------------------------------------
        $display("-----------------------------------");
        $display(" FINAL RESULTS");
        $display("-----------------------------------");

        $display("Output pixels = %0d", out_idx);
        $display("Line count    = %0d", line_count);
        $display("Pixel count   = %0d", pixel_count);
        $display("err_width     = %b", err_width);
        $display("err_height    = %b", err_height);

        if (out_idx != 6) begin
            $error("FAIL: Expected 6 pixels, received %0d", out_idx);
            errors = errors + 1;
        end

        if (line_count !== 12'd2) begin
            $error("FAIL: Expected line_count=2");
            errors = errors + 1;
        end

        if (pixel_count !== 24'd6) begin
            $error("FAIL: Expected pixel_count=6");
            errors = errors + 1;
        end

        if (err_width !== 1'b0) begin
            $error("FAIL: Unexpected err_width");
            errors = errors + 1;
        end

        if (err_height !== 1'b0) begin
            $error("FAIL: Unexpected err_height");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("BASIC TEST PASSED");
        else
            $display("BASIC TEST FAILED: %0d errors", errors);

        $finish;
    end

endmodule
