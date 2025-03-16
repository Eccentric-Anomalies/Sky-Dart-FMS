( === BUTTONS.FTH === )

( LANDING LIGHT LOGIC )
: HANDLE-LIGHT-BUTTON 
    MASK-BUTTON-STATE AND IF 1 ELSE 0 THEN     ( 1 if STATE-MASK is set, 0 otherwise )
    PORT-LANDING-LIGHT OUT                ( send directly to the light )
    ;
PORT-BUTTON-LANDING-LIGHT 0 LISTEN HANDLE-LIGHT-BUTTON ( Listen for the light button )
