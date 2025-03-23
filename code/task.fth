\ === TASK.FTH ===

\ Definitions and tools for defining tasks on the FMS

\ Code for testing menu display

MENU-CREATE MY-TEST-MENU
MY-TEST-MENU MENU-CLEAR

: TEST-XT
    6 6 AT-XY
    S" HI!" TYPE
;

: TEST-MENU-CREATE
    ['] TEST-XT S" TEXT" S" LABEL" MY-TEST-MENU 0 2 MENU-ADD-OPTION
;

\ Build the menu
TEST-MENU-CREATE


: TASK-INIT                         ( -- )
    TID-TASK-INIT P-STOP            (  )
    \ erase the ok message
    2 1 1 ERASE-DISPLAY-LINE        (  )
    \ start managing the FMS
    \ MY-TEST-MENU  MENU-SHOW         (  )
    MY-TEST-MENU 0 0 MENU-ITEM-SHOW
    MY-TEST-MENU 0 1 MENU-ITEM-SHOW
    MY-TEST-MENU 0 2 MENU-ITEM-SHOW
    MY-TEST-MENU 0 3 MENU-ITEM-SHOW
    MY-TEST-MENU 0 4 MENU-ITEM-SHOW
    MY-TEST-MENU 0 5 MENU-ITEM-SHOW
    MY-TEST-MENU 1 0 MENU-ITEM-SHOW
    MY-TEST-MENU 1 1 MENU-ITEM-SHOW
    MY-TEST-MENU 1 2 MENU-ITEM-SHOW
    MY-TEST-MENU 1 3 MENU-ITEM-SHOW
    MY-TEST-MENU 1 4 MENU-ITEM-SHOW
\    MY-TEST-MENU 1 5 MENU-ITEM-SHOW  garbage here
    PARK-CURSOR
;


\ Start the TASK one time initialization timer
TID-TASK-INIT 100 P-TIMER TASK-INIT
