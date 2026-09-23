SET profiling=1;
EXPLAIN ANALYZE

WITH 
jennifer_0 AS (select  
    subq_13.c6 as c0, 
    subq_13.c12 as c1, 
    subq_13.c10 as c2
  from 
    (select  
          ref_0.id as c0, 
          ref_0.created_at as c1, 
          subq_8.c0 as c2, 
          ref_0.user_id as c3, 
          case when ((false) 
                and (((false) 
                    or (((true) 
                        or (true)) 
                      and (((true) 
                          and ((ref_0.updated_at is not NULL) 
                            or (false))) 
                        and (EXISTS (
                          select  
                              ref_0.created_at as c0
                            from 
                              test_bd.products as ref_22,
                              lateral (select  
                                    subq_8.c4 as c0, 
                                    subq_9.c3 as c1, 
                                    ref_23.created_at as c2, 
                                    (select bio from test_bd.user_profiles limit 1 offset 2)
                                       as c3, 
                                    (select eid from test_bd.eids limit 1 offset 6)
                                       as c4, 
                                    ref_23.discount as c5, 
                                    ref_22.discount as c6, 
                                    subq_8.c3 as c7, 
                                    ref_0.created_at as c8, 
                                    subq_8.c2 as c9, 
                                    subq_9.c1 as c10
                                  from 
                                    test_bd.products as ref_23,
                                    lateral (select  
                                          ref_22.discount as c0, 
                                          ref_22.price as c1, 
                                          subq_8.c4 as c2, 
                                          ref_22.created_at as c3, 
                                          ref_0.user_id as c4, 
                                          ref_22.name as c5, 
                                          ref_23.price as c6
                                        from 
                                          test_bd.eids as ref_24
                                        where true) as subq_9
                                  where ((EXISTS (
                                        select  
                                            ref_23.created_at as c0, 
                                            subq_8.c4 as c1, 
                                            ref_23.category as c2, 
                                            subq_8.c2 as c3, 
                                            ref_22.category as c4, 
                                            ref_22.category as c5, 
                                            subq_8.c4 as c6, 
                                            ref_23.discount as c7
                                          from 
                                            test_bd.locations as ref_25
                                          where true)) 
                                      or (subq_9.c1 is not NULL)) 
                                    or (((ref_22.price is not NULL) 
                                        or (false)) 
                                      and (false))) as subq_10,
                              lateral (select  
                                    ref_26.id as c0, 
                                    ref_26.user_id as c1, 
                                    ref_26.id as c2, 
                                    ref_22.price as c3, 
                                    ref_0.id as c4, 
                                    ref_26.id as c5, 
                                    ref_26.id as c6, 
                                    subq_10.c10 as c7, 
                                    subq_10.c10 as c8, 
                                    subq_8.c3 as c9, 
                                    ref_0.user_id as c10, 
                                    ref_22.created_at as c11, 
                                    ref_22.created_at as c12, 
                                    subq_8.c4 as c13, 
                                    subq_10.c1 as c14, 
                                    58 as c15, 
                                    subq_10.c4 as c16, 
                                    ref_26.user_id as c17, 
                                    subq_8.c1 as c18, 
                                    subq_10.c7 as c19, 
                                    subq_10.c9 as c20, 
                                    ref_22.category as c21, 
                                    subq_10.c5 as c22
                                  from 
                                    test_bd.locations as ref_26
                                  where EXISTS (
                                    select  
                                        ref_26.user_id as c0, 
                                        ref_27.id as c1, 
                                        ref_26.name as c2, 
                                        (select virtual_col from test_bd.eids limit 1 offset 1)
                                           as c3, 
                                        ref_0.user_id as c4, 
                                        ref_27.eid as c5, 
                                        ref_22.category as c6, 
                                        ref_26.user_id as c7, 
                                        ref_27.eid as c8
                                      from 
                                        test_bd.eids as ref_27
                                      where true
                                      limit 128)) as subq_11,
                              lateral (select  
                                    subq_8.c0 as c0
                                  from 
                                    test_bd.employee as ref_28
                                  where (false) 
                                    or ((60 is NULL) 
                                      and (subq_11.c13 is not NULL))
                                  limit 170) as subq_12
                            where EXISTS (
                              select  
                                  subq_8.c1 as c0, 
                                  ref_29.birthdate as c1, 
                                  subq_12.c0 as c2, 
                                  subq_10.c0 as c3, 
                                  ref_22.price as c4, 
                                  subq_10.c0 as c5, 
                                  subq_11.c22 as c6, 
                                  subq_10.c0 as c7, 
                                  subq_12.c0 as c8
                                from 
                                  test_bd.user_profiles as ref_29
                                where subq_8.c1 is not NULL)))))) 
                  and ((ref_0.title is not NULL) 
                    and (EXISTS (
                      select  
                          ref_30.virtual_col as c0, 
                          ref_0.updated_at as c1, 
                          ref_0.updated_at as c2, 
                          (select id from test_bd.locations limit 1 offset 46)
                             as c3, 
                          ref_30.id as c4, 
                          ref_30.virtual_col as c5, 
                          subq_8.c0 as c6, 
                          ref_30.eid as c7, 
                          subq_8.c2 as c8, 
                          ref_30.id as c9, 
                          ref_0.user_id as c10, 
                          ref_30.id as c11, 
                          ref_0.id as c12
                        from 
                          test_bd.eids as ref_30
                        where ref_30.eid is NULL))))) 
              or ((true) 
                or (ref_0.id is NULL)) then subq_8.c2 else subq_8.c2 end
             as c4, 
          subq_8.c4 as c5, 
          ref_0.updated_at as c6, 
          subq_8.c3 as c7, 
          ref_0.user_id as c8, 
          subq_8.c3 as c9, 
          ref_0.title as c10, 
          subq_8.c0 as c11, 
          ref_0.user_id as c12, 
          ref_0.updated_at as c13, 
          subq_8.c3 as c14, 
          subq_8.c1 as c15, 
          (select updated_at from test_bd.posts limit 1 offset 2)
             as c16
        from 
          test_bd.posts as ref_0,
          lateral (select  
                ref_1.discount as c0, 
                ref_0.title as c1, 
                (select id from test_bd.locations limit 1 offset 1)
                   as c2, 
                ref_1.price as c3, 
                ref_0.id as c4
              from 
                test_bd.products as ref_1
              where ((false) 
                  and (((EXISTS (
                        select  
                            ref_2.name as c0, 
                            (select user_id from test_bd.comments limit 1 offset 1)
                               as c1, 
                            ref_2.name as c2, 
                            ref_0.updated_at as c3, 
                            subq_4.c0 as c4, 
                            subq_4.c2 as c5, 
                            subq_4.c1 as c6
                          from 
                            test_bd.products as ref_2,
                            lateral (select  
                                  ref_3.title as c0, 
                                  ref_3.id as c1, 
                                  ref_1.name as c2
                                from 
                                  test_bd.posts as ref_3,
                                  lateral (select  
                                        ref_2.tags as c0, 
                                        ref_2.category as c1, 
                                        ref_2.category as c2, 
                                        ref_0.user_id as c3, 
                                        ref_3.user_id as c4, 
                                        ref_2.category as c5, 
                                        (select id from test_bd.comments limit 1 offset 6)
                                           as c6, 
                                        54 as c7, 
                                        62 as c8, 
                                        ref_0.id as c9, 
                                        ref_1.category as c10, 
                                        ref_0.user_id as c11, 
                                        ref_4.name as c12, 
                                        14 as c13, 
                                        ref_0.content as c14, 
                                        ref_0.created_at as c15
                                      from 
                                        test_bd.products as ref_4
                                      where ((true) 
                                          and ((false) 
                                            or (ref_3.id is NULL))) 
                                        or ((true) 
                                          or (EXISTS (
                                            select  
                                                ref_5.virtual_col as c0, 
                                                subq_2.c0 as c1, 
                                                ref_2.id as c2, 
                                                ref_0.updated_at as c3, 
                                                ref_0.updated_at as c4, 
                                                ref_4.price as c5, 
                                                ref_2.price as c6, 
                                                subq_1.c2 as c7, 
                                                ref_1.category as c8, 
                                                (select id from test_bd.users limit 1 offset 6)
                                                   as c9
                                              from 
                                                test_bd.eids as ref_5,
                                                lateral (select  
                                                      ref_0.created_at as c0, 
                                                      36 as c1, 
                                                      ref_4.price as c2, 
                                                      ref_6.user_id as c3
                                                    from 
                                                      test_bd.locations as ref_6,
                                                      lateral (select distinct 
                                                            ref_4.name as c0
                                                          from 
                                                            test_bd.posts as ref_7
                                                          where ref_0.content is not NULL
                                                          limit 82) as subq_0
                                                    where true) as subq_1,
                                                lateral (select  
                                                      ref_4.id as c0, 
                                                      ref_5.eid as c1, 
                                                      ref_8.username as c2, 
                                                      ref_0.user_id as c3
                                                    from 
                                                      test_bd.users as ref_8
                                                    where false
                                                    limit 43) as subq_2
                                              where ref_4.tags is not NULL
                                              limit 140)))
                                      limit 61) as subq_3
                                where (((true) 
                                      or (true)) 
                                    and (subq_3.c8 is not NULL)) 
                                  and (true)) as subq_4,
                            lateral (select  
                                  subq_5.c0 as c0, 
                                  subq_5.c1 as c1
                                from 
                                  test_bd.products as ref_9,
                                  lateral (select  
                                        ref_10.name as c0, 
                                        ref_1.category as c1, 
                                        subq_4.c1 as c2, 
                                        ref_10.id as c3, 
                                        subq_4.c2 as c4, 
                                        ref_1.id as c5
                                      from 
                                        test_bd.locations as ref_10
                                      where ref_0.created_at is not NULL
                                      limit 91) as subq_5
                                where ((ref_2.created_at is not NULL) 
                                    and (true)) 
                                  or ((true) 
                                    and (ref_1.name is NULL))) as subq_6
                          where EXISTS (
                            select  
                                ref_11.content as c0, 
                                ref_11.title as c1, 
                                subq_4.c2 as c2, 
                                ref_1.discount as c3, 
                                subq_4.c1 as c4, 
                                subq_6.c0 as c5, 
                                subq_4.c0 as c6, 
                                ref_2.category as c7, 
                                subq_4.c2 as c8
                              from 
                                test_bd.posts as ref_11,
                                lateral (select  
                                      ref_0.user_id as c0, 
                                      ref_11.created_at as c1, 
                                      ref_11.updated_at as c2, 
                                      ref_11.title as c3, 
                                      ref_2.discount as c4
                                    from 
                                      test_bd.products as ref_12
                                    where (((true) 
                                          and ((ref_2.name is NULL) 
                                            or ((false) 
                                              and (true)))) 
                                        or ((EXISTS (
                                            select  
                                                ref_13.user_id as c0, 
                                                ref_12.category as c1, 
                                                subq_4.c1 as c2, 
                                                ref_1.price as c3, 
                                                ref_11.id as c4, 
                                                ref_1.created_at as c5, 
                                                ref_11.id as c6, 
                                                ref_1.name as c7
                                              from 
                                                test_bd.user_profiles as ref_13
                                              where EXISTS (
                                                select distinct 
                                                    ref_13.bio as c0, 
                                                    (select birthdate from test_bd.user_profiles limit 1 offset 1)
                                                       as c1, 
                                                    95 as c2
                                                  from 
                                                    test_bd.user_post_comments as ref_14
                                                  where subq_6.c1 is NULL
                                                  limit 76)
                                              limit 53)) 
                                          or (true))) 
                                      and (subq_6.c0 is NULL)
                                    limit 78) as subq_7
                              where (true) 
                                and (((EXISTS (
                                      select  
                                          ref_11.content as c0, 
                                          subq_7.c3 as c1, 
                                          ref_1.category as c2
                                        from 
                                          test_bd.user_profiles as ref_15
                                        where ref_0.title is NULL
                                        limit 98)) 
                                    or (EXISTS (
                                      select  
                                          ref_0.id as c0, 
                                          subq_7.c2 as c1, 
                                          ref_0.title as c2
                                        from 
                                          test_bd.products as ref_16
                                        where (76 is NULL) 
                                          or ((true) 
                                            or (false))))) 
                                  or (true))
                              limit 51)
                          limit 123)) 
                      or (((true) 
                          and ((ref_1.category is NULL) 
                            and (ref_0.content is NULL))) 
                        and (EXISTS (
                          select  
                              ref_1.name as c0, 
                              ref_0.updated_at as c1
                            from 
                              test_bd.employee as ref_17
                            where true
                            limit 173)))) 
                    and ((((((true) 
                              or (EXISTS (
                                select  
                                    ref_18.title as c0, 
                                    ref_18.username as c1, 
                                    ref_1.id as c2, 
                                    ref_0.updated_at as c3, 
                                    ref_1.id as c4
                                  from 
                                    test_bd.user_post_comments as ref_18
                                  where ref_1.created_at is not NULL))) 
                            or ((((EXISTS (
                                    select  
                                        ref_1.tags as c0, 
                                        ref_1.discount as c1, 
                                        ref_0.title as c2
                                      from 
                                        test_bd.locations as ref_19
                                      where EXISTS (
                                        select  
                                            ref_1.id as c0
                                          from 
                                            test_bd.user_post_comments as ref_20
                                          where EXISTS (
                                            select  
                                                ref_20.title as c0, 
                                                ref_20.username as c1, 
                                                ref_21.comment as c2, 
                                                ref_21.username as c3
                                              from 
                                                test_bd.user_post_comments as ref_21
                                              where true
                                              limit 90)
                                          limit 121)
                                      limit 133)) 
                                  or ((false) 
                                    or (false))) 
                                and (false)) 
                              and (true))) 
                          or (ref_0.user_id is NULL)) 
                        or (75 is not NULL)) 
                      or (ref_1.price is not NULL)))) 
                and ((false) 
                  and ((ref_1.id is not NULL) 
                    or (ref_1.id is NULL)))
              limit 122) as subq_8
        where (((false) 
              and ((EXISTS (
                  select  
                      ref_0.content as c0, 
                      ref_31.eid as c1, 
                      subq_8.c2 as c2, 
                      ref_31.id as c3, 
                      51 as c4, 
                      ref_31.eid as c5, 
                      subq_8.c4 as c6, 
                      subq_8.c4 as c7, 
                      ref_31.id as c8, 
                      subq_8.c0 as c9, 
                      subq_8.c0 as c10, 
                      ref_0.created_at as c11, 
                      ref_0.title as c12, 
                      subq_8.c3 as c13, 
                      ref_31.eid as c14, 
                      subq_8.c3 as c15, 
                      subq_8.c3 as c16, 
                      ref_31.virtual_col as c17, 
                      ref_31.id as c18
                    from 
                      test_bd.eids as ref_31
                    where true)) 
                and (subq_8.c1 is NULL))) 
            or (true)) 
          and (false)
        limit 93) as subq_13
  where (false) 
    or ((EXISTS (
        select  
            subq_13.c6 as c0, 
            subq_13.c5 as c1
          from 
            test_bd.employee as ref_32
          where (false) 
            or (((false) 
                or ((((EXISTS (
                        select  
                            ref_32.eid as c0, 
                            subq_13.c15 as c1, 
                            subq_17.c0 as c2
                          from 
                            test_bd.posts as ref_33,
                            lateral (select  
                                  subq_15.c1 as c0
                                from 
                                  test_bd.users as ref_34,
                                  lateral (select  
                                        subq_14.c7 as c0, 
                                        ref_35.birthdate as c1, 
                                        subq_13.c1 as c2
                                      from 
                                        test_bd.user_profiles as ref_35,
                                        lateral (select  
                                              ref_34.created_at as c0, 
                                              ref_32.hire_date as c1, 
                                              (select comment from test_bd.comments limit 1 offset 1)
                                                 as c2, 
                                              subq_13.c7 as c3, 
                                              subq_13.c7 as c4, 
                                              ref_32.salary as c5, 
                                              ref_35.profile_picture as c6, 
                                              subq_13.c10 as c7
                                            from 
                                              test_bd.user_profiles as ref_36
                                            where EXISTS (
                                              select  
                                                  ref_37.years as c0, 
                                                  ref_32.age as c1, 
                                                  ref_36.user_id as c2, 
                                                  ref_34.id as c3
                                                from 
                                                  test_bd.employee as ref_37
                                                where true
                                                limit 151)
                                            limit 104) as subq_14
                                      where ref_34.username is NULL
                                      limit 136) as subq_15
                                where ((true) 
                                    and ((((true) 
                                          and ((true) 
                                            and (EXISTS (
                                              select  
                                                  ref_34.created_at as c0, 
                                                  ref_32.years as c1
                                                from 
                                                  test_bd.locations as ref_38,
                                                  lateral (select  
                                                        ref_39.username as c0, 
                                                        subq_13.c4 as c1, 
                                                        ref_32.salary as c2, 
                                                        ref_34.id as c3, 
                                                        subq_13.c9 as c4, 
                                                        subq_15.c1 as c5, 
                                                        (select id from test_bd.products limit 1 offset 4)
                                                           as c6, 
                                                        ref_32.id as c7, 
                                                        ref_34.username as c8, 
                                                        ref_32.eid as c9
                                                      from 
                                                        test_bd.user_post_comments as ref_39
                                                      where true) as subq_16
                                                where ref_32.hire_date is not NULL
                                                limit 39)))) 
                                        or (EXISTS (
                                          select  
                                              subq_15.c1 as c0
                                            from 
                                              test_bd.user_profiles as ref_40
                                            where false))) 
                                      or (true))) 
                                  or (false)) as subq_17
                          where false
                          limit 145)) 
                      or ((ref_32.age is NULL) 
                        and (true))) 
                    or ((subq_13.c6 is not NULL) 
                      or (EXISTS (
                        select  
                            ref_41.title as c0, 
                            subq_13.c11 as c1, 
                            (select profile_picture from test_bd.user_profiles limit 1 offset 2)
                               as c2, 
                            subq_19.c2 as c3, 
                            ref_32.age as c4
                          from 
                            test_bd.user_post_comments as ref_41,
                            lateral (select  
                                  subq_18.c0 as c0, 
                                  subq_13.c15 as c1, 
                                  subq_18.c0 as c2, 
                                  subq_18.c2 as c3, 
                                  ref_32.eid as c4, 
                                  subq_18.c1 as c5
                                from 
                                  test_bd.products as ref_42,
                                  lateral (select  
                                        ref_43.id as c0, 
                                        (select id from test_bd.comments limit 1 offset 4)
                                           as c1, 
                                        ref_32.salary as c2, 
                                        ref_41.username as c3
                                      from 
                                        test_bd.users as ref_43
                                      where EXISTS (
                                        select  
                                            ref_42.category as c0, 
                                            ref_43.created_at as c1, 
                                            subq_13.c10 as c2
                                          from 
                                            test_bd.eids as ref_44
                                          where true
                                          limit 85)) as subq_18
                                where (ref_32.department_id is NULL) 
                                  or (EXISTS (
                                    select  
                                        ref_42.id as c0, 
                                        (select eid from test_bd.eids limit 1 offset 2)
                                           as c1, 
                                        subq_13.c11 as c2, 
                                        subq_18.c3 as c3
                                      from 
                                        test_bd.user_post_comments as ref_45
                                      where subq_18.c2 is NULL
                                      limit 124))) as subq_19
                          where (true) 
                            or (false))))) 
                  or ((((false) 
                        and ((false) 
                          and (((((((false) 
                                      or (true)) 
                                    and (((false) 
                                        or (true)) 
                                      and (true))) 
                                  or (true)) 
                                or (ref_32.department_id is not NULL)) 
                              or (true)) 
                            and (((true) 
                                and ((false) 
                                  or ((false) 
                                    and (76 is not NULL)))) 
                              or (true))))) 
                      and (subq_13.c4 is NULL)) 
                    or ((subq_13.c10 is NULL) 
                      or (false))))) 
              and (subq_13.c14 is not NULL))
          limit 110)) 
      or (((((((subq_13.c1 is not NULL) 
                  or (((subq_13.c7 is NULL) 
                      or ((select id from test_bd.posts limit 1 offset 3)
                           is not NULL)) 
                    and (true))) 
                and (((EXISTS (
                      select  
                          ref_46.username as c0, 
                          ref_46.email as c1, 
                          ref_46.id as c2, 
                          subq_13.c3 as c3, 
                          subq_13.c16 as c4, 
                          subq_13.c15 as c5, 
                          subq_13.c11 as c6, 
                          ref_46.email as c7
                        from 
                          test_bd.users as ref_46
                        where EXISTS (
                          select  
                              ref_47.id as c0, 
                              ref_46.username as c1, 
                              ref_46.username as c2, 
                              ref_47.virtual_col as c3, 
                              ref_46.created_at as c4, 
                              82 as c5, 
                              ref_46.email as c6
                            from 
                              test_bd.eids as ref_47
                            where false
                            limit 123)
                        limit 85)) 
                    or (true)) 
                  or ((subq_13.c7 is NULL) 
                    or ((false) 
                      or (true))))) 
              or (((EXISTS (
                    select  
                        subq_13.c14 as c0, 
                        subq_13.c8 as c1, 
                        (select email from test_bd.users limit 1 offset 55)
                           as c2, 
                        ref_48.updated_at as c3
                      from 
                        test_bd.posts as ref_48
                      where (subq_13.c7 is not NULL) 
                        and (false)
                      limit 127)) 
                  and ((EXISTS (
                      select  
                          ref_49.title as c0, 
                          ref_49.title as c1
                        from 
                          test_bd.user_post_comments as ref_49
                        where true)) 
                    or (EXISTS (
                      select  
                          ref_50.id as c0, 
                          subq_21.c5 as c1, 
                          subq_21.c20 as c2, 
                          ref_50.id as c3, 
                          ref_50.id as c4, 
                          87 as c5, 
                          ref_50.name as c6, 
                          subq_21.c11 as c7, 
                          subq_13.c7 as c8, 
                          ref_50.name as c9, 
                          subq_21.c17 as c10, 
                          subq_21.c26 as c11, 
                          ref_50.id as c12, 
                          ref_50.name as c13, 
                          subq_21.c6 as c14, 
                          subq_13.c12 as c15, 
                          subq_13.c12 as c16, 
                          subq_21.c10 as c17, 
                          subq_13.c4 as c18, 
                          ref_50.name as c19, 
                          subq_13.c3 as c20, 
                          ref_50.user_id as c21
                        from 
                          test_bd.locations as ref_50,
                          lateral (select  
                                subq_13.c4 as c0, 
                                subq_20.c2 as c1, 
                                ref_50.user_id as c2, 
                                ref_51.user_id as c3, 
                                ref_50.name as c4, 
                                ref_50.id as c5, 
                                subq_13.c3 as c6, 
                                subq_13.c4 as c7, 
                                ref_51.coordinates as c8, 
                                subq_20.c3 as c9, 
                                ref_51.user_id as c10, 
                                (select created_at from test_bd.users limit 1 offset 1)
                                   as c11, 
                                ref_50.user_id as c12, 
                                ref_51.coordinates as c13, 
                                subq_20.c2 as c14, 
                                ref_50.id as c15, 
                                72 as c16, 
                                ref_51.id as c17, 
                                59 as c18, 
                                subq_13.c12 as c19, 
                                subq_20.c0 as c20, 
                                ref_51.name as c21, 
                                subq_13.c13 as c22, 
                                subq_20.c3 as c23, 
                                subq_20.c0 as c24, 
                                ref_51.name as c25, 
                                ref_51.id as c26, 
                                ref_50.id as c27, 
                                55 as c28
                              from 
                                test_bd.locations as ref_51,
                                lateral (select  
                                      ref_52.name as c0, 
                                      ref_52.id as c1, 
                                      subq_13.c7 as c2, 
                                      (select eid from test_bd.employee limit 1 offset 5)
                                         as c3, 
                                      ref_51.name as c4
                                    from 
                                      test_bd.locations as ref_52
                                    where (false) 
                                      and (ref_51.coordinates is NULL)
                                    limit 141) as subq_20
                              where EXISTS (
                                select  
                                    ref_53.comment as c0, 
                                    subq_13.c15 as c1
                                  from 
                                    test_bd.user_post_comments as ref_53
                                  where subq_13.c12 is not NULL)) as subq_21
                        where true
                        limit 117)))) 
                or (true))) 
            and (true)) 
          and (EXISTS (
            select  
                subq_13.c1 as c0
              from 
                test_bd.user_post_comments as ref_54
              where subq_13.c14 is NULL))) 
        or (((((false) 
                or (true)) 
              and (EXISTS (
                select  
                    ref_55.user_id as c0, 
                    subq_13.c14 as c1, 
                    subq_13.c16 as c2
                  from 
                    test_bd.posts as ref_55
                  where (select id from test_bd.eids limit 1 offset 6)
                       is NULL
                  limit 68))) 
            and (false)) 
          and (((((subq_13.c2 is not NULL) 
                  or (false)) 
                and (EXISTS (
                  select  
                      ref_56.email as c0, 
                      subq_13.c8 as c1
                    from 
                      test_bd.users as ref_56
                    where subq_13.c14 is not NULL
                    limit 123))) 
              or (false)) 
            or (((15 is NULL) 
                and ((subq_13.c12 is not NULL) 
                  or ((((((EXISTS (
                              select  
                                  subq_13.c15 as c0, 
                                  subq_13.c2 as c1, 
                                  subq_13.c6 as c2, 
                                  subq_13.c14 as c3, 
                                  subq_13.c6 as c4
                                from 
                                  test_bd.products as ref_57
                                where (((ref_57.category is not NULL) 
                                      and (((EXISTS (
                                            select  
                                                subq_13.c11 as c0
                                              from 
                                                test_bd.eids as ref_58,
                                                lateral (select  
                                                      ref_58.virtual_col as c0, 
                                                      31 as c1
                                                    from 
                                                      test_bd.users as ref_59
                                                    where false
                                                    limit 72) as subq_22
                                              where (true) 
                                                and (EXISTS (
                                                  select  
                                                      ref_58.virtual_col as c0, 
                                                      46 as c1, 
                                                      subq_13.c1 as c2, 
                                                      subq_22.c0 as c3, 
                                                      94 as c4, 
                                                      23 as c5, 
                                                      ref_60.comment as c6, 
                                                      subq_13.c8 as c7, 
                                                      subq_22.c1 as c8, 
                                                      subq_22.c1 as c9, 
                                                      ref_58.virtual_col as c10, 
                                                      subq_22.c1 as c11, 
                                                      subq_22.c1 as c12
                                                    from 
                                                      test_bd.comments as ref_60
                                                    where subq_13.c12 is NULL
                                                    limit 97)))) 
                                          and (false)) 
                                        or (((EXISTS (
                                              select  
                                                  ref_57.tags as c0, 
                                                  67 as c1, 
                                                  ref_61.department_id as c2
                                                from 
                                                  test_bd.employee as ref_61
                                                where (false) 
                                                  and (ref_61.email is not NULL)
                                                limit 138)) 
                                            or (((true) 
                                                and (EXISTS (
                                                  select  
                                                      ref_57.id as c0, 
                                                      ref_62.created_at as c1, 
                                                      ref_62.user_id as c2
                                                    from 
                                                      test_bd.comments as ref_62
                                                    where EXISTS (
                                                      select  
                                                          subq_26.c8 as c0, 
                                                          subq_13.c7 as c1, 
                                                          ref_62.created_at as c2, 
                                                          subq_26.c5 as c3, 
                                                          subq_24.c3 as c4, 
                                                          subq_23.c0 as c5, 
                                                          ref_62.created_at as c6, 
                                                          (select title from test_bd.user_post_comments limit 1 offset 4)
                                                             as c7, 
                                                          subq_13.c7 as c8, 
                                                          ref_62.comment as c9, 
                                                          ref_63.username as c10, 
                                                          subq_26.c6 as c11, 
                                                          ref_57.name as c12, 
                                                          (select price from test_bd.products limit 1 offset 6)
                                                             as c13, 
                                                          subq_24.c5 as c14, 
                                                          subq_23.c1 as c15
                                                        from 
                                                          test_bd.user_post_comments as ref_63,
                                                          lateral (select  
                                                                ref_64.user_id as c0, 
                                                                ref_63.title as c1
                                                              from 
                                                                test_bd.locations as ref_64
                                                              where ref_62.user_id is not NULL
                                                              limit 33) as subq_23,
                                                          lateral (select  
                                                                ref_62.user_id as c0, 
                                                                (select profile_picture from test_bd.user_profiles limit 1 offset 2)
                                                                   as c1, 
                                                                subq_23.c1 as c2, 
                                                                ref_65.birthdate as c3, 
                                                                ref_57.price as c4, 
                                                                ref_57.created_at as c5, 
                                                                ref_65.user_id as c6, 
                                                                ref_63.title as c7, 
                                                                subq_13.c0 as c8
                                                              from 
                                                                test_bd.user_profiles as ref_65
                                                              where true
                                                              limit 184) as subq_24,
                                                          lateral (select  
                                                                12 as c0, 
                                                                subq_24.c0 as c1, 
                                                                (select email from test_bd.users limit 1 offset 2)
                                                                   as c2, 
                                                                subq_24.c2 as c3, 
                                                                subq_13.c4 as c4, 
                                                                subq_13.c2 as c5, 
                                                                subq_24.c7 as c6, 
                                                                ref_62.id as c7, 
                                                                subq_13.c0 as c8, 
                                                                subq_24.c7 as c9, 
                                                                ref_62.id as c10, 
                                                                ref_66.title as c11, 
                                                                subq_13.c2 as c12, 
                                                                subq_23.c1 as c13
                                                              from 
                                                                test_bd.user_post_comments as ref_66,
                                                                lateral (select  
                                                                      subq_24.c2 as c0, 
                                                                      subq_13.c3 as c1
                                                                    from 
                                                                      test_bd.employee as ref_67
                                                                    where (false) 
                                                                      or (false)
                                                                    limit 160) as subq_25
                                                              where ((true) 
                                                                  or (((false) 
                                                                      and (EXISTS (
                                                                        select  
                                                                            subq_25.c0 as c0, 
                                                                            subq_24.c5 as c1, 
                                                                            subq_25.c0 as c2, 
                                                                            ref_63.comment as c3, 
                                                                            ref_62.post_id as c4, 
                                                                            (select created_at from test_bd.products limit 1 offset 2)
                                                                               as c5, 
                                                                            ref_68.id as c6, 
                                                                            ref_62.post_id as c7, 
                                                                            ref_62.id as c8, 
                                                                            ref_66.username as c9, 
                                                                            47 as c10, 
                                                                            ref_66.comment as c11, 
                                                                            subq_23.c0 as c12, 
                                                                            subq_25.c1 as c13, 
                                                                            subq_24.c2 as c14, 
                                                                            subq_24.c7 as c15, 
                                                                            ref_62.user_id as c16, 
                                                                            subq_25.c0 as c17, 
                                                                            subq_25.c1 as c18
                                                                          from 
                                                                            test_bd.eids as ref_68
                                                                          where true))) 
                                                                    or (true))) 
                                                                and (true)
                                                              limit 108) as subq_26
                                                        where (true) 
                                                          and (false)
                                                        limit 116)
                                                    limit 187))) 
                                              and (EXISTS (
                                                select  
                                                    subq_13.c5 as c0, 
                                                    ref_57.category as c1, 
                                                    16 as c2, 
                                                    ref_57.discount as c3, 
                                                    ref_57.name as c4, 
                                                    ref_69.id as c5, 
                                                    ref_69.tags as c6, 
                                                    ref_57.discount as c7, 
                                                    ref_57.category as c8, 
                                                    ref_57.created_at as c9, 
                                                    ref_57.name as c10, 
                                                    subq_13.c7 as c11, 
                                                    ref_69.price as c12
                                                  from 
                                                    test_bd.products as ref_69
                                                  where (true) 
                                                    or (((EXISTS (
                                                          select  
                                                              subq_13.c8 as c0, 
                                                              ref_70.profile_picture as c1, 
                                                              subq_27.c4 as c2, 
                                                              subq_27.c0 as c3, 
                                                              ref_70.user_id as c4, 
                                                              ref_70.user_id as c5
                                                            from 
                                                              test_bd.user_profiles as ref_70,
                                                              lateral (select  
                                                                    ref_70.birthdate as c0, 
                                                                    ref_71.virtual_col as c1, 
                                                                    ref_69.price as c2, 
                                                                    ref_70.birthdate as c3, 
                                                                    ref_70.user_id as c4
                                                                  from 
                                                                    test_bd.eids as ref_71
                                                                  where (true) 
                                                                    or (true)) as subq_27
                                                            where false
                                                            limit 135)) 
                                                        or (false)) 
                                                      or (subq_13.c1 is NULL))
                                                  limit 107)))) 
                                          or (true)))) 
                                    and (((false) 
                                        or ((true) 
                                          and (true))) 
                                      and (false))) 
                                  or ((subq_13.c15 is NULL) 
                                    and (true))
                                limit 154)) 
                            or ((select birthdate from test_bd.user_profiles limit 1 offset 3)
                                 is NULL)) 
                          or ((EXISTS (
                              select  
                                  ref_72.salary as c0, 
                                  ref_72.id as c1, 
                                  ref_72.email as c2, 
                                  subq_13.c8 as c3, 
                                  ref_72.hire_date as c4, 
                                  ref_72.eid as c5, 
                                  subq_13.c8 as c6
                                from 
                                  test_bd.employee as ref_72
                                where (((true) 
                                      or (true)) 
                                    and (false)) 
                                  or ((((true) 
                                        and (EXISTS (
                                          select  
                                              ref_72.department_id as c0, 
                                              ref_72.age as c1, 
                                              subq_13.c7 as c2
                                            from 
                                              test_bd.products as ref_73
                                            where (true) 
                                              or (EXISTS (
                                                select  
                                                    ref_72.department_id as c0
                                                  from 
                                                    test_bd.products as ref_74
                                                  where EXISTS (
                                                    select  
                                                        ref_75.created_at as c0, 
                                                        ref_73.id as c1
                                                      from 
                                                        test_bd.users as ref_75
                                                      where true
                                                      limit 178)
                                                  limit 74))
                                            limit 92))) 
                                      and ((EXISTS (
                                          select  
                                              subq_13.c13 as c0, 
                                              subq_13.c8 as c1, 
                                              ref_76.title as c2, 
                                              ref_72.years as c3, 
                                              ref_72.email as c4, 
                                              subq_13.c16 as c5
                                            from 
                                              test_bd.user_post_comments as ref_76
                                            where subq_13.c2 is NULL
                                            limit 127)) 
                                        and (true))) 
                                    and ((false) 
                                      and ((((((((false) 
                                                    or (subq_13.c4 is not NULL)) 
                                                  and (true)) 
                                                and (true)) 
                                              and ((((ref_72.salary is not NULL) 
                                                    and ((ref_72.eid is not NULL) 
                                                      and (false))) 
                                                  or (false)) 
                                                and (((true) 
                                                    or (((((false) 
                                                            and (ref_72.eid is NULL)) 
                                                          or ((true) 
                                                            and (true))) 
                                                        or (EXISTS (
                                                          select  
                                                              subq_13.c11 as c0, 
                                                              ref_77.virtual_col as c1, 
                                                              ref_77.id as c2, 
                                                              ref_77.virtual_col as c3, 
                                                              subq_13.c16 as c4, 
                                                              subq_13.c3 as c5, 
                                                              ref_72.id as c6, 
                                                              ref_72.hire_date as c7, 
                                                              ref_72.years as c8
                                                            from 
                                                              test_bd.eids as ref_77
                                                            where subq_13.c3 is not NULL
                                                            limit 107))) 
                                                      and (true))) 
                                                  and ((ref_72.department_id is not NULL) 
                                                    and (((false) 
                                                        or (EXISTS (
                                                          select  
                                                              ref_78.comment as c0, 
                                                              ref_72.years as c1, 
                                                              (select department_id from test_bd.employee limit 1 offset 6)
                                                                 as c2
                                                            from 
                                                              test_bd.user_post_comments as ref_78
                                                            where EXISTS (
                                                              select  
                                                                  subq_13.c1 as c0, 
                                                                  subq_13.c0 as c1, 
                                                                  ref_72.eid as c2, 
                                                                  ref_72.department_id as c3
                                                                from 
                                                                  test_bd.users as ref_79,
                                                                  lateral (select  
                                                                        ref_79.email as c0, 
                                                                        ref_80.user_id as c1, 
                                                                        62 as c2
                                                                      from 
                                                                        test_bd.comments as ref_80,
                                                                        lateral (select  
                                                                              ref_78.username as c0
                                                                            from 
                                                                              test_bd.eids as ref_81
                                                                            where false
                                                                            limit 171) as subq_28,
                                                                        lateral (select  
                                                                              ref_82.years as c0
                                                                            from 
                                                                              test_bd.employee as ref_82
                                                                            where true
                                                                            limit 90) as subq_29
                                                                      where true) as subq_30
                                                                where false
                                                                limit 119)))) 
                                                      or (false)))))) 
                                            and (true)) 
                                          or (true)) 
                                        and (ref_72.email is NULL))))
                                limit 125)) 
                            and (subq_13.c8 is not NULL))) 
                        or (true)) 
                      or ((subq_13.c9 is not NULL) 
                        and (subq_13.c3 is NULL))) 
                    and (false)))) 
              and (89 is NULL))))))
  limit 149)
select  
    coalesce(case when ((select category from test_bd.products limit 1 offset 5)
               is NULL) 
          or (true) then subq_31.c0 else subq_31.c0 end
        ,
      subq_34.c0) as c0, 
    subq_31.c1 as c1, 
    subq_36.c0 as c2, 
    subq_36.c3 as c3
  from 
    (select  
          ref_83.id as c0, 
          ref_83.eid as c1
        from 
          test_bd.eids as ref_83
        where true) as subq_31,
    lateral (select  
          ref_84.c1 as c0, 
          (select email from test_bd.employee limit 1 offset 4)
             as c1, 
          subq_33.c0 as c2, 
          ref_84.c2 as c3
        from 
          jennifer_0 as ref_84
            inner join test_bd.employee as ref_85
              right join test_bd.user_post_comments as ref_86
              on (((ref_86.username is NULL) 
                    or ((false) 
                      or (EXISTS (
                        select  
                            subq_31.c0 as c0, 
                            subq_31.c0 as c1, 
                            subq_31.c0 as c2, 
                            ref_87.title as c3, 
                            subq_31.c1 as c4, 
                            subq_31.c0 as c5, 
                            ref_85.age as c6, 
                            ref_85.id as c7, 
                            ref_85.hire_date as c8, 
                            (select discount from test_bd.products limit 1 offset 6)
                               as c9, 
                            ref_87.username as c10, 
                            (select birthdate from test_bd.user_profiles limit 1 offset 64)
                               as c11
                          from 
                            test_bd.user_post_comments as ref_87
                          where (ref_86.title is NULL) 
                            and (false)
                          limit 110)))) 
                  or (EXISTS (
                    select  
                        ref_86.comment as c0, 
                        ref_85.department_id as c1, 
                        ref_88.username as c2, 
                        ref_85.eid as c3, 
                        ref_85.hire_date as c4, 
                        ref_88.username as c5, 
                        ref_86.username as c6, 
                        ref_88.comment as c7, 
                        ref_85.email as c8, 
                        ref_88.title as c9
                      from 
                        test_bd.user_post_comments as ref_88
                      where (true) 
                        and (EXISTS (
                          select  
                              ref_85.department_id as c0, 
                              ref_85.years as c1, 
                              subq_31.c0 as c2, 
                              ref_86.title as c3
                            from 
                              test_bd.employee as ref_89
                            where ref_86.comment is NULL
                            limit 85)))))
            on (subq_31.c0 is NULL),
          lateral (select  
                ref_84.c2 as c0
              from 
                test_bd.users as ref_90,
                lateral (select  
                      ref_86.comment as c0, 
                      subq_31.c1 as c1, 
                      ref_90.id as c2, 
                      ref_91.id as c3, 
                      (select username from test_bd.users limit 1 offset 6)
                         as c4, 
                      ref_91.name as c5, 
                      62 as c6, 
                      subq_31.c0 as c7, 
                      ref_90.id as c8, 
                      30 as c9, 
                      ref_85.age as c10, 
                      ref_90.created_at as c11, 
                      ref_85.eid as c12, 
                      16 as c13, 
                      ref_90.email as c14, 
                      (select tags from test_bd.products limit 1 offset 1)
                         as c15, 
                      ref_86.username as c16, 
                      ref_91.price as c17, 
                      ref_90.email as c18
                    from 
                      test_bd.products as ref_91
                    where (ref_90.id is NULL) 
                      or (ref_91.name is NULL)) as subq_32
              where (EXISTS (
                  select  
                      ref_85.email as c0
                    from 
                      test_bd.products as ref_92
                    where false
                    limit 55)) 
                and ((ref_86.comment is not NULL) 
                  or (true))
              limit 9) as subq_33
        where 36 is not NULL
        limit 151) as subq_34,
    lateral (select  
          ref_93.hire_date as c0, 
          subq_34.c0 as c1, 
          subq_35.c2 as c2, 
          ref_93.email as c3, 
          (select email from test_bd.employee limit 1 offset 1)
             as c4
        from 
          test_bd.employee as ref_93,
          lateral (select  
                ref_93.email as c0, 
                ref_95.content as c1, 
                ref_94.hire_date as c2
              from 
                test_bd.employee as ref_94
                  right join test_bd.posts as ref_95
                  on (ref_94.years = ref_95.id )
              where 73 is NULL
              limit 64) as subq_35
        where (false) 
          and ((true) 
            and (subq_34.c0 is NULL))
        limit 124) as subq_36
  where false
  limit 125
;
SHOW profiles;