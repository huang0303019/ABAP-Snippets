*&---------------------------------------------------------------------*
*& 包含               ZBPCR_013_TOP
*&---------------------------------------------------------------------*
TYPES :BEGIN OF ty_alv,
         zyxt           TYPE /bic/azbpcdt0172-/bic/zyxt,  "源系统
         zcompany       TYPE /bic/azbpcdt0172-/bic/zcompany,  "公司代码
         zcust_vendor   TYPE char10,    "客户/供应商
         zid_num        TYPE /bic/azbpcdt0172-/bic/zid_num,     "证件号码
         zname          TYPE char80,    "客户/供应商描述
         zsfyx_c        TYPE /bic/azbpcdt0172-/bic/zsfyx_c,
         zsfyx          TYPE char10,
         zpcompany      TYPE /bic/azbpcdt0172-/bic/zpcompany,  "ADDED BY CYJ 20200525 贸易伙伴
         zmdm_cust_vend TYPE char10,    "ADD BY CYJ 20200629 MDM集团客户/供应商
         zbox           TYPE c,
         color          TYPE c LENGTH 4,
         light          TYPE c,
         message        TYPE char50.
TYPES :it_colfields TYPE lvc_t_scol,
       END OF ty_alv.

DATA:gt_alv TYPE TABLE OF ty_alv,
     gs_alv TYPE ty_alv.
DATA:gt_del TYPE TABLE OF ty_alv,
     gs_del TYPE ty_alv.


DATA:gt_cust TYPE TABLE OF /bic/azbpcdt0172,
     gs_cust TYPE /bic/azbpcdt0172.

DATA:gt_vendor TYPE TABLE OF /bic/azbpcdt0182,
     gs_vendor TYPE /bic/azbpcdt0182.

DATA:gt_entity TYPE TABLE OF zbpcmap047,
     gs_entity TYPE zbpcmap047.

DATA:
  gv_index TYPE lvc_s_row-index,  "当前选中ALV的行的index
  ok_code  LIKE sy-ucomm,
  ok_save  LIKE sy-ucomm.

DATA:gv_error TYPE c.

"动态SQL变量
DATA:gv_tablename  TYPE string,
     gv_code_field TYPE string,
     gv_mdm_field  TYPE string, "ADD BY CYJ 20200629 MDM集团客户/供应商
     gv_name_field TYPE string.
*     gv_yxt type /bic/azbpcdt0172-/bic/zyxt.
DATA:gv_sql_field TYPE string,
     gv_sql_where TYPE string.

*&---------------------------------------------------------------------*
*&     FIELD-SYMBOLS
*&---------------------------------------------------------------------*
FIELD-SYMBOLS:
  <fs_alv>    TYPE ty_alv.

*&---------------------------------------------------------------------*
*      OO ALV OBJECT
*&---------------------------------------------------------------------*
DATA:
  gt_fieldcat_9000 TYPE lvc_t_fcat,
  gt_exclude       TYPE ui_functions,
  gt_sort          TYPE  lvc_t_sort,
  gs_stbl          TYPE lvc_s_stbl,
  gs_layout        TYPE lvc_s_layo,
  gs_variant       TYPE disvariant,
  zcl_grid_9000    TYPE REF TO cl_gui_alv_grid,
  zcl_ctnr_9000    TYPE REF TO cl_gui_custom_container,
  gt_fcode         TYPE STANDARD TABLE OF sy-ucomm,
  gs_colfields     TYPE lvc_s_scol.

*-----------------------------------------------------------------------
*       OO ALV CLASS
*-----------------------------------------------------------------------
*----------------------------------------------------------------------*
*       CLASS ZCL_EVENT9000 DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_event9000 DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_toolbar_9000
                  FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      handle_user_command_9000
                  FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
    "Data in the Output Table was Updated.
*      data_changed_finished_9000
*                  FOR EVENT data_changed_finished OF cl_gui_alv_grid
*        IMPORTING e_modified et_good_cells.

ENDCLASS. "alv_event DEFINITION

*----------------------------------------------------------------------*
*       CLASS ZCL_EVENT9000 IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_event9000 IMPLEMENTATION.
  METHOD handle_toolbar_9000.
    PERFORM frm_set_toolbar_9000 USING e_object.
  ENDMETHOD.                    "handle_toolbar
*
  METHOD handle_user_command_9000.
    PERFORM frm_user_command_9000 USING e_ucomm.
  ENDMETHOD.                    "handle_user_command

  "Data in the Output Table was Updated.
*  METHOD data_changed_finished_9000.
*    PERFORM frm_data_changed_finished_9000 USING e_modified et_good_cells.
*  ENDMETHOD.

ENDCLASS. "alv_event IMPLEMENTATION

*-----------------------------------------------------------------------
*       OO ALV CLASS EVENT
*-----------------------------------------------------------------------
DATA:
  zcl_event9000   TYPE REF TO zcl_event9000.