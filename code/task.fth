\ === TASK.FTH ===
\
\ Utilities for managing the creation and display of FMS UI tasks
\
\ task_create   allocates and initializes a task definition structure
\ Usage: period poll-xt init-xt task_create taskname    ( <name> period-msec poll-xt init-xt -- )
\           simply execute taskname to obtain address of the struct
\
\ task_start    initialize and start the UI task        ( task-addr -- )
\ Usage: taskname task_start
\

\ Constants
SYSTEM_CELL_SIZE 3 * CONSTANT TASK_STRUCT_SIZE
0 CONSTANT TASK_INIT
SYSTEM_CELL_SIZE CONSTANT TASK_POLL
TASK_POLL SYSTEM_CELL_SIZE + CONSTANT TASK_ORIG

\ Definitions and tools for defining UI tasks on the FMS
VARIABLE task_current_xt        \ current task poll xt

\ Global task pointers 
VARIABLE task_main_addr
VARIABLE t_diag_addr




\ Initialize variables
0 task_current_xt !

\ FMS task poll handler executes poll for current task, if any
\
: task_poll                      ( -- )
    task_current_xt @ 0<> IF            (  )
        task_current_xt @ EXECUTE       (  )
    THEN
;

\ Stop task polling and call the task init
\
: task_init                         ( init-xt -- )
    task_current_xt @ 0<> IF        ( init-xt )
        0 task_current_xt !         ( init-xt )
    THEN
    EXECUTE                         (  )
; 

\ Create a task definition - will create an executable <name>
\ <name> points to three cell block: init-xt, poll-xt, orig-task
\
: task_create                   ( <name> poll-xt init-xt -- )
    CREATE                      ( poll-xt init-xt )
    , ,                         (  )
    0 ,                         (  )
;

\ Get task init-xt
\
: task_get_init                 ( task-addr -- xt )
    TASK_INIT + @               ( xt )
;

\ Get task poll-xt
\
: task_get_poll                 ( task-addr -- xt )
    TASK_POLL + @               ( xt )
;

\ Set task orig-addr
\
: task_set_orig                 ( orig-addr task-addr -- )
    TASK_ORIG + !               (  )
;

\ Get task orig-addr
\
: task_get_orig                 ( task-addr -- orig-addr )
    TASK_ORIG + @
;

\ Set the task polling xt and begin polling
\ arguments: origin task, new task
\
: task_start                    ( orig-addr task-addr -- )
    DUP task_get_init           ( orig-addr task-addr init-xt )
    task_init                   ( orig-addr task-addr )
    DUP task_get_poll           ( orig-addr task-addr poll-xt )
    task_current_xt !           ( orig-addr task-addr )
    task_set_orig               (  )
;

\ Start the poll timer
TID_TASK_POLL 250 P-TIMER task_poll