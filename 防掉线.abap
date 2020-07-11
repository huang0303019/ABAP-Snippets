DATA : text TYPE string,
       time TYPE i.
time = 0.
ls_text = 'Please open another session for working!'
DO.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = time
      text       = sy-index
    EXCEPTIONS
      OTHERS     = 1.
  time = time + 1.
  IF time = 999.
    time = 0.
  ENDIF.
  WAIT UP TO 30 SECONDS.
ENDDO.