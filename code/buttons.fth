\ === BUTTONS.FTH ===

\ Listeners and words for connecting button inputs with simple outputs

\ LANDING LIGHT
: handle_light_button                           ( raw-event )
    MASK_BUTTON_STATE AND IF 1 ELSE 0 THEN      ( 1 | 0 )
    PORT_LANDING_LIGHT OUT                      (  )
;

\ Listen for state change on the landing light button
PORT_BUTTON_LANDING_LIGHT 0 LISTEN handle_light_button
