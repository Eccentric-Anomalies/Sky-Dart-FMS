CR
.( AMC Sky Dart System Software v0.0.2)
CR

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
\ UI tasks (order is IMPORTANT!)
INCLUDE task_chron.fth
INCLUDE task_main.fth
\ Simple IO Processing
INCLUDE buttons.fth


\ load any user code present
: LDUSER S" user.fth" INCLUDED ;
LDUSER
