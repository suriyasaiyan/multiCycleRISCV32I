`timescale 1ns / 1ps
`include "defines.vh"

module controlUnit(
    input wire clk, rst,
    input wire [6:0] opCode,
    input wire [2:0] funct3,
    input wire branchOut,
    output reg iMemRead,
    output reg [1:0] pcSelect,
    output reg memPC,
    output reg regWrite, 
    output reg dMemRead,
    output reg dMemWrite, 
    output reg [3:0] dMemByteRead,
    output reg [3:0] dMemByteWrite,
    output reg [2:0] branchOp,
    output reg aluSrcB,
    output reg aluSrcA,
    output reg [1:0] aluOp, 
    output reg aluOutDataSel,
    output reg [3:0] cstate
);

    localparam [3:0] S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100, 
                      S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111, S8 = 4'b1000, S9 = 4'b1001, 
                      S10 = 4'b1010, S11 = 4'b1011, S12 = 4'b1100, S13 = 4'b1101, S14 = 4'b1110,
                      S15 = 4'b1111;

    reg [3:0] currentState, nextState;

    always @(posedge clk) begin 
        if (rst) 
            currentState <= S15;
        else 
            currentState <= nextState;
    end
    
    always @(*) begin
        cstate = currentState;

        case (currentState)
            S0: begin 
                nextState = S1; iMemRead = 1; pcSelect = 2'b10;
                dMemWrite = 0; dMemRead = 0; regWrite = 0; 
                dMemByteRead = 4'b0000; dMemByteWrite = 4'b0000;
            end
            S1: begin
                nextState = (opCode == `LOAD || opCode == `STORE) ? S2 : 
                            (opCode == `ART || opCode == `IMM) ? S6 : 
                            (opCode == `BRANCH) ? S8 : 
                            (opCode == `SYSTEM) ? S14 : 
                            (opCode == `JAL || opCode == `JALR) ? S10 : 
                            (opCode == `FENCE) ? S13 : 
                            (opCode == `AUIPC || opCode == `LUI) ? S11 : S0;
            end
            S2: begin 
                aluSrcA = 1; aluSrcB = 1; aluOp = 2'b00;
                nextState = (opCode == `LOAD) ? S3 : (opCode == `STORE) ? S5 : S0;
            end
            S3: begin
                dMemRead = 1; dMemByteRead = 4'b1111; aluOutDataSel = 1; nextState = S4;
            end
            S4: begin
                regWrite = 1; memPC = 1; pcSelect = 2'b01; nextState = S0;
            end
            S5: begin
                dMemWrite = 1; dMemByteWrite = 4'b1111; pcSelect = 2'b01; nextState = S0;
            end
            S6: begin
                aluSrcA = 1; aluOp = 2'b10; aluSrcB = (opCode == `ART) ? 0 : 1; nextState = S7;
            end
            S7: begin
                regWrite = 1; aluOutDataSel = 0; memPC = 1; pcSelect = 2'b01; nextState = S0;
            end
            S8: begin
                branchOp = funct3; aluSrcA = 0; aluSrcB = 1; aluOp = 2'b00; nextState = S9;
            end
            S9: begin
                pcSelect = branchOut ? 2'b00 : 2'b01; nextState = S0;
            end
            S10: begin
                memPC = 0; regWrite = 1; aluOp = 2'b00; 
                aluSrcA = (opCode == `JALR) ? 1 : 0; aluSrcB = 1; pcSelect = 2'b00; nextState = S0;
            end
            S11: begin
                aluSrcA = 0; aluSrcB = 1; aluOp = (opCode == `LUI) ? 2'b11 : 2'b00; nextState = S12;
            end
            S12: begin
                aluOutDataSel = 0; memPC = 1; regWrite = 1; pcSelect = 2'b01; nextState = S0;
            end
            S13: begin
                aluOp = 2'b00; regWrite = 1; nextState = S0;
            end
            S14: begin
            end
            S15: begin
                iMemRead = 0; pcSelect = 2'b10; memPC = 0; regWrite = 0;
                dMemRead = 0; dMemWrite = 0; branchOp = 3'b000; aluSrcB = 0;
                aluSrcA = 0; aluOp = 2'b00; aluOutDataSel = 0;
                nextState = S0;
            end
            default : nextState = S0;
        endcase
    end
endmodule
               
