`timescale 1s / 1ms
module fsm(Clock, Reset, S1, S2, S3, L1, L2, L3);
  input Clock;
  input Reset;
  input // sensors for approaching vehicles
  S1, // Northbound on SW 4th Avenue
  S2, // Eastbound on SW Harrison Street
  S3; // Westbound on SW Harrison Street
  output reg [1:0] // outputs for controlling traffic lights
  // (01, 10, 11 for green, yellow, red)
  L1, // light for NB SW 4th Avenue
  L2, // light for EB SW Harrison Street
  L3; // light for WB SW Harrison Street

  logic greendecr, yellowdecr, load, enHarrison, enFourth, keepfourth;
  logic [7:0] nbgreen, ewgreen, yellow, greenval;

  enum bit [1:0] {FLASH = 2'b00,
                    FOURTH = 2'b01,
                    HARRISON = 2'b10} State, Next;

  assign nbgreen = 8'b00101100;
  assign ewgreen = 8'b00001110;
  assign keepfourth = S1 && !(S2 || S3);

  counter cgreen(Clock, load, greenval, greendecr, tugreen);
  counter cyellow(Clock, load, 8'b00000011, yellowdecr, tuyellow);

  tlight t1(L1, S1, tugreen, keepfourth, tuyellow, Clock, Reset, enFourth);
  tlight t2(L2, S2|S3, tugreen, 1'b0, tuyellow, Clock, Reset, enHarrison);
  tlight t3(L3, S3|S2, tugreen, 1'b0, tuyellow, Clock, Reset, enHarrison);

  always_ff @(posedge Clock)
    begin
    if (!Reset)
      begin
      load = 0;
      greendecr = 0;
      yellowdecr = 0;
      enFourth = 0;
      enHarrison = 0;
      State <= FLASH;
      end
    else
      begin
      case(State)
        HARRISON:
          begin
            if(load)
              load = 0;
            else
              begin
              if(tugreen)
                begin
                greendecr = 0;
                greenval = nbgreen;
                load = 1;
                yellowdecr = 1;
                end
              else if(tuyellow)
                begin
                yellowdecr = 0;
                load = 1;
                greendecr = 1;
                enFourth = 1;
                enHarrison = 0;
                State <= Next;
                end
              end
          end
        FOURTH:
          begin
            enHarrison = 0;
            if(load)
              begin
              load = 0;
              end
            else
              begin
              //NOTE: this only matters if we just came
              //out of reset
              greendecr = 1;
              if(tugreen && !keepfourth)
                begin
                greendecr = 0;
                greenval = ewgreen;
                load = 1;
                yellowdecr = 1;
                end
              else if (tuyellow)
                begin
                yellowdecr = 0;
                greendecr = 1;
                load = 1;
                enHarrison = 1;
                enFourth = 0;
                State <= Next;
                end
              end
          end
        FLASH:
          begin
            greenval = nbgreen;
            load = 1;
            enFourth = 1;
            enHarrison = 1;
            State <= Next;
          end
      endcase
      end //if reset
  end //always

  always_comb
    begin
    Next = State;
    case (State)
      FOURTH: Next = HARRISON;
      HARRISON: Next = FOURTH;
      FLASH: Next = FOURTH;
    endcase
    end
endmodule

module tlight(light, sensor, tugreen, keepgreen, tuyellow, clk, reset, enable);
  output logic [1:0] light;
  input sensor, keepgreen;
  input clk, reset, tugreen, tuyellow, enable ;

  enum bit [2:0] {FLASH = 3'b000,
                    GREEN = 3'b001,
                    YELLOW = 3'b010,
                    RED = 3'b100} State, Next;

  always_ff @(posedge clk, negedge reset)
    begin
    if (!reset) State <= FLASH;
    else if(enable) State <= Next;
  end

  always_comb
    begin
    Next = State;
    case (State)
      RED: Next = GREEN;
      GREEN: if (tugreen && !keepgreen) Next = YELLOW;
      YELLOW: if (tuyellow) Next = RED;
      FLASH: Next = RED;
    endcase
    end

    //(01, 10, 11 for green, yellow, red)
    always_comb
      begin
      light = 2'b00;
      case (State)
        FLASH: light = 2'b00;
        GREEN: light = 2'b01;
        YELLOW: light = 2'b10;
        RED: light = 2'b11;
      endcase
      end
endmodule
