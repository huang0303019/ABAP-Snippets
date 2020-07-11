*&---------------------------------------------------------------------*
*& 包含               ZBPCR_013_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  9000_PAI_EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 9000_pai_exit_command INPUT.
  ok_save = ok_code.
  CLEAR ok_code.

  CASE ok_save.
    WHEN 'BACK'.
      "可在此做一些清空操作，如解锁操作
      LEAVE TO SCREEN 0.

    WHEN 'END' OR 'EXIT'.
      "可在此做一些清空操作，如解锁操作
      LEAVE PROGRAM.

    WHEN OTHERS.

  ENDCASE.
ENDMODULE.                 " 9000_PAI_EXIT_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  9000_PAI_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 9000_pai_user_command INPUT.
  ok_save = ok_code.
  CLEAR ok_code.

  CASE ok_save.
    WHEN 'BACK'.
      "可在此做一些清空操作，如解锁操作
      LEAVE TO SCREEN 0.

    WHEN 'END' OR 'EXIT'.
      "可在此做一些清空操作，如解锁操作
      LEAVE PROGRAM.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " 9000_PAI_USER_COMMAND  INPUT