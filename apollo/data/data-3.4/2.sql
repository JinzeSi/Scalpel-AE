SET profiling=1;
EXPLAIN ANALYZE
select  
  ref_2.comment as c0, 
  subq_0.c0 as c1, 
  subq_0.c0 as c2, 
  ref_0.salary as c3, 
  ref_2.created_at as c4
from 
  test_bd.employee as ref_0
    right join (select  
            ref_1.id as c0, 
            (select title from test_bd.posts limit 1 offset 76)
               as c1, 
            ref_1.salary as c2, 
            ref_1.email as c3, 
            ref_1.email as c4
          from 
            test_bd.employee as ref_1
          where true
          limit 114) as subq_0
      left join test_bd.comments as ref_2
      on (subq_0.c0 = ref_2.id )
    on (((true) 
          and (true)) 
        and ((false) 
          and (ref_0.id is NULL))),
  lateral (select distinct 
        ref_2.post_id as c0, 
        ref_0.age as c1, 
        ref_2.post_id as c2, 
        ref_2.post_id as c3, 
        ref_3.years as c4, 
        coalesce(ref_3.department_id,
          ref_0.department_id) as c5, 
        ref_3.department_id as c6, 
        ref_2.comment as c7, 
        ref_0.eid as c8
      from 
        test_bd.employee as ref_3
      where ref_2.id is not NULL
      limit 140) as subq_1
where (((((false) 
          and (ref_2.comment is NULL)) 
        and (subq_0.c0 is not NULL)) 
      or ((EXISTS (
          select  
              ref_0.hire_date as c0, 
              subq_0.c3 as c1, 
              ref_0.department_id as c2, 
              subq_1.c6 as c3, 
              ref_0.id as c4
            from 
              test_bd.posts as ref_4
            where ref_0.department_id is NULL
            limit 63)) 
        and (((subq_0.c3 is not NULL) 
            or (EXISTS (
              select  
                  15 as c0, 
                  subq_1.c5 as c1, 
                  ref_5.updated_at as c2
                from 
                  test_bd.posts as ref_5,
                  lateral (select  
                        ref_6.years as c0, 
                        subq_1.c8 as c1, 
                        ref_2.comment as c2, 
                        ref_6.years as c3, 
                        ref_6.hire_date as c4
                      from 
                        test_bd.employee as ref_6
                      where true
                      limit 124) as subq_2,
                  lateral (select  
                        ref_5.title as c0, 
                        ref_2.user_id as c1, 
                        subq_0.c2 as c2, 
                        ref_5.content as c3, 
                        ref_2.comment as c4, 
                        subq_1.c1 as c5, 
                        ref_2.created_at as c6, 
                        ref_0.age as c7, 
                        ref_5.id as c8, 
                        ref_7.user_id as c9, 
                        ref_7.post_id as c10, 
                        ref_5.id as c11, 
                        ref_0.hire_date as c12, 
                        (select id from test_bd.comments limit 1 offset 3)
                           as c13, 
                        ref_7.comment as c14, 
                        ref_2.post_id as c15, 
                        subq_0.c0 as c16, 
                        ref_2.user_id as c17
                      from 
                        test_bd.comments as ref_7
                      where (false) 
                        or ((false) 
                          and (subq_0.c0 is NULL))
                      limit 185) as subq_3
                where false
                limit 148))) 
          and (EXISTS (
            select  
                57 as c0, 
                ref_0.department_id as c1, 
                ref_8.virtual_col as c2, 
                ref_0.department_id as c3
              from 
                test_bd.eids as ref_8
              where false
              limit 114))))) 
    or (false)) 
  or (((((subq_0.c2 is not NULL) 
          or (((subq_0.c1 is not NULL) 
              or (ref_2.user_id is NULL)) 
            and ((((((EXISTS (
                        select  
                            13 as c0, 
                            (select post_id from test_bd.comments limit 1 offset 2)
                               as c1, 
                            subq_6.c0 as c2, 
                            ref_0.salary as c3, 
                            ref_0.hire_date as c4
                          from 
                            test_bd.products as ref_9,
                            lateral (select  
                                  ref_0.hire_date as c0, 
                                  ref_2.post_id as c1, 
                                  (select updated_at from test_bd.posts limit 1 offset 3)
                                     as c2, 
                                  subq_5.c6 as c3
                                from 
                                  test_bd.eids as ref_10,
                                  lateral (select  
                                        subq_4.c1 as c0, 
                                        subq_4.c3 as c1, 
                                        subq_4.c1 as c2, 
                                        subq_4.c4 as c3, 
                                        ref_0.hire_date as c4, 
                                        subq_4.c5 as c5, 
                                        ref_0.years as c6, 
                                        subq_1.c5 as c7
                                      from 
                                        test_bd.user_profiles as ref_11,
                                        lateral (select  
                                              ref_12.user_id as c0, 
                                              ref_11.bio as c1, 
                                              72 as c2, 
                                              (select discount from test_bd.products limit 1 offset 3)
                                                 as c3, 
                                              ref_12.updated_at as c4, 
                                              ref_12.id as c5, 
                                              ref_9.created_at as c6
                                            from 
                                              test_bd.posts as ref_12
                                            where false
                                            limit 131) as subq_4
                                      where subq_1.c5 is NULL
                                      limit 163) as subq_5
                                where true
                                limit 108) as subq_6
                          where ref_0.email is NULL
                          limit 74)) 
                      and (ref_2.post_id is NULL)) 
                    and ((EXISTS (
                        select  
                            ref_0.eid as c0, 
                            ref_0.id as c1, 
                            ref_13.created_at as c2, 
                            ref_0.department_id as c3, 
                            (select title from test_bd.user_post_comments limit 1 offset 1)
                               as c4, 
                            ref_2.comment as c5
                          from 
                            test_bd.comments as ref_13
                          where (ref_2.id is NULL) 
                            or (true)
                          limit 174)) 
                      and (ref_2.user_id is not NULL))) 
                  and (ref_0.id is not NULL)) 
                and (((ref_2.post_id is not NULL) 
                    or (ref_0.years is NULL)) 
                  and (EXISTS (
                    select  
                        (select id from test_bd.eids limit 1 offset 1)
                           as c0
                      from 
                        test_bd.eids as ref_14
                      where false
                      limit 192)))) 
              and (ref_2.user_id is not NULL)))) 
        or (((((true) 
                and (((86 is not NULL) 
                    or (subq_0.c4 is NULL)) 
                  and ((19 is NULL) 
                    or (ref_0.age is NULL)))) 
              or (subq_0.c4 is not NULL)) 
            or ((subq_1.c6 is not NULL) 
              and (EXISTS (
                select  
                    ref_15.birthdate as c0, 
                    subq_1.c8 as c1, 
                    subq_1.c8 as c2, 
                    subq_1.c1 as c3, 
                    ref_0.email as c4, 
                    ref_2.post_id as c5
                  from 
                    test_bd.user_profiles as ref_15
                  where false
                  limit 94)))) 
          or ((ref_2.user_id is NULL) 
            and (true)))) 
      or ((EXISTS (
          select  
              ref_0.hire_date as c0
            from 
              test_bd.eids as ref_16
                inner join test_bd.user_profiles as ref_17
                on (true)
            where ref_16.virtual_col is NULL)) 
        or (ref_0.salary is not NULL))) 
    or ((false) 
      or (false)))
limit 91;
SHOW profiles;