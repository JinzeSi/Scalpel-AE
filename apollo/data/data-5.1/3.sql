SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c0 as c0
from 
  (select  
        ref_0.hire_date as c0, 
        ref_0.age as c1, 
        ref_0.hire_date as c2, 
        ref_0.years as c3, 
        case when (EXISTS (
              select  
                  ref_1.salary as c0, 
                  ref_0.age as c1, 
                  ref_0.age as c2, 
                  ref_0.age as c3, 
                  ref_0.hire_date as c4, 
                  ref_0.department_id as c5, 
                  ref_1.salary as c6
                from 
                  test_bd.employee as ref_1
                where false
                limit 147)) 
            or (ref_0.hire_date is not NULL) then ref_0.age else ref_0.age end
           as c4, 
        ref_0.department_id as c5, 
        ref_0.salary as c6, 
        ref_0.department_id as c7
      from 
        test_bd.employee as ref_0
      where EXISTS (
        select  
            ref_2.user_id as c0, 
            ref_2.user_id as c1, 
            ref_2.profile_picture as c2, 
            ref_0.department_id as c3, 
            (select post_id from test_bd.comments limit 1 offset 6)
               as c4, 
            (select virtual_col from test_bd.eids limit 1 offset 4)
               as c5, 
            ref_0.department_id as c6, 
            ref_0.eid as c7, 
            ref_2.profile_picture as c8, 
            ref_2.bio as c9, 
            ref_0.age as c10, 
            ref_0.hire_date as c11, 
            ref_0.eid as c12, 
            ref_0.id as c13, 
            56 as c14, 
            ref_0.hire_date as c15
          from 
            test_bd.user_profiles as ref_2
          where ((false) 
              and (EXISTS (
                select  
                    ref_2.birthdate as c0, 
                    ref_2.profile_picture as c1
                  from 
                    test_bd.users as ref_3
                  where ref_3.username is not NULL
                  limit 86))) 
            or (((true) 
                and (EXISTS (
                  select  
                      ref_4.price as c0, 
                      ref_4.id as c1, 
                      ref_4.tags as c2, 
                      ref_2.bio as c3, 
                      ref_0.age as c4, 
                      ref_4.id as c5
                    from 
                      test_bd.products as ref_4
                    where (true) 
                      and ((true) 
                        and ((EXISTS (
                            select  
                                ref_4.category as c0, 
                                ref_4.category as c1, 
                                ref_2.user_id as c2, 
                                ref_0.email as c3, 
                                ref_0.hire_date as c4
                              from 
                                test_bd.comments as ref_5
                              where ((true) 
                                  or (true)) 
                                or ((true) 
                                  or (ref_5.comment is NULL))
                              limit 163)) 
                          or (EXISTS (
                            select  
                                42 as c0, 
                                ref_2.birthdate as c1, 
                                ref_4.created_at as c2, 
                                ref_0.salary as c3
                              from 
                                test_bd.users as ref_6
                              where ((true) 
                                  or ((((true) 
                                        or (true)) 
                                      or (true)) 
                                    or ((true) 
                                      and (true)))) 
                                and (EXISTS (
                                  select  
                                      ref_0.department_id as c0, 
                                      ref_4.category as c1, 
                                      ref_0.id as c2, 
                                      ref_4.tags as c3, 
                                      ref_6.username as c4, 
                                      ref_7.title as c5, 
                                      ref_4.name as c6, 
                                      ref_4.discount as c7, 
                                      ref_0.salary as c8, 
                                      ref_0.eid as c9, 
                                      ref_7.comment as c10, 
                                      ref_4.id as c11, 
                                      (select username from test_bd.user_post_comments limit 1 offset 3)
                                         as c12, 
                                      ref_4.discount as c13
                                    from 
                                      test_bd.user_post_comments as ref_7
                                    where ref_7.title is NULL))
                              limit 68))))
                    limit 110))) 
              and (true))
          limit 46)) as subq_0
where subq_0.c2 is NULL
limit 117;
SHOW profiles;