SET profiling=1;
EXPLAIN ANALYZE

select  
  case when (((true) 
          or (true)) 
        or ((ref_1.created_at is NULL) 
          or ((ref_1.tags is not NULL) 
            or ((EXISTS (
                select  
                    (select username from test_bd.user_post_comments limit 1 offset 6)
                       as c0, 
                    ref_1.created_at as c1
                  from 
                    test_bd.users as ref_25
                  where ref_1.tags is NULL
                  limit 104)) 
              and ((((EXISTS (
                      select  
                          63 as c0, 
                          ref_26.created_at as c1, 
                          ref_1.name as c2, 
                          ref_26.content as c3, 
                          64 as c4, 
                          ref_0.id as c5
                        from 
                          test_bd.posts as ref_26
                        where true
                        limit 66)) 
                    and (true)) 
                  and ((((false) 
                        and (false)) 
                      or (false)) 
                    or ((ref_1.created_at is NULL) 
                      or ((ref_1.name is not NULL) 
                        or (EXISTS (
                          select  
                              ref_1.price as c0
                            from 
                              test_bd.products as ref_27
                            where ref_1.discount is not NULL
                            limit 137)))))) 
                and (true)))))) 
      and (ref_0.user_id is NULL) then ref_0.coordinates else ref_0.coordinates end
     as c0, 
  ref_0.user_id as c1, 
  case when (((ref_1.id is not NULL) 
          or (((((true) 
                  or (EXISTS (
                    select  
                        ref_0.user_id as c0, 
                        ref_28.id as c1, 
                        ref_28.created_at as c2
                      from 
                        test_bd.comments as ref_28
                      where ref_0.id is NULL
                      limit 14))) 
                and ((ref_0.coordinates is not NULL) 
                  or (ref_0.name is not NULL))) 
              or (true)) 
            and (68 is NULL))) 
        or ((ref_0.id is not NULL) 
          or (ref_0.coordinates is NULL))) 
      and (((9 is not NULL) 
          or (EXISTS (
            select  
                41 as c0, 
                ref_1.id as c1, 
                ref_0.user_id as c2
              from 
                test_bd.posts as ref_29
              where EXISTS (
                select  
                    53 as c0
                  from 
                    test_bd.user_profiles as ref_30
                  where (false) 
                    or (((false) 
                        and (EXISTS (
                          select  
                              ref_30.birthdate as c0, 
                              99 as c1, 
                              ref_30.birthdate as c2, 
                              ref_30.bio as c3
                            from 
                              test_bd.employee as ref_31
                            where EXISTS (
                              select  
                                  ref_32.department_id as c0, 
                                  ref_0.user_id as c1, 
                                  ref_0.user_id as c2
                                from 
                                  test_bd.employee as ref_32,
                                  lateral (select  
                                        ref_30.user_id as c0, 
                                        ref_33.eid as c1, 
                                        ref_1.name as c2, 
                                        ref_30.profile_picture as c3, 
                                        ref_0.name as c4, 
                                        ref_0.name as c5, 
                                        ref_0.coordinates as c6, 
                                        ref_0.coordinates as c7
                                      from 
                                        test_bd.eids as ref_33
                                      where false
                                      limit 190) as subq_5
                                where true
                                limit 144)))) 
                      and (true)))))) 
        or ((ref_1.price is not NULL) 
          and (ref_1.id is NULL))) then ref_0.id else ref_0.id end
     as c2, 
  ref_1.price as c3, 
  ref_1.tags as c4
from 
  test_bd.locations as ref_0
    inner join test_bd.products as ref_1
    on ((true) 
        or (((((3 is NULL) 
                and (((((true) 
                        and (ref_0.user_id is not NULL)) 
                      or (EXISTS (
                        select  
                            ref_0.user_id as c0, 
                            ref_2.department_id as c1, 
                            ref_2.years as c2, 
                            ref_2.salary as c3, 
                            ref_2.id as c4, 
                            ref_0.user_id as c5, 
                            (select email from test_bd.users limit 1 offset 1)
                               as c6, 
                            ref_0.user_id as c7, 
                            ref_0.user_id as c8, 
                            ref_0.user_id as c9, 
                            ref_0.user_id as c10, 
                            ref_0.id as c11, 
                            ref_2.id as c12
                          from 
                            test_bd.employee as ref_2
                          where ref_2.department_id is not NULL
                          limit 126))) 
                    and ((EXISTS (
                        select  
                            ref_3.id as c0, 
                            ref_1.created_at as c1
                          from 
                            test_bd.locations as ref_3
                          where ((false) 
                              or (true)) 
                            and (true)
                          limit 62)) 
                      or (false))) 
                  or (ref_0.id is NULL))) 
              or ((((EXISTS (
                      select  
                          ref_0.coordinates as c0, 
                          ref_4.virtual_col as c1
                        from 
                          test_bd.eids as ref_4
                        where true)) 
                    or ((false) 
                      and (ref_0.name is not NULL))) 
                  and ((ref_1.tags is NULL) 
                    or (false))) 
                and ((((((false) 
                          or (false)) 
                        and (EXISTS (
                          select  
                              ref_0.id as c0, 
                              ref_5.title as c1, 
                              ref_0.name as c2
                            from 
                              test_bd.user_post_comments as ref_5
                            where ((false) 
                                or (EXISTS (
                                  select  
                                      ref_1.name as c0, 
                                      ref_0.id as c1, 
                                      ref_5.title as c2, 
                                      ref_1.tags as c3, 
                                      ref_0.id as c4, 
                                      ref_1.discount as c5
                                    from 
                                      test_bd.user_profiles as ref_6
                                    where ref_6.profile_picture is not NULL
                                    limit 124))) 
                              and ((ref_5.title is NULL) 
                                and (true))
                            limit 84))) 
                      or (EXISTS (
                        select  
                            ref_0.name as c0, 
                            ref_1.name as c1
                          from 
                            test_bd.locations as ref_7
                          where false))) 
                    and ((EXISTS (
                        select  
                            ref_1.id as c0, 
                            subq_0.c8 as c1, 
                            subq_0.c4 as c2, 
                            subq_0.c3 as c3, 
                            ref_1.name as c4, 
                            subq_0.c3 as c5, 
                            86 as c6, 
                            ref_0.coordinates as c7, 
                            39 as c8, 
                            subq_0.c1 as c9, 
                            ref_1.tags as c10, 
                            subq_0.c3 as c11, 
                            (select email from test_bd.users limit 1 offset 1)
                               as c12, 
                            ref_8.title as c13, 
                            75 as c14, 
                            ref_8.user_id as c15, 
                            ref_8.updated_at as c16, 
                            ref_0.coordinates as c17
                          from 
                            test_bd.posts as ref_8,
                            lateral (select  
                                  ref_9.virtual_col as c0, 
                                  ref_1.discount as c1, 
                                  ref_1.name as c2, 
                                  ref_9.virtual_col as c3, 
                                  ref_0.coordinates as c4, 
                                  ref_9.virtual_col as c5, 
                                  ref_0.coordinates as c6, 
                                  95 as c7, 
                                  ref_1.price as c8, 
                                  (select eid from test_bd.eids limit 1 offset 1)
                                     as c9, 
                                  ref_1.created_at as c10, 
                                  ref_9.eid as c11
                                from 
                                  test_bd.eids as ref_9
                                where (false) 
                                  and (true)
                                limit 105) as subq_0
                          where EXISTS (
                            select  
                                subq_2.c0 as c0, 
                                ref_1.discount as c1
                              from 
                                test_bd.employee as ref_10,
                                lateral (select  
                                      ref_10.id as c0, 
                                      ref_1.created_at as c1
                                    from 
                                      test_bd.user_profiles as ref_11,
                                      lateral (select  
                                            ref_8.id as c0, 
                                            ref_0.name as c1, 
                                            subq_0.c3 as c2, 
                                            ref_8.created_at as c3, 
                                            ref_8.id as c4, 
                                            (select created_at from test_bd.comments limit 1 offset 4)
                                               as c5
                                          from 
                                            test_bd.user_profiles as ref_12
                                          where false) as subq_1
                                    where true
                                    limit 80) as subq_2
                              where true
                              limit 80)
                          limit 80)) 
                      and (((ref_1.created_at is not NULL) 
                          or (ref_0.coordinates is not NULL)) 
                        or (false)))) 
                  or ((true) 
                    or ((EXISTS (
                        select  
                            ref_0.user_id as c0, 
                            (select discount from test_bd.products limit 1 offset 5)
                               as c1, 
                            ref_1.category as c2, 
                            ref_0.user_id as c3, 
                            ref_0.user_id as c4, 
                            ref_0.user_id as c5, 
                            ref_1.created_at as c6, 
                            ref_0.coordinates as c7, 
                            ref_0.id as c8
                          from 
                            test_bd.employee as ref_13
                          where true
                          limit 115)) 
                      and (true)))))) 
            and (EXISTS (
              select  
                  ref_1.category as c0, 
                  ref_1.category as c1
                from 
                  test_bd.comments as ref_14
                where ((true) 
                    and (ref_0.user_id is NULL)) 
                  and (ref_0.name is not NULL)
                limit 45))) 
          and (((((false) 
                  and (ref_0.name is NULL)) 
                and (((EXISTS (
                      select  
                          ref_0.name as c0
                        from 
                          test_bd.posts as ref_15
                        where ref_0.coordinates is not NULL
                        limit 144)) 
                    or (ref_0.id is not NULL)) 
                  and ((true) 
                    and (ref_1.discount is not NULL)))) 
              or (((false) 
                  or ((true) 
                    or (true))) 
                or ((true) 
                  and (ref_0.user_id is not NULL)))) 
            or (((true) 
                and (EXISTS (
                  select  
                      ref_16.department_id as c0, 
                      ref_16.id as c1, 
                      ref_0.user_id as c2, 
                      ref_16.email as c3, 
                      ref_1.discount as c4, 
                      ref_16.department_id as c5, 
                      ref_0.coordinates as c6, 
                      ref_1.category as c7, 
                      (select username from test_bd.user_post_comments limit 1 offset 3)
                         as c8, 
                      ref_16.age as c9, 
                      ref_16.department_id as c10, 
                      ref_1.name as c11, 
                      ref_0.user_id as c12, 
                      ref_0.coordinates as c13
                    from 
                      test_bd.employee as ref_16
                    where ((EXISTS (
                          select  
                              ref_0.user_id as c0, 
                              ref_1.id as c1, 
                              ref_17.virtual_col as c2, 
                              ref_1.tags as c3, 
                              42 as c4, 
                              ref_0.user_id as c5, 
                              ref_1.category as c6, 
                              ref_1.category as c7, 
                              ref_16.id as c8, 
                              (select eid from test_bd.eids limit 1 offset 3)
                                 as c9, 
                              24 as c10, 
                              ref_16.email as c11
                            from 
                              test_bd.eids as ref_17
                            where ref_1.name is NULL
                            limit 114)) 
                        or (ref_16.email is not NULL)) 
                      and ((false) 
                        and ((true) 
                          or ((((true) 
                                or ((true) 
                                  and ((ref_16.hire_date is NULL) 
                                    or (false)))) 
                              or ((false) 
                                or (true))) 
                            and ((EXISTS (
                                select  
                                    subq_3.c0 as c0
                                  from 
                                    test_bd.products as ref_18,
                                    lateral (select  
                                          ref_18.category as c0, 
                                          ref_18.name as c1
                                        from 
                                          test_bd.employee as ref_19
                                        where ref_18.price is NULL) as subq_3
                                  where subq_3.c1 is not NULL
                                  limit 164)) 
                              and ((EXISTS (
                                  select  
                                      ref_1.category as c0, 
                                      ref_0.coordinates as c1, 
                                      ref_16.salary as c2, 
                                      ref_1.discount as c3, 
                                      ref_1.name as c4, 
                                      ref_16.years as c5, 
                                      ref_0.user_id as c6
                                    from 
                                      test_bd.eids as ref_20
                                    where ref_16.years is NULL
                                    limit 128)) 
                                and (false))))))
                    limit 94))) 
              and ((ref_0.name is NULL) 
                and (((ref_0.user_id is NULL) 
                    or (ref_1.created_at is NULL)) 
                  and (((false) 
                      or (EXISTS (
                        select  
                            (select price from test_bd.products limit 1 offset 6)
                               as c0, 
                            ref_21.virtual_col as c1, 
                            ref_0.id as c2, 
                            ref_1.created_at as c3, 
                            ref_21.virtual_col as c4, 
                            ref_21.id as c5, 
                            50 as c6, 
                            (select user_id from test_bd.posts limit 1 offset 3)
                               as c7, 
                            ref_21.virtual_col as c8, 
                            ref_0.id as c9, 
                            ref_1.tags as c10, 
                            ref_1.name as c11
                          from 
                            test_bd.eids as ref_21
                          where (((false) 
                                or ((false) 
                                  or (((true) 
                                      and (((false) 
                                          and (true)) 
                                        and ((ref_0.id is NULL) 
                                          and (true)))) 
                                    or (EXISTS (
                                      select  
                                          ref_22.email as c0, 
                                          ref_1.tags as c1, 
                                          ref_21.id as c2
                                        from 
                                          test_bd.users as ref_22
                                        where (true) 
                                          and (false)))))) 
                              and (true)) 
                            and ((ref_21.eid is NULL) 
                              or (EXISTS (
                                select  
                                    ref_1.price as c0, 
                                    ref_23.id as c1, 
                                    ref_21.id as c2, 
                                    ref_21.virtual_col as c3, 
                                    ref_1.tags as c4, 
                                    ref_0.user_id as c5, 
                                    subq_4.c4 as c6, 
                                    56 as c7, 
                                    ref_1.price as c8, 
                                    ref_0.id as c9, 
                                    ref_21.virtual_col as c10, 
                                    ref_23.id as c11, 
                                    subq_4.c0 as c12, 
                                    ref_23.id as c13
                                  from 
                                    test_bd.users as ref_23,
                                    lateral (select  
                                          ref_24.created_at as c0, 
                                          ref_23.id as c1, 
                                          ref_24.username as c2, 
                                          ref_21.virtual_col as c3, 
                                          ref_23.created_at as c4, 
                                          ref_23.username as c5, 
                                          ref_0.user_id as c6
                                        from 
                                          test_bd.users as ref_24
                                        where ((false) 
                                            and ((ref_23.created_at is not NULL) 
                                              or (true))) 
                                          or (true)
                                        limit 11) as subq_4
                                  where false
                                  limit 147)))
                          limit 128))) 
                    or (false))))))))
where ref_1.price is not NULL
limit 116;
SHOW profiles;