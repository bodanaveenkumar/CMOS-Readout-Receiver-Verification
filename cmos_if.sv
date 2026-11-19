
interface cmos_if #(parameter DW = 12) (input logic pix_clk);

    logic rst_n;
    logic fval;
    logic lval;
    logic [DW-1:0] pix_data;

    logic [11:0] cfg_width;
    logic [11:0] cfg_height;

    logic vid_valid;
    logic [DW-1:0] vid_data;
    logic vid_sof;
    logic vid_eol;

    logic frame_start;
    logic frame_done;
    logic [11:0] line_count;
    logic [23:0] pixel_count;
    logic err_width;
    logic err_height;

endinterface
