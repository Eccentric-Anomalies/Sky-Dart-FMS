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
TASK_POLL SYSTEM_CELL_SIZE + CONSTANT TASK_PERIOD

\ Definitions and tools for defining UI tasks on the FMS
VARIABLE task_current_xt        \ current task poll xt


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
: task_init 		( init-xt -- )
    task_current_xt @ 0<> IF        ( init-xt )
        TID_TASK_POLL P-STOP        ( init-xt )
        0 task_current_xt !         (  )
    THEN
	execute                         (  )
; 

\ Create a task definition - will create an executable <name>
\ <name> points to three cell block: init-xt, poll-xt, period-msec
\
: task_create                   ( <name> period-msec poll-xt init-xt -- )
    CREATE                      ( period-msec poll-xt init-xt )
    TASK_STRUCT_SIZE ALLOT      ( period-msec poll-xt init-xt )
    , , ,                       (  )
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

\ Get task poll period
\
: task_get_period               ( task-addr -- period )
    TASK_PERIOD + @             ( period )
;

\ Set the task polling xt and begin polling
\
: task_start                    ( task-addr -- )
    DUP task_get_init           ( task-addr init-xt )
    task_init                   ( task-addr )
    DUP task_get_poll           ( task-addr poll-xt )
    task_current_xt !           ( task-addr )
    task_get_period             ( period-msec )
    TID_TASK_POLL SWAP          ( tid period-msec )
    P-TIMER task_poll           (  )
;
