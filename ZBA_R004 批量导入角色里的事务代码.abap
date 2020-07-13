******************************************
* 产生角色的菜单文件，合并用户角色，超级爽，
* 十年前我就研究过角色的导入文件，今天终于实现了。
* 第一次就给测试角色导入了3000个事务代码，呵呵呵。
* 作者：刘欣
* 2013-08-17
* basis100@qq.com
* QQ522929
* ZBA_R004 解放BASIS的双手
******************************************
 
REPORT  ZBA_R004.
 
TYPE-POOLS: SLIS,KCDE.
 
*-----------内表定义--------------
DATA:BEGIN OF itab OCCURS 0,
 
       UNAME type AGR_USERS-UNAME,          "用户名
       NAME_TEXT type V_USERNAME-NAME_TEXT, "完整用户名称
       TCODE type AGR_TCODES-TCODE,       "事务代码
       TTEXT type TSTCT-TTEXT,           "代码说明
 
      END of itab.
 
 
DATA: username TYPE V_USERNAME-NAME_TEXT,
      tcodes  TYPE AGR_TCODES-TCODE,
*      DEPARTMENT type ADCP~DEPARTMENT,"部门信息
 
      G_REPID TYPE SY-REPID,
      IT_EVENTS TYPE SLIS_T_EVENT,
      IT_FIELD TYPE SLIS_T_FIELDCAT_ALV,
      WA_FIELD TYPE SLIS_FIELDCAT_ALV,
      IT_SORT TYPE SLIS_T_SORTINFO_ALV.
 
 
 
 DATA : BEGIN OF wa OCCURS 0,
        fileline(300) TYPE C ,       "事务代码
        END OF wa.
  DATA :   lineresult(300) TYPE C,
        sspace(20) TYPE C.
 
  DATA: LINT_INDEX TYPE I value 1.
   DATA: test(5) TYPE N .
 
PARAMETERS:  P_FILE LIKE RLGRAP-FILENAME DEFAULT 'C:\saprolefile.txt'.
 
 
INITIALIZATION.
G_REPID = SY-REPID.
 
*--------选择字段-----------------------
start-of-selection.
     SELECT-OPTIONS name FOR USERNAME NO INTERVALS.
*     SELECT-OPTIONS codes FOR tcodes  NO INTERVALS.
end-of-selection.
 
 
 
 
*------执行-----------
perform tosql.
perform listshow.
perform savetxt.
 
*--------------------------------
* 用户名，完整用户名称，部门名称ADCP~DEPARTMENT,角色名AGR_USERS~AGR_NAME，角色中文说明AGR_TEXTS~TEXT，事务代码,事务代码说明
*--------------------------------
form tosql.
SELECT DISTINCT  usr21~bname AS uname   V_USERNAME~NAME_TEXT           AGR_TCODES~TCODE   TSTCT~TTEXT
 
        INTO corresponding fields of table itab
        FROM USR21
 
        INNER JOIN v_username       on V_USERNAME~persnumber = usr21~persnumber "通过usr21的号码，连接用户信息表
        INNER JOIN adcp         ON adcp~persnumber = usr21~persnumber       "通过usr21的号码，连接部门表
        INNER JOIN agr_users          ON agr_users~uname = usr21~bname            "通过usr21的用户名，连接角色表
        INNER JOIN AGR_TEXTS   on  AGR_TEXTS~AGR_NAME = AGR_USERS~AGR_NAME "通过角色名，加入角色中文说明表
        INNER JOIN AGR_TCODES   on  AGR_TCODES~AGR_NAME = AGR_USERS~AGR_NAME "通过角色名，加入角色中文说明表
        INNER JOIN TSTCT   on  TSTCT~TCODE = AGR_TCODES~TCODE "通过  表
 
 
 
 
        where AGR_USERS~UNAME in name and   AGR_TEXTS~LINE = '00000' and TSTCT~SPRSL = '1'.
 
 
DELETE ADJACENT DUPLICATES FROM itab.
 
SORT itab BY  UNAME TCODE.
 
endform.
 
*--------------------------------
* form listshow
*--------------------------------
form listshow.
********宏定义.
  DEFINE ADD_FIELD.
    WA_FIELD-FIELDNAME = &1.
    WA_FIELD-REPTEXT_DDIC = &2.
    WA_FIELD-NO_ZERO = 'X'.
    APPEND WA_FIELD TO IT_FIELD.
  END-OF-DEFINITION.
 
  ADD_FIELD 'UNAME'  '登录用户名'.
  ADD_FIELD 'NAME_TEXT'  '中文名称'.
  ADD_FIELD 'TCODE'  '事务代码'.
  ADD_FIELD 'TTEXT'  '事务代码说明'.
 
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'"
       EXPORTING
            I_CALLBACK_PROGRAM = G_REPID
            I_BACKGROUND_ID   = 'ALV_BACKGROUND'
*            I_GRID_TITLE      = '查询用户-角色-事务代码'
            IT_FIELDCAT        = IT_FIELD
*            IS_LAYOUT          = GS_LAYOUT
*            IT_SORT            = IT_SORT
            I_SAVE             = 'A'
*            IT_EVENTS          = IT_EVENTS[]
       TABLES
            T_OUTTAB           = itab
       EXCEPTIONS
            PROGRAM_ERROR = 1
            OTHERS        = 2.
endform.
 
*&---------------------------------------------------------------------*
*&      Form  savetxt
*&---------------------------------------------------------------------*
form savetxt.
 
CLEAR    wa[].
SORT ITAB  BY tcode.
DELETE ADJACENT DUPLICATES FROM itab.
 
*添加第一行信息
wa-fileline = 'FORMAT              1.2B'.
insert wa-fileline INTO wa index 1.
 
*添加菜单和文本说明等信息
 
LOOP AT ITAB INTO itab.
 
*取行号加1构成编号
      LINT_INDEX =  LINT_INDEX + 1.
      move LINT_INDEX to test  .
 
*字符串合并
   CONCATENATE 'NODE               #'  test  '00001' test  'TRANSACTION        #' itab-tcode cl_ABAP_char_utilities=>cr_lf  INTO lineresult .
 
   CONCATENATE lineresult 'TEXT               #'  test  'ZH' itab-TTEXT cl_ABAP_char_utilities=>cr_lf  INTO lineresult .
 
   REPLACE '#' WITH  ' ' INTO lineresult.
   REPLACE '#' WITH  ' ' INTO lineresult.
   REPLACE '#' WITH  ' ' INTO lineresult.
 
   APPEND lineresult  TO wa.
 
ENDLOOP.
 
 
 
 
 
 
    CALL FUNCTION 'WS_DOWNLOAD'
     EXPORTING
*       BIN_FILESIZE                  = ' '
*       CODEPAGE                      = ' '
       FILENAME                      = P_FILE
       FILETYPE                      = 'DAT'
*       MODE                          = ' '
*       WK1_N_FORMAT                  = ' '
*       WK1_N_SIZE                    = ' '
*       WK1_T_FORMAT                  = ' '
*       WK1_T_SIZE                    = ' '
*       COL_SELECT                    = ' '
*       COL_SELECTMASK                = ' '
*       NO_AUTH_CHECK                 = ' '
*     IMPORTING
*       FILELENGTH                    =
      TABLES
        data_tab                      = wa
*       FIELDNAMES                    =
*     EXCEPTIONS
*       FILE_OPEN_ERROR               = 1
*       FILE_WRITE_ERROR              = 2
*       INVALID_FILESIZE              = 3
*       INVALID_TYPE                  = 4
*       NO_BATCH                      = 5
*       UNKNOWN_ERROR                 = 6
*       INVALID_TABLE_WIDTH           = 7
*       GUI_REFUSE_FILETRANSFER       = 8
*       CUSTOMER_ERROR                = 9
*       NO_AUTHORITY                  = 10
*       OTHERS                        = 11
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
 
 
IF SY-SUBRC = 0.
   SKIP.
   WRITE:/  'Very good, download successful'.
ELSE.
   FORMAT COLOR COL_TOTAL.
   SKIP.
   WRITE:/  'Error in Download'.
   SKIP.
   WRITE:/  'Is the file Open by Excel or Lotus?'.
ENDIF.
 
 
    endform.
 
 
*
*
*FORMAT              1.2B
*NODE                000020000100002TRANSACTION         PFCG
*TEXT                00002ZH角色管理
*NODE                000030000100003TRANSACTION         SU01
*TEXT                00003ZH创建用户
*NODE                000040000100004TRANSACTION         ZBA01
*TEXT                00004ZH查询用户
*NODE                000050000100005TRANSACTION         ZBA08
*TEXT                00005ZH查询用户888
*
*//---------------格式说明---------------
*
*Character 1 - 20: name of record type
*
*Record description or record type 'FORMAT'
*Characters 21 - 40: Version of the format used in the file (left-aligned); the format described here is version 1.2B
*
*Record description or record type 'NODE'
*Characters 21 - 25: node object ID (right-aligned)
*Characters 26 - 30: parent node ID (right-aligned)
*Characters 31 - 35: sort sequence (right-aligned)
*Characters 36 - 55: node type ? FOLDER for folders,
*- TRANSACTION for SAP transactions,
*- URL for URLs
*- KW for Knowledge Warehouse links
*- Your own node types if defined
*Characters 56 - 310: node information for the node type
*In case of node type FOLDER: no node information needed
*In case of node type TRANSACTION: transaction code
*In case of node type URL: URL
*In case of your own node type: the node information
*
*Record description for record type 'TEXT'
*Characters 21 - 25: node object ID (right-aligned)
*Characters 26 - 27: language for the text of this record in ISO standard(for example EN = English, FR = French, DE = German, ...)
*Characters 28 - 107: text in the language specified in characters 26 - 27