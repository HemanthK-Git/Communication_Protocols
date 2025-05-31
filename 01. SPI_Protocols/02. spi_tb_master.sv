// data transfer from master to slave

`timescale 1ns / 1ps

module spi_tb();
    reg clk=0;
    reg rst =0;
    reg tx_enable = 0;
    wire mosi;
    wire ss;
    wire sclk;

    spi dut(clk,sclk,rst,tx_enable,mosi,ss);

    always #5 clk=~clk;

    initial begin
        rst = 1;
        repeat(5) @(posedge clk);
        rst = 0;
    end

    initial begin
        tx_enable = 0;
        repeat(5) @(posedge clk) ;
        tx_enable = 1;
    end

endmodule
