\ === TASK.FTH ===

\ Definitions and tools for defining tasks on the FMS

\ Code for testing menu display

MENU-CREATE MY-TEST-MENU

: TEST-XT
    S" HI!" TYPE
;


' TEST-XT S" TEXT" S" LABEL" MY-TEST-MENU 0 2 MENU-ADD-OPTION
