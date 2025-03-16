CR
.( AMC Sky Dart System Software v0.0.2)
CR

\ To execute the Sky Dart system in USER SPACE, place sources in:
\ <user>/AppData/Roaming/Eccentric Anomalies/Tungsten Moon
\

\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\ IMPORTANT: When executing in USER SPACE, comment out the following lines

\ leave the ability to erase the built-in code
MARKER RESET-SYSTEM

INCLUDE spacecraft/computer/forth_sources/iomap.fth
INCLUDE spacecraft/computer/forth_sources/clock.fth
INCLUDE spacecraft/computer/forth_sources/fms.fth
INCLUDE spacecraft/computer/forth_sources/buttons.fth

\ load any user code present
: LDUSER S" user.fth" INCLUDED ;
LDUSER

\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\\ IMPORTANT: When executing in USER SPACE, un-comment the following lines

\ RESET-SYSTEM         \ only if fully replacing stock system software

\ INCLUDE iomap.fth
\ INCLUDE clock.fth
\ INCLUDE fms.fth
\ INCLUDE buttons.fth
\ INCLUDE your own forth sources

PAGE        ( clear the screen )
