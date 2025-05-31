// data transfer from master to slave

`timescale 1ns / 1ps

module spi(
    input clk,sclk,rst,tx_enable,
    output reg mosi,cs
    );

    typedef enum logic[1:0] {
        idle = 0,
        start_tx = 1,
        data_tx = 2,
        end_tx = 3
        } state_type;
        
        state_type state,next_state;

    reg spi_clk = 0;
    reg [2:0] count = 0;
    reg [2:0] bit_count = 0;
    reg [7:0] din = 8'b10101110;

    // generating the serial clock from system clock: sclk = 1/8 clk
    always @(posedge clk)
    begin
        case(next_state)
        
            idle: 
                begin
                    spi_clk <= 0;
                end 

            start_tx:
                begin
                    if(count<3'd3 || count == 3'd7)
                        spi_clk <= 1'b1;
                    else
                        spi_clk <= 1'b0;
                end

            data_tx:
                begin
                    if(count<3'd3 || count == 3'd7)
                        spi_clk <= 1'b1;
                    else
                        spi_clk <= 1'b0;
                end

             end_tx:
                begin
                    if(count<3'd3 || count == 3'd7)
                        spi_clk <= 1'b1;
                    else
                        spi_clk <= 1'b0;
                end

             default: spi_clk <= 1'b0;
           
        endcase

    end

    // transfering the data 
    always@(posedge clk)
        begin
            if(rst)
                state <= idle;
            else
                state <= next_state;

        end

        always@(*)
        begin
            case(state)
                idle:
                    begin
                        cs =1'b1;
                        mosi = 1'b0;
                        if(tx_enable==1'b1)
                            next_state = start_tx;
                        else
                            next_state = idle;
                    end

                start_tx:
                    begin
                        cs = 1'b0;
                        if(count == 3'd7)
                            next_state = data_tx;
                        else
                            next_state = start_tx;
                    end

                data_tx:
                    begin
                        mosi = din[7-bit_count];
                        if(bit_count != 8)
                            next_state = data_tx;
                        else begin
                            next_state = end_tx;
                             mosi = 1'b0;
                        end
                
                    end

                end_tx:
                    begin
                        cs = 1'b1;
                        mosi = 1'b0;
                        if(count == 3'd7)
                            next_state = idle;
                        else
                            next_state = end_tx;
                     end

                default: next_state = idle;

            endcase

        end

// creating a counter block
always@(posedge clk)
    begin
        case(state)
            idle:
                begin
                    count <= 0;
                    bit_count <= 0;

                end

             start_tx:
                 begin
                    count <= count +1;
                 end

             data_tx:
                begin
                    if(bit_count != 8)
                        begin
                            if(count<3'd7)
                                count <= count+1;
                            else begin
                                count <= 0;
                                bit_count <= bit_count + 1;
                            end
                        end
                end

             end_tx:
                begin
                    count <= count + 1;
                    bit_count <= 0;
                end

             default:
                begin
                    count <= 0;
                    bit_count <= 0;
                end
          endcase
    end

assign sclk = spi_clk;

endmodule
