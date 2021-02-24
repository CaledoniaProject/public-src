CREATE TABLE cmd_exec(cmd_output text);
COPY cmd_exec FROM PROGRAM 'pwd; whoami';
SELECT * FROM cmd_exec;
DROP TABLE IF EXISTS cmd_exec;

