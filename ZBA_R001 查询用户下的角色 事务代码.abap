******************************************
* 查询用户下的角色，事务代码
* 作者：刘欣
* 2013-5-3
* basis100@qq.com
* QQ522929
******************************************
REPORT  ZBA_R001.
TYPE-POOLS: SLIS,KCDE.
*-----------内表定义--------------
DATA:BEGIN OF itab OCCURS 0,
       UNAME type AGR_USERS-UNAME,          "用户名
       NAME_TEXT type V_USERNAME-NAME_TEXT, "完整用户名称
       DEPARTMENT type ADCP-DEPARTMENT,    "部门信息
       AGR_NAME  type AGR_USERS-AGR_NAME,   "角色名
       TEXT type AGR_TEXTS-TEXT,         "角色中文说明
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
 
INITIALIZATION.
G_REPID = SY-REPID.
*--------选择字段-----------------------
start-of-selection.
     SELECT-OPTIONS name FOR USERNAME NO INTERVALS.
     SELECT-OPTIONS codes FOR tcodes  NO INTERVALS.
end-of-selection.
 
 
*------执行-----------
perform tosql.
perform listshow.
*--------------------------------
* 用户名，完整用户名称，部门名称,角色名，角色中文说明，事务代码,事务代码说明
*--------------------------------
form tosql.
SELECT DISTINCT  usr21~bname AS uname   V_USERNAME~NAME_TEXT  ADCP~DEPARTMENT  AGR_USERS~AGR_NAME    AGR_TEXTS~TEXT   AGR_TCODES~TCODE   TSTCT~TTEXT
        INTO corresponding fields of table itab
        FROM USR21
        INNER JOIN v_username       on V_USERNAME~persnumber = usr21~persnumber "通过usr21的号码，连接用户信息表
        INNER JOIN adcp      ON adcp~persnumber = usr21~persnumber       "通过usr21的号码，连接部门表
        INNER JOIN agr_users       ON agr_users~uname = usr21~bname            "通过usr21的用户名，连接角色表
        INNER JOIN AGR_TEXTS   on  AGR_TEXTS~AGR_NAME = AGR_USERS~AGR_NAME "通过角色名，加入角色中文说明表
        INNER JOIN AGR_TCODES   on  AGR_TCODES~AGR_NAME = AGR_USERS~AGR_NAME "通过角色名，加入角色中文说明表
        INNER JOIN TSTCT   on  TSTCT~TCODE = AGR_TCODES~TCODE "通过  表
 
 
        where AGR_USERS~UNAME in name and AGR_TCODES~TCODE in codes and AGR_TEXTS~LINE = '00000' and TSTCT~SPRSL = '1'.
 
DELETE ADJACENT DUPLICATES FROM itab.
SORT itab BY  UNAME AGR_NAME TCODE.
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
  ADD_FIELD 'DEPARTMENT'  '部门'.
  ADD_FIELD 'AGR_NAME'  '角色'.
  ADD_FIELD 'TEXT'  '角色名称'.
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