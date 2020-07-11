*&---------------------------------------------------------------------*
*& 包含               ZBPCR_013_FRM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form FRM_GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_data .
    DATA:   lv_yxt TYPE /bic/azbpcdt0172-/bic/zyxt.
    CONCATENATE '/bic/zyxt AS zyxt'
                             '/bic/zcompany AS zcompany'
                             gv_code_field 'AS zcust_vendor'
                             '/bic/zid_num AS zid_num'
                             gv_name_field 'AS zname'
                             '/bic/zsfyx_c AS zsfyx_c'
                             '/bic/zpcompany AS zpcompany'
                             gv_mdm_field 'AS ZMDM_CUST_VEND'"ADDED BY CYJ 20200629 MDM集团客商编码
    INTO gv_sql_field SEPARATED BY space.
  
    CONCATENATE '/bic/zcompany IN s_bukrs'
                             'AND /bic/zid_num IN s_id'
                             'AND' gv_code_field 'IN s_code'
    INTO gv_sql_where SEPARATED BY space.
  
  
    IF p_yxt <> ''.
      CONCATENATE gv_sql_where
                             'AND /bic/zyxt = p_yxt'
    INTO gv_sql_where SEPARATED BY space.
    ENDIF.
  
    CHECK p_insert NE 'X'.   "手工新增不需要取数
  
    SELECT (gv_sql_field)
        INTO CORRESPONDING FIELDS OF TABLE gt_alv
        FROM (gv_tablename)
        WHERE (gv_sql_where).
  
    LOOP AT gt_alv ASSIGNING <fs_alv>.
      IF <fs_alv>-zsfyx_c = ''.
        <fs_alv>-zsfyx = '有效'.
      ELSEIF <fs_alv>-zsfyx_c = 'X'.
        <fs_alv>-zsfyx = '无效'.
      ENDIF.
    ENDLOOP.
  
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_BUILD_ALV_FIELDCAT
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_build_alv_fieldcat .
    CLEAR gt_fieldcat_9000.
  
    IF p_view NE 'X'.
      PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                                 USING 'ZBOX' TEXT-001  1  '' '' '' '' 'X' 'X' 'X'.
    ELSE.
      PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                                 USING 'ZYXT' TEXT-006  10  '' '' '' '' ' ' '' ''.
      PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                                 USING 'ZSFYX' TEXT-007  10  '' '' '' '' ' ' '' ''.
    ENDIF.
  
    PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                               USING 'ZCOMPANY' TEXT-002  4  '' '' '' '' ' ' '' ''.
    PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                               USING 'ZID_NUM' TEXT-003  60  '' '' '' '' ' ' '' ''.
    IF p_cust = 'X'."ADDED BY CYJ 20200629 描述改为客户、供应商
      PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                                 USING 'ZCUST_VENDOR' TEXT-011  10  '' '' '' '' ' ' '' ''.
    ELSE.
      PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                                 USING 'ZCUST_VENDOR' TEXT-012  10  '' '' '' '' ' ' '' ''.
    ENDIF.
    PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                               USING 'ZNAME' TEXT-005  80  '' '' '' '' ' ' '' ''.
    PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                               USING 'ZPCOMPANY' TEXT-008  4  '' '' '' '' ' ' '' ''.
    IF p_cust = 'X'.
      PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                                 USING 'ZMDM_CUST_VEND' TEXT-012  10  '' '' '' '' ' ' '' ''."ADDED BY CYJ 20200629 MDM集团客商编码
    ELSE.
      PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                                 USING 'ZMDM_CUST_VEND' TEXT-011  10  '' '' '' '' ' ' '' ''."ADDED BY CYJ 20200629 MDM集团客商编码
    ENDIF.
  *  PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
  *                             USING 'LIGHT' TEXT-009  4  '' '' '' '' ' ' '' ''.
    PERFORM fm_append_fieldcat TABLES gt_fieldcat_9000
                               USING 'MESSAGE' TEXT-010  80  '' '' '' '' ' ' '' ''.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *&      Form  FM_APPEND_FIELDCAT
  *&---------------------------------------------------------------------*
  FORM fm_append_fieldcat  TABLES ft_tab TYPE lvc_t_fcat
                            USING  VALUE(fu_filed_name)
                                   VALUE(fu_filed_text)
                                   VALUE(fu_outlen)
                                   VALUE(fu_cref)
                                   VALUE(fu_qref)
                                   VALUE(fu_ref_tab)
                                   VALUE(fu_ref_name)
                                   VALUE(fu_edit)
                                   VALUE(fu_fix_column)
                                   VALUE(fu_checkbox).
  
    DATA lw_fieldcat TYPE lvc_s_fcat.
  
    lw_fieldcat-fieldname = fu_filed_name."字段名
    lw_fieldcat-coltext = fu_filed_text. "列标题
    lw_fieldcat-outputlen = fu_outlen."输出长度
    lw_fieldcat-cfieldname = fu_cref."金额字段参照
    lw_fieldcat-qfieldname = fu_qref."数量字段参照
    lw_fieldcat-ref_table = fu_ref_tab."内部表字段的参考表名称
    lw_fieldcat-ref_field = fu_ref_name."内部表字段的参考表名称
    lw_fieldcat-edit = fu_edit. "可编辑
    lw_fieldcat-fix_column = fu_fix_column."固定列
    lw_fieldcat-checkbox = fu_checkbox. "选择框
  
    IF p_change = 'X'.
      IF lw_fieldcat-fieldname = 'ZID_NUM' OR  lw_fieldcat-fieldname = 'ZNAME'
        OR  lw_fieldcat-fieldname = 'ZPCOMPANY'
        OR  lw_fieldcat-fieldname = 'ZMDM_CUST_VEND'"ADDED BY CYJ 20200629 MDM集团客商编码
        .
        lw_fieldcat-edit = 'X'.
      ENDIF.
    ELSEIF p_insert = 'X'.
      IF lw_fieldcat-fieldname = 'ZCOMPANY' OR  lw_fieldcat-fieldname = 'ZID_NUM'
        OR lw_fieldcat-fieldname = 'ZCUST_VENDOR' OR  lw_fieldcat-fieldname = 'ZNAME'
        OR  lw_fieldcat-fieldname = 'ZPCOMPANY'
        OR  lw_fieldcat-fieldname = 'ZMDM_CUST_VEND'"ADDED BY CYJ 20200629 MDM集团客商编码
        .
        lw_fieldcat-edit = 'X'.
      ENDIF.
    ENDIF.
  
  
    APPEND lw_fieldcat TO ft_tab.
  
  ENDFORM.                    " FM_APPEND_FIELDCAT
  *&---------------------------------------------------------------------*
  *& Form FRM_BUILD_ALV_LAYOUT
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_build_alv_layout .
    gs_layout-zebra = 'X'.  "斑马线
    gs_layout-cwidth_opt = 'X'. "自适应宽度
  *  gs_layout-info_fname = 'COLOR'. "行颜色
  *  gs_layout-ctab_fname = 'IT_COLFIELDS'. "单元格颜色
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_EXCLUDE_TB_FUNCTIONS
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_exclude_tb_functions .
    DATA wa_exclude TYPE ui_func.
    CLEAR: gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_copy .
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row .
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_cut .
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_sort.
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_sort_asc.
    APPEND wa_exclude TO gt_exclude.
  
    CLEAR wa_exclude.
    wa_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc.
    APPEND wa_exclude TO gt_exclude.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_SET_TOOLBAR_9000
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> E_OBJECT
  *&---------------------------------------------------------------------*
  FORM frm_set_toolbar_9000  USING fu_object TYPE REF TO cl_alv_event_toolbar_set.
    DATA lw_toolbar TYPE stb_button.
  
    CHECK p_view NE 'X'.
  
    CLEAR lw_toolbar.
    lw_toolbar-butn_type = 3.
    APPEND lw_toolbar TO fu_object->mt_toolbar.
  
    CLEAR lw_toolbar.
    lw_toolbar-butn_type = 0.
    lw_toolbar-function = 'ALL'.
    lw_toolbar-quickinfo = '全选'.
    lw_toolbar-text = '全选'.
    lw_toolbar-icon  = icon_select_all.
    APPEND lw_toolbar TO fu_object->mt_toolbar.
  
    CLEAR lw_toolbar.
    lw_toolbar-butn_type = 3.
    APPEND lw_toolbar TO fu_object->mt_toolbar.
  
    CLEAR lw_toolbar.
    lw_toolbar-butn_type = 0.
    lw_toolbar-function = 'NOTALL'.
    lw_toolbar-quickinfo = '取消全选'.
    lw_toolbar-text = '取消全选'.
    lw_toolbar-icon  = icon_deselect_all.
    APPEND lw_toolbar TO fu_object->mt_toolbar.
  
    CLEAR lw_toolbar.
    lw_toolbar-butn_type = 3.
    APPEND lw_toolbar TO fu_object->mt_toolbar.
  
    CLEAR lw_toolbar.
    lw_toolbar-butn_type = 0.
    lw_toolbar-function = 'DELETE'.
    lw_toolbar-quickinfo = '删除行'.
    lw_toolbar-text = '删除行'.
    lw_toolbar-icon  =  icon_delete_row.
    APPEND lw_toolbar TO fu_object->mt_toolbar.
  
    IF p_insert = 'X'.
      CLEAR lw_toolbar.
      lw_toolbar-butn_type = 3.
      APPEND lw_toolbar TO fu_object->mt_toolbar.
  
      CLEAR lw_toolbar.
      lw_toolbar-butn_type = 0.
      lw_toolbar-function = 'ADD'.
      lw_toolbar-quickinfo = '增加行'.
      lw_toolbar-text = '增加行'.
      lw_toolbar-icon  =  icon_insert_row.
      APPEND lw_toolbar TO fu_object->mt_toolbar.
    ENDIF.
  
    CLEAR lw_toolbar.
    lw_toolbar-butn_type = 3.
    APPEND lw_toolbar TO fu_object->mt_toolbar.
  
    CLEAR lw_toolbar.
    lw_toolbar-butn_type = 0.
    lw_toolbar-function = 'SAVE'.
    lw_toolbar-quickinfo = '保存'.
    lw_toolbar-text = '保存'.
    lw_toolbar-icon  =  icon_system_save.
    APPEND lw_toolbar TO fu_object->mt_toolbar.
  
    CLEAR lw_toolbar.
    lw_toolbar-butn_type = 3.
    APPEND lw_toolbar TO fu_object->mt_toolbar.
  
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_USER_COMMAND_9000
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> E_UCOMM
  *&---------------------------------------------------------------------*
  FORM frm_user_command_9000  USING  fu_command TYPE sy-ucomm.
  
    CASE fu_command.
      WHEN 'ALL'.    "全选
        PERFORM fm_select_all.
      WHEN 'NOTALL'.    "取消全选
        PERFORM fm_select_no.
      WHEN 'DELETE'.    "删除行
        PERFORM frm_del_row.
      WHEN 'ADD'.    "增加行
        PERFORM frm_add_row.
      WHEN 'SAVE'.    "保存
        PERFORM frm_check_data.
        PERFORM frm_save_data.
      WHEN OTHERS.
    ENDCASE.
  
    PERFORM frm_refresh_alv.    "刷新alv
  
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_SAVE_DATA
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_save_data .
    CLEAR:gs_cust,gt_cust.
    CLEAR:gs_vendor,gt_vendor.
  
    CHECK gv_error IS INITIAL.
    sy-subrc = 0.
  
    IF p_cust EQ 'X'.
      IF gt_del IS NOT INITIAL.
        LOOP AT gt_del INTO gs_del.
          gs_cust-/bic/zyxt = '手工'.
          gs_cust-/bic/zcompany = gs_del-zcompany.
          gs_cust-/bic/zid_num = gs_del-zid_num.
          gs_cust-/bic/zcustomer = gs_del-zcust_vendor.
          gs_cust-/bic/zcus_name = gs_del-zname.
          gs_cust-/bic/zpcompany = gs_del-zpcompany.
  *        gs_cust-/bic/zpcompany = '9999'.
          APPEND gs_cust TO gt_cust.
          CLEAR gs_cust.
        ENDLOOP.
        DELETE  /bic/azbpcdt0172 FROM TABLE gt_cust.
      ENDIF.
      IF sy-subrc = 0.
        CLEAR:gs_cust,gt_cust.
        LOOP AT gt_alv INTO gs_alv.
          gs_cust-/bic/zyxt = '手工'.
          gs_cust-/bic/zcompany = gs_alv-zcompany.
          gs_cust-/bic/zid_num = gs_alv-zid_num.
          gs_cust-/bic/zcustomer = gs_alv-zcust_vendor.
          gs_cust-/bic/zcus_name = gs_alv-zname.
          gs_cust-/bic/zpcompany = gs_alv-zpcompany.
          gs_cust-/bic/zvendor = gs_alv-zmdm_cust_vend."ADDED BY CYJ 20200629 MDM集团客商编码
  *        gs_cust-/bic/zpcompany = '9999'.
          APPEND gs_cust TO gt_cust.
          CLEAR gs_cust.
        ENDLOOP.
        MODIFY /bic/azbpcdt0172 FROM TABLE gt_cust.
      ENDIF.
    ELSEIF p_vendor EQ 'X'.
      IF gt_del IS NOT INITIAL.
        LOOP AT gt_del INTO gs_del.
          gs_vendor-/bic/zyxt = '手工'.
          gs_vendor-/bic/zcompany = gs_del-zcompany.
          gs_vendor-/bic/zid_num = gs_del-zid_num.
          gs_vendor-/bic/zvendor = gs_del-zcust_vendor.
          gs_vendor-/bic/zven_name = gs_del-zname.
          gs_vendor-/bic/zpcompany = gs_del-zpcompany.
  *        gs_vendor-/bic/zpcompany = '9999'.
          APPEND gs_vendor TO gt_vendor.
          CLEAR gs_vendor.
        ENDLOOP.
        DELETE /bic/azbpcdt0182 FROM TABLE gt_vendor.
      ENDIF.
      IF sy-subrc = 0.
        CLEAR:gs_vendor,gt_vendor.
        LOOP AT gt_alv INTO gs_alv.
          gs_vendor-/bic/zyxt = '手工'.
          gs_vendor-/bic/zcompany = gs_alv-zcompany.
          gs_vendor-/bic/zid_num = gs_alv-zid_num.
          gs_vendor-/bic/zvendor = gs_alv-zcust_vendor.
          gs_vendor-/bic/zven_name = gs_alv-zname.
          gs_vendor-/bic/zpcompany = gs_alv-zpcompany.
          gs_vendor-/bic/zcustomer = gs_alv-zmdm_cust_vend."ADDED BY CYJ 20200629 MDM集团客商编码
  *        gs_vendor-/bic/zpcompany = '9999'.
          APPEND gs_vendor TO gt_vendor.
          CLEAR gs_vendor.
        ENDLOOP.
        MODIFY /bic/azbpcdt0182 FROM TABLE gt_vendor.
      ENDIF.
    ENDIF.
  
    IF sy-subrc = 0.
      COMMIT WORK.
      CLEAR:gs_alv,gt_alv.
      MESSAGE '保存成功' TYPE 'I'.
    ELSE.
      ROLLBACK WORK.
      MESSAGE '保存失败' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  
    PERFORM frm_refresh_alv.    "刷新alv
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_ADD_ROW
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_add_row .
    APPEND INITIAL LINE TO gt_alv.
    PERFORM frm_refresh_alv.    "刷新alv
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_DEL_ROW
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_del_row .
    LOOP AT  gt_alv INTO gs_alv WHERE zbox = 'X'.
      gs_del = gs_alv.
      APPEND gs_del TO gt_del.
      CLEAR gs_del.
    ENDLOOP.
  *********BEGIN ADDED BY CYJ 20200602  "从自建表中获取已有数据，如果不存在于自建表，则无需删除，仅需从屏幕上删掉即可
    IF gt_del[] IS NOT INITIAL.
      IF p_cust = 'X'.
        SELECT
          /bic/zcustomer AS zcust_vendor,"changed by cyj 20200628 主键变更
          /bic/zcompany
          FROM /bic/azbpcdt0172
          INTO TABLE @DATA(lt_codename)
          FOR ALL ENTRIES IN @gt_del
          WHERE /bic/zcustomer = @gt_del-zcust_vendor"changed by cyj 20200628 主键变更
          AND   /bic/zcompany = @gt_del-zcompany.
      ELSEIF p_vendor = 'X'.
        SELECT
          /bic/zvendor AS zcust_vendor"changed by cyj 20200628 主键变更
          /bic/zcompany
          FROM /bic/azbpcdt0182
          INTO TABLE lt_codename
          FOR ALL ENTRIES IN gt_del
          WHERE /bic/zvendor = gt_del-zcust_vendor"changed by cyj 20200628 主键变更
          AND   /bic/zcompany = gt_del-zcompany .
      ENDIF.
      IF sy-subrc NE 0."没有任何数据，则直接清空删除表
        REFRESH:gt_del.
      ELSE.
        SORT lt_codename BY zcust_vendor /bic/zcompany."changed by cyj 20200628 主键变更
        LOOP AT gt_del INTO DATA(ls_del).
          READ TABLE lt_codename TRANSPORTING NO FIELDS
          WITH KEY zcust_vendor = ls_del-zcust_vendor /bic/zcompany = ls_del-zcompany"changed by cyj 20200628 主键变更
          BINARY SEARCH.
          IF sy-subrc NE 0."不存在于自建表中，就不用再删除啦
            DELETE gt_del.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  *********BEGIN ADDED BY CYJ 20200602  "从自建表中获取已有数据，如果不存在于自建表，则无需删除，仅需从屏幕上删掉即可
    DELETE gt_alv WHERE zbox = 'X'.
    PERFORM frm_refresh_alv.    "刷新alv
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FM_SELECT_ALL
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM fm_select_all .
    LOOP AT gt_alv ASSIGNING <fs_alv> WHERE zbox = ''.
      <fs_alv>-zbox = 'X'.
    ENDLOOP.
  
    PERFORM frm_refresh_alv.    "刷新alv
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FM_SELECT_NO
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM fm_select_no .
    LOOP AT gt_alv ASSIGNING <fs_alv> WHERE zbox = 'X'.
      <fs_alv>-zbox = ''.
    ENDLOOP.
    PERFORM frm_refresh_alv.    "刷新alv
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_CHECK_DATA
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_check_data.
  
    CLEAR gv_error.
    "清空处理消息
    LOOP AT gt_alv INTO gs_alv.
      gs_alv-light = ''."清空消息
      gs_alv-message = ''.
      IF gs_alv IS NOT INITIAL.
        MODIFY gt_alv FROM gs_alv  .
      ELSE."行全部为空则删除
        DELETE gt_alv.
      ENDIF.
    ENDLOOP.
  
    PERFORM frm_check_alv.  "校验alv界面数据 证件号码和客商编码 唯一
  
    IF p_insert = 'X'.
      PERFORM frm_check_table.  "若是新增 校验alv界面数据是否已在手工维护表存在 （公司、证件号码）
    ENDIF.
  
  *  PERFORM frm_check_mdm.   "校验alv界面数据是否已在mdm存在（公司、证件号码）
  
    PERFORM frm_modify_data.   "查找mdm和手工维护表中证件号码是否存在，若存在则报错
  
    PERFORM frm_check_data2.  "校验客商编号 9开头 10位数字 校验公司代码在ENTITY主数据对应的公司代码中
  
    PERFORM frm_check_zpcompany.  "校验贸易伙伴必须是9999或者存在于MDM公司代码中
  
    CASE gv_error.
      WHEN 1.
        MESSAGE '同一个证件号码不能同时存在两个不同的客商编码，请修改' TYPE 'S' DISPLAY LIKE 'E'.
      WHEN 2.
        MESSAGE '数据已手工维护过,请检查' TYPE 'S' DISPLAY LIKE 'E'.
      WHEN 3.
        MESSAGE '数据已在MDM存在,请检查' TYPE 'S' DISPLAY LIKE 'E'.
      WHEN 4.
        MESSAGE '同一个证件号码不能同时存在两个不同的客商编码，请修改' TYPE 'S' DISPLAY LIKE 'E'.
      WHEN 5.
        MESSAGE '客商编码必须是10位编码，请修改' TYPE 'S' DISPLAY LIKE 'E'.
      WHEN 6.
        MESSAGE '公司代码必须为集团合并范围内公司，请修改' TYPE 'S' DISPLAY LIKE 'E'.
      WHEN 7.
        MESSAGE '贸易伙伴不能为空且必须是9999或者存在于BPC公司代码中，请修改' TYPE 'S' DISPLAY LIKE 'E'.
    ENDCASE.
    PERFORM frm_refresh_alv.    "刷新alv
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_REFRESH_ALV
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_refresh_alv .
    CALL METHOD zcl_grid_9000->refresh_table_display
      EXPORTING
        is_stable      = gs_stbl
        i_soft_refresh = 'X'.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_DATA_CHANGED_FINISHED_9000
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> E_MODIFIED
  *&      --> ET_GOOD_CELLS
  *&---------------------------------------------------------------------*
  FORM frm_data_changed_finished_9000  USING    e_modified
                                                                                 et_good_cells TYPE lvc_t_modi.
  
    CHECK e_modified = 'X'.
    LOOP AT et_good_cells INTO DATA(es_good_cell).
      CASE es_good_cell-fieldname.
        WHEN 'ZCUST_VENDOR'.
          READ TABLE gt_alv INTO gs_alv INDEX es_good_cell-row_id.
          IF sy-subrc = 0.
            MESSAGE es_good_cell-fieldname TYPE 'I'.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
    "刷新OOALV
    PERFORM frm_refresh_alv.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_CHECK_ALV
  *&---------------------------------------------------------------------*
  *& 校验alv界面数据 证件号码和客商编码 唯一
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_check_alv .
  
    DATA:lt_alv1 TYPE TABLE OF ty_alv.
    DATA:lt_alv2 TYPE TABLE OF ty_alv.
  
    lt_alv1 = gt_alv.
    SORT lt_alv1 BY zid_num.
    DELETE ADJACENT DUPLICATES FROM lt_alv1 COMPARING zid_num.
  
    lt_alv2 = gt_alv.
    SORT lt_alv2 BY zid_num.
    DELETE ADJACENT DUPLICATES FROM lt_alv2 COMPARING zid_num zcust_vendor.
  
    IF lines( lt_alv1 ) <> lines( lt_alv2 ).
      gv_error = '1'.
    ENDIF.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_CHECK_TABLE
  *&---------------------------------------------------------------------*
  *& 若是新增 校验alv界面数据是否已在手工维护表存在 （公司、证件号码）
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_check_table .
    DATA:lv_sql_where TYPE string.
  
    CHECK gv_error IS INITIAL.
  
  *  CONCATENATE '/bic/zcompany = gt_alv-zcompany'
  *                           'AND /bic/zid_num = gt_alv-zid_num'
  *                           'AND /bic/zsfyx_c IS INITIAL'
  *  INTO lv_sql_where SEPARATED BY space.
  
    CHECK gt_alv IS NOT INITIAL.
  
    SELECT COUNT(*)
      FROM (gv_tablename)
      FOR ALL ENTRIES IN @gt_alv
      WHERE /bic/zcompany = @gt_alv-zcompany
      AND    /bic/zid_num = @gt_alv-zid_num
      AND    /bic/zsfyx_c IS INITIAL.
  *    WHERE (lv_sql_where).
  
    IF sy-subrc = 0.
      gv_error = '2'.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_CHECK_MDM
  *&---------------------------------------------------------------------*
  *& 校验alv界面数据是否已在mdm存在（公司、证件号码）
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_check_mdm .
    TYPES:BEGIN OF ty_mdm,
            bukrs  TYPE char4,       "公司代码
            id_num TYPE /bic/azmdmde0042-zxbp_id_num,    "证件号码
            code   TYPE char10,      "客商编码
            name   TYPE char80,     "客商描述
          END OF ty_mdm.
    DATA:lt_mdm TYPE TABLE OF ty_mdm,
         ls_mdm TYPE ty_mdm.
  
    CHECK gv_error IS INITIAL.
  
    CHECK gt_alv IS NOT INITIAL.
  
    IF p_cust = 'X'.
      SELECT
        /bic/azmdmde0052~zxbukrs AS bukrs
        /bic/azmdmde0042~zxbp_id_num AS id_num
        /bic/azmdmde0042~zxzkunnr AS code
        /bic/azmdmde0042~zxname_org1 AS name
        FROM /bic/azmdmde0042
        INNER JOIN /bic/azmdmde0052 ON /bic/azmdmde0042~zxzkunnr = /bic/azmdmde0052~zxzkunnr
        INTO TABLE lt_mdm
        FOR ALL ENTRIES IN gt_alv
        WHERE /bic/azmdmde0052~zxbukrs = gt_alv-zcompany
        AND    /bic/azmdmde0042~zxbp_id_num = gt_alv-zid_num
        AND    /bic/azmdmde0042~zxxblck = ''.
    ELSEIF p_vendor = 'X'.
      SELECT
        /bic/azmdmde0072~zgbukrs AS bukrs
        /bic/azmdmde0082~zgbp_id_num AS id_num
        /bic/azmdmde0082~zgzlifnr AS code
        /bic/azmdmde0082~zgname_org1 AS name
        FROM /bic/azmdmde0082
        INNER JOIN /bic/azmdmde0072 ON /bic/azmdmde0082~zgzlifnr = /bic/azmdmde0072~zgzlifnr
        INTO TABLE lt_mdm
        FOR ALL ENTRIES IN gt_alv
        WHERE /bic/azmdmde0072~zgbukrs = gt_alv-zcompany
        AND    /bic/azmdmde0082~zgbp_id_num = gt_alv-zid_num
        AND    /bic/azmdmde0082~zgxblck = ''.
    ENDIF.
  
    IF lt_mdm IS NOT INITIAL.
      gv_error = '3'.
    ENDIF.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_MODIFY_DATA
  *&---------------------------------------------------------------------*
  *& 查找mdm和手工维护表中证件号码是否存在，若存在则用原数据替换alv中客商编号、客商描述
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_modify_data .
  *  CHECK gv_error IS INITIAL.
  
    TYPES:BEGIN OF ty_codename,
            id_num TYPE /bic/azmdmde0042-zxbp_id_num,
            code   TYPE char10,
            name   TYPE char80,
          END OF ty_codename.
    DATA:lt_codename TYPE TABLE OF ty_codename,
         ls_codename TYPE ty_codename.
  
    IF p_cust = 'X'.
  
      SELECT
        /bic/azbpcdt0172~/bic/zid_num AS id_num
        /bic/azbpcdt0172~/bic/zcustomer AS code
        /bic/azbpcdt0172~/bic/zcus_name AS name
        FROM /bic/azbpcdt0172
        INTO TABLE lt_codename
        FOR ALL ENTRIES IN gt_alv
        WHERE /bic/azbpcdt0172~/bic/zid_num = gt_alv-zid_num
        AND    /bic/azbpcdt0172~/bic/zcompany <> gt_alv-zcompany
        AND    /bic/azbpcdt0172~/bic/zsfyx_c = ''.
  
    ELSEIF p_vendor = 'X'.
  
      SELECT
        /bic/azbpcdt0182~/bic/zid_num AS id_num
        /bic/azbpcdt0182~/bic/zvendor AS code
        /bic/azbpcdt0182~/bic/zven_name AS name
        FROM /bic/azbpcdt0182
        INTO TABLE lt_codename
        FOR ALL ENTRIES IN gt_alv
        WHERE /bic/azbpcdt0182~/bic/zid_num = gt_alv-zid_num
        AND    /bic/azbpcdt0182~/bic/zcompany <> gt_alv-zcompany
        AND    /bic/azbpcdt0182~/bic/zsfyx_c = ''.
  
  
    ENDIF.
  
    LOOP AT gt_alv ASSIGNING <fs_alv>.
      CLEAR ls_codename.
      READ TABLE lt_codename INTO ls_codename WITH KEY  id_num = <fs_alv>-zid_num.
      IF sy-subrc = 0.
        IF <fs_alv>-zcust_vendor <> ls_codename-code.
  *      <fs_alv>-zcust_vendor = ls_codename-code.
  *      <fs_alv>-zname = ls_codename-name.
          gv_error = '4'.
          <fs_alv>-light = gv_error.
          <fs_alv>-message = <fs_alv>-message && '同一个证件号码不能同时存在两个不同的客商编码，请修改；'.
  *      EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_INITIAL_DATA
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_initial_data .
    IF p_cust = 'X'.
      gv_tablename = '/bic/azbpcdt0172'.
      gv_code_field = '/bic/zcustomer'.
      gv_mdm_field = '/bic/zvendor'.
      gv_name_field = '/bic/zcus_name'.
    ELSEIF p_vendor = 'X'.
      gv_tablename = '/bic/azbpcdt0182'.
      gv_code_field = '/bic/zvendor'.
      gv_mdm_field = '/bic/zcustomer'.
      gv_name_field = '/bic/zven_name'.
    ENDIF.
  
  *  IF p_sg = 'X'.
  *    gv_yxt = '''手工'''.
  *  ELSEIF p_mdm = 'X'.
  *    gv_yxt = '''MDM'''.
  *  ENDIF.
  
    IF p_change EQ 'X'.
      p_yxt = '手工'.
    ENDIF.
  
    IF p_insert = 'X'.
      APPEND INITIAL LINE TO gt_alv.
    ENDIF.
  
    "ENTITY
    SELECT *
      INTO TABLE gt_entity
      FROM zbpcmap047.
    SORT gt_entity BY zmdmcp.
  
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_CREATE_LIST
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_create_list .
    TYPES:BEGIN OF ty_listbox,
            col1 TYPE zbpcmap051-zmdmyxt,
            col2 TYPE zbpcmap051-zyxtbs,
          END OF ty_listbox.
  
    DATA:lt_list TYPE TABLE OF ty_listbox,
         ls_list TYPE ty_listbox.
  
  
    lt_list = VALUE #( ( col1 = '' )
                    ( col1 = '手工')
                    ( col1 = 'MDM' ) ).
  
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
  *     DDIC_STRUCTURE   = ' '
        retfield         = 'COL1'
  *     PVALKEY          = ' '
        dynpprog         = sy-repid
        dynpnr           = sy-dynnr
        dynprofield      = 'COL1'
  *     STEPL            = 0
        window_title     = 'WINDOW--TITLE'
  *     VALUE            = ''
        value_org        = 'S' "C表示cell，S表示structure
  *     MULTIPLE_CHOICE  = 'X'"多项选择，用于SELECT-OPTIONS
  *     DISPLAY          = 'F'"C则只能显示，不能选择
        callback_program = sy-repid
      TABLES
        value_tab        = lt_list
      EXCEPTIONS
        parameter_error  = 1
        no_values_found  = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_CHECK_DATA2
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_check_data2 .
    DATA:lv_num TYPE p LENGTH 10.
  
  *  CHECK gv_error IS INITIAL.
  
  *****************CHANGED BY CYJ 20200615 调整为从BPC主数据获取
    DATA: lt_/b28/potdpw7h TYPE STANDARD TABLE OF /b28/potdpw7h,
          ls_/b28/potdpw7h TYPE /b28/potdpw7h.
  
    SELECT *
      FROM /b28/potdpw7h
      INTO TABLE lt_/b28/potdpw7h
     WHERE /b28/s_otdpw7h LIKE 'E%'.
    SORT lt_/b28/potdpw7h BY /b28/s_otdpw7h.
  *****************CHANGED BY CYJ 20200615 调整为从BPC主数据获取
  
    LOOP AT gt_alv ASSIGNING <fs_alv>.
  
      "校验客商编码为10位数字
      CONDENSE <fs_alv>-zcust_vendor NO-GAPS.
  *    IF <fs_alv>-zcust_vendor+0(1) = '9'."changed by cyj 20200615不做9开头校验
      IF strlen( <fs_alv>-zcust_vendor ) = 10.
        TRY.
            lv_num = <fs_alv>-zcust_vendor.
          CATCH cx_root. "all error
            gv_error = '5'.
            <fs_alv>-light = gv_error.
            <fs_alv>-message = <fs_alv>-message && '客商编码必须是10位编码，请修改；'.
            CONTINUE.
        ENDTRY.
      ELSE.
        gv_error = '5'.
        <fs_alv>-light = gv_error.
        <fs_alv>-message = <fs_alv>-message && '客商编码必须是10位编码，请修改；'.
        CONTINUE.
      ENDIF.
  *    ELSE."changed by cyj 20200615不做9开头校验
  *      gv_error = '5'.
  *      <fs_alv>-light = gv_error.
  *      <fs_alv>-MESSAGE = '客商编码必须9打头且10位编码，请修改'.
  **      EXIT.
  *    ENDIF.
  
      "校验公司代码存在性
      CLEAR gs_entity.
  *    READ TABLE gt_entity INTO gs_entity WITH KEY zmdmcp = <fs_alv>-zcompany BINARY SEARCH.
      READ TABLE lt_/b28/potdpw7h INTO ls_/b28/potdpw7h WITH KEY /b28/s_otdpw7h = 'E' && <fs_alv>-zcompany BINARY SEARCH.
      IF sy-subrc <> 0.
        gv_error = '6'.
        <fs_alv>-light = gv_error.
        <fs_alv>-message = <fs_alv>-message && '公司代码必须为集团合并范围内公司，请修改；'.
  *      EXIT.
      ENDIF.
  
    ENDLOOP.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form FRM_CHECK_ZPCOMPANY
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_check_zpcompany .
  *****************CHANGED BY CYJ 20200615 调整为从BPC主数据获取
  *  DATA: lt_zmdmde001 TYPE STANDARD TABLE OF /bic/azmdmde0012,
  *        ls_zmdmde001 TYPE /bic/azmdmde0012.
  *
  *  SELECT *
  *    FROM /bic/azmdmde0012
  *    INTO TABLE lt_zmdmde001
  *     FOR ALL ENTRIES IN gt_alv
  *   WHERE zabukrs = gt_alv-zpcompany(4).
    DATA: lt_/b28/potddg4b TYPE STANDARD TABLE OF /b28/potddg4b,
          ls_/b28/potddg4b TYPE /b28/potddg4b.
  
    SELECT *
      FROM /b28/potddg4b
      INTO TABLE lt_/b28/potddg4b
     WHERE /b28/s_otddg4b LIKE 'I%'.
    SORT lt_/b28/potddg4b BY /b28/s_otddg4b.
  *****************CHANGED BY CYJ 20200615 调整为从BPC主数据获取
  
    LOOP AT gt_alv ASSIGNING <fs_alv>.
  
      "校验客商编码为10位数字
      CONDENSE <fs_alv>-zpcompany NO-GAPS.
      IF <fs_alv>-zpcompany IS INITIAL."不能为空
        gv_error = '7'.
        <fs_alv>-light = gv_error.
        <fs_alv>-message = <fs_alv>-message && '贸易伙伴不能为空且必须是9999或者存在于BPC公司代码中，请修改；'.
  *      EXIT.
      ELSEIF <fs_alv>-zpcompany <> '9999'.                    "等于9999无需校验
  *      READ TABLE lt_zmdmde001 INTO ls_zmdmde001 WITH KEY zabukrs = <fs_alv>-zpcompany BINARY SEARCH.
        READ TABLE lt_/b28/potddg4b INTO ls_/b28/potddg4b WITH KEY /b28/s_otddg4b = 'I' && <fs_alv>-zpcompany BINARY SEARCH.
        IF sy-subrc NE 0.
          gv_error = '7'.
          <fs_alv>-light = gv_error.
          <fs_alv>-message = <fs_alv>-message && '贸易伙伴不能为空且必须是9999或者存在于BPC公司代码中，请修改；'.
  *        EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDFORM.