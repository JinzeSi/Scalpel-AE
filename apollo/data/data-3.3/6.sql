SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_3.c0 as c0, 
  subq_3.c0 as c1
from 
  (select  
        ref_0.department_id as c0
      from 
        test_bd.employee as ref_0,
        lateral (select  
              ref_1.discount as c0, 
              ref_1.category as c1
            from 
              test_bd.products as ref_1
            where ((false) 
                or (false)) 
              and ((EXISTS (
                  select  
                      42 as c0, 
                      ref_2.department_id as c1, 
                      ref_1.id as c2, 
                      ref_2.age as c3, 
                      ref_2.email as c4, 
                      ref_0.department_id as c5, 
                      ref_0.hire_date as c6, 
                      ref_0.department_id as c7, 
                      ref_0.id as c8, 
                      ref_2.department_id as c9, 
                      ref_0.eid as c10, 
                      ref_1.created_at as c11, 
                      95 as c12, 
                      ref_0.salary as c13, 
                      ref_1.created_at as c14
                    from 
                      test_bd.employee as ref_2
                    where (true) 
                      or (false)
                    limit 39)) 
                and (((ref_1.category is NULL) 
                    and ((EXISTS (
                        select  
                            ref_3.hire_date as c0, 
                            ref_0.id as c1, 
                            ref_0.salary as c2, 
                            ref_3.hire_date as c3, 
                            ref_1.created_at as c4, 
                            ref_3.id as c5
                          from 
                            test_bd.employee as ref_3
                          where ref_0.salary is not NULL
                          limit 162)) 
                      and (true))) 
                  or (EXISTS (
                    select  
                        ref_0.age as c0, 
                        ref_0.email as c1
                      from 
                        test_bd.products as ref_4
                      where EXISTS (
                        select  
                            subq_0.c0 as c0, 
                            ref_5.comment as c1, 
                            subq_1.c1 as c2
                          from 
                            test_bd.user_post_comments as ref_5,
                            lateral (select  
                                  ref_4.id as c0, 
                                  ref_1.tags as c1
                                from 
                                  test_bd.users as ref_6
                                where true) as subq_0,
                            lateral (select  
                                  ref_0.department_id as c0, 
                                  8 as c1
                                from 
                                  test_bd.users as ref_7
                                where (ref_7.id is NULL) 
                                  and (subq_0.c0 is not NULL)) as subq_1
                          where (true) 
                            or (true))))))
            limit 55) as subq_2
      where (EXISTS (
          select  
              subq_2.c0 as c0, 
              subq_2.c1 as c1, 
              ref_0.hire_date as c2
            from 
              test_bd.user_post_comments as ref_8
            where ((true) 
                or ((false) 
                  and ((ref_8.username is NULL) 
                    and (((((ref_0.hire_date is NULL) 
                            and ((((((ref_8.comment is not NULL) 
                                      or ((true) 
                                        and (false))) 
                                    and (true)) 
                                  and ((subq_2.c0 is not NULL) 
                                    and (ref_0.hire_date is NULL))) 
                                and ((EXISTS (
                                    select  
                                        ref_0.email as c0, 
                                        32 as c1, 
                                        ref_8.username as c2, 
                                        ref_8.title as c3, 
                                        subq_2.c1 as c4, 
                                        subq_2.c1 as c5, 
                                        ref_9.price as c6, 
                                        ref_8.comment as c7, 
                                        subq_2.c1 as c8, 
                                        ref_9.price as c9, 
                                        ref_9.price as c10, 
                                        ref_8.username as c11
                                      from 
                                        test_bd.products as ref_9
                                      where (true) 
                                        or (ref_0.salary is NULL)
                                      limit 187)) 
                                  or (ref_0.age is NULL))) 
                              and (EXISTS (
                                select  
                                    subq_2.c1 as c0, 
                                    ref_8.comment as c1, 
                                    ref_0.eid as c2, 
                                    subq_2.c1 as c3, 
                                    subq_2.c1 as c4, 
                                    ref_10.age as c5, 
                                    subq_2.c0 as c6, 
                                    ref_8.comment as c7, 
                                    ref_10.eid as c8, 
                                    ref_0.eid as c9, 
                                    ref_8.username as c10, 
                                    ref_0.salary as c11, 
                                    subq_2.c1 as c12, 
                                    ref_10.email as c13
                                  from 
                                    test_bd.employee as ref_10
                                  where (false) 
                                    or (true)
                                  limit 172)))) 
                          and (ref_8.username is not NULL)) 
                        or (false)) 
                      or (((ref_8.comment is NULL) 
                          and (subq_2.c0 is NULL)) 
                        and (true)))))) 
              and (true))) 
        and ((((true) 
              and (false)) 
            and (ref_0.email is not NULL)) 
          or (true))
      limit 151) as subq_3
where ((EXISTS (
      select  
          ref_11.created_at as c0, 
          subq_3.c0 as c1, 
          ref_11.name as c2, 
          ref_12.id as c3, 
          ref_11.price as c4
        from 
          test_bd.products as ref_11
            right join test_bd.products as ref_12
            on (ref_11.created_at = ref_12.created_at )
        where ((EXISTS (
              select  
                  ref_12.price as c0
                from 
                  test_bd.eids as ref_13
                where (((ref_13.id is not NULL) 
                      or (ref_12.category is NULL)) 
                    or (EXISTS (
                      select  
                          ref_11.category as c0, 
                          subq_3.c0 as c1, 
                          ref_11.discount as c2, 
                          ref_14.id as c3, 
                          subq_4.c1 as c4, 
                          ref_13.id as c5
                        from 
                          test_bd.posts as ref_14,
                          lateral (select  
                                subq_3.c0 as c0, 
                                subq_3.c0 as c1, 
                                ref_12.created_at as c2, 
                                ref_12.created_at as c3, 
                                ref_11.tags as c4, 
                                subq_3.c0 as c5, 
                                ref_12.id as c6, 
                                ref_13.virtual_col as c7
                              from 
                                test_bd.comments as ref_15
                              where ((true) 
                                  and (true)) 
                                or (false)
                              limit 135) as subq_4
                        where (false) 
                          and ((subq_4.c6 is NULL) 
                            or (((EXISTS (
                                  select  
                                      subq_3.c0 as c0
                                    from 
                                      test_bd.user_profiles as ref_16,
                                      lateral (select  
                                            ref_14.updated_at as c0, 
                                            ref_16.bio as c1, 
                                            ref_12.name as c2, 
                                            ref_12.created_at as c3, 
                                            ref_11.tags as c4
                                          from 
                                            test_bd.user_profiles as ref_17
                                          where true) as subq_5
                                    where EXISTS (
                                      select  
                                          ref_14.id as c0
                                        from 
                                          test_bd.user_profiles as ref_18
                                        where (((true) 
                                              and (false)) 
                                            or ((52 is not NULL) 
                                              or (false))) 
                                          or ((subq_3.c0 is NULL) 
                                            and ((false) 
                                              and (false)))
                                        limit 153)
                                    limit 26)) 
                                or (false)) 
                              or (EXISTS (
                                select  
                                    ref_11.created_at as c0, 
                                    ref_11.price as c1, 
                                    ref_12.tags as c2, 
                                    ref_13.eid as c3, 
                                    subq_4.c1 as c4, 
                                    subq_3.c0 as c5, 
                                    ref_14.updated_at as c6, 
                                    ref_14.user_id as c7, 
                                    49 as c8, 
                                    73 as c9, 
                                    ref_19.eid as c10
                                  from 
                                    test_bd.eids as ref_19,
                                    lateral (select  
                                          ref_13.virtual_col as c0, 
                                          ref_13.id as c1, 
                                          subq_4.c3 as c2, 
                                          ref_14.id as c3, 
                                          subq_4.c7 as c4, 
                                          ref_14.user_id as c5, 
                                          subq_3.c0 as c6, 
                                          ref_11.id as c7, 
                                          ref_12.id as c8, 
                                          ref_14.created_at as c9, 
                                          ref_11.tags as c10, 
                                          subq_3.c0 as c11, 
                                          ref_12.id as c12
                                        from 
                                          test_bd.user_post_comments as ref_20
                                        where EXISTS (
                                          select  
                                              ref_20.comment as c0
                                            from 
                                              test_bd.posts as ref_21
                                            where true
                                            limit 104)
                                        limit 104) as subq_6
                                  where (false) 
                                    and ((true) 
                                      or (true))))))
                        limit 106))) 
                  and (((EXISTS (
                        select  
                            subq_3.c0 as c0, 
                            ref_12.id as c1, 
                            ref_11.price as c2
                          from 
                            test_bd.user_profiles as ref_22,
                            lateral (select  
                                  ref_13.id as c0, 
                                  subq_3.c0 as c1, 
                                  ref_23.id as c2
                                from 
                                  test_bd.comments as ref_23
                                where EXISTS (
                                  select  
                                      ref_24.user_id as c0, 
                                      (select created_at from test_bd.comments limit 1 offset 1)
                                         as c1
                                    from 
                                      test_bd.posts as ref_24
                                    where true
                                    limit 132)
                                limit 142) as subq_7,
                            lateral (select  
                                  ref_22.bio as c0, 
                                  subq_7.c0 as c1, 
                                  73 as c2, 
                                  ref_12.name as c3, 
                                  ref_13.virtual_col as c4, 
                                  ref_13.virtual_col as c5, 
                                  ref_11.category as c6, 
                                  ref_22.bio as c7, 
                                  subq_7.c1 as c8, 
                                  ref_22.user_id as c9
                                from 
                                  test_bd.users as ref_25
                                where true
                                limit 51) as subq_8
                          where (((false) 
                                or (true)) 
                              and (true)) 
                            and ((EXISTS (
                                select  
                                    ref_13.eid as c0, 
                                    ref_13.virtual_col as c1, 
                                    subq_8.c8 as c2, 
                                    subq_8.c0 as c3
                                  from 
                                    test_bd.user_profiles as ref_26
                                  where ref_13.eid is NULL
                                  limit 72)) 
                              and (EXISTS (
                                select  
                                    subq_7.c2 as c0, 
                                    ref_22.birthdate as c1, 
                                    ref_12.price as c2, 
                                    ref_22.bio as c3, 
                                    ref_12.tags as c4
                                  from 
                                    test_bd.products as ref_27
                                  where ref_22.profile_picture is NULL
                                  limit 50))))) 
                      or ((false) 
                        and (((select discount from test_bd.products limit 1 offset 5)
                               is NULL) 
                          or ((true) 
                            or (true))))) 
                    and (EXISTS (
                      select  
                          ref_11.tags as c0
                        from 
                          test_bd.users as ref_28
                        where (false) 
                          and (EXISTS (
                            select  
                                ref_13.eid as c0
                              from 
                                test_bd.products as ref_29,
                                lateral (select  
                                      ref_29.id as c0
                                    from 
                                      test_bd.users as ref_30
                                    where false
                                    limit 37) as subq_9
                              where false
                              limit 153))
                        limit 94)))
                limit 148)) 
            and (EXISTS (
              select  
                  ref_31.id as c0, 
                  subq_3.c0 as c1, 
                  (select username from test_bd.user_post_comments limit 1 offset 5)
                     as c2, 
                  ref_12.created_at as c3, 
                  subq_3.c0 as c4
                from 
                  test_bd.posts as ref_31
                where ref_31.id is not NULL
                limit 104))) 
          or (ref_12.created_at is NULL))) 
    and (false)) 
  or (((((subq_3.c0 is NULL) 
          and ((((subq_3.c0 is NULL) 
                and (false)) 
              and (subq_3.c0 is NULL)) 
            or ((select id from test_bd.users limit 1 offset 5)
                 is NULL))) 
        and ((EXISTS (
            select  
                ref_32.created_at as c0, 
                subq_3.c0 as c1, 
                subq_3.c0 as c2, 
                subq_3.c0 as c3, 
                ref_32.id as c4, 
                (select user_id from test_bd.locations limit 1 offset 1)
                   as c5, 
                ref_32.created_at as c6, 
                (select id from test_bd.products limit 1 offset 6)
                   as c7, 
                subq_3.c0 as c8, 
                ref_32.username as c9, 
                ref_32.created_at as c10
              from 
                test_bd.users as ref_32
              where false
              limit 44)) 
          or ((true) 
            or (subq_3.c0 is NULL)))) 
      or (subq_3.c0 is not NULL)) 
    and ((subq_3.c0 is NULL) 
      or (subq_3.c0 is not NULL)));
SHOW profiles;