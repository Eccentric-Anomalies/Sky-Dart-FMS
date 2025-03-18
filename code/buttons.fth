\ === BUTTONS.FTH ===

\ Listeners and words for connecting button inputs with simple outputs

\ LANDING LIGHT
: HANDLE-LIGHT-BUTTON                           ( raw-event )
    MASK-BUTTON-STATE AND IF 1 ELSE 0 THEN      ( 1 | 0 )
    PORT-LANDING-LIGHT OUT                      (  )
;

\ Listen for state change on the landing light button
PORT-BUTTON-LANDING-LIGHT 0 LISTEN HANDLE-LIGHT-BUTTON
