
`timescale 1ns/1ps
`include "frame_txn.sv"

module tb_txn_test;

    frame_txn txn;

    initial begin
        $display("Starting transaction test...");

        txn = new();

        if (txn.randomize()) begin
            txn.display();
            $display("TRANSACTION TEST PASSED");
        end
        else begin
            $error("Transaction randomization FAILED");
        end

        $finish;
    end

endmodule
