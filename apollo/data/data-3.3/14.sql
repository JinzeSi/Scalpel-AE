SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c0 as c0, 
  (select title from test_bd.user_post_comments limit 1 offset 2)
     as c1, 
  subq_0.c2 as c2, 
  case when (false) 
      and ((false) 
        or ((EXISTS (
            select  
                subq_0.c1 as c0, 
                subq_0.c1 as c1, 
                subq_2.c0 as c2
              from 
                test_bd.employee as ref_6
              where subq_0.c2 is not NULL
              limit 111)) 
          and (false))) then ref_5.id else ref_5.id end
     as c3, 
  (select department_id from test_bd.employee limit 1 offset 70)
     as c4, 
  coalesce(subq_0.c1,
    null) as c5, 
  subq_2.c0 as c6, 
  ref_5.created_at as c7, 
  subq_0.c0 as c8, 
  case when (true) 
      or (true) then (select years from test_bd.employee limit 1 offset 1)
       else (select years from test_bd.employee limit 1 offset 1)
       end
     as c9, 
  ref_5.username as c10, 
  subq_2.c0 as c11, 
  ref_5.id as c12
from 
  (select  
          ref_1.updated_at as c0, 
          ref_1.content as c1, 
          ref_0.user_id as c2
        from 
          test_bd.posts as ref_0
              right join test_bd.posts as ref_1
              on (ref_1.user_id is NULL)
            right join test_bd.users as ref_2
            on (ref_0.id is not NULL)
        where ref_2.username is not NULL
        limit 34) as subq_0
    inner join (select  
            ref_3.years as c0, 
            ref_3.hire_date as c1
          from 
            test_bd.employee as ref_3,
            lateral (select  
                  43 as c0, 
                  ref_4.email as c1, 
                  ref_3.department_id as c2, 
                  ref_4.created_at as c3
                from 
                  test_bd.users as ref_4
                where ((true) 
                    and ((false) 
                      and ((true) 
                        or (false)))) 
                  and (ref_4.email is NULL)
                limit 34) as subq_1
          where true) as subq_2
      inner join test_bd.users as ref_5
      on (ref_5.created_at is not NULL)
    on (true)
where ((subq_0.c0 is NULL) 
    and (((subq_0.c0 is not NULL) 
        and (subq_2.c1 is not NULL)) 
      and (subq_2.c0 is not NULL))) 
  or ((subq_2.c0 is NULL) 
    and (subq_2.c0 is not NULL));
SHOW profiles;