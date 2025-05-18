\ To execute the Sky Dart system in USER SPACE, place sources in:
\ <user>/AppData/Roaming/Eccentric Anomalies/Tungsten Moon
\

\ =======================================================================
\ IMPORTANT: COMMENT following line if running this code in USER SPACE

MARKER reset_system

\ =======================================================================
\ IMPORTANT: When executing in USER SPACE, UNCOMMENT the following line
\ to erase the stock operating system code so it can be replaced

\ reset_system 

1 CELLS CONSTANT SYSTEM_CELL_SIZE

INCLUDE version.fth
INCLUDE iomap.fth
INCLUDE clock.fth
INCLUDE fms.fth
INCLUDE menu.fth
INCLUDE task.fth
INCLUDE task_globals.fth
\ UI/menu tasks below: menu leaves first, root last
\ Levels seperated by ----
INCLUDE task_gear.fth
INCLUDE task_padsvc_prop.fth
INCLUDE task_padsvc_gear.fth
\ ----
INCLUDE task_chron.fth
INCLUDE task_padsvc.fth
INCLUDE task_diag.fth
\ ----
INCLUDE task_main.fth
\ Simple IO Processing
INCLUDE buttons.fth


\ load any user code present
: LDUSER S" user.fth" INCLUDED ;
LDUSER
