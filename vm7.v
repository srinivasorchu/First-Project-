`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 10:39:48
// Design Name: 
// Module Name: vending_machine_7prod
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


module vending_machine_7prod (
    input clk,
    input reset,
    input cancel,
    input [1:0] coin,
    input [2:0] select,
    output reg [6:0] product,
    output reg [5:0] change,
    output reg [7:0] anode,
    output reg [6:0] cathode
);

    // States (money in steps of 5₹)
    parameter s0=3'd0, s5=3'd1, s10=3'd2, s15=3'd3,
              s20=3'd4, s25=3'd5, s30=3'd6, s35=3'd7;
    reg [2:0] state, next_state;

    // Coin edge detection
    reg [1:0] prev_coin;
    wire coin_inserted = (coin != prev_coin) && (coin != 2'b00);

    // State update
    always @(posedge clk) begin
        prev_coin <= coin;
        if (reset) state <= s0;
        else state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (state)
            s0: begin
                if (cancel) next_state = s0;
                else if (coin_inserted) begin
                    if (coin == 2'b01) next_state = s5;
                    else if (coin == 2'b10) next_state = s10;
                    else next_state = s0;
                end else next_state = s0;
            end
            s5: begin
                if (cancel) next_state = s0;
                else if (coin_inserted) begin
                    if (coin == 2'b01) next_state = s10;
                    else if (coin == 2'b10) next_state = s15;
                    else next_state = s5;
                end else next_state = s5;
            end
            s10: begin
                if (cancel) next_state = s0;
                else if (coin_inserted) begin
                    if (coin == 2'b01) next_state = s15;
                    else if (coin == 2'b10) next_state = s20;
                    else next_state = s10;
                end else next_state = s10;
            end
            s15: begin
                if (cancel) next_state = s0;
                else if (coin_inserted) begin
                    if (coin == 2'b01) next_state = s20;
                    else if (coin == 2'b10) next_state = s25;
                    else next_state = s15;
                end else next_state = s15;
            end
            s20: begin
                if (cancel) next_state = s0;
                else if (coin_inserted) begin
                    if (coin == 2'b01) next_state = s25;
                    else if (coin == 2'b10) next_state = s30;
                    else next_state = s20;
                end else next_state = s20;
            end
            s25: begin
                if (cancel) next_state = s0;
                else if (coin_inserted) begin
                    if (coin == 2'b01) next_state = s30;
                    else if (coin == 2'b10) next_state = s35;
                    else next_state = s25;
                end else next_state = s25;
            end
            s30: begin
                if (cancel) next_state = s0;
                else if (coin_inserted) begin
                    if (coin == 2'b01) next_state = s35;
                    else next_state = s30;
                end else next_state = s30;
            end
            s35: begin
                if (cancel) next_state = s0;
                else next_state = s35;
            end
            default: next_state = s0;
        endcase
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            product <= 0;
            change <= 0;
        end else begin
            product <= 0;
            change <= 0;

            case (state)
                s0: if (cancel) change <= 0;
                s5: begin
                    if (cancel) change <= 5;
                    else if (select == 3'd0) product[0] <= 1;
                end
                s10: begin
                    if (cancel) change <= 10;
                    else if (select == 3'd0) begin product[0] <= 1; change <= 5; end
                    else if (select == 3'd1) product[1] <= 1;
                end
                s15: begin
                    if (cancel) change <= 15;
                    else if (select == 3'd1) begin product[1] <= 1; change <= 5; end
                    else if (select == 3'd2) product[2] <= 1;
                end
                s20: begin
                    if (cancel) change <= 20;
                    else if (select == 3'd0) begin product[0] <= 1; change <= 15; end
                    else if (select == 3'd1) begin product[1] <= 1; change <= 10; end
                    else if (select == 3'd2) begin product[2] <= 1; change <= 5; end
                    else if (select == 3'd3) product[3] <= 1;
                end
                s25: begin
                    if (cancel) change <= 25;
                    else if (select == 3'd1) begin product[1] <= 1; change <= 15; end
                    else if (select == 3'd2) begin product[2] <= 1; change <= 10; end
                    else if (select == 3'd3) begin product[3] <= 1; change <= 5; end
                    else if (select == 3'd4) product[4] <= 1;
                end
                s30: begin
                    if (cancel) change <= 30;
                    else if (select == 3'd0) begin product[0] <= 1; change <= 25; end
                    else if (select == 3'd1) begin product[1] <= 1; change <= 20; end
                    else if (select == 3'd2) begin product[2] <= 1; change <= 15; end
                    else if (select == 3'd3) begin product[3] <= 1; change <= 10; end
                    else if (select == 3'd4) begin product[4] <= 1; change <= 5; end
                    else if (select == 3'd5) product[5] <= 1;
                end
                s35: begin
                    if (cancel) change <= 30;
                    else if (select == 3'd1) begin product[1] <= 1; change <= 25; end
                    else if (select == 3'd2) begin product[2] <= 1; change <= 20; end
                    else if (select == 3'd3) begin product[3] <= 1; change <= 15; end
                    else if (select == 3'd4) begin product[4] <= 1; change <= 10; end
                    else if (select == 3'd5) begin product[5] <= 1; change <= 5; end
                    else if (select == 3'd6) product[6] <= 1;
                end
                default: ;
            endcase
        end
    end

    // 7-segment display driver (same as before)
    reg [5:0] display_value;
    always @(*) begin
        case (state)
            s0: display_value = 0;  s5: display_value = 5;
            s10: display_value = 10; s15: display_value = 15;
            s20: display_value = 20; s25: display_value = 25;
            s30: display_value = 30; s35: display_value = 35;
            default: display_value = 0;
        endcase
    end

    function [6:0] seg7; input [3:0] digit;
        case (digit)
            4'd0: seg7 = 7'b1000000; 4'd1: seg7 = 7'b1111001;
            4'd2: seg7 = 7'b0100100; 4'd3: seg7 = 7'b0110000;
            4'd4: seg7 = 7'b0011001; 4'd5: seg7 = 7'b0010010;
            4'd6: seg7 = 7'b0000010; 4'd7: seg7 = 7'b1111000;
            4'd8: seg7 = 7'b0000000; 4'd9: seg7 = 7'b0010000;
            default: seg7 = 7'b1111111;
        endcase
    endfunction

    reg [16:0] clkdiv; wire scan_clk = clkdiv[16];
    always @(posedge clk) begin
        if (reset) clkdiv <= 0;
        else clkdiv <= clkdiv + 1;
    end

    reg [3:0] digit_to_display;
    always @(posedge clk) begin
        if (reset) begin
            anode <= 8'b11111111; cathode <= 7'b1111111;
        end else begin
            anode <= 8'b11111111; cathode <= 7'b1111111;
            case (scan_clk)
                1'b0: begin anode <= 8'b11111110; digit_to_display = display_value % 10; end
                1'b1: begin anode <= 8'b11111101; digit_to_display = display_value / 10; end
            endcase
            cathode <= seg7(digit_to_display);
        end
    end

endmodule
