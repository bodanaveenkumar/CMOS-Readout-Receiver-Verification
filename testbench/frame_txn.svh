`ifndef FRAME_TXN_SVH
`define FRAME_TXN_SVH
class frame_txn;

    // Frame geometry
    rand int unsigned width;
    rand int unsigned height;

    // Blanking intervals, measured in clock cycles
    rand int unsigned front_porch;
    rand int unsigned back_porch;
    rand int unsigned hblank;
    rand int unsigned vblank;

    // Pixel values, one 12-bit pixel per clock
    rand bit [11:0] pixels[];

    // Constrain the frame to manageable simulation sizes
    constraint c_geometry {
        width  inside {[1:64]};
        height inside {[1:16]};
    }

    constraint c_timing {
        front_porch inside {[1:4]};
        back_porch  inside {[1:4]};
        hblank      inside {[1:4]};
        vblank      inside {[1:4]};
    }

    // Allocate one pixel for every position in the frame
    constraint c_pixels {
        pixels.size() == width * height;
    }

    // Print the generated transaction
    function void display();
        $display("Frame: width=%0d height=%0d",
                 width, height);

        $display("Timing: front=%0d back=%0d hblank=%0d vblank=%0d",
                 front_porch, back_porch, hblank, vblank);

        $display("Total pixels=%0d", pixels.size());
    endfunction

endclass
`endif