
`timescale 1ns/1ps
`include "frame_txn.sv"
`include "generator.sv"

module tb_generator_test;

    mailbox #(frame_txn) gen2drv;
    generator gen;

    initial begin
        $display("=== GENERATOR TEST START ===");

        gen2drv = new();
        gen = new(gen2drv, 5);

        // Start the generator
        gen.run();

        // Check that all five transactions were sent
        if (gen2drv.num() == 5)
            $display("GENERATOR TEST PASSED");
        else
            $error("Expected 5 transactions, got %0d",
                   gen2drv.num());

        $finish;
    end

endmodule
