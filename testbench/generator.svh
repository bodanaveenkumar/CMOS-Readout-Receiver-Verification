
`ifndef GENERATOR_SVH
`define GENERATOR_SVH

class generator;

    mailbox #(frame_txn) gen2drv;
    mailbox #(frame_txn) gen2sb;

    int unsigned num_frames;

    function new(
        mailbox #(frame_txn) gen2drv,
        mailbox #(frame_txn) gen2sb
    );
        this.gen2drv = gen2drv;
        this.gen2sb  = gen2sb;
        this.num_frames = 3;
    endfunction

    task run();
        frame_txn txn;

        $display("GENERATOR: Starting generation of %0d frames",
                 num_frames);

        for (int i = 0; i < num_frames; i++) begin

            // Create a new transaction for every frame.
            txn = new();

            // Randomize frame geometry, timing and pixel data.
            if (!txn.randomize()) begin
                $fatal(1,
                    "GENERATOR ERROR: Randomization failed for frame %0d",
                    i + 1);
            end

            $display("\nGENERATOR: Generated frame %0d of %0d",
                     i + 1, num_frames);

            txn.display();

            // Send the same transaction to the driver and scoreboard.
            gen2drv.put(txn);
            gen2sb.put(txn);

            $display("GENERATOR: Frame %0d sent to driver and scoreboard",
                     i + 1);
        end

        $display("\nGENERATOR: Finished generating all frames");
    endtask

endclass

`endif
