-- pg_read_file、pg_ls_dir 都有目录限制，只能用这个方法

create table docs (data TEXT);
copy docs from '/etc/passwd';
select * from docs limit 10;
drop table docs;

