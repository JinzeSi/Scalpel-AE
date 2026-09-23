SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.id as c0, 
  subq_0.c1 as c1, 
  subq_0.c0 as c2, 
  subq_1.c3 as c3, 
  subq_1.c2 as c4, 
  coalesce(subq_0.c0,
    subq_1.c3) as c5, 
  coalesce(subq_0.c0,
    subq_1.c1) as c6
from 
  test_bd.users as ref_0
      left join (select  
            ref_1.id as c0, 
            ref_1.name as c1, 
            ref_1.user_id as c2
          from 
            test_bd.locations as ref_1
          where false) as subq_0
      on (ref_0.email is NULL)
    inner join (select distinct 
          ref_4.virtual_col as c0, 
          ref_4.id as c1, 
          ref_2.id as c2, 
          ref_4.virtual_col as c3, 
          ref_3.username as c4
        from 
          test_bd.eids as ref_2
            left join test_bd.user_post_comments as ref_3
              right join test_bd.eids as ref_4
              on (EXISTS (
                  select  
                      ref_3.comment as c0
                    from 
                      test_bd.eids as ref_5
                    where EXISTS (
                      select  
                          ref_6.email as c0, 
                          ref_4.id as c1, 
                          ref_3.title as c2, 
                          ref_4.virtual_col as c3, 
                          ref_3.comment as c4, 
                          ref_6.id as c5, 
                          (select id from test_bd.employee limit 1 offset 3)
                             as c6, 
                          ref_4.virtual_col as c7
                        from 
                          test_bd.users as ref_6
                        where ((false) 
                            and (((true) 
                                and (ref_4.virtual_col is not NULL)) 
                              and (EXISTS (
                                select  
                                    ref_4.virtual_col as c0, 
                                    ref_4.eid as c1, 
                                    ref_7.id as c2, 
                                    ref_5.eid as c3, 
                                    ref_3.title as c4, 
                                    ref_4.id as c5, 
                                    (select years from test_bd.employee limit 1 offset 4)
                                       as c6, 
                                    ref_4.virtual_col as c7, 
                                    ref_4.eid as c8, 
                                    ref_6.id as c9
                                  from 
                                    test_bd.users as ref_7
                                  where false
                                  limit 92)))) 
                          and (EXISTS (
                            select  
                                ref_3.username as c0
                              from 
                                test_bd.eids as ref_8
                              where ref_3.username is not NULL
                              limit 75))
                        limit 115)
                    limit 184))
            on (((select username from test_bd.users limit 1 offset 4)
                     is NULL) 
                and (true))
        where ref_2.id is not NULL
        limit 49) as subq_1
    on (((((subq_1.c1 is NULL) 
              and (false)) 
            or (subq_1.c0 is not NULL)) 
          or (((((false) 
                  or (ref_0.created_at is NULL)) 
                or ((EXISTS (
                    select  
                        ref_0.email as c0, 
                        ref_9.id as c1, 
                        ref_9.id as c2, 
                        ref_9.id as c3, 
                        (select eid from test_bd.employee limit 1 offset 4)
                           as c4, 
                        subq_0.c2 as c5, 
                        subq_1.c2 as c6, 
                        ref_9.name as c7
                      from 
                        test_bd.locations as ref_9
                      where (true) 
                        or ((false) 
                          and (((false) 
                              or ((false) 
                                or (true))) 
                            or (true)))
                      limit 93)) 
                  and (((false) 
                      and ((((((false) 
                                or ((false) 
                                  and (true))) 
                              or (false)) 
                            and ((true) 
                              or (false))) 
                          or ((true) 
                            and (((true) 
                                or ((EXISTS (
                                    select  
                                        ref_10.virtual_col as c0
                                      from 
                                        test_bd.eids as ref_10
                                      where false
                                      limit 73)) 
                                  or (((ref_0.created_at is NULL) 
                                      or (EXISTS (
                                        select  
                                            subq_1.c2 as c0, 
                                            subq_0.c0 as c1, 
                                            subq_2.c14 as c2, 
                                            subq_2.c8 as c3, 
                                            92 as c4, 
                                            ref_11.user_id as c5, 
                                            69 as c6, 
                                            ref_11.birthdate as c7, 
                                            subq_2.c13 as c8, 
                                            subq_1.c0 as c9, 
                                            ref_11.profile_picture as c10, 
                                            subq_2.c3 as c11
                                          from 
                                            test_bd.user_profiles as ref_11,
                                            lateral (select  
                                                  ref_0.email as c0, 
                                                  (select coordinates from test_bd.locations limit 1 offset 4)
                                                     as c1, 
                                                  ref_0.id as c2, 
                                                  ref_12.id as c3, 
                                                  ref_11.profile_picture as c4, 
                                                  ref_12.id as c5, 
                                                  (select name from test_bd.locations limit 1 offset 6)
                                                     as c6, 
                                                  ref_11.user_id as c7, 
                                                  ref_11.profile_picture as c8, 
                                                  ref_0.username as c9, 
                                                  subq_0.c1 as c10, 
                                                  ref_0.created_at as c11, 
                                                  subq_0.c2 as c12, 
                                                  subq_0.c1 as c13, 
                                                  subq_1.c0 as c14
                                                from 
                                                  test_bd.products as ref_12
                                                where (ref_0.username is not NULL) 
                                                  and (false)
                                                limit 89) as subq_2
                                          where (EXISTS (
                                              select  
                                                  subq_2.c11 as c0, 
                                                  ref_0.email as c1, 
                                                  ref_0.email as c2, 
                                                  subq_2.c10 as c3, 
                                                  subq_1.c1 as c4, 
                                                  subq_0.c1 as c5, 
                                                  subq_2.c10 as c6, 
                                                  30 as c7, 
                                                  ref_0.id as c8, 
                                                  subq_2.c6 as c9, 
                                                  ref_0.username as c10, 
                                                  (select comment from test_bd.user_post_comments limit 1 offset 4)
                                                     as c11, 
                                                  ref_13.name as c12, 
                                                  17 as c13
                                                from 
                                                  test_bd.locations as ref_13
                                                where subq_0.c0 is not NULL
                                                limit 81)) 
                                            and (false)))) 
                                    and (true)))) 
                              or (subq_1.c2 is NULL)))) 
                        or ((subq_1.c0 is not NULL) 
                          or (true)))) 
                    or ((subq_0.c1 is not NULL) 
                      and (subq_1.c0 is not NULL))))) 
              or (((((((true) 
                          and ((((subq_0.c1 is NULL) 
                                and (ref_0.created_at is not NULL)) 
                              and (subq_0.c2 is NULL)) 
                            and (EXISTS (
                              select  
                                  subq_1.c1 as c0, 
                                  subq_0.c1 as c1, 
                                  subq_1.c1 as c2
                                from 
                                  test_bd.comments as ref_14,
                                  lateral (select  
                                        ref_0.email as c0, 
                                        ref_14.created_at as c1, 
                                        ref_0.id as c2, 
                                        ref_0.id as c3, 
                                        subq_0.c1 as c4, 
                                        subq_5.c0 as c5, 
                                        subq_0.c0 as c6, 
                                        subq_1.c1 as c7, 
                                        ref_0.username as c8, 
                                        subq_1.c1 as c9, 
                                        ref_15.name as c10, 
                                        33 as c11, 
                                        ref_14.post_id as c12, 
                                        ref_14.post_id as c13, 
                                        subq_1.c4 as c14, 
                                        ref_0.email as c15, 
                                        subq_1.c3 as c16, 
                                        subq_5.c0 as c17, 
                                        subq_5.c0 as c18, 
                                        subq_5.c1 as c19, 
                                        ref_0.created_at as c20, 
                                        ref_15.user_id as c21, 
                                        ref_0.email as c22, 
                                        ref_0.email as c23
                                      from 
                                        test_bd.locations as ref_15,
                                        lateral (select  
                                              subq_0.c1 as c0, 
                                              subq_1.c2 as c1
                                            from 
                                              test_bd.employee as ref_16
                                            where EXISTS (
                                              select  
                                                  ref_17.comment as c0, 
                                                  ref_17.title as c1, 
                                                  ref_0.created_at as c2, 
                                                  subq_4.c0 as c3, 
                                                  (select created_at from test_bd.products limit 1 offset 44)
                                                     as c4, 
                                                  subq_0.c2 as c5, 
                                                  ref_15.coordinates as c6, 
                                                  ref_15.coordinates as c7, 
                                                  ref_14.id as c8, 
                                                  ref_0.created_at as c9, 
                                                  ref_16.id as c10, 
                                                  ref_15.coordinates as c11, 
                                                  ref_0.email as c12, 
                                                  ref_0.email as c13, 
                                                  subq_4.c0 as c14, 
                                                  ref_0.id as c15, 
                                                  subq_0.c0 as c16, 
                                                  ref_14.created_at as c17, 
                                                  ref_16.id as c18, 
                                                  ref_14.user_id as c19
                                                from 
                                                  test_bd.user_post_comments as ref_17,
                                                  lateral (select  
                                                        ref_17.title as c0
                                                      from 
                                                        test_bd.user_profiles as ref_18,
                                                        lateral (select  
                                                              ref_0.username as c0, 
                                                              51 as c1, 
                                                              ref_19.id as c2, 
                                                              ref_17.title as c3, 
                                                              ref_16.eid as c4, 
                                                              ref_15.name as c5, 
                                                              ref_19.coordinates as c6, 
                                                              ref_15.user_id as c7
                                                            from 
                                                              test_bd.locations as ref_19
                                                            where true
                                                            limit 109) as subq_3
                                                      where true) as subq_4
                                                where (false) 
                                                  and (true)
                                                limit 123)
                                            limit 100) as subq_5
                                      where (true) 
                                        or ((false) 
                                          and (ref_15.coordinates is NULL))) as subq_6
                                where (true) 
                                  and (false)
                                limit 121)))) 
                        and (subq_1.c3 is NULL)) 
                      and (((((((ref_0.email is not NULL) 
                                  and (subq_0.c0 is NULL)) 
                                or (ref_0.email is not NULL)) 
                              or ((false) 
                                and (((subq_1.c4 is NULL) 
                                    and (true)) 
                                  and (EXISTS (
                                    select  
                                        ref_0.username as c0, 
                                        subq_1.c3 as c1, 
                                        ref_20.id as c2, 
                                        subq_1.c0 as c3, 
                                        ref_0.created_at as c4
                                      from 
                                        test_bd.products as ref_20
                                      where ref_0.created_at is NULL
                                      limit 74))))) 
                            or (((false) 
                                or (false)) 
                              and ((subq_1.c4 is NULL) 
                                or ((subq_1.c4 is NULL) 
                                  and ((EXISTS (
                                      select  
                                          ref_0.id as c0, 
                                          subq_1.c1 as c1, 
                                          subq_0.c0 as c2, 
                                          subq_1.c0 as c3, 
                                          ref_21.user_id as c4, 
                                          subq_1.c0 as c5
                                        from 
                                          test_bd.comments as ref_21
                                        where ref_0.created_at is not NULL
                                        limit 138)) 
                                    and ((false) 
                                      or ((ref_0.created_at is not NULL) 
                                        and (false)))))))) 
                          or ((ref_0.username is NULL) 
                            and ((true) 
                              or ((true) 
                                or ((true) 
                                  and (((((ref_0.username is NULL) 
                                          and ((true) 
                                            and (subq_0.c1 is NULL))) 
                                        and (true)) 
                                      or (subq_1.c3 is NULL)) 
                                    or (true))))))) 
                        or (EXISTS (
                          select  
                              subq_0.c0 as c0, 
                              subq_1.c1 as c1, 
                              ref_22.birthdate as c2
                            from 
                              test_bd.user_profiles as ref_22
                            where true)))) 
                    or (((false) 
                        or (subq_1.c1 is NULL)) 
                      or ((EXISTS (
                          select  
                              ref_0.id as c0, 
                              subq_1.c3 as c1, 
                              subq_1.c3 as c2, 
                              subq_0.c2 as c3, 
                              ref_0.email as c4, 
                              ref_23.email as c5, 
                              subq_0.c2 as c6
                            from 
                              test_bd.users as ref_23
                            where (EXISTS (
                                select  
                                    ref_24.user_id as c0, 
                                    subq_7.c1 as c1, 
                                    subq_0.c0 as c2, 
                                    subq_7.c2 as c3, 
                                    (select username from test_bd.users limit 1 offset 3)
                                       as c4, 
                                    ref_0.email as c5, 
                                    ref_23.id as c6, 
                                    97 as c7, 
                                    (select birthdate from test_bd.user_profiles limit 1 offset 5)
                                       as c8, 
                                    1 as c9, 
                                    subq_7.c2 as c10, 
                                    ref_23.id as c11
                                  from 
                                    test_bd.comments as ref_24,
                                    lateral (select  
                                          ref_25.id as c0, 
                                          subq_1.c2 as c1, 
                                          ref_0.created_at as c2
                                        from 
                                          test_bd.eids as ref_25
                                        where subq_0.c1 is not NULL
                                        limit 38) as subq_7
                                  where true)) 
                              and (((((EXISTS (
                                        select  
                                            ref_26.username as c0, 
                                            ref_0.username as c1, 
                                            ref_0.username as c2, 
                                            ref_0.created_at as c3, 
                                            subq_8.c3 as c4, 
                                            subq_0.c2 as c5, 
                                            subq_1.c0 as c6, 
                                            subq_1.c2 as c7, 
                                            ref_23.created_at as c8, 
                                            ref_26.username as c9, 
                                            subq_8.c0 as c10
                                          from 
                                            test_bd.users as ref_26,
                                            lateral (select  
                                                  42 as c0, 
                                                  ref_27.id as c1, 
                                                  subq_1.c2 as c2, 
                                                  ref_23.created_at as c3
                                                from 
                                                  test_bd.users as ref_27
                                                where ((ref_23.created_at is not NULL) 
                                                    and ((true) 
                                                      and (false))) 
                                                  and (EXISTS (
                                                    select  
                                                        ref_28.created_at as c0, 
                                                        subq_0.c0 as c1, 
                                                        subq_1.c1 as c2
                                                      from 
                                                        test_bd.users as ref_28
                                                      where ref_0.email is NULL))) as subq_8
                                          where ref_26.id is NULL
                                          limit 140)) 
                                      or (subq_0.c1 is NULL)) 
                                    and (subq_1.c1 is NULL)) 
                                  and (false)) 
                                and ((false) 
                                  and (false)))
                            limit 72)) 
                        or (subq_1.c0 is not NULL)))) 
                  or ((((false) 
                        and ((true) 
                          or ((false) 
                            and (true)))) 
                      or (subq_1.c2 is not NULL)) 
                    or (subq_0.c2 is NULL))) 
                and ((((false) 
                      and (((true) 
                          and (ref_0.username is not NULL)) 
                        and (false))) 
                    and (true)) 
                  and (false)))) 
            and (EXISTS (
              select  
                  subq_0.c2 as c0, 
                  ref_29.title as c1, 
                  21 as c2, 
                  (select id from test_bd.comments limit 1 offset 4)
                     as c3, 
                  ref_0.email as c4, 
                  subq_1.c3 as c5, 
                  subq_0.c1 as c6, 
                  subq_1.c3 as c7, 
                  subq_1.c2 as c8, 
                  ref_0.id as c9, 
                  ref_0.created_at as c10, 
                  subq_1.c2 as c11, 
                  subq_0.c2 as c12, 
                  (select post_id from test_bd.comments limit 1 offset 4)
                     as c13, 
                  ref_0.id as c14, 
                  subq_0.c0 as c15, 
                  ref_0.id as c16, 
                  ref_0.email as c17, 
                  ref_29.comment as c18, 
                  ref_0.username as c19, 
                  subq_1.c2 as c20, 
                  subq_0.c0 as c21, 
                  subq_1.c1 as c22, 
                  subq_0.c1 as c23
                from 
                  test_bd.user_post_comments as ref_29
                where ref_29.username is not NULL
                limit 133)))) 
        and ((false) 
          or ((((EXISTS (
                  select  
                      (select bio from test_bd.user_profiles limit 1 offset 44)
                         as c0, 
                      subq_0.c0 as c1, 
                      (select eid from test_bd.eids limit 1 offset 2)
                         as c2, 
                      subq_1.c2 as c3
                    from 
                      test_bd.user_post_comments as ref_30
                    where ((EXISTS (
                          select  
                              ref_31.post_id as c0, 
                              subq_1.c1 as c1
                            from 
                              test_bd.comments as ref_31
                            where (false) 
                              and (subq_0.c1 is NULL)
                            limit 104)) 
                        and ((EXISTS (
                            select  
                                ref_0.created_at as c0, 
                                ref_0.id as c1, 
                                ref_30.username as c2, 
                                ref_30.username as c3, 
                                ref_32.profile_picture as c4, 
                                ref_30.title as c5, 
                                subq_1.c0 as c6, 
                                subq_1.c2 as c7
                              from 
                                test_bd.user_profiles as ref_32
                              where (((true) 
                                    and (false)) 
                                  and (subq_0.c1 is NULL)) 
                                or (true)
                              limit 102)) 
                          or (ref_30.comment is NULL))) 
                      or (ref_0.email is NULL)
                    limit 81)) 
                or ((true) 
                  or (ref_0.created_at is NULL))) 
              or (subq_0.c0 is NULL)) 
            and (EXISTS (
              select  
                  ref_33.comment as c0, 
                  subq_0.c2 as c1, 
                  subq_0.c2 as c2
                from 
                  test_bd.user_post_comments as ref_33
                where ref_33.comment is not NULL)))))
where (EXISTS (
    select  
        subq_9.c1 as c0, 
        subq_9.c12 as c1, 
        coalesce(subq_0.c2,
          subq_9.c7) as c2
      from 
        (select  
              subq_1.c3 as c0, 
              ref_34.created_at as c1, 
              ref_34.created_at as c2, 
              (select eid from test_bd.eids limit 1 offset 2)
                 as c3, 
              ref_34.created_at as c4, 
              subq_0.c0 as c5, 
              (select bio from test_bd.user_profiles limit 1 offset 3)
                 as c6, 
              ref_0.id as c7, 
              subq_1.c2 as c8, 
              subq_1.c2 as c9, 
              ref_34.id as c10, 
              subq_1.c3 as c11, 
              ref_34.post_id as c12
            from 
              test_bd.comments as ref_34
            where false) as subq_9
      where (true) 
        and ((select created_at from test_bd.posts limit 1 offset 6)
             is not NULL)
      limit 149)) 
  or (false)
limit 122;
SHOW profiles;