\ === MENU.FTH ===
\
\ Utilities for managing the creation and display of FMS function key buttons
\
\ menu_create   allocates a menu definition structure
\ Usage: menu_create mymenuname                     ( <name> -- )
\           simply execute mymenuname to obtain address of the struct
\
\ menu_clear    zeros out menu definition structure
\ Usage: mymenuname menu_clear                      ( addr -- )
\
\ menu_set_item_xt set the XT for a specific function key position (col row)
\ Usage: xt mymenuname col row menu_set_item_xt    ( xt addr col row -- )
\
\ menu_get_Item_xt get the XT for a specific function key position (col row)
\ Usage: mymenuname col row menu_get_Item_xt       ( addr col row -- xt)
\
\ menu_set_item_text set the item text for a specific f key position (col row)
\ Usage: c-addr u mymenuname col row menu_set_item_text    ( c-addr u addr col row -- );
\ 
\ menu_get_item_text get the item text for a specific f key position (col row)
\ Usage: mymenuname col row menu_get_item_text             ( addr col row -- c-addr u )
\
\ menu_set_item_label set the item label for a specific f key position (col row)
\ Usage: c-addr u mymenuname col row menu_set_item_label   ( c-addr u addr col row -- );
\ 
\ menu_get_item_label get the item label for a specific f key position (col row)
\ Usage: mymenuname col row menu_get_item_label            ( addr col row -- c-addr u )
\
\ menu_add_option set up parameters of a single menu item
\ Usage: xt S" ITEM" S" LABEL" mymenuname col row menu_add_option  ( xt t-addr tu l-addr lu m-addr col row -- )
\
\ menu_show display the menu on screen
\ Usage: mymenuname menu_show   ( m-addr -- )

\ Constants
\ Define sizes and offsets of items in a menu definition structure
\ Struct consists of return XT (u), menu name (c-addr u), list of 12 menu items
\ Each menu item consists of XT (u), text (c-addr u), label (c-addr u)
SYSTEM_CELL_SIZE 5 * CONSTANT MENU_ITEM_STRUCT_SIZE
\ Each menu has a menu item for each button
FMS_FN_ROWS 2* CONSTANT MENU_ITEM_QTY          
\ Offset in menu struct for items
0 CONSTANT MENU_ITEMS_OFFSET
\ Offset in an item for XT
0 CONSTANT MENU_ITEM_XT_OFFSET
\ Offset in an item for text
SYSTEM_CELL_SIZE CONSTANT MENU_ITEM_TEXT_OFFSET
\ Offset in an item for label text
SYSTEM_CELL_SIZE 2* MENU_ITEM_TEXT_OFFSET + 
    CONSTANT MENU_ITEM_LABEL_OFFSET
\ So we can define the overall structure size
MENU_ITEM_QTY MENU_ITEM_STRUCT_SIZE * CONSTANT MENU_STRUCT_SIZE

\ Variables
2VARIABLE menu_col_row_scratch
VARIABLE menu_scratch
\ currently displayed menu
VARIABLE menu_current
\ col and row of last fkey pressed
2VARIABLE menu_fkey_col_row

\ initialize current menu to null
0 menu_current !


\ Create a menu definition structure - creates executable <name>
\
: menu_create                   ( <name> -- )
    CREATE                      (  )
    MENU_STRUCT_SIZE ALLOT      (  )
;

\ Clear a menu definition structure
\
: menu_clear                    ( addr -- )
    MENU_STRUCT_SIZE 0          ( addr u b )
    FILL                        (  )
;

\ Utility for printing a horizontal rule
\
: horizontal_rule                (  --  )
    ." ------------------------"
;

\ Utility for printing a horizontal double rule
\
: horizontal_double_rule                (  --  )
    ." ========================"
;

\ Utility for getting address of an item xt
\
: menu_get_item_xt_addr         ( addr col row -- addr )
    SWAP                        ( addr row col )
    FMS_FN_ROWS * +             ( addr u )
    MENU_ITEM_STRUCT_SIZE *     ( addr offset )
    MENU_ITEM_XT_OFFSET +       ( addr offset )
    MENU_ITEMS_OFFSET +         ( addr offset )
    +                           ( addr )
;

\  Set the menu item xt (col row are function key coordinates)
\
: menu_set_item_xt              ( xt addr col row -- )
    menu_get_item_xt_addr       ( xt addr )
    !                           (  )
;

\ Get a menu item xt (col row are function key coordinates)
\
: menu_get_item_xt              ( addr col row -- xt)
    menu_get_item_xt_addr       ( addr )
    @                           ( xt )
;

\ Utility for getting address of an item text
\
: menu_get_item_text_addr       ( addr col row -- addr )
    SWAP                        ( addr row col )
    FMS_FN_ROWS * +             ( addr u )
    MENU_ITEM_STRUCT_SIZE *     ( addr offset )
    MENU_ITEM_TEXT_OFFSET +     ( addr offset )
    MENU_ITEMS_OFFSET +         ( addr offset )
    +                           ( addr )
;

\  Set the menu item text (col row are function key coordinates)
\
: menu_set_item_text            ( c-addr u addr col row -- )
    menu_get_item_text_addr     ( c-addr u addr )
    2!                          (  )
;

\ Get a menu item text (col row are function key coordinates)
\
: menu_get_item_text            ( addr col row -- c-addr u )
    menu_get_item_text_addr     ( addr )
    2@                          ( c-addr u )
;

\ Utility for getting address of an item label
\
: menu_get_item_label_addr      ( addr col row -- addr )
    SWAP                        ( addr row col )
    FMS_FN_ROWS * +             ( addr u )
    MENU_ITEM_STRUCT_SIZE *     ( addr offset )
    MENU_ITEM_LABEL_OFFSET +    ( addr offset )
    MENU_ITEMS_OFFSET +         ( addr offset )
    +                           ( addr )
;

\  Set the menu item label (col row are function key coordinates)
\
: menu_set_item_label           ( c-addr u addr col row -- )
    menu_get_item_label_addr    ( c-addr u addr )
    2!                          (  )
;

\ Get a menu item label (col row are function key coordinates)
\
: menu_get_item_label           ( addr col row -- c-addr u )
    menu_get_item_label_addr    ( addr )
    2@                          ( c-addr u )
;

\ Set a complete menu line in one step 
\
: menu_add_option               ( xt t-addr tu l-addr lu m-addr col row -- )
    2DUP                        ( xt t-addr tu l-addr lu m-addr col row col row -- )
    menu_col_row_scratch 2!     ( xt t-addr tu l-addr lu m-addr col row )
    2 PICK                      ( xt t-addr tu l-addr lu m-addr col row m-addr )
    menu_scratch !              ( xt t-addr tu l-addr lu m-addr col row )
    menu_set_item_label         ( xt t-addr tu )
    menu_scratch @              ( xt t-addr tu m-addr )
    menu_col_row_scratch 2@     ( xt t-addr tu m-addr col row )
    menu_set_item_text          ( xt )
    menu_scratch @              ( xt m-addr )
    menu_col_row_scratch 2@     ( xt m-addr col row )
    menu_set_item_xt            (  )
;

\ Utility for displaying a single menu item text
\
: menu_item_text_show           ( m-addr col row  -- )
    2DUP                        ( m-addr col row col row )
    menu_col_row_scratch 2!     ( m-addr col row )
    menu_get_item_text          ( c-addr u )
    menu_col_row_scratch 2@     ( c-addr u col row )
    fms_set_fkey_text           (  )
;

\ Utility for displaying a single menu item label
\
: menu_item_label_show          ( m-addr col row  -- )
    2DUP                        ( m-addr col row col row )
    menu_col_row_scratch 2!     ( m-addr col row )
    menu_get_item_label         ( c-addr u )
    menu_col_row_scratch 2@     ( c-addr u col row )
    fms_set_fkey_label          (  )
;

\ Display a complete menu on the screen
\
: menu_show                             ( m-addr -- )
    DUP menu_current !                  ( m-addr )
    2 0 DO                              ( m-addr )
        6 0 DO                          ( m-addr )
            DUP                         ( m-addr m-addr )
            J I menu_item_text_show     ( m-addr )
            DUP                         ( m-addr m-addr )
            J I menu_item_label_show    ( m-addr )
        LOOP                            ( m-addr )
    LOOP                                ( m-addr )
    DROP                                (  )
;



\ Given the raw FMS function key event, execute the corresponding
\ execution token, if any
\
: handle_fms_function                   ( raw-event -- )
    menu_current @ SWAP                 ( m-addr raw-event )
    fms_key_event_to_col_row            ( m-addr col row )
    2DUP menu_fkey_col_row 2!           ( m-addr col row )
    menu_get_item_xt                    ( xt )
    DUP 0<> IF                          ( xt )
        EXECUTE                         (  )
    ELSE                                ( xt )
        DROP                            (  )
    THEN
;


\ FMS button handler
\
: menu_handle_button                     ( raw-event -- )
    DUP                                 ( raw-event raw-event )
    MASK_FMS_KEYGROUP AND               ( raw-event key-group )
    MASK_FMS_KEYPAD <> IF               ( raw-event)
        handle_fms_function             (  )
    ELSE
        fms_handle_keypad               (  )
    THEN
    fms_park_cursor
;

\ Listen for all button press events on the FMS
PORT_BUTTON_FMS 0 LISTEN menu_handle_button
