\ === task_globals.fth ===
\
\ Global variables for sharing data between tasks
\


\ Global task pointers 
\ If a task needs a reference to a task structure that is 
\ defined later in the interpretation, place a reference
\ to it here after it is created.
VARIABLE task_main_addr
VARIABLE t_diag_addr


