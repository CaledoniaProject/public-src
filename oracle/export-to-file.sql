set TERMOUT OFF
set colsep ,
set headsep off
set pagesize 0
set trimspool on
set linesize 30000

spool output.txt

SELECT
  XX,
  YY
FROM
  some_table;

spool off

