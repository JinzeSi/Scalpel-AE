SET profiling=1;
EXPLAIN ANALYZE

select  
  (select username from test_bd.user_post_comments limit 1 offset 76)
     as c0, 
  subq_14.c1 as c1
from 
  (select  
        ref_7.hire_date as c0, 
        (select id from test_bd.locations limit 1 offset 5)
           as c1, 
        ref_6.name as c2, 
        subq_0.c4 as c3, 
        ref_7.years as c4, 
        case when (ref_6.user_id is NULL) 
            and (EXISTS (
              select  
                  ref_6.coordinates as c0, 
                  subq_0.c0 as c1, 
                  subq_0.c3 as c2, 
                  ref_11.virtual_col as c3, 
                  subq_0.c3 as c4, 
                  ref_7.email as c5, 
                  subq_0.c1 as c6, 
                  ref_7.hire_date as c7, 
                  subq_0.c4 as c8, 
                  ref_6.id as c9, 
                  ref_6.name as c10, 
                  subq_0.c4 as c11, 
                  ref_6.name as c12, 
                  ref_6.id as c13, 
                  ref_6.name as c14, 
                  ref_7.email as c15
                from 
                  test_bd.eids as ref_11
                where (((false) 
                      and (((true) 
                          and (((true) 
                              and (true)) 
                            or ((EXISTS (
                                select  
                                    ref_12.title as c0
                                  from 
                                    test_bd.user_post_comments as ref_12
                                  where (true) 
                                    or (((((true) 
                                            and (true)) 
                                          or ((EXISTS (
                                              select  
                                                  subq_5.c1 as c0, 
                                                  ref_6.name as c1
                                                from 
                                                  test_bd.locations as ref_13,
                                                  lateral (select  
                                                        ref_14.user_id as c0, 
                                                        ref_7.email as c1, 
                                                        ref_12.title as c2, 
                                                        ref_14.bio as c3, 
                                                        subq_0.c3 as c4, 
                                                        ref_6.coordinates as c5
                                                      from 
                                                        test_bd.user_profiles as ref_14
                                                      where true
                                                      limit 78) as subq_2,
                                                  lateral (select  
                                                        ref_12.username as c0, 
                                                        ref_6.user_id as c1, 
                                                        ref_13.coordinates as c2, 
                                                        ref_15.username as c3, 
                                                        ref_11.eid as c4, 
                                                        ref_15.comment as c5, 
                                                        ref_11.virtual_col as c6, 
                                                        ref_12.title as c7, 
                                                        subq_2.c5 as c8, 
                                                        ref_7.department_id as c9, 
                                                        ref_7.eid as c10, 
                                                        ref_7.id as c11, 
                                                        ref_15.title as c12, 
                                                        ref_13.coordinates as c13, 
                                                        ref_11.eid as c14, 
                                                        ref_6.coordinates as c15, 
                                                        subq_0.c2 as c16, 
                                                        ref_13.user_id as c17, 
                                                        ref_13.id as c18, 
                                                        subq_0.c2 as c19, 
                                                        subq_2.c4 as c20, 
                                                        subq_0.c0 as c21, 
                                                        ref_12.comment as c22, 
                                                        subq_0.c0 as c23, 
                                                        ref_13.name as c24, 
                                                        ref_15.username as c25, 
                                                        (select created_at from test_bd.users limit 1 offset 1)
                                                           as c26, 
                                                        ref_13.coordinates as c27, 
                                                        ref_12.comment as c28
                                                      from 
                                                        test_bd.user_post_comments as ref_15
                                                      where EXISTS (
                                                        select  
                                                            ref_13.name as c0, 
                                                            ref_12.title as c1, 
                                                            52 as c2, 
                                                            ref_12.username as c3, 
                                                            subq_0.c1 as c4
                                                          from 
                                                            test_bd.users as ref_16
                                                          where false
                                                          limit 120)) as subq_3,
                                                  lateral (select  
                                                        subq_4.c0 as c0, 
                                                        subq_0.c2 as c1, 
                                                        ref_6.id as c2, 
                                                        subq_3.c15 as c3
                                                      from 
                                                        test_bd.user_post_comments as ref_17,
                                                        lateral (select  
                                                              ref_17.comment as c0, 
                                                              subq_0.c0 as c1
                                                            from 
                                                              test_bd.users as ref_18
                                                            where false
                                                            limit 92) as subq_4
                                                      where false
                                                      limit 73) as subq_5
                                                where false)) 
                                            and (false))) 
                                        and (false)) 
                                      or ((ref_11.virtual_col is NULL) 
                                        and (((EXISTS (
                                              select  
                                                  ref_6.id as c0, 
                                                  ref_6.name as c1, 
                                                  ref_19.created_at as c2, 
                                                  ref_7.department_id as c3, 
                                                  (select virtual_col from test_bd.eids limit 1 offset 3)
                                                     as c4, 
                                                  (select created_at from test_bd.posts limit 1 offset 92)
                                                     as c5, 
                                                  ref_11.id as c6
                                                from 
                                                  test_bd.users as ref_19,
                                                  lateral (select  
                                                        ref_12.title as c0, 
                                                        ref_20.username as c1, 
                                                        ref_12.username as c2, 
                                                        ref_6.id as c3, 
                                                        ref_11.virtual_col as c4, 
                                                        ref_20.username as c5, 
                                                        ref_6.user_id as c6, 
                                                        subq_7.c2 as c7, 
                                                        ref_19.username as c8, 
                                                        81 as c9, 
                                                        ref_7.department_id as c10, 
                                                        ref_12.username as c11, 
                                                        ref_19.created_at as c12, 
                                                        ref_7.hire_date as c13, 
                                                        ref_7.salary as c14
                                                      from 
                                                        test_bd.users as ref_20,
                                                        lateral (select  
                                                              ref_6.id as c0, 
                                                              (select salary from test_bd.employee limit 1 offset 16)
                                                                 as c1, 
                                                              ref_12.username as c2, 
                                                              ref_20.id as c3
                                                            from 
                                                              test_bd.posts as ref_21
                                                            where EXISTS (
                                                              select  
                                                                  ref_19.created_at as c0, 
                                                                  ref_22.birthdate as c1, 
                                                                  ref_12.comment as c2, 
                                                                  subq_0.c3 as c3, 
                                                                  (select comment from test_bd.user_post_comments limit 1 offset 4)
                                                                     as c4, 
                                                                  82 as c5, 
                                                                  (select created_at from test_bd.users limit 1 offset 6)
                                                                     as c6, 
                                                                  ref_21.updated_at as c7
                                                                from 
                                                                  test_bd.user_profiles as ref_22
                                                                where ((true) 
                                                                    or ((true) 
                                                                      and (false))) 
                                                                  and (ref_6.user_id is NULL))) as subq_6,
                                                        lateral (select  
                                                              ref_20.username as c0, 
                                                              73 as c1, 
                                                              ref_6.coordinates as c2, 
                                                              ref_19.username as c3
                                                            from 
                                                              test_bd.employee as ref_23
                                                            where true
                                                            limit 101) as subq_7
                                                      where (false) 
                                                        and (subq_0.c1 is NULL)) as subq_8
                                                where EXISTS (
                                                  select  
                                                      ref_24.created_at as c0, 
                                                      ref_12.username as c1, 
                                                      subq_12.c5 as c2, 
                                                      ref_12.username as c3, 
                                                      subq_0.c1 as c4
                                                    from 
                                                      test_bd.users as ref_24,
                                                      lateral (select  
                                                            ref_7.hire_date as c0, 
                                                            ref_7.department_id as c1, 
                                                            subq_11.c0 as c2, 
                                                            ref_19.created_at as c3, 
                                                            ref_24.id as c4, 
                                                            ref_19.created_at as c5
                                                          from 
                                                            test_bd.user_post_comments as ref_25,
                                                            lateral (select  
                                                                  subq_10.c2 as c0
                                                                from 
                                                                  test_bd.user_post_comments as ref_26,
                                                                  lateral (select  
                                                                        ref_7.age as c0, 
                                                                        ref_12.title as c1, 
                                                                        ref_6.name as c2
                                                                      from 
                                                                        test_bd.eids as ref_27,
                                                                        lateral (select  
                                                                              ref_27.id as c0, 
                                                                              ref_12.username as c1, 
                                                                              ref_7.id as c2, 
                                                                              ref_26.username as c3, 
                                                                              ref_7.years as c4, 
                                                                              ref_6.coordinates as c5, 
                                                                              ref_25.title as c6, 
                                                                              ref_26.username as c7, 
                                                                              ref_11.virtual_col as c8, 
                                                                              subq_0.c0 as c9, 
                                                                              ref_19.id as c10
                                                                            from 
                                                                              test_bd.employee as ref_28
                                                                            where true) as subq_9
                                                                      where true
                                                                      limit 12) as subq_10
                                                                where ref_19.id is NULL
                                                                limit 92) as subq_11
                                                          where ((EXISTS (
                                                                select  
                                                                    ref_12.username as c0
                                                                  from 
                                                                    test_bd.eids as ref_29
                                                                  where EXISTS (
                                                                    select  
                                                                        ref_29.id as c0
                                                                      from 
                                                                        test_bd.employee as ref_30
                                                                      where (true) 
                                                                        and ((true) 
                                                                          and (true))
                                                                      limit 96)
                                                                  limit 109)) 
                                                              or (true)) 
                                                            or (((true) 
                                                                or (ref_25.title is not NULL)) 
                                                              or (true))) as subq_12
                                                    where false
                                                    limit 74)
                                                limit 157)) 
                                            and ((true) 
                                              and (((true) 
                                                  or (true)) 
                                                or (((((select updated_at from test_bd.posts limit 1 offset 47)
                                                           is NULL) 
                                                      and (false)) 
                                                    or (false)) 
                                                  and (true))))) 
                                          and (true)))))) 
                              and (false)))) 
                        or (true))) 
                    and ((ref_6.coordinates is not NULL) 
                      or (((EXISTS (
                            select  
                                ref_11.id as c0, 
                                ref_31.id as c1, 
                                subq_0.c1 as c2
                              from 
                                test_bd.users as ref_31
                              where ((true) 
                                  or (false)) 
                                and (subq_0.c5 is NULL)
                              limit 85)) 
                          or (EXISTS (
                            select  
                                subq_0.c3 as c0, 
                                ref_32.user_id as c1, 
                                ref_11.eid as c2, 
                                88 as c3, 
                                ref_6.user_id as c4, 
                                ref_32.user_id as c5, 
                                ref_11.id as c6, 
                                ref_7.years as c7
                              from 
                                test_bd.user_profiles as ref_32
                              where false))) 
                        and (true)))) 
                  or ((false) 
                    and ((false) 
                      or (ref_6.coordinates is not NULL)))
                limit 125)) then ref_6.coordinates else ref_6.coordinates end
           as c5, 
        ref_7.eid as c6, 
        ref_7.age as c7, 
        5 as c8, 
        (select email from test_bd.users limit 1 offset 5)
           as c9, 
        ref_7.id as c10, 
        subq_0.c5 as c11, 
        coalesce(ref_6.id,
          ref_7.age) as c12, 
        ref_6.id as c13, 
        subq_0.c4 as c14, 
        subq_0.c5 as c15
      from 
        (select  
                ref_0.id as c0, 
                91 as c1, 
                ref_0.eid as c2, 
                ref_0.eid as c3, 
                ref_0.id as c4, 
                ref_0.id as c5
              from 
                test_bd.eids as ref_0
              where (EXISTS (
                  select  
                      ref_1.title as c0, 
                      ref_1.title as c1, 
                      ref_1.username as c2
                    from 
                      test_bd.user_post_comments as ref_1
                    where true)) 
                and (EXISTS (
                  select  
                      ref_0.id as c0, 
                      ref_0.eid as c1, 
                      ref_0.virtual_col as c2, 
                      ref_2.price as c3, 
                      56 as c4
                    from 
                      test_bd.products as ref_2
                    where ((20 is NULL) 
                        or ((EXISTS (
                            select  
                                (select email from test_bd.users limit 1 offset 6)
                                   as c0, 
                                ref_0.virtual_col as c1, 
                                ref_3.comment as c2
                              from 
                                test_bd.user_post_comments as ref_3
                              where EXISTS (
                                select  
                                    ref_3.comment as c0, 
                                    ref_2.price as c1, 
                                    ref_2.name as c2, 
                                    ref_2.category as c3, 
                                    36 as c4
                                  from 
                                    test_bd.posts as ref_4
                                  where true
                                  limit 167)
                              limit 82)) 
                          and (ref_0.id is not NULL))) 
                      and (EXISTS (
                        select  
                            ref_5.id as c0, 
                            ref_0.eid as c1
                          from 
                            test_bd.comments as ref_5
                          where ref_2.tags is not NULL
                          limit 78))))
              limit 94) as subq_0
          right join test_bd.locations as ref_6
            left join test_bd.employee as ref_7
            on (ref_6.name is NULL)
          on (((subq_0.c0 is not NULL) 
                or (true)) 
              and (EXISTS (
                select  
                    ref_8.created_at as c0, 
                    ref_8.created_at as c1
                  from 
                    test_bd.comments as ref_8,
                    lateral (select  
                          (select created_at from test_bd.users limit 1 offset 34)
                             as c0, 
                          ref_8.created_at as c1, 
                          95 as c2, 
                          subq_0.c3 as c3, 
                          ref_6.user_id as c4, 
                          subq_0.c3 as c5, 
                          ref_6.id as c6, 
                          ref_9.comment as c7, 
                          ref_7.email as c8
                        from 
                          test_bd.user_post_comments as ref_9
                        where false) as subq_1
                  where EXISTS (
                    select  
                        ref_7.age as c0, 
                        ref_10.years as c1, 
                        ref_8.id as c2, 
                        subq_0.c5 as c3, 
                        ref_8.id as c4, 
                        ref_6.id as c5, 
                        ref_6.coordinates as c6
                      from 
                        test_bd.employee as ref_10
                      where ((true) 
                          or (ref_7.years is NULL)) 
                        or ((true) 
                          or (false))
                      limit 47)
                  limit 146)))
      where ref_7.years is NULL
      limit 105) as subq_13,
  lateral (select  
        ref_33.id as c0, 
        subq_13.c1 as c1
      from 
        test_bd.users as ref_33
      where EXISTS (
        select  
            ref_34.salary as c0, 
            ref_34.email as c1, 
            ref_34.eid as c2, 
            subq_13.c2 as c3, 
            subq_13.c2 as c4, 
            subq_13.c12 as c5, 
            subq_13.c0 as c6
          from 
            test_bd.employee as ref_34
          where ref_34.years is NULL
          limit 91)
      limit 75) as subq_14,
  lateral (select  
        subq_13.c5 as c0
      from 
        (select  
              subq_14.c0 as c0
            from 
              test_bd.user_profiles as ref_35
                right join test_bd.comments as ref_36
                on (true)
            where EXISTS (
              select  
                  ref_35.user_id as c0, 
                  ref_37.eid as c1, 
                  subq_13.c6 as c2, 
                  subq_13.c12 as c3, 
                  subq_13.c4 as c4, 
                  subq_13.c4 as c5, 
                  ref_35.user_id as c6, 
                  (select profile_picture from test_bd.user_profiles limit 1 offset 1)
                     as c7, 
                  ref_35.profile_picture as c8, 
                  ref_35.birthdate as c9, 
                  ref_37.eid as c10, 
                  ref_36.id as c11, 
                  subq_14.c1 as c12, 
                  (select title from test_bd.user_post_comments limit 1 offset 1)
                     as c13, 
                  (select username from test_bd.user_post_comments limit 1 offset 6)
                     as c14, 
                  ref_36.id as c15, 
                  subq_13.c0 as c16, 
                  ref_36.post_id as c17, 
                  10 as c18
                from 
                  test_bd.eids as ref_37
                where ((((((((((true) 
                                    and ((false) 
                                      and (false))) 
                                  or (false)) 
                                and (EXISTS (
                                  select  
                                      subq_14.c0 as c0, 
                                      ref_36.user_id as c1, 
                                      ref_35.bio as c2
                                    from 
                                      test_bd.user_post_comments as ref_38
                                    where (ref_36.comment is NULL) 
                                      or ((true) 
                                        or ((((select tags from test_bd.products limit 1 offset 86)
                                                 is NULL) 
                                            or ((false) 
                                              and (false))) 
                                          and (false)))))) 
                              or (true)) 
                            or (EXISTS (
                              select  
                                  subq_13.c3 as c0, 
                                  ref_36.post_id as c1, 
                                  ref_36.user_id as c2, 
                                  ref_39.title as c3
                                from 
                                  test_bd.user_post_comments as ref_39
                                where true
                                limit 102))) 
                          or ((subq_13.c1 is NULL) 
                            or (EXISTS (
                              select  
                                  ref_36.post_id as c0, 
                                  subq_14.c0 as c1, 
                                  ref_35.bio as c2, 
                                  ref_40.user_id as c3, 
                                  ref_37.id as c4, 
                                  ref_36.id as c5, 
                                  55 as c6
                                from 
                                  test_bd.locations as ref_40
                                where false)))) 
                        or ((subq_13.c7 is NULL) 
                          and (((true) 
                              or (((ref_35.user_id is not NULL) 
                                  and ((false) 
                                    and (subq_14.c0 is not NULL))) 
                                and ((false) 
                                  or (true)))) 
                            and (false)))) 
                      or (true)) 
                    and (false)) 
                  and (ref_36.post_id is NULL))
            limit 115) as subq_15
      where EXISTS (
        select  
            ref_41.created_at as c0, 
            subq_14.c0 as c1, 
            subq_13.c14 as c2
          from 
            test_bd.comments as ref_41
          where subq_13.c11 is NULL)
      limit 87) as subq_16
where subq_13.c12 is not NULL
limit 29;
SHOW profiles;