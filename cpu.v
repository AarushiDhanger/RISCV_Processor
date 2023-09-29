`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2023 11:16:02 PM
// Design Name: 
// Module Name: cpu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu(
    input rst_n,
    input clk,
    output reg [31:0] imem_addr,  //Instruction memory address
    input [31:0] imem_insn, //Instruction from Instruction memory
    output [31:0] dmem_addr, //Data memory address
    inout [31:0] dmem_data, //Data to/ from data memory
    output dmem_wen //Write enable for data memory (1 for Store, 0 for Load)
    );
    
    //16-bit counter
    reg [15:0] counter;
    reg [31:0] PC;
    reg [31:0] instruction;

    //pipelining
    reg fetch_reg, decode_reg, execute_reg, memAccess_reg, writeBack_reg;
    
    //fetch
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
           //reset program counter, fetch pipeline, and counter
           PC <= 16'b0;
           counter <= 16'b0;
           fetch_reg <= 1'b0;
           end
        else begin
           if(imem_insn) begin
              imem_addr <= PC;
              PC <= PC + 4;
              counter <= counter + 1;
              fetch_reg <= 1'b1;
              instruction <= imem_insn;
           end
         end
    end
    
    //decode
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
           //resetting program counter, decode pipeline, counter
           PC <= 16'b0;
           counter <= 16'b0;
           decode_reg <= 1'b0;
           end
        else begin
           imem_addr <= PC;
           PC <= PC + 4;
           counter <= counter + 1;
           if(fetch_reg == 1) begin
              decode_reg <= 1'b1;
              imem_addr <= PC;
              PC <= PC + 4;
              counter <= counter + 1;
            
           end
         end
    end
    
    //execute
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
           PC <= 16'b0;
           counter <= 16'b0;
           execute_reg <= 1'b0;
           end
        else begin
           if(decode_reg) begin
              imem_addr <= PC; 
              PC <= PC + 4;
              counter <= counter + 1;
              execute_reg <= 1'b1;
           end
         end 
    end

    // memory access
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
           PC <= 16'b0;
           counter <= 16'b0;
           memAccess_reg <= 1'b0;
           end
        else begin
            if(execute_reg) begin
               imem_addr <= PC;
               PC <= PC + 4;
               counter <= counter + 1;
            end
         end
    end
    
    //Write Back
    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        PC <= 16'b0;
           writeBack_reg <= 1'b0;
           counter <= 16'b0;
           end
        else begin
            if(memAccess_reg) begin
               imem_addr <= PC;
               PC <= PC + 4;
               counter <= counter + 1;
            end
         end
    end
    