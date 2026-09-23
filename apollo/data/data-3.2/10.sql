SET profiling=1;
EXPLAIN ANALYZE

select  
  (select virtual_col from test_bd.eids limit 1 offset 6)
     as c0, 
  (select department_id from test_bd.employee limit 1 offset 56)
     as c1, 
  ref_0.years as c2, 
  (select name from test_bd.locations limit 1 offset 1)
     as c3, 
  ref_0.eid as c4, 
  case when (ref_0.age is not NULL) 
      and ((false) 
        and (true)) then ref_0.salary else ref_0.salary end
     as c5, 
  ref_0.email as c6, 
  coalesce((select name from test_bd.products limit 1 offset 3)
      ,
    ref_0.email) as c7, 
  ref_0.eid as c8, 
  (select category from test_bd.products limit 1 offset 4)
     as c9, 
  ref_0.age as c10, 
  ref_0.salary as c11, 
  38 as c12, 
  ref_0.email as c13
from 
  test_bd.employee as ref_0
where (((((EXISTS (
            select  
                (select username from test_bd.user_post_comments limit 1 offset 3)
                   as c0, 
                83 as c1, 
                ref_1.eid as c2, 
                ref_0.age as c3, 
                ref_1.eid as c4
              from 
                test_bd.eids as ref_1
              where true)) 
          and (EXISTS (
            select  
                ref_0.years as c0, 
                (select bio from test_bd.user_profiles limit 1 offset 4)
                   as c1, 
                ref_2.name as c2, 
                ref_0.years as c3, 
                ref_0.id as c4, 
                ref_2.tags as c5, 
                ref_0.id as c6, 
                ref_0.eid as c7, 
                ref_0.department_id as c8, 
                ref_0.hire_date as c9, 
                ref_0.years as c10, 
                ref_0.id as c11
              from 
                test_bd.products as ref_2
              where ((true) 
                  or (((false) 
                      and (EXISTS (
                        select  
                            72 as c0, 
                            ref_3.birthdate as c1, 
                            ref_2.discount as c2, 
                            ref_2.created_at as c3, 
                            ref_3.birthdate as c4, 
                            ref_2.tags as c5, 
                            ref_3.profile_picture as c6
                          from 
                            test_bd.user_profiles as ref_3
                          where EXISTS (
                            select  
                                97 as c0, 
                                94 as c1, 
                                ref_2.tags as c2, 
                                ref_4.user_id as c3
                              from 
                                test_bd.locations as ref_4
                              where true
                              limit 60)))) 
                    or (true))) 
                and (ref_0.email is not NULL)))) 
        or ((false) 
          and (false))) 
      or (false)) 
    and (ref_0.age is NULL)) 
  or ((true) 
    and (ref_0.salary is not NULL));
SHOW profiles;