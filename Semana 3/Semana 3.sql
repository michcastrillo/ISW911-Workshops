select * from dba_tab_cols

----------------------create tables option 1
select case  when  fila = 1  then 'create table NORTHWIND.' ||tabla||'('
else columna end columna  from (
select  c.table_name tabla,column_name|| ' '  ||data_type|| ' (' || c.data_length||  '),'  columna,
row_number() over( partition by  c.table_name order by column_name ) fila
from dba_tab_cols c 
inner join dba_objects o
on c.owner=o.owner
and c.table_name =o.object_name
where  c.owner='NORTHWIND'
) cp

---------------------------create tables option 2
select replace(replace(case
                         when fila = 1 then
                          'CREATE TABLE ' || tabla || ' (' || columna
                         else
                          '                        ' || columna
                       end,
                       'VARCHAR2',
                       'VARCHAR'),
               'NUMBER',
               'NUMERIC') statment_table
  from (select o.owner || '.' || c.table_name tabla,
               c.column_name || ' ' || c.data_type || ' (' || c.data_length || '),' columna,
               row_number() OVER(PARTITION BY c.table_name ORDER BY rownum) fila
          from dba_tab_cols c
         inner join dba_objects o
            on c.owner = o.owner
           and c.table_name = o.object_name
         where o.owner = 'NORTHWIND'
           and o.object_type = 'TABLE')


select * from user_tables


----------copy from oracle--------------
create table as 
select * from ******