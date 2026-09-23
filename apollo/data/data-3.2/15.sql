SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_4.c0 as c0, 
  subq_4.c1 as c1
from 
  (select  
        subq_2.c1 as c0, 
        subq_2.c1 as c1
      from 
        (select  
              (select title from test_bd.user_post_comments limit 1 offset 6)
                 as c0, 
              ref_0.id as c1
            from 
              test_bd.users as ref_0
            where (((false) 
                  or ((EXISTS (
                      select  
                          ref_1.salary as c0, 
                          ref_0.created_at as c1, 
                          ref_0.id as c2
                        from 
                          test_bd.employee as ref_1,
                          lateral (select  
                                ref_0.created_at as c0, 
                                ref_1.age as c1, 
                                70 as c2, 
                                ref_0.id as c3, 
                                ref_2.profile_picture as c4, 
                                ref_0.email as c5
                              from 
                                test_bd.user_profiles as ref_2
                              where true
                              limit 150) as subq_0,
                          lateral (select  
                                subq_0.c4 as c0, 
                                subq_0.c4 as c1, 
                                ref_3.created_at as c2, 
                                ref_0.email as c3, 
                                ref_1.email as c4, 
                                ref_0.email as c5, 
                                ref_3.username as c6, 
                                ref_3.created_at as c7, 
                                ref_3.email as c8, 
                                ref_0.created_at as c9
                              from 
                                test_bd.users as ref_3
                              where (false) 
                                and (false)
                              limit 86) as subq_1
                        where ((select id from test_bd.posts limit 1 offset 2)
                               is NULL) 
                          or (subq_1.c4 is not NULL))) 
                    or (false))) 
                and ((ref_0.created_at is NULL) 
                  and (EXISTS (
                    select  
                        ref_4.name as c0, 
                        ref_0.id as c1, 
                        ref_4.name as c2, 
                        ref_0.email as c3, 
                        ref_4.coordinates as c4, 
                        ref_4.name as c5, 
                        ref_0.id as c6, 
                        ref_4.coordinates as c7, 
                        ref_0.id as c8, 
                        ref_4.id as c9, 
                        ref_0.id as c10, 
                        ref_0.created_at as c11, 
                        ref_0.created_at as c12
                      from 
                        test_bd.locations as ref_4
                      where ((true) 
                          or ((ref_0.username is not NULL) 
                            or (false))) 
                        or ((false) 
                          and (false))
                      limit 102)))) 
              and ((EXISTS (
                  select  
                      13 as c0
                    from 
                      test_bd.users as ref_5
                    where ((((true) 
                            and ((EXISTS (
                                select  
                                    ref_6.price as c0, 
                                    ref_0.created_at as c1, 
                                    ref_0.id as c2, 
                                    ref_6.discount as c3
                                  from 
                                    test_bd.products as ref_6
                                  where false)) 
                              and (EXISTS (
                                select  
                                    (select username from test_bd.user_post_comments limit 1 offset 5)
                                       as c0, 
                                    ref_0.username as c1, 
                                    ref_0.username as c2
                                  from 
                                    test_bd.employee as ref_7
                                  where true
                                  limit 67)))) 
                          and (false)) 
                        and (ref_5.username is NULL)) 
                      or (((((false) 
                              or ((true) 
                                or (EXISTS (
                                  select  
                                      ref_5.created_at as c0, 
                                      ref_8.eid as c1, 
                                      ref_0.email as c2
                                    from 
                                      test_bd.employee as ref_8
                                    where ref_8.email is NULL)))) 
                            or (((ref_0.id is not NULL) 
                                and (ref_5.created_at is NULL)) 
                              or ((false) 
                                and ((false) 
                                  or (false))))) 
                          and ((true) 
                            and (((EXISTS (
                                  select  
                                      ref_0.email as c0, 
                                      ref_0.id as c1, 
                                      ref_9.user_id as c2, 
                                      56 as c3, 
                                      ref_0.username as c4, 
                                      ref_9.user_id as c5, 
                                      ref_9.id as c6, 
                                      ref_9.updated_at as c7, 
                                      ref_9.content as c8, 
                                      ref_0.username as c9, 
                                      ref_0.email as c10, 
                                      ref_5.created_at as c11, 
                                      ref_0.id as c12
                                    from 
                                      test_bd.posts as ref_9
                                    where (((((false) 
                                              and (false)) 
                                            or (ref_0.email is not NULL)) 
                                          or (90 is not NULL)) 
                                        or (false)) 
                                      and ((EXISTS (
                                          select  
                                              ref_9.user_id as c0
                                            from 
                                              test_bd.comments as ref_10
                                            where (false) 
                                              and (false)
                                            limit 28)) 
                                        or (ref_9.updated_at is NULL))
                                    limit 148)) 
                                and (((false) 
                                    and (ref_0.id is NULL)) 
                                  or (ref_0.email is NULL))) 
                              and (EXISTS (
                                select  
                                    ref_11.hire_date as c0, 
                                    ref_0.email as c1, 
                                    ref_0.email as c2, 
                                    7 as c3, 
                                    (select name from test_bd.locations limit 1 offset 2)
                                       as c4, 
                                    ref_5.id as c5, 
                                    ref_5.username as c6, 
                                    ref_11.department_id as c7, 
                                    ref_11.salary as c8, 
                                    ref_5.created_at as c9, 
                                    ref_11.email as c10, 
                                    ref_0.username as c11, 
                                    ref_11.age as c12, 
                                    ref_0.email as c13, 
                                    ref_0.email as c14, 
                                    ref_0.email as c15, 
                                    ref_5.email as c16, 
                                    ref_5.username as c17, 
                                    ref_11.email as c18, 
                                    ref_11.department_id as c19, 
                                    ref_5.created_at as c20, 
                                    100 as c21, 
                                    (select category from test_bd.products limit 1 offset 54)
                                       as c22, 
                                    ref_0.username as c23, 
                                    ref_0.email as c24, 
                                    28 as c25, 
                                    ref_0.username as c26, 
                                    (select discount from test_bd.products limit 1 offset 2)
                                       as c27, 
                                    (select name from test_bd.locations limit 1 offset 3)
                                       as c28
                                  from 
                                    test_bd.employee as ref_11
                                  where (false) 
                                    and (true)))))) 
                        or (ref_5.username is not NULL))
                    limit 75)) 
                or (false))) as subq_2
      where ((true) 
          or (false)) 
        and (((((true) 
                and (subq_2.c0 is NULL)) 
              or ((((100 is not NULL) 
                    and ((false) 
                      or (subq_2.c1 is not NULL))) 
                  and (EXISTS (
                    select  
                        subq_2.c1 as c0, 
                        ref_12.name as c1, 
                        subq_2.c0 as c2, 
                        subq_2.c0 as c3, 
                        ref_12.name as c4, 
                        subq_2.c1 as c5, 
                        ref_12.user_id as c6, 
                        ref_12.coordinates as c7, 
                        subq_2.c1 as c8
                      from 
                        test_bd.locations as ref_12
                      where (true) 
                        or (EXISTS (
                          select  
                              ref_12.coordinates as c0
                            from 
                              test_bd.products as ref_13
                            where ((ref_13.name is not NULL) 
                                and (true)) 
                              or (false)
                            limit 14))
                      limit 104))) 
                or (EXISTS (
                  select  
                      subq_2.c0 as c0, 
                      subq_3.c10 as c1, 
                      subq_2.c0 as c2, 
                      subq_3.c7 as c3, 
                      subq_2.c1 as c4, 
                      ref_14.bio as c5, 
                      79 as c6, 
                      subq_2.c1 as c7, 
                      subq_2.c0 as c8, 
                      ref_14.profile_picture as c9, 
                      ref_14.profile_picture as c10, 
                      subq_2.c0 as c11, 
                      subq_2.c0 as c12, 
                      subq_2.c1 as c13
                    from 
                      test_bd.user_profiles as ref_14,
                      lateral (select  
                            78 as c0, 
                            subq_2.c0 as c1, 
                            subq_2.c0 as c2, 
                            (select username from test_bd.users limit 1 offset 3)
                               as c3, 
                            ref_14.user_id as c4, 
                            ref_14.birthdate as c5, 
                            ref_14.user_id as c6, 
                            89 as c7, 
                            subq_2.c1 as c8, 
                            ref_15.profile_picture as c9, 
                            subq_2.c0 as c10, 
                            subq_2.c1 as c11
                          from 
                            test_bd.user_profiles as ref_15
                          where true
                          limit 113) as subq_3
                    where (true) 
                      and (((false) 
                          or (true)) 
                        or (subq_3.c6 is NULL))
                    limit 115)))) 
            or (subq_2.c0 is NULL)) 
          or (true))
      limit 24) as subq_4
where ((EXISTS (
      select  
          ref_16.user_id as c0, 
          subq_4.c1 as c1, 
          19 as c2, 
          subq_4.c1 as c3, 
          subq_4.c1 as c4
        from 
          test_bd.comments as ref_16
        where false)) 
    and (EXISTS (
      select  
          ref_17.id as c0, 
          subq_4.c1 as c1, 
          38 as c2, 
          ref_17.name as c3, 
          subq_5.c0 as c4, 
          ref_17.name as c5, 
          ref_17.name as c6, 
          subq_4.c0 as c7, 
          subq_4.c0 as c8
        from 
          test_bd.products as ref_17,
          lateral (select  
                ref_18.title as c0, 
                ref_18.comment as c1, 
                subq_4.c1 as c2, 
                ref_19.title as c3, 
                ref_18.comment as c4, 
                ref_18.title as c5, 
                ref_19.comment as c6, 
                subq_4.c1 as c7
              from 
                test_bd.user_post_comments as ref_18
                  inner join test_bd.user_post_comments as ref_19
                  on ((true) 
                      and (ref_17.price is NULL))
              where (false) 
                and (ref_17.price is NULL)) as subq_5
        where false
        limit 51))) 
  or ((((EXISTS (
          select  
              subq_4.c1 as c0, 
              (select id from test_bd.comments limit 1 offset 4)
                 as c1, 
              ref_21.user_id as c2, 
              subq_4.c0 as c3, 
              ref_20.id as c4, 
              subq_4.c0 as c5, 
              ref_21.id as c6
            from 
              test_bd.eids as ref_20
                right join test_bd.locations as ref_21
                on (((((EXISTS (
                            select  
                                ref_21.coordinates as c0, 
                                ref_21.user_id as c1, 
                                ref_20.eid as c2, 
                                47 as c3
                              from 
                                test_bd.eids as ref_22
                              where (true) 
                                or (true)
                              limit 93)) 
                          and ((subq_4.c1 is not NULL) 
                            or (false))) 
                        or ((true) 
                          and (false))) 
                      and (false)) 
                    and ((true) 
                      or (subq_4.c1 is NULL)))
            where ref_21.name is NULL
            limit 131)) 
        or (false)) 
      and (((EXISTS (
            select  
                ref_23.name as c0
              from 
                test_bd.locations as ref_23
              where ref_23.name is NULL)) 
          or (true)) 
        or (EXISTS (
          select  
              ref_24.tags as c0, 
              ref_24.price as c1, 
              subq_4.c1 as c2, 
              (select email from test_bd.employee limit 1 offset 2)
                 as c3, 
              subq_4.c0 as c4, 
              subq_4.c0 as c5, 
              ref_24.price as c6, 
              ref_24.tags as c7, 
              ref_24.name as c8, 
              subq_4.c1 as c9, 
              ref_24.created_at as c10, 
              46 as c11, 
              ref_24.tags as c12, 
              ref_24.created_at as c13, 
              ref_24.created_at as c14, 
              (select user_id from test_bd.comments limit 1 offset 5)
                 as c15, 
              ref_24.tags as c16, 
              subq_4.c1 as c17, 
              ref_24.tags as c18
            from 
              test_bd.products as ref_24
            where ((EXISTS (
                  select  
                      (select tags from test_bd.products limit 1 offset 5)
                         as c0, 
                      subq_4.c1 as c1
                    from 
                      test_bd.posts as ref_25
                    where false
                    limit 131)) 
                and (true)) 
              and (subq_4.c0 is NULL)
            limit 166)))) 
    or (((subq_4.c1 is NULL) 
        or (((EXISTS (
              select  
                  ref_26.eid as c0, 
                  ref_26.virtual_col as c1, 
                  ref_26.virtual_col as c2, 
                  ref_26.virtual_col as c3, 
                  subq_4.c0 as c4, 
                  ref_26.virtual_col as c5, 
                  subq_4.c1 as c6, 
                  subq_4.c0 as c7, 
                  ref_26.virtual_col as c8, 
                  subq_4.c1 as c9, 
                  subq_4.c0 as c10, 
                  ref_26.id as c11, 
                  subq_4.c0 as c12
                from 
                  test_bd.eids as ref_26
                where false
                limit 21)) 
            and ((EXISTS (
                select  
                    subq_4.c1 as c0, 
                    subq_4.c1 as c1, 
                    ref_27.name as c2, 
                    subq_4.c1 as c3, 
                    ref_27.name as c4, 
                    ref_27.user_id as c5
                  from 
                    test_bd.locations as ref_27
                  where ((true) 
                      and (ref_27.user_id is not NULL)) 
                    or (EXISTS (
                      select  
                          subq_6.c0 as c0, 
                          ref_28.created_at as c1, 
                          ref_27.user_id as c2
                        from 
                          test_bd.users as ref_28,
                          lateral (select  
                                subq_4.c0 as c0
                              from 
                                test_bd.users as ref_29
                              where EXISTS (
                                select  
                                    subq_4.c1 as c0, 
                                    16 as c1
                                  from 
                                    test_bd.eids as ref_30
                                  where (false) 
                                    and (true)
                                  limit 62)
                              limit 149) as subq_6
                        where ((select id from test_bd.comments limit 1 offset 5)
                               is not NULL) 
                          and (ref_27.user_id is NULL)))
                  limit 29)) 
              and ((true) 
                or (subq_4.c1 is not NULL)))) 
          or (false))) 
      or ((subq_4.c0 is not NULL) 
        and (subq_4.c0 is NULL))))
limit 78;
SHOW profiles;