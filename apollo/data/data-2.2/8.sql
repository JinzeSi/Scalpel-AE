SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_1.c0 as c0, 
  subq_1.c10 as c1, 
  subq_1.c6 as c2, 
  case when ((((true) 
            and (subq_1.c3 is not NULL)) 
          and (false)) 
        or (((false) 
            or (subq_1.c1 is NULL)) 
          or (((false) 
              or ((true) 
                or (true))) 
            or (true)))) 
      and ((subq_1.c14 is not NULL) 
        or (subq_1.c5 is NULL)) then subq_1.c15 else subq_1.c15 end
     as c3
from 
  (select  
        ref_1.years as c0, 
        ref_5.profile_picture as c1, 
        ref_1.eid as c2, 
        ref_3.virtual_col as c3, 
        ref_4.id as c4, 
        ref_2.email as c5, 
        ref_2.email as c6, 
        coalesce(ref_0.post_id,
          ref_3.virtual_col) as c7, 
        ref_4.user_id as c8, 
        ref_5.user_id as c9, 
        ref_2.email as c10, 
        coalesce(ref_1.id,
          ref_2.id) as c11, 
        ref_4.user_id as c12, 
        (select title from test_bd.user_post_comments limit 1 offset 1)
           as c13, 
        (select eid from test_bd.eids limit 1 offset 39)
           as c14, 
        ref_0.id as c15, 
        ref_2.id as c16, 
        ref_3.eid as c17
      from 
        test_bd.comments as ref_0
            inner join test_bd.employee as ref_1
            on (ref_0.id = ref_1.age )
          inner join test_bd.users as ref_2
              right join test_bd.eids as ref_3
              on (ref_2.id = ref_3.eid )
            left join test_bd.comments as ref_4
              right join test_bd.user_profiles as ref_5
              on (((true) 
                    and (ref_4.post_id is NULL)) 
                  or (((ref_5.bio is not NULL) 
                      and (true)) 
                    or ((true) 
                      and ((((false) 
                            or ((false) 
                              or ((ref_5.bio is NULL) 
                                and (true)))) 
                          or ((((false) 
                                or ((true) 
                                  and ((select bio from test_bd.user_profiles limit 1 offset 6)
                                       is not NULL))) 
                              and ((true) 
                                and ((EXISTS (
                                    select  
                                        subq_0.c0 as c0, 
                                        ref_4.id as c1, 
                                        ref_4.user_id as c2, 
                                        (select birthdate from test_bd.user_profiles limit 1 offset 3)
                                           as c3, 
                                        ref_6.id as c4, 
                                        ref_4.id as c5, 
                                        ref_4.id as c6, 
                                        (select id from test_bd.comments limit 1 offset 2)
                                           as c7, 
                                        subq_0.c1 as c8, 
                                        ref_4.post_id as c9, 
                                        ref_4.comment as c10, 
                                        ref_6.username as c11, 
                                        74 as c12, 
                                        (select id from test_bd.comments limit 1 offset 4)
                                           as c13
                                      from 
                                        test_bd.users as ref_6,
                                        lateral (select  
                                              ref_5.birthdate as c0, 
                                              ref_5.profile_picture as c1, 
                                              ref_5.user_id as c2
                                            from 
                                              test_bd.comments as ref_7
                                            where EXISTS (
                                              select  
                                                  ref_4.id as c0, 
                                                  ref_7.comment as c1, 
                                                  ref_7.created_at as c2, 
                                                  ref_4.post_id as c3, 
                                                  ref_8.user_id as c4, 
                                                  ref_5.bio as c5, 
                                                  ref_7.post_id as c6, 
                                                  ref_6.username as c7, 
                                                  ref_5.user_id as c8, 
                                                  ref_5.user_id as c9
                                                from 
                                                  test_bd.locations as ref_8
                                                where true
                                                limit 31)) as subq_0
                                      where EXISTS (
                                        select  
                                            ref_5.user_id as c0, 
                                            ref_4.created_at as c1, 
                                            subq_0.c1 as c2
                                          from 
                                            test_bd.users as ref_9
                                          where ref_5.user_id is NULL
                                          limit 107))) 
                                  and ((ref_4.user_id is NULL) 
                                    or (false))))) 
                            or (EXISTS (
                              select  
                                  ref_10.user_id as c0, 
                                  ref_5.profile_picture as c1, 
                                  ref_4.created_at as c2, 
                                  ref_5.user_id as c3
                                from 
                                  test_bd.comments as ref_10
                                where EXISTS (
                                  select  
                                      ref_4.created_at as c0, 
                                      ref_11.title as c1, 
                                      ref_11.title as c2
                                    from 
                                      test_bd.user_post_comments as ref_11
                                    where ((false) 
                                        and ((true) 
                                          or (ref_5.birthdate is not NULL))) 
                                      and (true)))))) 
                        and (ref_4.user_id is NULL)))))
            on (ref_4.user_id is NULL)
          on (ref_3.virtual_col is not NULL)
      where (true) 
        or (false)) as subq_1
where (subq_1.c5 is NULL) 
  and (case when (subq_1.c10 is NULL) 
        or (((((((subq_1.c6 is NULL) 
                    and ((((subq_1.c1 is not NULL) 
                          and (subq_1.c11 is not NULL)) 
                        and (subq_1.c13 is not NULL)) 
                      or (((((true) 
                              or (((EXISTS (
                                    select  
                                        subq_2.c4 as c0, 
                                        subq_2.c11 as c1, 
                                        subq_1.c8 as c2, 
                                        ref_12.birthdate as c3
                                      from 
                                        test_bd.user_profiles as ref_12,
                                        lateral (select  
                                              ref_13.email as c0, 
                                              subq_1.c4 as c1, 
                                              ref_12.profile_picture as c2, 
                                              ref_13.username as c3, 
                                              ref_13.username as c4, 
                                              subq_1.c5 as c5, 
                                              ref_12.profile_picture as c6, 
                                              ref_13.created_at as c7, 
                                              subq_1.c3 as c8, 
                                              subq_1.c10 as c9, 
                                              ref_12.birthdate as c10, 
                                              subq_1.c2 as c11
                                            from 
                                              test_bd.users as ref_13
                                            where (subq_1.c6 is not NULL) 
                                              and (true)
                                            limit 123) as subq_2
                                      where subq_2.c11 is NULL
                                      limit 81)) 
                                  or (false)) 
                                and (false))) 
                            or (true)) 
                          or (true)) 
                        and ((subq_1.c6 is NULL) 
                          and (true))))) 
                  or ((subq_1.c0 is not NULL) 
                    and (true))) 
                and (((subq_1.c3 is NULL) 
                    or ((subq_1.c16 is not NULL) 
                      or (((EXISTS (
                            select  
                                subq_1.c7 as c0, 
                                49 as c1
                              from 
                                test_bd.posts as ref_14,
                                lateral (select  
                                      subq_1.c1 as c0, 
                                      subq_3.c5 as c1, 
                                      ref_15.id as c2, 
                                      ref_14.user_id as c3, 
                                      subq_1.c11 as c4, 
                                      ref_14.id as c5, 
                                      ref_15.id as c6, 
                                      subq_1.c13 as c7, 
                                      subq_1.c4 as c8, 
                                      ref_15.updated_at as c9, 
                                      ref_14.created_at as c10, 
                                      (select username from test_bd.users limit 1 offset 2)
                                         as c11, 
                                      ref_14.user_id as c12, 
                                      ref_14.content as c13, 
                                      ref_15.created_at as c14, 
                                      subq_1.c15 as c15
                                    from 
                                      test_bd.posts as ref_15,
                                      lateral (select distinct 
                                            ref_15.content as c0, 
                                            ref_16.name as c1, 
                                            ref_14.content as c2, 
                                            ref_16.created_at as c3, 
                                            subq_1.c11 as c4, 
                                            68 as c5, 
                                            ref_14.id as c6, 
                                            (select tags from test_bd.products limit 1 offset 5)
                                               as c7
                                          from 
                                            test_bd.products as ref_16
                                          where (false) 
                                            or (false)
                                          limit 94) as subq_3
                                    where EXISTS (
                                      select  
                                          ref_15.content as c0, 
                                          ref_14.updated_at as c1, 
                                          ref_14.updated_at as c2, 
                                          ref_14.id as c3, 
                                          ref_17.age as c4, 
                                          subq_3.c0 as c5, 
                                          subq_3.c6 as c6, 
                                          subq_3.c0 as c7, 
                                          subq_3.c0 as c8, 
                                          ref_15.id as c9, 
                                          subq_3.c7 as c10, 
                                          subq_3.c5 as c11, 
                                          ref_17.salary as c12, 
                                          ref_14.content as c13
                                        from 
                                          test_bd.employee as ref_17
                                        where (((true) 
                                              and ((true) 
                                                or (false))) 
                                            or (ref_14.user_id is NULL)) 
                                          or (false)
                                        limit 192)) as subq_4
                              where true
                              limit 142)) 
                          or (subq_1.c6 is not NULL)) 
                        and (((subq_1.c16 is not NULL) 
                            or ((24 is not NULL) 
                              or (true))) 
                          or (EXISTS (
                            select  
                                ref_18.title as c0, 
                                ref_18.username as c1, 
                                ref_18.title as c2, 
                                subq_1.c4 as c3, 
                                subq_1.c15 as c4, 
                                ref_18.comment as c5, 
                                subq_1.c6 as c6, 
                                subq_1.c5 as c7, 
                                subq_1.c16 as c8, 
                                (select username from test_bd.user_post_comments limit 1 offset 2)
                                   as c9
                              from 
                                test_bd.user_post_comments as ref_18
                              where true)))))) 
                  and (subq_1.c4 is not NULL))) 
              or (subq_1.c9 is not NULL)) 
            and (subq_1.c11 is not NULL)) 
          and ((false) 
            and (((((((((subq_1.c2 is not NULL) 
                            and (EXISTS (
                              select  
                                  subq_1.c4 as c0
                                from 
                                  test_bd.user_post_comments as ref_19
                                where true
                                limit 184))) 
                          or (false)) 
                        or (((true) 
                            and (true)) 
                          and (((true) 
                              and ((subq_1.c2 is not NULL) 
                                and ((EXISTS (
                                    select  
                                        ref_20.eid as c0, 
                                        (select name from test_bd.locations limit 1 offset 1)
                                           as c1, 
                                        ref_20.id as c2, 
                                        subq_1.c7 as c3
                                      from 
                                        test_bd.eids as ref_20
                                      where (EXISTS (
                                          select  
                                              ref_21.birthdate as c0, 
                                              ref_21.profile_picture as c1, 
                                              subq_1.c2 as c2, 
                                              subq_1.c13 as c3, 
                                              ref_21.profile_picture as c4, 
                                              ref_21.profile_picture as c5, 
                                              ref_21.user_id as c6, 
                                              (select updated_at from test_bd.posts limit 1 offset 3)
                                                 as c7, 
                                              subq_1.c6 as c8, 
                                              ref_21.user_id as c9, 
                                              subq_1.c8 as c10, 
                                              ref_21.profile_picture as c11
                                            from 
                                              test_bd.user_profiles as ref_21,
                                              lateral (select  
                                                    (select eid from test_bd.eids limit 1 offset 6)
                                                       as c0, 
                                                    subq_1.c6 as c1, 
                                                    ref_22.created_at as c2, 
                                                    ref_22.created_at as c3
                                                  from 
                                                    test_bd.users as ref_22
                                                  where false) as subq_5
                                            where EXISTS (
                                              select  
                                                  subq_1.c14 as c0, 
                                                  ref_21.bio as c1
                                                from 
                                                  test_bd.products as ref_23
                                                where subq_5.c2 is NULL
                                                limit 117)
                                            limit 106)) 
                                        or ((select created_at from test_bd.comments limit 1 offset 30)
                                             is not NULL)
                                      limit 65)) 
                                  or (subq_1.c5 is NULL)))) 
                            and (false)))) 
                      and (((false) 
                          or (((true) 
                              or ((true) 
                                and (((select email from test_bd.users limit 1 offset 23)
                                       is not NULL) 
                                  or ((false) 
                                    and ((EXISTS (
                                        select  
                                            subq_1.c5 as c0
                                          from 
                                            test_bd.user_post_comments as ref_24
                                          where (((((subq_1.c0 is NULL) 
                                                    and ((false) 
                                                      or (true))) 
                                                  and ((false) 
                                                    and (false))) 
                                                and (((true) 
                                                    and ((EXISTS (
                                                        select  
                                                            ref_24.username as c0, 
                                                            ref_25.eid as c1
                                                          from 
                                                            test_bd.employee as ref_25
                                                          where true
                                                          limit 144)) 
                                                      or (false))) 
                                                  or (((false) 
                                                      or (true)) 
                                                    and (((ref_24.comment is not NULL) 
                                                        and (true)) 
                                                      and (true))))) 
                                              or (true)) 
                                            or (EXISTS (
                                              select  
                                                  ref_24.title as c0, 
                                                  subq_1.c13 as c1, 
                                                  ref_26.coordinates as c2
                                                from 
                                                  test_bd.locations as ref_26
                                                where true))
                                          limit 92)) 
                                      or ((true) 
                                        or ((subq_1.c5 is not NULL) 
                                          and ((EXISTS (
                                              select  
                                                  subq_1.c12 as c0, 
                                                  subq_8.c0 as c1, 
                                                  ref_27.comment as c2, 
                                                  subq_1.c16 as c3, 
                                                  subq_8.c1 as c4, 
                                                  ref_27.comment as c5, 
                                                  subq_1.c9 as c6, 
                                                  subq_8.c1 as c7, 
                                                  63 as c8, 
                                                  ref_27.title as c9
                                                from 
                                                  test_bd.user_post_comments as ref_27,
                                                  lateral (select  
                                                        ref_28.hire_date as c0, 
                                                        ref_28.id as c1
                                                      from 
                                                        test_bd.employee as ref_28,
                                                        lateral (select  
                                                              subq_1.c13 as c0, 
                                                              subq_1.c11 as c1, 
                                                              subq_1.c7 as c2, 
                                                              ref_29.category as c3, 
                                                              subq_1.c0 as c4, 
                                                              ref_28.salary as c5, 
                                                              ref_29.category as c6, 
                                                              ref_28.eid as c7, 
                                                              ref_28.email as c8, 
                                                              ref_28.id as c9, 
                                                              ref_27.comment as c10, 
                                                              ref_28.years as c11, 
                                                              subq_1.c12 as c12, 
                                                              subq_1.c12 as c13
                                                            from 
                                                              test_bd.products as ref_29
                                                            where (false) 
                                                              or (EXISTS (
                                                                select  
                                                                    ref_28.department_id as c0, 
                                                                    subq_1.c4 as c1
                                                                  from 
                                                                    test_bd.users as ref_30
                                                                  where true))
                                                            limit 131) as subq_6,
                                                        lateral (select  
                                                              ref_28.id as c0, 
                                                              subq_6.c7 as c1
                                                            from 
                                                              test_bd.eids as ref_31
                                                            where (true) 
                                                              and ((false) 
                                                                or ((false) 
                                                                  or ((ref_28.years is NULL) 
                                                                    or (true))))
                                                            limit 59) as subq_7
                                                      where EXISTS (
                                                        select  
                                                            subq_1.c7 as c0, 
                                                            ref_32.user_id as c1, 
                                                            ref_32.coordinates as c2
                                                          from 
                                                            test_bd.locations as ref_32
                                                          where (subq_1.c0 is NULL) 
                                                            or (EXISTS (
                                                              select  
                                                                  98 as c0, 
                                                                  ref_27.title as c1, 
                                                                  ref_28.hire_date as c2, 
                                                                  subq_7.c1 as c3, 
                                                                  ref_33.id as c4, 
                                                                  subq_6.c6 as c5
                                                                from 
                                                                  test_bd.eids as ref_33
                                                                where ref_32.coordinates is NULL)))
                                                      limit 106) as subq_8
                                                where subq_1.c6 is NULL)) 
                                            and ((false) 
                                              and (((true) 
                                                  or (EXISTS (
                                                    select  
                                                        subq_1.c15 as c0, 
                                                        subq_12.c0 as c1
                                                      from 
                                                        test_bd.user_profiles as ref_34,
                                                        lateral (select  
                                                              66 as c0
                                                            from 
                                                              test_bd.products as ref_35,
                                                              lateral (select  
                                                                    ref_34.birthdate as c0, 
                                                                    ref_35.name as c1, 
                                                                    ref_35.created_at as c2, 
                                                                    ref_36.comment as c3, 
                                                                    ref_35.category as c4, 
                                                                    ref_34.birthdate as c5, 
                                                                    ref_35.name as c6, 
                                                                    ref_34.profile_picture as c7, 
                                                                    ref_36.comment as c8, 
                                                                    ref_34.bio as c9, 
                                                                    ref_36.comment as c10, 
                                                                    ref_34.user_id as c11, 
                                                                    ref_34.profile_picture as c12, 
                                                                    ref_35.tags as c13, 
                                                                    ref_36.username as c14, 
                                                                    subq_1.c8 as c15, 
                                                                    ref_35.price as c16, 
                                                                    ref_35.category as c17, 
                                                                    ref_35.created_at as c18, 
                                                                    subq_1.c17 as c19, 
                                                                    68 as c20, 
                                                                    ref_35.price as c21, 
                                                                    ref_35.tags as c22, 
                                                                    (select name from test_bd.products limit 1 offset 95)
                                                                       as c23, 
                                                                    ref_34.profile_picture as c24, 
                                                                    26 as c25, 
                                                                    ref_34.profile_picture as c26, 
                                                                    (select coordinates from test_bd.locations limit 1 offset 63)
                                                                       as c27, 
                                                                    ref_34.user_id as c28, 
                                                                    ref_35.category as c29, 
                                                                    ref_36.username as c30, 
                                                                    ref_34.birthdate as c31, 
                                                                    ref_36.username as c32, 
                                                                    subq_1.c17 as c33, 
                                                                    subq_1.c1 as c34, 
                                                                    ref_36.title as c35, 
                                                                    ref_34.bio as c36, 
                                                                    ref_34.user_id as c37, 
                                                                    ref_35.id as c38
                                                                  from 
                                                                    test_bd.user_post_comments as ref_36
                                                                  where EXISTS (
                                                                    select  
                                                                        subq_1.c16 as c0, 
                                                                        (select created_at from test_bd.users limit 1 offset 5)
                                                                           as c1, 
                                                                        ref_36.comment as c2, 
                                                                        ref_35.id as c3, 
                                                                        54 as c4, 
                                                                        ref_34.birthdate as c5, 
                                                                        ref_37.coordinates as c6
                                                                      from 
                                                                        test_bd.locations as ref_37
                                                                      where true)) as subq_9,
                                                              lateral (select  
                                                                    subq_1.c9 as c0, 
                                                                    ref_34.birthdate as c1, 
                                                                    subq_9.c18 as c2
                                                                  from 
                                                                    test_bd.posts as ref_38
                                                                  where (false) 
                                                                    and (true)) as subq_10,
                                                              lateral (select  
                                                                    63 as c0, 
                                                                    ref_39.username as c1, 
                                                                    ref_34.birthdate as c2
                                                                  from 
                                                                    test_bd.user_post_comments as ref_39
                                                                  where false
                                                                  limit 31) as subq_11
                                                            where (false) 
                                                              or (false)
                                                            limit 104) as subq_12,
                                                        lateral (select  
                                                              ref_40.email as c0, 
                                                              ref_34.user_id as c1, 
                                                              subq_1.c1 as c2, 
                                                              subq_1.c16 as c3, 
                                                              subq_1.c2 as c4
                                                            from 
                                                              test_bd.users as ref_40
                                                            where true
                                                            limit 125) as subq_13
                                                      where false
                                                      limit 91))) 
                                                or (false))))))))))) 
                            or ((((false) 
                                  or (true)) 
                                and (false)) 
                              and (true)))) 
                        and ((((EXISTS (
                                select  
                                    subq_1.c4 as c0, 
                                    (select email from test_bd.users limit 1 offset 3)
                                       as c1, 
                                    (select content from test_bd.posts limit 1 offset 3)
                                       as c2, 
                                    subq_1.c14 as c3, 
                                    subq_1.c16 as c4, 
                                    ref_41.virtual_col as c5, 
                                    ref_41.virtual_col as c6, 
                                    subq_1.c8 as c7, 
                                    ref_41.eid as c8, 
                                    subq_1.c8 as c9
                                  from 
                                    test_bd.eids as ref_41
                                  where (subq_1.c13 is NULL) 
                                    or (false))) 
                              or (true)) 
                            or ((true) 
                              or ((true) 
                                and (((true) 
                                    or (((false) 
                                        or (((true) 
                                            or ((((true) 
                                                  and ((false) 
                                                    and (true))) 
                                                and (false)) 
                                              and (((true) 
                                                  and (false)) 
                                                or (true)))) 
                                          and (true))) 
                                      or (subq_1.c6 is NULL))) 
                                  and ((false) 
                                    and ((subq_1.c17 is not NULL) 
                                      or (false))))))) 
                          or (subq_1.c7 is not NULL)))) 
                    and (subq_1.c10 is NULL)) 
                  or (EXISTS (
                    select  
                        subq_1.c11 as c0, 
                        subq_1.c3 as c1, 
                        subq_1.c6 as c2, 
                        (select comment from test_bd.user_post_comments limit 1 offset 4)
                           as c3, 
                        subq_1.c13 as c4, 
                        subq_1.c1 as c5, 
                        ref_42.virtual_col as c6, 
                        subq_1.c14 as c7, 
                        subq_1.c3 as c8, 
                        38 as c9, 
                        ref_42.eid as c10, 
                        ref_42.eid as c11
                      from 
                        test_bd.eids as ref_42
                      where ((false) 
                          and (((true) 
                              or ((false) 
                                and (true))) 
                            or (EXISTS (
                              select  
                                  subq_1.c10 as c0, 
                                  ref_43.title as c1, 
                                  ref_43.username as c2, 
                                  ref_43.username as c3, 
                                  subq_1.c2 as c4, 
                                  ref_43.username as c5, 
                                  subq_1.c0 as c6, 
                                  ref_42.eid as c7, 
                                  ref_43.username as c8, 
                                  ref_43.comment as c9, 
                                  subq_1.c4 as c10, 
                                  subq_1.c12 as c11, 
                                  ref_43.title as c12, 
                                  ref_42.virtual_col as c13
                                from 
                                  test_bd.user_post_comments as ref_43
                                where (((true) 
                                      or ((EXISTS (
                                          select  
                                              ref_42.id as c0, 
                                              subq_1.c17 as c1, 
                                              ref_42.virtual_col as c2
                                            from 
                                              test_bd.eids as ref_44
                                            where (false) 
                                              or (true)
                                            limit 98)) 
                                        or ((EXISTS (
                                            select  
                                                ref_45.bio as c0, 
                                                ref_42.virtual_col as c1, 
                                                ref_43.username as c2, 
                                                subq_14.c0 as c3, 
                                                ref_42.eid as c4, 
                                                ref_42.virtual_col as c5, 
                                                (select birthdate from test_bd.user_profiles limit 1 offset 1)
                                                   as c6, 
                                                subq_14.c10 as c7, 
                                                ref_43.username as c8, 
                                                subq_14.c4 as c9, 
                                                ref_42.virtual_col as c10, 
                                                subq_1.c13 as c11, 
                                                ref_45.profile_picture as c12, 
                                                ref_42.virtual_col as c13, 
                                                subq_1.c1 as c14, 
                                                subq_1.c10 as c15, 
                                                ref_45.user_id as c16, 
                                                subq_14.c10 as c17, 
                                                ref_43.title as c18
                                              from 
                                                test_bd.user_profiles as ref_45,
                                                lateral (select  
                                                      ref_46.id as c0, 
                                                      ref_42.eid as c1, 
                                                      ref_46.id as c2, 
                                                      54 as c3, 
                                                      ref_45.user_id as c4, 
                                                      subq_1.c5 as c5, 
                                                      ref_46.coordinates as c6, 
                                                      ref_43.title as c7, 
                                                      ref_45.profile_picture as c8, 
                                                      ref_42.virtual_col as c9, 
                                                      (select updated_at from test_bd.posts limit 1 offset 4)
                                                         as c10, 
                                                      subq_1.c16 as c11
                                                    from 
                                                      test_bd.locations as ref_46
                                                    where (true) 
                                                      and (true)) as subq_14
                                              where 4 is NULL)) 
                                          and ((true) 
                                            and ((true) 
                                              and (EXISTS (
                                                select  
                                                    subq_1.c15 as c0, 
                                                    subq_1.c9 as c1, 
                                                    ref_42.eid as c2, 
                                                    ref_43.username as c3, 
                                                    (select id from test_bd.comments limit 1 offset 5)
                                                       as c4
                                                  from 
                                                    test_bd.employee as ref_47
                                                  where EXISTS (
                                                    select  
                                                        ref_42.virtual_col as c0, 
                                                        ref_42.virtual_col as c1, 
                                                        ref_47.salary as c2, 
                                                        ref_43.comment as c3
                                                      from 
                                                        test_bd.user_post_comments as ref_48
                                                      where (subq_1.c12 is not NULL) 
                                                        or ((((false) 
                                                              and ((subq_1.c12 is not NULL) 
                                                                and ((ref_43.title is not NULL) 
                                                                  and (true)))) 
                                                            and ((true) 
                                                              and (true))) 
                                                          or (EXISTS (
                                                            select  
                                                                ref_47.years as c0
                                                              from 
                                                                test_bd.user_post_comments as ref_49
                                                              where (EXISTS (
                                                                  select  
                                                                      ref_49.title as c0, 
                                                                      ref_43.username as c1
                                                                    from 
                                                                      test_bd.user_profiles as ref_50
                                                                    where true
                                                                    limit 109)) 
                                                                and ((((false) 
                                                                      or (false)) 
                                                                    or (false)) 
                                                                  or (false)))))
                                                      limit 104)))))))) 
                                    or (subq_1.c14 is not NULL)) 
                                  and ((ref_43.comment is not NULL) 
                                    or (true)))))) 
                        and (((ref_42.virtual_col is not NULL) 
                            or ((false) 
                              and (ref_42.virtual_col is not NULL))) 
                          and (EXISTS (
                            select  
                                ref_51.coordinates as c0, 
                                28 as c1, 
                                subq_1.c2 as c2, 
                                ref_51.user_id as c3, 
                                ref_51.id as c4, 
                                ref_51.id as c5, 
                                subq_1.c16 as c6, 
                                ref_42.virtual_col as c7
                              from 
                                test_bd.locations as ref_51
                              where ((true) 
                                  or (EXISTS (
                                    select  
                                        subq_1.c2 as c0, 
                                        ref_52.coordinates as c1, 
                                        (select user_id from test_bd.posts limit 1 offset 28)
                                           as c2, 
                                        63 as c3, 
                                        ref_42.virtual_col as c4, 
                                        ref_42.eid as c5, 
                                        ref_42.id as c6, 
                                        (select id from test_bd.comments limit 1 offset 2)
                                           as c7
                                      from 
                                        test_bd.locations as ref_52
                                      where true))) 
                                or ((false) 
                                  and ((false) 
                                    and (false)))
                              limit 127)))
                      limit 35))) 
                or (EXISTS (
                  select  
                      ref_53.user_id as c0, 
                      subq_1.c13 as c1, 
                      ref_53.user_id as c2, 
                      ref_53.user_id as c3, 
                      (select name from test_bd.locations limit 1 offset 6)
                         as c4, 
                      ref_53.birthdate as c5, 
                      ref_53.profile_picture as c6, 
                      subq_1.c1 as c7, 
                      ref_53.profile_picture as c8, 
                      subq_1.c16 as c9
                    from 
                      test_bd.user_profiles as ref_53
                    where ((false) 
                        or (subq_1.c16 is NULL)) 
                      and (EXISTS (
                        select  
                            ref_54.id as c0, 
                            ref_53.birthdate as c1, 
                            ref_54.eid as c2, 
                            ref_54.eid as c3, 
                            subq_1.c6 as c4
                          from 
                            test_bd.employee as ref_54
                          where subq_1.c16 is not NULL
                          limit 141))
                    limit 117))) 
              and ((subq_1.c17 is not NULL) 
                or (false))))) then subq_1.c7 else subq_1.c7 end
       is not NULL)
limit 46;
SHOW profiles;