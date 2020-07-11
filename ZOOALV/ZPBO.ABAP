*&---------------------------------------------------------------------*
*& 包含               ZBPCR_013_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  9000_PBO_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 9000_pbo_status OUTPUT.
*  IF p_disp IS NOT INITIAL.
*    APPEND 'SAVE' TO  gt_fcode.
*  ELSE.
*    CLEAR gt_fcode.
*  ENDIF.

  SET PF-STATUS '9000' EXCLUDING gt_fcode.
  SET TITLEBAR '9000'.

ENDMODULE.                 " 9000_PBO_STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  9000_PBO_ALV_OUTPUT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 9000_pbo_alv_output OUTPUT.
*  IF zcl_ctnr_9000 IS INITIAL.
*    CREATE OBJECT zcl_ctnr_9000
*      EXPORTING
*        container_name              = 'ZCONTAINER_9000'
*      EXCEPTIONS
*        cntl_error                  = 1
*        cntl_system_error           = 2
*        create_error                = 3
*        lifetime_error              = 4
*        lifetime_dynpro_dynpro_link = 5
*        OTHERS                      = 6.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*  ENDIF.

  IF zcl_grid_9000 IS INITIAL.

    CREATE OBJECT zcl_grid_9000
      EXPORTING
        i_parent = cl_gui_container=>default_screen. "全屏，不用画控件

    CREATE OBJECT zcl_event9000.
    SET HANDLER zcl_event9000->handle_user_command_9000 FOR zcl_grid_9000.
    SET HANDLER zcl_event9000->handle_toolbar_9000      FOR zcl_grid_9000.
*    SET HANDLER zcl_event9000->data_changed_finished_9000      FOR zcl_grid_9000.

    CALL METHOD zcl_grid_9000->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

    CALL METHOD zcl_grid_9000->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

    gs_variant-report = sy-cprog.
    CALL METHOD zcl_grid_9000->set_table_for_first_display
      EXPORTING
        i_save                        = 'A'
        i_buffer_active               = 'X'
        is_variant                    = gs_variant
        it_toolbar_excluding          = gt_exclude
        is_layout                     = gs_layout
      CHANGING
        it_outtab                     = gt_alv
        it_fieldcatalog               = gt_fieldcat_9000
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

    CALL METHOD cl_gui_cfw=>flush.

  ELSE.

    CALL METHOD zcl_grid_9000->refresh_table_display
      EXPORTING
        is_stable      = gs_stbl
        i_soft_refresh = 'X'.
  ENDIF.


ENDMODULE.                 " 9000_PBO_ALV_OUTPUT  OUTPUT