# http://marceloochoa.blogspot.com/2017/06/using-datapump-on-oracledocker.html
# https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_export.htm#SUTIL837
# content=METADATA_ONLY

import cx_Oracle
cx_Oracle.init_oracle_client(lib_dir="/usr/local/homebrew/opt/instantclient")

tns = cx_Oracle.makedsn('1.1.1.1', 1521, service_name = 'ORCLCDB')
connection = cx_Oracle.connect(user = 'test', password = 'test', dsn = tns)

cursor = connection.cursor()
for result in cursor.execute('SELECT 1 FROM DUAL'):
    print(result)
