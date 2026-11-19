module cmos_readout_rx #(
    parameter DW = 12
)(
    input  wire          pix_clk,
    input  wire          rst_n,            // async assert, active low
    // ---- sensor interface ---
    input  wire          fval,
    input  wire          lval,
    input  wire [DW-1:0] pix_data,
    // ---- static configuration ---
    input  wire [11:0]   cfg_width,        // expected pixels per line  (1..4095)
    input  wire [11:0]   cfg_height,       // expected lines per frame  (1..4095)
    // ---- video output ---
    output reg           vid_valid,
    output reg  [DW-1:0] vid_data,
    output reg           vid_sof,
    output reg           vid_eol,
    // ---- status ---
    output reg           frame_start,      // 1-cycle pulse
    output reg           frame_done,       // 1-cycle pulse
    output reg  [11:0]   line_count,       // lines completed in current frame
    output wire [23:0]   pixel_count,      // pixels received in current frame
    output reg           err_width,        // 1-cycle pulse
    output reg           err_height        // 1-cycle pulse
);
    reg          fval_d, act_d;
    reg          hold_vld, hold_sof, sof_pend;
    reg [DW-1:0] hold_data;
    reg [11:0]   line_pix;
    reg [19:0]   pix_cnt;
    assign pixel_count = {4'd0, pix_cnt};
    wire act       = lval;
    wire fs        = fval & ~fval_d;           // frame start (FVAL rise)
    wire fe        = ~fval & fval_d;           // frame end   (FVAL fall)
    wire line_end  = act_d & ~act;             // end of an active line
    wire [11:0] lines_now = (fs ? 12'd0 : line_count) + (line_end ? 12'd1 : 12'd0);
    always @(posedge pix_clk or negedge rst_n) begin
        if (!rst_n) begin
            fval_d <= 1'b0; act_d <= 1'b0;
            hold_vld <= 1'b0; hold_sof <= 1'b0; sof_pend <= 1'b0; hold_data <= {DW{1'b0}};
            line_pix <= 12'd0; pix_cnt <= 20'd0; line_count <= 12'd0;
            vid_valid <= 1'b0; vid_data <= {DW{1'b0}}; vid_sof <= 1'b0; vid_eol <= 1'b0;
            frame_start <= 1'b0; frame_done <= 1'b0; err_width <= 1'b0; err_height <= 1'b0;
        end else begin
            fval_d      <= fval;
            act_d       <= act;
             frame_start <= fs;
            frame_done  <= fe;
            err_width   <= 1'b0;
            err_height  <= 1'b0;
            vid_valid   <= 1'b0;
            vid_sof     <= 1'b0;
            vid_eol     <= 1'b0;
            // ---------------- line end (checked first) ---------------
            if (line_end && !fe) begin
                if (hold_vld) begin
                    vid_valid <= 1'b1; vid_data <= hold_data;
                    vid_sof   <= hold_sof; vid_eol <= 1'b1;
                end
                hold_vld <= 1'b0;
                if (line_pix != cfg_width) err_width <= 1'b1;
                line_pix <= 12'd0;
            end
            // ---------------- frame end ---------------
            if (fe) begin
                if (lines_now != cfg_height) err_height <= 1'b1;
                sof_pend <= 1'b0;
            end
            // ---------------- frame start ---------------
            if (fs) begin
                sof_pend <= 1'b1;
                pix_cnt  <= 20'd0;
            end
            line_count <= lines_now;
            // ---------------- active pixel ---------------
            if (act) begin
                if (hold_vld && !line_end) begin
                    vid_valid <= 1'b1; vid_data <= hold_data;
                    vid_sof   <= hold_sof; vid_eol <= 1'b0;
                end
                hold_vld  <= 1'b1;
                hold_data <= pix_data;
                hold_sof  <= fs | sof_pend;
                sof_pend  <= 1'b0;
                line_pix  <= (line_end ? 12'd0 : line_pix) + 12'd1;
                pix_cnt   <= (fs ? 20'd0 : pix_cnt) + 20'd1;
            end
        end
    end
endmodule