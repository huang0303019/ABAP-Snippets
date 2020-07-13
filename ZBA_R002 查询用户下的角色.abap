******************************************
* 查询用户下的角色(刘欣)
* 2013-5-3
* basis100@qq.com
*******表: AGR_TCODES     角色名:AGR_NAME    事务代码:TCODE (这个表在ZBA01中使用,ZBA02中没用)
*表: AGR_USERS      角色名:AGR_NAME     用户名:UNAME
*表: V_USERNAME     用户名:BNAME        完整的人员名称:NAME_TEXT
*表: AGR_TEXTS      角色名:AGR_NAME     角色说明:TEXT
******************************************
REPORT  ZBA_R002.
 
TYPE-POOLS: SLIS,KCDE.
DATA: username(20) TYPE C,
      G_REPID TYPE SY-REPID,
      IT_EVENTS TYPE SLIS_T_EVENT,
      IT_FIELD TYPE SLIS_T_FIELDCAT_ALV,
      WA_FIELD TYPE SLIS_FIELDCAT_ALV,
      IT_SORT TYPE SLIS_T_SORTINFO_ALV.
INITIALIZATION.
G_REPID = SY-REPID.
 
DATA:BEGIN OF itab OCCURS 0,
       UNAME type AGR_USERS-UNAME,
       NAME_TEXT type V_USERNAME-NAME_TEXT,
       AGR_NAME  type AGR_USERS-AGR_NAME,
       TEXT type AGR_TEXTS-TEXT,
      END of itab.
 
 
start-of-selection.
     SELECT-OPTIONS name FOR USERNAME NO INTERVALS.
end-of-selection.
 
perform tosql.
perform listshow.
*--------------------------------
* form tosql
*--------------------------------
form tosql.
SELECT DISTINCT AGR_USERS~AGR_NAME    AGR_USERS~UNAME    V_USERNAME~NAME_TEXT   AGR_TEXTS~TEXT
         INTO corresponding fields of table itab
        FROM AGR_USERS
            INNER JOIN V_USERNAME on AGR_USERS~UNAME = V_USERNAME~BNAME       "加入用户全称
            INNER JOIN AGR_TEXTS on  AGR_USERS~AGR_NAME = AGR_TEXTS~AGR_NAME     "加入角色说明
        where AGR_USERS~UNAME in name.
DELETE ADJACENT DUPLICATES FROM itab.
 
SORT itab BY  UNAME AGR_NAME .
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
  ADD_FIELD 'AGR_NAME'  '角色'.
  ADD_FIELD 'TEXT'  '角色说明'.
 
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'"
       EXPORTING
            I_CALLBACK_PROGRAM = G_REPID
            I_BACKGROUND_ID   = 'ALV_BACKGROUND'
*            I_GRID_TITLE      = ' 用户权限查询'
            IT_FIELDCAT        = IT_FIELD
*            IS_LAYOUT          = GS_LAYOUT
*            IT_SORT            = IT_SORT
            I_SAVE             = 'A'
            IT_EVENTS          = IT_EVENTS[]
       TABLES
            T_OUTTAB           = itab
       EXCEPTIONS
            PROGRAM_ERROR = 1
            OTHERS        = 2.
endform.