SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_3.c0 as c0, 
  subq_3.c0 as c1, 
  subq_3.c0 as c2, 
  subq_3.c2 as c3
from 
  (select  
          ref_0.username as c0
        from 
          test_bd.user_post_comments as ref_0
              inner join test_bd.comments as ref_1
              on (((EXISTS (
                      select  
                          ref_0.comment as c0, 
                          ref_1.comment as c1, 
                          subq_0.c1 as c2, 
                          (select tags from test_bd.products limit 1 offset 5)
                             as c3, 
                          ref_0.comment as c4, 
                          ref_1.comment as c5, 
                          ref_2.post_id as c6
                        from 
                          test_bd.comments as ref_2,
                          lateral (select  
                                ref_1.comment as c0, 
                                ref_2.comment as c1, 
                                ref_2.id as c2, 
                                ref_2.user_id as c3, 
                                (select username from test_bd.user_post_comments limit 1 offset 1)
                                   as c4, 
                                ref_2.created_at as c5
                              from 
                                test_bd.products as ref_3
                              where (ref_0.comment is not NULL) 
                                and (ref_1.user_id is not NULL)
                              limit 92) as subq_0
                        where false
                        limit 61)) 
                    or ((false) 
                      and (EXISTS (
                        select  
                            ref_0.comment as c0, 
                            ref_0.username as c1, 
                            ref_0.title as c2
                          from 
                            test_bd.employee as ref_4
                          where EXISTS (
                            select  
                                ref_4.department_id as c0, 
                                ref_4.salary as c1, 
                                ref_4.hire_date as c2, 
                                ref_1.created_at as c3, 
                                45 as c4
                              from 
                                test_bd.users as ref_5
                              where (false) 
                                and (true)
                              limit 113)
                          limit 139)))) 
                  and (false))
            left join test_bd.employee as ref_6
            on (ref_0.username is NULL)
        where false
        limit 132) as subq_1
    right join (select  
          ref_7.hire_date as c0, 
          ref_7.eid as c1, 
          ref_8.birthdate as c2
        from 
          test_bd.employee as ref_7
            left join test_bd.user_profiles as ref_8
            on (((ref_7.department_id is not NULL) 
                  or ((EXISTS (
                      select  
                          ref_8.profile_picture as c0, 
                          ref_7.years as c1, 
                          ref_8.birthdate as c2, 
                          ref_8.bio as c3, 
                          ref_7.years as c4
                        from 
                          test_bd.posts as ref_9
                        where true
                        limit 100)) 
                    or (EXISTS (
                      select  
                          ref_8.user_id as c0, 
                          ref_8.user_id as c1
                        from 
                          test_bd.user_profiles as ref_10
                        where ((ref_7.department_id is not NULL) 
                            or (true)) 
                          or (EXISTS (
                            select  
                                ref_8.profile_picture as c0
                              from 
                                test_bd.posts as ref_11
                              where true
                              limit 110)))))) 
                or (false))
        where EXISTS (
          select  
              ref_8.user_id as c0, 
              ref_12.created_at as c1, 
              (select name from test_bd.products limit 1 offset 6)
                 as c2, 
              ref_7.id as c3, 
              (select username from test_bd.users limit 1 offset 6)
                 as c4, 
              ref_8.user_id as c5, 
              ref_12.id as c6
            from 
              test_bd.users as ref_12
            where ((ref_8.user_id is not NULL) 
                or (EXISTS (
                  select  
                      ref_12.username as c0, 
                      ref_7.id as c1, 
                      subq_2.c25 as c2, 
                      ref_7.hire_date as c3, 
                      ref_8.profile_picture as c4, 
                      ref_12.email as c5, 
                      ref_8.bio as c6, 
                      ref_13.hire_date as c7, 
                      ref_12.username as c8, 
                      ref_12.created_at as c9, 
                      ref_12.username as c10, 
                      ref_7.age as c11, 
                      ref_7.years as c12, 
                      ref_13.years as c13, 
                      subq_2.c8 as c14
                    from 
                      test_bd.employee as ref_13,
                      lateral (select  
                            ref_7.eid as c0, 
                            ref_14.hire_date as c1, 
                            ref_7.years as c2, 
                            ref_12.username as c3, 
                            ref_12.username as c4, 
                            ref_7.age as c5, 
                            ref_13.department_id as c6, 
                            ref_8.profile_picture as c7, 
                            ref_13.salary as c8, 
                            ref_14.hire_date as c9, 
                            ref_12.email as c10, 
                            (select user_id from test_bd.locations limit 1 offset 3)
                               as c11, 
                            ref_13.hire_date as c12, 
                            ref_7.age as c13, 
                            (select hire_date from test_bd.employee limit 1 offset 2)
                               as c14, 
                            ref_14.age as c15, 
                            ref_14.salary as c16, 
                            ref_7.email as c17, 
                            ref_12.username as c18, 
                            ref_14.years as c19, 
                            ref_7.hire_date as c20, 
                            ref_12.created_at as c21, 
                            ref_14.department_id as c22, 
                            ref_8.birthdate as c23, 
                            ref_7.department_id as c24, 
                            ref_14.age as c25
                          from 
                            test_bd.employee as ref_14
                          where (ref_8.user_id is not NULL) 
                            and (((ref_8.bio is NULL) 
                                or (((true) 
                                    and (false)) 
                                  or ((EXISTS (
                                      select  
                                          ref_12.id as c0
                                        from 
                                          test_bd.user_post_comments as ref_15
                                        where false
                                        limit 139)) 
                                    or (true)))) 
                              and ((((ref_13.eid is NULL) 
                                    or (((true) 
                                        or (true)) 
                                      and (ref_8.birthdate is not NULL))) 
                                  and (false)) 
                                or ((EXISTS (
                                    select  
                                        ref_13.years as c0
                                      from 
                                        test_bd.products as ref_16
                                      where (((true) 
                                            and ((EXISTS (
                                                select  
                                                    ref_17.virtual_col as c0, 
                                                    ref_7.years as c1, 
                                                    ref_7.department_id as c2, 
                                                    ref_8.user_id as c3, 
                                                    ref_13.age as c4
                                                  from 
                                                    test_bd.eids as ref_17
                                                  where true
                                                  limit 152)) 
                                              or (false))) 
                                          or (ref_14.eid is not NULL)) 
                                        and (true)
                                      limit 45)) 
                                  and ((true) 
                                    and (false)))))
                          limit 169) as subq_2
                    where ref_12.email is not NULL
                    limit 155))) 
              and ((((ref_7.years is NULL) 
                    and (ref_8.bio is not NULL)) 
                  and (((ref_8.bio is NULL) 
                      or (ref_7.id is not NULL)) 
                    or (true))) 
                or (ref_8.profile_picture is NULL)))) as subq_3
    on ((((true) 
            or (((subq_3.c1 is NULL) 
                or (((false) 
                    and ((EXISTS (
                        select  
                            subq_1.c0 as c0, 
                            subq_3.c1 as c1, 
                            ref_18.title as c2, 
                            subq_3.c0 as c3
                          from 
                            test_bd.posts as ref_18
                          where (subq_3.c2 is not NULL) 
                            and (false)
                          limit 65)) 
                      or (((EXISTS (
                            select  
                                subq_3.c2 as c0
                              from 
                                test_bd.comments as ref_19
                              where (((EXISTS (
                                      select  
                                          ref_20.title as c0, 
                                          subq_3.c0 as c1, 
                                          ref_20.comment as c2, 
                                          subq_3.c1 as c3, 
                                          ref_20.username as c4, 
                                          subq_1.c0 as c5, 
                                          ref_20.title as c6, 
                                          subq_1.c0 as c7, 
                                          98 as c8, 
                                          51 as c9, 
                                          ref_20.comment as c10, 
                                          subq_3.c2 as c11, 
                                          subq_3.c2 as c12, 
                                          ref_19.user_id as c13, 
                                          ref_20.username as c14, 
                                          subq_1.c0 as c15
                                        from 
                                          test_bd.user_post_comments as ref_20
                                        where true
                                        limit 100)) 
                                    and (true)) 
                                  and (true)) 
                                or ((subq_3.c2 is not NULL) 
                                  or (true)))) 
                          and (((select profile_picture from test_bd.user_profiles limit 1 offset 3)
                                 is NULL) 
                            or (subq_3.c1 is NULL))) 
                        or ((subq_1.c0 is NULL) 
                          or (true))))) 
                  or ((subq_3.c2 is not NULL) 
                    or (((false) 
                        and (false)) 
                      or (subq_3.c2 is NULL))))) 
              or (true))) 
          and (EXISTS (
            select distinct 
                subq_1.c0 as c0, 
                ref_21.user_id as c1, 
                ref_21.coordinates as c2, 
                subq_3.c0 as c3, 
                subq_3.c1 as c4
              from 
                test_bd.locations as ref_21
              where EXISTS (
                select  
                    ref_21.coordinates as c0, 
                    subq_1.c0 as c1, 
                    ref_22.email as c2, 
                    ref_22.id as c3
                  from 
                    test_bd.users as ref_22
                  where false
                  limit 57)))) 
        or (coalesce(subq_1.c0,
            subq_1.c0) is NULL))
where subq_1.c0 is NULL
limit 77;
SHOW profiles;