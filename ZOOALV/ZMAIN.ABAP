************************************************************************
* 功能描述: 非直连公司客商填报
* 开发作者: 黄凌烽
* 开发日期: 2020.04.07
* 实现技术: OOALV
*
* 变更记录
*  修改日期   开发人员   描述
*----------------------------------------------------------------------*
*
************************************************************************
REPORT zbpcr_013.

TABLES:/bic/azbpcdt0172.
************************************************************************
* Parameters and Selection Options
************************************************************************
"基本选择
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
PARAMETERS p_cust  RADIOBUTTON GROUP  g1 USER-COMMAND flag1 DEFAULT 'X'.
PARAMETERS p_vendor  RADIOBUTTON GROUP  g1 .
SELECTION-SCREEN END OF BLOCK b1.

"功能选择
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
PARAMETERS p_view  RADIOBUTTON GROUP  g2 USER-COMMAND flag2 DEFAULT 'X'.
PARAMETERS p_insert  RADIOBUTTON GROUP  g2 .
PARAMETERS p_change  RADIOBUTTON GROUP  g2 .
SELECTION-SCREEN END OF BLOCK b2.

"数据筛选
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03.

*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS:p_sg TYPE c RADIOBUTTON GROUP g3  MODIF ID m2 DEFAULT 'X'.  "手工
*SELECTION-SCREEN COMMENT 5(5) TEXT-R01 FOR FIELD p_sg MODIF ID m2.
*PARAMETERS:p_mdm TYPE c RADIOBUTTON GROUP g3 MODIF ID m2.           "MDM
*SELECTION-SCREEN COMMENT 20(5) TEXT-R02 FOR FIELD p_mdm MODIF ID m2.
*SELECTION-SCREEN END OF LINE.

PARAMETERS:p_yxt   TYPE /bic/azbpcdt0082-/bic/zyxt AS LISTBOX VISIBLE LENGTH 10 MODIF ID m2. "源系统

SELECT-OPTIONS:s_bukrs FOR /bic/azbpcdt0172-/bic/zcompany MODIF ID m1,"公司代码
                      s_id FOR /bic/azbpcdt0172-/bic/zid_num MODIF ID m1,"证件号码
                      s_code FOR /bic/azbpcdt0172-/bic/zcustomer MODIF ID m1."证件号码
SELECTION-SCREEN END OF BLOCK b3.


************************************************************************
* Includes
************************************************************************
INCLUDE zbpcr_013_top.
INCLUDE zbpcr_013_pbo.
INCLUDE zbpcr_013_pai.
INCLUDE zbpcr_013_frm.


************************************************************************
INITIALIZATION.
************************************************************************
  "refresh_table_display 刷新alv
  gs_stbl-row = 'X'.
  gs_stbl-col = 'X'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_yxt.
  PERFORM frm_create_list.

AT SELECTION-SCREEN  OUTPUT.
  LOOP AT SCREEN.
    IF p_insert EQ 'X'.
      IF screen-group1 = 'M1' OR screen-group1 = 'M2'.
        screen-active  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    IF p_view NE 'X' AND screen-group1 = 'M2'.
      screen-active  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

************************************************************************
AT SELECTION-SCREEN.
************************************************************************
************************************************************************
START-OF-SELECTION.
************************************************************************

  PERFORM frm_initial_data.
  PERFORM frm_get_data.     "取数
  PERFORM frm_build_alv_fieldcat.
  PERFORM frm_build_alv_layout.
  PERFORM frm_exclude_tb_functions.

  CALL SCREEN 9000.

************************************************************************
END-OF-SELECTION.
************************************************************************
  FREE: gt_alv,gt_del.