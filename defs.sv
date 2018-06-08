`ifndef DEFS_IMPORT
`define DEFS_IMPORT

    package defs;

    typedef	enum {FALSE, TRUE} bool_t;

    //(00, 01, 10, 11 for flash, green, yellow, red)
    typedef enum bit [1:0] {
      FLASH = 2'b00,
      GREEN = 2'b01,
      YELLOW = 2'b10,
      RED = 2'b11
      } color;

    endpackage

  import defs::*;

`endif
