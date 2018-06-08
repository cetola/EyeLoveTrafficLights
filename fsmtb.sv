`timescale 1s / 1ms

`include "defs.sv"

  module fsmtb();
  //default to 1Hz
  parameter CLOCK_CYCLE  = 2;
  parameter CLOCK_WIDTH  = CLOCK_CYCLE/2;
  parameter IDLE_CLOCKS  = 4;

  bit Clock, Reset, S1, S2, S3;
  logic [1:0] L1, L2, L3;

  integer log;
  int err_count;
  int log_count;
  color c;

  fsm controller(Clock, Reset, S1, S2, S3, L1, L2, L3);

  initial
    begin
    //open log file
    log = $fopen("traffic.log");
    $display(">>>>>Begin fsm testbench");
    //debugging
    `ifdef DEBUG_MON
      $fdisplay(log, "\t\tS1\tS2\tS3\tL1\tL2\tL3\tClock\tReset");
      $fmonitor(log, "\t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t", S1, S2, S3, L1, L2, L3, Clock, Reset);
    `endif
    end

  //free running clock
  initial
    begin
    Clock = TRUE;
    forever #CLOCK_WIDTH Clock = ~Clock;
    end


  initial
    begin
    Reset = FALSE;
    repeat (IDLE_CLOCKS) @(negedge Clock);
    Reset = TRUE;
    end

    //----------------------------------------------------
    // Main Tests
    //
    // ===TESTS===
    // 1. ALL SENSORS ON THEN ALL SENSORS OFF
    // 2. RESET HIGH THEN LOW
    // 3. CONFIRM 4TH STAYS GREEN WHEN NO HARRISON SENSOR
    // 4. CONFIRM HARRISON TURNS RED EVEN IF NO 4TH SENSOR
    //----------------------------------------------------

    initial
    begin
    repeat (1) @(negedge Clock); // Reset false, sensors all 0
    repeat (1) @(negedge Clock); {S1,S2,S3} = 3'b111;   // Reset true, turn on sensors

    //----------------------------------------
    // ALL SENSORS
    //----------------------------------------

    //1 - 4th
    repeat (4) @(negedge Clock); log_err(RED, RED, RED); $fdisplay(log, "ALL SENSORS HIGH");
    repeat (45) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (1) @(negedge Clock); log_err(YELLOW, RED, RED);
    repeat (4) @(negedge Clock); log_err(YELLOW, RED, RED);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);
    //5 - Harrison
    repeat (1) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (14) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (1) @(negedge Clock); log_err(RED, YELLOW, YELLOW);
    repeat (4) @(negedge Clock); log_err(RED, YELLOW, YELLOW);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);
    //10 - 4th
    repeat (1) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (44) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (1) @(negedge Clock); log_err(YELLOW, RED, RED);
    repeat (4) @(negedge Clock); log_err(YELLOW, RED, RED);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);
    //15 - Harrison
    repeat (1) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (14) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (1) @(negedge Clock); log_err(RED, YELLOW, YELLOW);{S1,S2,S3} = 3'b000; //sensors off
    repeat (4) @(negedge Clock); log_err(RED, YELLOW, YELLOW);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);
    //20 - 4th
    repeat (1) @(negedge Clock); log_err(GREEN, RED, RED); $fdisplay(log, "ALL SENSORS LOW");
    repeat (44) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (1) @(negedge Clock); log_err(YELLOW, RED, RED);
    repeat (4) @(negedge Clock); log_err(YELLOW, RED, RED);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);
    //25 - Harrison
    repeat (1) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (14) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (1) @(negedge Clock); log_err(RED, YELLOW, YELLOW);
    repeat (4) @(negedge Clock); log_err(RED, YELLOW, YELLOW);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);
    //30 - 4th
    repeat (1) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (44) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (1) @(negedge Clock); log_err(YELLOW, RED, RED);
    repeat (4) @(negedge Clock); log_err(YELLOW, RED, RED);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);
    //35 - Harrison
    repeat (1) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (14) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (1) @(negedge Clock); log_err(RED, YELLOW, YELLOW);
    repeat (4) @(negedge Clock); log_err(RED, YELLOW, YELLOW);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);

    //----------------------------------------
    // RESET - LOW
    //----------------------------------------

    repeat (1) @(negedge Clock); Reset = FALSE; $fdisplay(log, "RESET LOW");
    repeat (1) @(negedge Clock); log_err(FLASH, FLASH, FLASH);
    repeat (10) @(negedge Clock); log_err(FLASH, FLASH, FLASH);

    //----------------------------------------
    // RESET - HIGH
    //----------------------------------------

    repeat (1) @(negedge Clock); Reset = TRUE; $fdisplay(log, "RESET HIGH");
    repeat (2) @(negedge Clock); log_err(RED, RED, RED);


    //----------------------------------------
    // 4TH STAYS GREEN WHEN NO HARRISON SENSOR
    //----------------------------------------

    repeat (1) @(negedge Clock); log_err(GREEN, RED, RED); {S1,S2,S3} = 3'b100; $fdisplay(log, "4th MUST STAY GREEN");
    repeat (46) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (20) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (20) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (20) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (20) @(negedge Clock); log_err(GREEN, RED, RED);
    repeat (20) @(negedge Clock); log_err(GREEN, RED, RED);

    //----------------------------------------
    // HARRISON TURNS RED EVEN IF NO 4TH SENSOR
    //----------------------------------------

    repeat (1) @(negedge Clock); log_err(GREEN, RED, RED); {S1,S2,S3} = 3'b011;  $fdisplay(log, "HARRISON MUST TURN RED");
    repeat (5) @(negedge Clock); log_err(YELLOW, RED, RED);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);
    repeat (1) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (14) @(negedge Clock); log_err(RED, GREEN, GREEN);
    repeat (1) @(negedge Clock); log_err(RED, YELLOW, YELLOW);
    repeat (4) @(negedge Clock); log_err(RED, YELLOW, YELLOW);
    repeat (1) @(negedge Clock); log_err(RED, RED, RED);$fdisplay(log, "END");
    $fclose(log);
    $display(">>>>>There were %d errors.", err_count);
    $display(">>>>>End fsm testbench");
    $stop;
    end

    function automatic void log_err(
      input bit [1:0] EL1,
      input bit [1:0] EL2,
      input bit [1:0] EL3);
      log_count++;
      if(L1 !== EL1 || L2 !== EL2 || L3 !== EL3)
        begin
        err_count++;
        $fdisplay(log, "ERR%d: expected %b %b %b got %b %b %b", err_count, EL1, EL2, EL3, L1, L2, L3);
        end
      else
        $fdisplay(log, "check count: %d", log_count);
    endfunction
endmodule
