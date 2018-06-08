module fsmassertions(Clock, Reset, S1, S2, S3, L1, L2, L3);
input Clock;
input Reset;
input				// sensors for approaching vehicles
	S1,				// Northbound on SW 4th Avenue
	S2,				// Eastbound on SW Harrison Street
	S3;				// Westbound on SW Harrison Street
	
input [1:0]	// outputs for controlling traffic lights (00, 01 11 for green, yellow, red)
	L1,				// light for NB SW 4th Avenue
	L2,				// light for EB SW Harrison Street
	L3;				// light for WB SW Harrison Street
	
parameter
	GREEN  = 2'b01,
	YELLOW = 2'b10,
	RED    = 2'b11;


// assure light outputs alway valid except during reset

property validl1_p;
 @(posedge Clock)
 	disable iff (Reset)
   (!($isunknown(L1)));
endproperty
validl1_a: assert property(validl1_p) else $error("L1 is unknown or tri-state");

property validl2_p;
 @(posedge Clock)
 	disable iff (Reset)
   !$isunknown(L2);
endproperty
validl2_a: assert property(validl2_p) else $error("L2 is unknown or tri-state");

property validl3_p;
 @(posedge Clock)
 	disable iff (Reset)
   !$isunknown(L3);
endproperty
validl3_a: assert property(validl3_p) else $error("L3 is unknown or tri-state");
	
// assure that L2 always same as L3

property l2samel3_p;
 @(posedge Clock)
 	disable iff (Reset)
   (L2 == L3);
endproperty
l2samel3_a: assert property(l2samel3_p) else $error("L2 should always be same as L3");


// assure that if one light is yellow the other must be red
// more sophisticated: use a variable!

property yellow1red23_p;
 @(posedge Clock)
 	disable iff (Reset)
   (L1 == YELLOW)  |-> (L2 == RED) && (L3 == RED);
endproperty
yellow1red23_a: assert property(yellow1red23_p) else $error("L2 and L3 should be RED when L1 is YELLOW");

property yellow2red1_p;
 @(posedge Clock)
 	disable iff (Reset)
   (L2 == YELLOW)  |-> (L1 == RED);
endproperty
yellow2red1_a: assert property(yellow2red1_p) else $error("L1 should be RED when L2 is YELLOW");

property yellow3red1_p;
 @(posedge Clock)
 	disable iff (Reset)
   (L3 == YELLOW)  |-> (L1 == RED) ;
endproperty
yellow3red1_a: assert property(yellow3red1_p) else $error("L1 should be RED when L3 is YELLOW");



// assure that if one light is green the other must be red
// more sophisticated: use a variable!

property green1red23_p;
 @(posedge Clock)
 	disable iff (Reset)
   (L1 == GREEN)  |-> (L2 == RED) && (L3 == RED);
endproperty
green1red23_a: assert property(green1red23_p) else $error("L2 or L3 not RED when L1 is GREEN");

property green2red1_p;
 @(posedge Clock)
 	disable iff (Reset)
   (L2 == GREEN)  |-> (L1 == RED);
endproperty
green2red1_a: assert property(green2red1_p) else $error("L1 not RED when L2 is GREEN");

property green3red1_p;
 @(posedge Clock)
 	disable iff (Reset)
   (L3 == GREEN)  |-> (L1 == RED);
endproperty
green3red1_a: assert property(green3red1_p) else $error("L1 not RED when L3 is GREEN");



// check correct EW green to yellow to red sequence

property ewgreenduration_p;
 @(posedge Clock)
	disable iff (Reset)
   (L3 == RED) ##1 (L3 == GREEN)  |=>  
   	(L3 == GREEN) [*14] ##1 (L3 == YELLOW) ;
endproperty
ewgreenduration_a: assert property(ewgreenduration_p) else $error("EW GREEN duration incorrect");

property ewyellowduration_p;
 @(posedge Clock)
	disable iff (Reset)
   (L3 == GREEN) ##1 (L3 == YELLOW)  |=>  
   	(L3 == YELLOW) [*4] ##1 (L3 == RED) ;
endproperty
ewyellowduration_a: assert property(ewyellowduration_p) else $error("EW YELLOW duration incorrect");

property ewredduration_p;
 @(posedge Clock)
	disable iff (Reset)
   (L3 == YELLOW) ##1 (L3 == RED)  |=>  
   	(L3 == RED) [*44]  ;
endproperty
ewredduration_a: assert property(ewredduration_p) else $error("EW RED duration incorrect");



property nsgreenduration_p;
 @(posedge Clock)
	disable iff (Reset)
   (L1 == RED) ##1 (L1 == GREEN)  |=>  
   	(L1 == GREEN) [*44] ##1 ((($past(S1) && ~$past(S2) && ~$past(S3)) && (L1 == GREEN))[*0:$])  ##1 (L1 == YELLOW) ;
endproperty
nsgreenduration_a: assert property(nsgreenduration_p) else $error("NS GREEN duration incorrect");


property nsyellowduration_p;
 @(posedge Clock)
	disable iff (Reset)
   (L1 == GREEN) ##1 (L1 == YELLOW)  |=>  
   	(L1 == YELLOW) [*4] ##1 (L1 == RED) ;
endproperty
nsyellowduration_a: assert property(nsyellowduration_p) else $error("NS YELLOW duration incorrect");


property nsreddurationstrict_p;
 @(posedge Clock)
	disable iff (Reset)
   (L1 == YELLOW) ##1 (L1 == RED)  |=>  
   	(L1 == RED) [*(15+5+1)] ##1 (L1 == GREEN) ;
endproperty
nsreddurationstrict_a: assert property(nsreddurationstrict_p) else $error("NS RED duration incorrect");



endmodule





module test;

reg Clock;
reg Reset;
reg S1, S2, S3;
wire [1:0] L1, L2, L3;

fsm  f0(Clock, Reset, S1, S2, S3, L1, L2, L3);
bind fsm fsmassertions fsma(Clock, Reset, S1, S2, S3, L1, L2, L3);

initial
begin
Clock = 1;
forever #(5) Clock = ~Clock;
end


initial
begin

Reset = 1;
repeat (2) @(negedge Clock);
Reset = 0;
S1 = 0; S2 = 0; S3 = 0;
repeat (200) @(negedge Clock);
S1 = 1; S2 = 0; S3 = 0;
repeat (100) @(negedge Clock);
S1 = 1; S2 = 1; S3 = 0;
repeat (100) @(negedge Clock);
S1 = 0; S2 = 0; S3 = 0;
repeat (100) @(negedge Clock);


Reset = 1;
repeat (2) @(negedge Clock);
Reset = 0;
S1 = 1; S2 = 1; S3  = 0;
repeat (200) @(negedge Clock);
*/
$finish();
end


endmodule


