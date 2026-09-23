SET profiling=1;
EXPLAIN ANALYZE

select  
  43 as c0, 
  subq_3.c2 as c1, 
  subq_3.c5 as c2
from 
  (select  
        subq_1.c6 as c0, 
        subq_1.c1 as c1, 
        subq_1.c2 as c2, 
        subq_1.c6 as c3, 
        subq_1.c1 as c4, 
        subq_1.c5 as c5
      from 
        (select  
              subq_0.c0 as c0, 
              subq_0.c3 as c1, 
              37 as c2, 
              ref_0.title as c3, 
              ref_0.title as c4, 
              (select content from test_bd.posts limit 1 offset 1)
                 as c5, 
              subq_0.c5 as c6
            from 
              test_bd.user_post_comments as ref_0,
              lateral (select  
                    ref_0.comment as c0, 
                    ref_0.comment as c1, 
                    ref_1.virtual_col as c2, 
                    ref_1.id as c3, 
                    ref_0.comment as c4, 
                    ref_1.virtual_col as c5, 
                    ref_1.id as c6
                  from 
                    test_bd.eids as ref_1
                  where (false) 
                    or (ref_0.username is not NULL)) as subq_0
            where EXISTS (
              select  
                  subq_0.c6 as c0
                from 
                  test_bd.products as ref_2
                where true
                limit 119)
            limit 55) as subq_1
      where (((23 is NULL) 
            and (subq_1.c1 is not NULL)) 
          or (EXISTS (
            select  
                (select id from test_bd.comments limit 1 offset 6)
                   as c0, 
                ref_3.hire_date as c1, 
                (select title from test_bd.user_post_comments limit 1 offset 6)
                   as c2, 
                ref_3.department_id as c3, 
                97 as c4, 
                ref_3.salary as c5, 
                subq_1.c0 as c6, 
                ref_3.department_id as c7, 
                ref_3.email as c8, 
                subq_2.c1 as c9, 
                subq_2.c1 as c10, 
                ref_3.hire_date as c11, 
                subq_1.c5 as c12, 
                (select years from test_bd.employee limit 1 offset 89)
                   as c13, 
                subq_2.c0 as c14, 
                ref_3.age as c15, 
                13 as c16, 
                ref_3.years as c17, 
                subq_1.c6 as c18, 
                subq_1.c5 as c19
              from 
                test_bd.employee as ref_3,
                lateral (select  
                      ref_4.username as c0, 
                      ref_3.eid as c1
                    from 
                      test_bd.users as ref_4
                    where (true) 
                      and (EXISTS (
                        select  
                            (select hire_date from test_bd.employee limit 1 offset 5)
                               as c0, 
                            subq_1.c3 as c1, 
                            subq_1.c2 as c2, 
                            subq_1.c5 as c3
                          from 
                            test_bd.products as ref_5
                          where ref_4.id is NULL))
                    limit 31) as subq_2
              where ((76 is not NULL) 
                  and (false)) 
                or (false)
              limit 147))) 
        or ((((false) 
              and ((select coordinates from test_bd.locations limit 1 offset 6)
                   is not NULL)) 
            or (subq_1.c5 is NULL)) 
          and (EXISTS (
            select  
                ref_6.id as c0, 
                12 as c1, 
                subq_1.c3 as c2, 
                ref_6.created_at as c3, 
                ref_7.birthdate as c4, 
                ref_6.email as c5, 
                (select user_id from test_bd.comments limit 1 offset 3)
                   as c6
              from 
                test_bd.users as ref_6
                  inner join test_bd.user_profiles as ref_7
                  on (((select name from test_bd.locations limit 1 offset 2)
                           is NULL) 
                      and ((ref_6.created_at is NULL) 
                        or (true)))
              where (false) 
                or ((((((false) 
                          and ((subq_1.c0 is not NULL) 
                            or ((ref_7.bio is not NULL) 
                              and ((true) 
                                and (false))))) 
                        and (EXISTS (
                          select  
                              subq_1.c4 as c0, 
                              (select user_id from test_bd.locations limit 1 offset 1)
                                 as c1
                            from 
                              test_bd.employee as ref_8
                            where (ref_6.email is NULL) 
                              and (ref_7.bio is not NULL)
                            limit 111))) 
                      and (((EXISTS (
                            select  
                                ref_6.email as c0, 
                                ref_9.created_at as c1, 
                                ref_7.user_id as c2, 
                                ref_6.id as c3, 
                                (select username from test_bd.users limit 1 offset 3)
                                   as c4, 
                                ref_9.id as c5
                              from 
                                test_bd.comments as ref_9
                              where subq_1.c4 is NULL)) 
                          and (EXISTS (
                            select  
                                ref_10.hire_date as c0, 
                                ref_7.profile_picture as c1, 
                                ref_6.id as c2, 
                                ref_6.created_at as c3, 
                                (select created_at from test_bd.comments limit 1 offset 1)
                                   as c4, 
                                ref_10.id as c5, 
                                ref_10.salary as c6
                              from 
                                test_bd.employee as ref_10
                              where true
                              limit 144))) 
                        or (90 is NULL))) 
                    and (false)) 
                  and (true)))))) as subq_3
where (((subq_3.c0 is NULL) 
      and ((EXISTS (
          select  
              ref_11.title as c0, 
              ref_11.username as c1, 
              ref_11.comment as c2, 
              81 as c3, 
              subq_3.c2 as c4
            from 
              test_bd.user_post_comments as ref_11
            where ref_11.title is not NULL
            limit 113)) 
        or ((subq_3.c3 is NULL) 
          and (subq_3.c5 is not NULL)))) 
    or ((subq_3.c4 is NULL) 
      and (true))) 
  and (((EXISTS (
        select  
            subq_3.c4 as c0, 
            subq_3.c2 as c1, 
            subq_3.c5 as c2
          from 
            test_bd.locations as ref_12
          where ref_12.name is not NULL)) 
      and ((((EXISTS (
              select  
                  subq_3.c0 as c0, 
                  35 as c1, 
                  subq_3.c1 as c2, 
                  ref_13.coordinates as c3, 
                  subq_3.c0 as c4, 
                  ref_13.user_id as c5
                from 
                  test_bd.locations as ref_13
                where ((EXISTS (
                      select  
                          subq_6.c0 as c0, 
                          subq_6.c1 as c1, 
                          ref_14.id as c2, 
                          (select post_id from test_bd.comments limit 1 offset 2)
                             as c3, 
                          subq_3.c3 as c4
                        from 
                          test_bd.posts as ref_14,
                          lateral (select  
                                subq_3.c4 as c0, 
                                subq_3.c0 as c1
                              from 
                                test_bd.employee as ref_15,
                                lateral (select  
                                      ref_15.hire_date as c0, 
                                      ref_16.id as c1, 
                                      64 as c2
                                    from 
                                      test_bd.eids as ref_16
                                    where ((true) 
                                        and (((true) 
                                            and (false)) 
                                          or (((ref_16.eid is not NULL) 
                                              and (subq_3.c0 is NULL)) 
                                            and (((false) 
                                                and (ref_14.title is not NULL)) 
                                              or (false))))) 
                                      or (ref_13.coordinates is NULL)) as subq_4,
                                lateral (select  
                                      89 as c0, 
                                      subq_3.c1 as c1, 
                                      subq_4.c1 as c2, 
                                      subq_3.c3 as c3, 
                                      18 as c4, 
                                      ref_17.hire_date as c5
                                    from 
                                      test_bd.employee as ref_17
                                    where ((subq_4.c1 is not NULL) 
                                        or (ref_15.department_id is not NULL)) 
                                      or (EXISTS (
                                        select  
                                            ref_15.email as c0, 
                                            ref_14.title as c1, 
                                            ref_15.id as c2, 
                                            ref_18.name as c3, 
                                            ref_13.name as c4, 
                                            ref_14.created_at as c5, 
                                            ref_15.salary as c6, 
                                            ref_17.age as c7, 
                                            subq_3.c3 as c8, 
                                            ref_14.created_at as c9, 
                                            ref_15.age as c10, 
                                            ref_13.id as c11, 
                                            ref_17.id as c12, 
                                            ref_14.updated_at as c13, 
                                            subq_4.c2 as c14, 
                                            ref_18.id as c15, 
                                            ref_14.id as c16, 
                                            ref_13.coordinates as c17
                                          from 
                                            test_bd.products as ref_18
                                          where false
                                          limit 160))
                                    limit 141) as subq_5
                              where (ref_14.title is NULL) 
                                or (ref_13.coordinates is not NULL)
                              limit 125) as subq_6
                        where (EXISTS (
                            select  
                                ref_14.user_id as c0, 
                                subq_3.c5 as c1, 
                                ref_19.id as c2, 
                                ref_19.user_id as c3, 
                                (select years from test_bd.employee limit 1 offset 1)
                                   as c4, 
                                ref_13.id as c5, 
                                subq_6.c1 as c6, 
                                ref_19.user_id as c7, 
                                subq_6.c0 as c8, 
                                subq_3.c3 as c9, 
                                (select price from test_bd.products limit 1 offset 1)
                                   as c10, 
                                subq_6.c1 as c11, 
                                ref_13.user_id as c12, 
                                ref_19.user_id as c13, 
                                subq_6.c1 as c14, 
                                ref_13.name as c15, 
                                subq_3.c2 as c16
                              from 
                                test_bd.locations as ref_19
                              where ((EXISTS (
                                    select  
                                        ref_20.title as c0
                                      from 
                                        test_bd.user_post_comments as ref_20
                                      where false
                                      limit 54)) 
                                  and (false)) 
                                or (false)
                              limit 129)) 
                          or (true)
                        limit 113)) 
                    or ((false) 
                      or (((false) 
                          and (ref_13.name is NULL)) 
                        or (((((EXISTS (
                                  select  
                                      (select created_at from test_bd.comments limit 1 offset 2)
                                         as c0, 
                                      ref_13.user_id as c1, 
                                      ref_13.user_id as c2, 
                                      subq_3.c0 as c3, 
                                      10 as c4, 
                                      ref_21.id as c5, 
                                      ref_21.user_id as c6, 
                                      ref_13.id as c7, 
                                      subq_3.c3 as c8, 
                                      subq_3.c5 as c9, 
                                      (select department_id from test_bd.employee limit 1 offset 6)
                                         as c10, 
                                      ref_13.name as c11, 
                                      ref_21.comment as c12, 
                                      subq_3.c4 as c13, 
                                      ref_21.post_id as c14, 
                                      73 as c15, 
                                      ref_13.user_id as c16, 
                                      subq_3.c1 as c17
                                    from 
                                      test_bd.comments as ref_21
                                    where false)) 
                                or ((false) 
                                  or (EXISTS (
                                    select  
                                        ref_13.id as c0, 
                                        subq_3.c0 as c1, 
                                        subq_3.c0 as c2, 
                                        ref_22.salary as c3, 
                                        ref_22.email as c4, 
                                        ref_13.name as c5, 
                                        (select name from test_bd.locations limit 1 offset 5)
                                           as c6
                                      from 
                                        test_bd.employee as ref_22
                                      where (ref_22.email is not NULL) 
                                        or (EXISTS (
                                          select  
                                              ref_22.salary as c0, 
                                              subq_3.c5 as c1
                                            from 
                                              test_bd.eids as ref_23
                                            where (false) 
                                              and ((false) 
                                                and (true))))
                                      limit 119)))) 
                              and (true)) 
                            and (true)) 
                          or (EXISTS (
                            select  
                                ref_24.bio as c0, 
                                ref_13.coordinates as c1, 
                                ref_13.id as c2, 
                                subq_3.c5 as c3, 
                                ref_13.coordinates as c4, 
                                ref_24.bio as c5, 
                                34 as c6, 
                                ref_13.coordinates as c7
                              from 
                                test_bd.user_profiles as ref_24
                              where ((false) 
                                  and (false)) 
                                or (((EXISTS (
                                      select  
                                          subq_3.c0 as c0, 
                                          ref_13.name as c1, 
                                          subq_3.c5 as c2, 
                                          ref_25.eid as c3, 
                                          85 as c4, 
                                          subq_3.c0 as c5, 
                                          ref_13.name as c6
                                        from 
                                          test_bd.eids as ref_25
                                        where false
                                        limit 139)) 
                                    and (EXISTS (
                                      select  
                                          ref_26.department_id as c0, 
                                          ref_26.id as c1, 
                                          subq_3.c4 as c2, 
                                          (select created_at from test_bd.comments limit 1 offset 6)
                                             as c3
                                        from 
                                          test_bd.employee as ref_26
                                        where (((false) 
                                              or (((false) 
                                                  or (false)) 
                                                and (subq_3.c3 is NULL))) 
                                            and (false)) 
                                          and (false)
                                        limit 129))) 
                                  and (false))
                              limit 146)))))) 
                  and (false))) 
            or ((((EXISTS (
                    select  
                        subq_3.c5 as c0, 
                        ref_27.created_at as c1, 
                        ref_27.created_at as c2
                      from 
                        test_bd.users as ref_27
                      where false
                      limit 65)) 
                  and ((true) 
                    and (((false) 
                        or (true)) 
                      or ((EXISTS (
                          select  
                              ref_28.eid as c0
                            from 
                              test_bd.eids as ref_28
                            where EXISTS (
                              select  
                                  subq_3.c3 as c0
                                from 
                                  test_bd.products as ref_29
                                where true
                                limit 130)
                            limit 62)) 
                        and (EXISTS (
                          select  
                              subq_3.c3 as c0, 
                              subq_3.c0 as c1, 
                              ref_30.user_id as c2, 
                              subq_3.c1 as c3, 
                              ref_30.birthdate as c4, 
                              ref_30.profile_picture as c5, 
                              subq_3.c4 as c6, 
                              subq_3.c1 as c7, 
                              subq_3.c2 as c8, 
                              (select name from test_bd.products limit 1 offset 5)
                                 as c9, 
                              subq_3.c3 as c10, 
                              ref_30.bio as c11, 
                              ref_30.birthdate as c12
                            from 
                              test_bd.user_profiles as ref_30
                            where (true) 
                              and (false)
                            limit 149)))))) 
                or ((subq_3.c0 is not NULL) 
                  and (subq_3.c3 is not NULL))) 
              or (subq_3.c3 is NULL))) 
          or (EXISTS (
            select  
                subq_3.c0 as c0, 
                subq_3.c4 as c1, 
                ref_31.post_id as c2, 
                15 as c3, 
                subq_3.c5 as c4
              from 
                test_bd.comments as ref_31
              where (((EXISTS (
                      select  
                          subq_3.c5 as c0, 
                          ref_32.virtual_col as c1, 
                          subq_3.c3 as c2, 
                          subq_7.c0 as c3, 
                          subq_8.c0 as c4, 
                          (select birthdate from test_bd.user_profiles limit 1 offset 1)
                             as c5, 
                          ref_31.created_at as c6, 
                          ref_31.id as c7
                        from 
                          test_bd.eids as ref_32,
                          lateral (select  
                                ref_33.title as c0
                              from 
                                test_bd.posts as ref_33
                              where ((false) 
                                  and (true)) 
                                or (false)
                              limit 77) as subq_7,
                          lateral (select  
                                subq_3.c4 as c0
                              from 
                                test_bd.posts as ref_34
                              where (ref_34.content is not NULL) 
                                or (subq_3.c4 is not NULL)
                              limit 133) as subq_8,
                          lateral (select  
                                subq_3.c0 as c0, 
                                subq_8.c0 as c1, 
                                ref_32.virtual_col as c2, 
                                (select user_id from test_bd.user_profiles limit 1 offset 46)
                                   as c3, 
                                ref_31.post_id as c4, 
                                subq_7.c0 as c5, 
                                ref_35.id as c6, 
                                ref_31.user_id as c7
                              from 
                                test_bd.posts as ref_35
                              where false
                              limit 83) as subq_9,
                          lateral (select  
                                ref_31.user_id as c0, 
                                (select bio from test_bd.user_profiles limit 1 offset 3)
                                   as c1, 
                                subq_9.c3 as c2, 
                                subq_9.c1 as c3, 
                                subq_7.c0 as c4, 
                                (select id from test_bd.comments limit 1 offset 6)
                                   as c5, 
                                ref_31.comment as c6, 
                                subq_7.c0 as c7, 
                                subq_7.c0 as c8, 
                                ref_31.post_id as c9
                              from 
                                test_bd.eids as ref_36
                              where EXISTS (
                                select  
                                    ref_37.id as c0, 
                                    ref_31.post_id as c1, 
                                    subq_8.c0 as c2, 
                                    subq_3.c1 as c3
                                  from 
                                    test_bd.comments as ref_37
                                  where false
                                  limit 52)
                              limit 125) as subq_10
                        where (false) 
                          or (subq_10.c2 is not NULL))) 
                    and (((false) 
                        and (ref_31.post_id is not NULL)) 
                      or (subq_3.c5 is not NULL))) 
                  or ((false) 
                    and (35 is not NULL))) 
                or (EXISTS (
                  select  
                      subq_3.c5 as c0, 
                      subq_13.c2 as c1, 
                      ref_31.comment as c2
                    from 
                      test_bd.posts as ref_38,
                      lateral (select  
                            subq_12.c13 as c0, 
                            subq_12.c21 as c1, 
                            ref_38.updated_at as c2, 
                            ref_31.user_id as c3, 
                            subq_12.c11 as c4
                          from 
                            test_bd.user_profiles as ref_39,
                            lateral (select  
                                  subq_3.c1 as c0, 
                                  ref_39.birthdate as c1, 
                                  subq_3.c3 as c2, 
                                  subq_3.c3 as c3, 
                                  ref_39.user_id as c4, 
                                  subq_3.c4 as c5, 
                                  subq_11.c1 as c6, 
                                  42 as c7, 
                                  ref_40.tags as c8, 
                                  ref_40.name as c9, 
                                  ref_40.price as c10, 
                                  (select post_id from test_bd.comments limit 1 offset 68)
                                     as c11, 
                                  ref_31.id as c12, 
                                  ref_31.id as c13, 
                                  subq_3.c0 as c14, 
                                  ref_39.user_id as c15, 
                                  (select user_id from test_bd.user_profiles limit 1 offset 6)
                                     as c16, 
                                  ref_38.id as c17, 
                                  ref_38.content as c18, 
                                  ref_40.id as c19, 
                                  ref_38.updated_at as c20, 
                                  ref_39.user_id as c21
                                from 
                                  test_bd.products as ref_40,
                                  lateral (select  
                                        ref_41.id as c0, 
                                        ref_31.comment as c1, 
                                        subq_3.c3 as c2, 
                                        (select user_id from test_bd.locations limit 1 offset 85)
                                           as c3, 
                                        ref_41.id as c4, 
                                        ref_31.post_id as c5, 
                                        ref_39.bio as c6
                                      from 
                                        test_bd.eids as ref_41
                                      where (false) 
                                        or ((((true) 
                                              or ((false) 
                                                and (false))) 
                                            and ((false) 
                                              and (((subq_3.c1 is NULL) 
                                                  and (subq_3.c0 is NULL)) 
                                                or ((ref_31.post_id is not NULL) 
                                                  or (true))))) 
                                          and (38 is NULL))
                                      limit 191) as subq_11
                                where true
                                limit 124) as subq_12
                          where (false) 
                            or (true)
                          limit 62) as subq_13,
                      lateral (select  
                            ref_38.created_at as c0, 
                            ref_38.user_id as c1
                          from 
                            test_bd.posts as ref_42
                          where (true) 
                            and (false)) as subq_14,
                      lateral (select  
                            subq_3.c1 as c0, 
                            subq_14.c0 as c1, 
                            ref_31.comment as c2, 
                            subq_14.c1 as c3, 
                            ref_38.id as c4, 
                            subq_3.c1 as c5, 
                            ref_38.updated_at as c6, 
                            subq_13.c3 as c7, 
                            subq_14.c0 as c8, 
                            subq_14.c1 as c9
                          from 
                            test_bd.user_post_comments as ref_43
                          where false
                          limit 65) as subq_15
                    where true
                    limit 21))
              limit 123))) 
        and (true))) 
    and (EXISTS (
      select  
          subq_3.c1 as c0, 
          subq_3.c4 as c1, 
          subq_3.c0 as c2, 
          subq_3.c1 as c3, 
          ref_44.virtual_col as c4, 
          subq_3.c0 as c5, 
          66 as c6, 
          subq_3.c0 as c7
        from 
          test_bd.eids as ref_44
        where subq_3.c3 is NULL
        limit 161)));
SHOW profiles;