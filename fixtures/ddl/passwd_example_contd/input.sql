-- admin can view all rows and fields
set role admin;
-- SET
table passwd;
 user_name | pwhash | uid | gid | real_name |  home_phone  | extra_info | home_dir    |   shell
-----------+--------+-----+-----+-----------+--------------+------------+-------------+-----------
 admin     | xxx    |   0 |   0 | Admin     | 111-222-3333 |            | /root       | /bin/dash
 bob       | xxx    |   1 |   1 | Bob       | 123-456-7890 |            | /home/bob   | /bin/zsh
 alice     | xxx    |   2 |   1 | Alice     | 098-765-4321 |            | /home/alice | /bin/zsh
(3 rows)

-- Test what Alice is able to do
set role alice;
-- SET
table passwd;
-- ERROR:  permission denied for relation passwd
select user_name,real_name,home_phone,extra_info,home_dir,shell from passwd;
--  user_name | real_name |  home_phone  | extra_info | home_dir    |   shell
-- -----------+-----------+--------------+------------+-------------+-----------
--  admin     | Admin     | 111-222-3333 |            | /root       | /bin/dash
--  bob       | Bob       | 123-456-7890 |            | /home/bob   | /bin/zsh
--  alice     | Alice     | 098-765-4321 |            | /home/alice | /bin/zsh
-- (3 rows)

update passwd set user_name = 'joe';
-- ERROR:  permission denied for relation passwd
-- Alice is allowed to change her own real_name, but no others
update passwd set real_name = 'Alice Doe';
-- UPDATE 1
update passwd set real_name = 'John Doe' where user_name = 'admin';
-- UPDATE 0
update passwd set shell = '/bin/xx';
-- ERROR:  new row violates WITH CHECK OPTION for "passwd"
delete from passwd;
-- ERROR:  permission denied for relation passwd
insert into passwd (user_name) values ('xxx');
-- ERROR:  permission denied for relation passwd
-- Alice can change her own password; RLS silently prevents updating other rows
update passwd set pwhash = 'abc';
-- UPDATE 1
