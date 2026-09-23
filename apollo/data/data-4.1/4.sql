SET profiling=1;
EXPLAIN ANALYZE

WITH 
jennifer_0 AS (select  
    subq_2.c0 as c0, 
    ref_0.email as c1
  from 
    test_bd.users as ref_0
      inner join test_bd.user_profiles as ref_1
        left join (select  
              72 as c0, 
              ref_2.price as c1, 
              99 as c2, 
              ref_2.tags as c3, 
              subq_1.c0 as c4, 
              (select age from test_bd.employee limit 1 offset 1)
                 as c5, 
              subq_1.c3 as c6, 
              subq_1.c7 as c7, 
              ref_2.discount as c8
            from 
              test_bd.products as ref_2,
              lateral (select  
                    ref_3.name as c0, 
                    ref_3.user_id as c1, 
                    ref_3.id as c2, 
                    ref_3.name as c3, 
                    ref_3.name as c4, 
                    3 as c5, 
                    ref_3.coordinates as c6, 
                    ref_2.id as c7
                  from 
                    test_bd.locations as ref_3
                  where (EXISTS (
                      select  
                          ref_2.discount as c0, 
                          ref_2.discount as c1
                        from 
                          test_bd.employee as ref_4
                        where (((ref_2.discount is NULL) 
                              and (ref_3.coordinates is NULL)) 
                            and ((EXISTS (
                                select  
                                    ref_4.email as c0, 
                                    ref_3.coordinates as c1
                                  from 
                                    test_bd.eids as ref_5
                                  where true)) 
                              or (EXISTS (
                                select  
                                    subq_0.c0 as c0, 
                                    ref_6.id as c1, 
                                    ref_6.created_at as c2, 
                                    ref_6.user_id as c3, 
                                    (select hire_date from test_bd.employee limit 1 offset 72)
                                       as c4, 
                                    ref_2.id as c5, 
                                    subq_0.c0 as c6, 
                                    ref_6.title as c7, 
                                    ref_3.coordinates as c8, 
                                    ref_4.department_id as c9, 
                                    61 as c10, 
                                    subq_0.c0 as c11, 
                                    ref_6.title as c12
                                  from 
                                    test_bd.posts as ref_6,
                                    lateral (select  
                                          ref_2.id as c0
                                        from 
                                          test_bd.user_post_comments as ref_7
                                        where (true) 
                                          and ((false) 
                                            and (true))
                                        limit 118) as subq_0
                                  where EXISTS (
                                    select  
                                        ref_8.id as c0, 
                                        ref_4.email as c1, 
                                        ref_8.coordinates as c2, 
                                        ref_3.user_id as c3, 
                                        ref_2.discount as c4, 
                                        subq_0.c0 as c5, 
                                        ref_6.id as c6, 
                                        subq_0.c0 as c7, 
                                        ref_8.id as c8, 
                                        ref_2.category as c9
                                      from 
                                        test_bd.locations as ref_8
                                      where true
                                      limit 133)
                                  limit 85)))) 
                          and (EXISTS (
                            select  
                                ref_2.created_at as c0, 
                                ref_3.user_id as c1
                              from 
                                test_bd.employee as ref_9
                              where true
                              limit 136)))) 
                    and (true)
                  limit 37) as subq_1
            where ((ref_2.name is NULL) 
                or (true)) 
              or (ref_2.id is not NULL)) as subq_2
        on (subq_2.c5 is not NULL)
      on (((ref_0.created_at is not NULL) 
            or (ref_0.username is not NULL)) 
          or ((ref_1.birthdate is not NULL) 
            or (false)))
  where (ref_1.profile_picture is not NULL) 
    or (EXISTS (
      select  
          ref_1.birthdate as c0, 
          ref_0.created_at as c1, 
          ref_0.created_at as c2
        from 
          (select  
                ref_0.username as c0, 
                ref_1.user_id as c1, 
                ref_11.birthdate as c2, 
                ref_11.profile_picture as c3, 
                subq_2.c3 as c4, 
                ref_10.virtual_col as c5, 
                ref_11.birthdate as c6, 
                ref_11.bio as c7
              from 
                test_bd.eids as ref_10
                  right join test_bd.user_profiles as ref_11
                  on (true)
              where false
              limit 152) as subq_3,
          lateral (select  
                ref_0.created_at as c0, 
                subq_4.c0 as c1, 
                subq_3.c7 as c2, 
                subq_4.c0 as c3, 
                subq_4.c0 as c4, 
                subq_4.c0 as c5, 
                subq_3.c0 as c6, 
                subq_2.c5 as c7, 
                ref_12.id as c8, 
                subq_4.c0 as c9, 
                (select username from test_bd.user_post_comments limit 1 offset 2)
                   as c10, 
                ref_0.email as c11, 
                subq_4.c0 as c12, 
                subq_2.c3 as c13, 
                ref_12.hire_date as c14, 
                subq_2.c3 as c15, 
                subq_4.c0 as c16, 
                subq_3.c3 as c17, 
                subq_4.c0 as c18, 
                subq_2.c4 as c19
              from 
                test_bd.employee as ref_12,
                lateral (select  
                      subq_2.c0 as c0
                    from 
                      test_bd.locations as ref_13
                    where false
                    limit 61) as subq_4
              where true
              limit 106) as subq_5
        where ((ref_0.created_at is NULL) 
            and (subq_3.c5 is not NULL)) 
          and (((EXISTS (
                select  
                    ref_1.birthdate as c0, 
                    subq_2.c2 as c1
                  from 
                    test_bd.eids as ref_14,
                    lateral (select  
                          ref_0.email as c0
                        from 
                          test_bd.user_profiles as ref_15
                        where ref_15.profile_picture is NULL
                        limit 108) as subq_6
                  where ((EXISTS (
                        select  
                            ref_14.eid as c0, 
                            ref_16.created_at as c1
                          from 
                            test_bd.products as ref_16
                          where ((subq_5.c5 is not NULL) 
                              or (64 is not NULL)) 
                            and (false)
                          limit 90)) 
                      or (ref_14.id is not NULL)) 
                    or (true))) 
              and (((subq_3.c5 is not NULL) 
                  and (true)) 
                and (subq_2.c6 is not NULL))) 
            or ((true) 
              and ((EXISTS (
                  select  
                      ref_1.user_id as c0, 
                      ref_1.birthdate as c1, 
                      ref_1.birthdate as c2, 
                      ref_0.created_at as c3, 
                      ref_0.email as c4, 
                      ref_17.id as c5, 
                      ref_17.name as c6, 
                      ref_17.user_id as c7, 
                      6 as c8, 
                      subq_3.c6 as c9, 
                      subq_2.c4 as c10, 
                      subq_5.c16 as c11
                    from 
                      test_bd.locations as ref_17
                    where EXISTS (
                      select  
                          subq_2.c8 as c0, 
                          subq_2.c7 as c1, 
                          ref_1.profile_picture as c2, 
                          subq_5.c7 as c3, 
                          73 as c4, 
                          subq_5.c13 as c5, 
                          ref_1.user_id as c6, 
                          (select eid from test_bd.employee limit 1 offset 3)
                             as c7, 
                          subq_2.c3 as c8, 
                          (select id from test_bd.users limit 1 offset 6)
                             as c9, 
                          ref_18.created_at as c10
                        from 
                          test_bd.products as ref_18
                        where ((true) 
                            or (true)) 
                          and ((19 is NULL) 
                            or ((true) 
                              and (((true) 
                                  or (true)) 
                                and (false))))))) 
                and (ref_0.username is not NULL))))
        limit 94))
  limit 190)
select  
    subq_11.c0 as c0, 
    subq_11.c0 as c1, 
    subq_11.c0 as c2, 
    subq_11.c0 as c3
  from 
    (select  
          subq_7.c2 as c0, 
          subq_10.c9 as c1, 
          subq_8.c3 as c2
        from 
          (select  
                ref_19.id as c0, 
                ref_20.discount as c1, 
                ref_20.created_at as c2, 
                ref_20.category as c3, 
                ref_20.price as c4
              from 
                test_bd.posts as ref_19
                  inner join test_bd.products as ref_20
                  on (ref_20.created_at is not NULL)
              where true
              limit 137) as subq_7,
          lateral (select  
                subq_7.c4 as c0, 
                ref_21.c1 as c1, 
                ref_21.c1 as c2, 
                ref_21.c1 as c3, 
                subq_7.c2 as c4, 
                ref_21.c1 as c5
              from 
                jennifer_0 as ref_21
              where (ref_21.c0 is NULL) 
                and (EXISTS (
                  select  
                      71 as c0, 
                      subq_7.c1 as c1, 
                      ref_21.c1 as c2, 
                      subq_7.c3 as c3, 
                      subq_7.c4 as c4, 
                      83 as c5, 
                      ref_21.c1 as c6, 
                      ref_22.name as c7
                    from 
                      test_bd.products as ref_22
                    where ref_22.name is not NULL))) as subq_8,
          lateral (select  
                ref_23.email as c0, 
                ref_23.years as c1, 
                subq_8.c2 as c2, 
                (select title from test_bd.posts limit 1 offset 73)
                   as c3, 
                ref_23.email as c4, 
                ref_23.hire_date as c5, 
                ref_23.age as c6, 
                ref_23.salary as c7, 
                subq_7.c0 as c8, 
                ref_23.salary as c9, 
                ref_23.salary as c10, 
                ref_23.salary as c11, 
                subq_7.c2 as c12, 
                subq_8.c5 as c13, 
                subq_8.c5 as c14, 
                subq_8.c5 as c15, 
                subq_7.c0 as c16
              from 
                test_bd.employee as ref_23
              where (EXISTS (
                  select  
                      subq_7.c3 as c0, 
                      ref_23.hire_date as c1, 
                      ref_23.salary as c2, 
                      subq_7.c4 as c3, 
                      subq_7.c3 as c4, 
                      ref_24.c0 as c5, 
                      ref_23.email as c6
                    from 
                      jennifer_0 as ref_24
                    where false
                    limit 136)) 
                or ((EXISTS (
                    select  
                        ref_25.username as c0, 
                        1 as c1, 
                        subq_9.c0 as c2, 
                        subq_8.c3 as c3, 
                        subq_7.c4 as c4, 
                        ref_25.id as c5, 
                        subq_7.c4 as c6, 
                        subq_8.c3 as c7, 
                        ref_23.hire_date as c8, 
                        ref_23.hire_date as c9, 
                        subq_7.c1 as c10, 
                        subq_8.c5 as c11, 
                        ref_25.email as c12
                      from 
                        test_bd.users as ref_25,
                        lateral (select  
                              subq_7.c3 as c0
                            from 
                              test_bd.users as ref_26
                            where true
                            limit 156) as subq_9
                      where EXISTS (
                        select  
                            ref_25.id as c0, 
                            ref_25.id as c1, 
                            subq_7.c3 as c2
                          from 
                            test_bd.user_profiles as ref_27
                          where true
                          limit 127)
                      limit 43)) 
                  and ((select eid from test_bd.eids limit 1 offset 3)
                       is NULL))
              limit 17) as subq_10
        where (true) 
          or (false)
        limit 96) as subq_11
  where (false) 
    and ((((subq_11.c2 is not NULL) 
          and (subq_11.c0 is not NULL)) 
        or ((subq_11.c1 is not NULL) 
          and ((subq_11.c2 is not NULL) 
            and (subq_11.c2 is NULL)))) 
      or (EXISTS (
        select  
            subq_19.c0 as c0, 
            39 as c1
          from 
            test_bd.user_post_comments as ref_28
              left join test_bd.user_profiles as ref_29
              on ((((false) 
                      and ((((subq_11.c2 is NULL) 
                            or ((((true) 
                                  and (false)) 
                                or (false)) 
                              and (EXISTS (
                                select  
                                    ref_28.title as c0, 
                                    ref_28.username as c1, 
                                    ref_29.bio as c2, 
                                    ref_30.content as c3, 
                                    ref_29.user_id as c4, 
                                    ref_28.comment as c5, 
                                    (select username from test_bd.user_post_comments limit 1 offset 6)
                                       as c6, 
                                    ref_29.bio as c7, 
                                    ref_30.created_at as c8, 
                                    ref_30.id as c9
                                  from 
                                    test_bd.posts as ref_30
                                  where false
                                  limit 74)))) 
                          or (ref_29.user_id is not NULL)) 
                        and ((((false) 
                              or (true)) 
                            and (true)) 
                          or (ref_28.username is not NULL)))) 
                    or (((false) 
                        and (subq_11.c2 is not NULL)) 
                      and ((false) 
                        or (EXISTS (
                          select  
                              (select virtual_col from test_bd.eids limit 1 offset 4)
                                 as c0, 
                              ref_28.comment as c1, 
                              ref_29.user_id as c2, 
                              ref_31.years as c3, 
                              ref_31.salary as c4, 
                              ref_28.comment as c5, 
                              subq_11.c0 as c6, 
                              (select username from test_bd.user_post_comments limit 1 offset 5)
                                 as c7, 
                              ref_31.department_id as c8, 
                              ref_31.eid as c9, 
                              (select years from test_bd.employee limit 1 offset 8)
                                 as c10, 
                              ref_29.user_id as c11, 
                              ref_29.bio as c12, 
                              (select hire_date from test_bd.employee limit 1 offset 5)
                                 as c13, 
                              76 as c14
                            from 
                              test_bd.employee as ref_31
                            where (ref_29.birthdate is not NULL) 
                              or (((true) 
                                  and (((ref_28.title is not NULL) 
                                      and (false)) 
                                    or ((false) 
                                      or (4 is NULL)))) 
                                and (ref_28.title is not NULL))
                            limit 162))))) 
                  and ((EXISTS (
                      select  
                          ref_29.user_id as c0, 
                          ref_29.profile_picture as c1
                        from 
                          test_bd.locations as ref_32
                        where (EXISTS (
                            select  
                                ref_32.user_id as c0, 
                                subq_18.c6 as c1
                              from 
                                test_bd.user_profiles as ref_33,
                                lateral (select  
                                      ref_29.bio as c0, 
                                      ref_29.user_id as c1, 
                                      subq_12.c1 as c2, 
                                      ref_34.tags as c3, 
                                      ref_34.category as c4, 
                                      ref_34.id as c5, 
                                      ref_33.birthdate as c6, 
                                      ref_28.comment as c7
                                    from 
                                      test_bd.products as ref_34,
                                      lateral (select  
                                            subq_11.c1 as c0, 
                                            ref_35.discount as c1
                                          from 
                                            test_bd.products as ref_35
                                          where true
                                          limit 115) as subq_12
                                    where ((EXISTS (
                                          select  
                                              (select title from test_bd.user_post_comments limit 1 offset 72)
                                                 as c0, 
                                              ref_29.profile_picture as c1, 
                                              subq_12.c0 as c2, 
                                              ref_28.comment as c3, 
                                              ref_28.comment as c4
                                            from 
                                              test_bd.user_post_comments as ref_36,
                                              lateral (select  
                                                    subq_12.c1 as c0
                                                  from 
                                                    test_bd.users as ref_37
                                                  where EXISTS (
                                                    select  
                                                        subq_13.c1 as c0, 
                                                        ref_37.email as c1
                                                      from 
                                                        test_bd.eids as ref_38,
                                                        lateral (select  
                                                              ref_34.discount as c0, 
                                                              ref_34.tags as c1, 
                                                              ref_29.birthdate as c2, 
                                                              ref_33.birthdate as c3, 
                                                              ref_36.title as c4, 
                                                              subq_12.c1 as c5, 
                                                              ref_37.created_at as c6
                                                            from 
                                                              test_bd.user_profiles as ref_39
                                                            where ref_29.user_id is NULL
                                                            limit 87) as subq_13,
                                                        lateral (select  
                                                              ref_34.discount as c0
                                                            from 
                                                              test_bd.employee as ref_40
                                                            where false
                                                            limit 89) as subq_14
                                                      where (true) 
                                                        or (false)
                                                      limit 138)
                                                  limit 60) as subq_15,
                                              lateral (select  
                                                    ref_41.id as c0, 
                                                    ref_32.coordinates as c1, 
                                                    subq_12.c1 as c2, 
                                                    ref_32.user_id as c3, 
                                                    subq_12.c0 as c4, 
                                                    (select bio from test_bd.user_profiles limit 1 offset 1)
                                                       as c5, 
                                                    ref_32.user_id as c6, 
                                                    subq_12.c1 as c7, 
                                                    ref_28.title as c8, 
                                                    ref_34.created_at as c9
                                                  from 
                                                    test_bd.eids as ref_41
                                                  where (ref_36.comment is not NULL) 
                                                    or ((false) 
                                                      and (EXISTS (
                                                        select  
                                                            subq_15.c0 as c0, 
                                                            ref_36.title as c1
                                                          from 
                                                            jennifer_0 as ref_42
                                                          where true
                                                          limit 82)))) as subq_16
                                            where true)) 
                                        or (ref_32.user_id is not NULL)) 
                                      and (false)
                                    limit 143) as subq_17,
                                lateral (select  
                                      75 as c0, 
                                      subq_17.c2 as c1, 
                                      ref_29.birthdate as c2, 
                                      ref_29.bio as c3, 
                                      subq_11.c0 as c4, 
                                      ref_43.name as c5, 
                                      subq_11.c1 as c6, 
                                      ref_32.coordinates as c7, 
                                      ref_29.birthdate as c8, 
                                      subq_17.c1 as c9, 
                                      ref_32.name as c10, 
                                      subq_11.c0 as c11, 
                                      ref_33.user_id as c12
                                    from 
                                      test_bd.locations as ref_43
                                    where false
                                    limit 144) as subq_18
                              where ref_33.profile_picture is not NULL
                              limit 160)) 
                          and (false))) 
                    and (ref_28.comment is not NULL))),
            lateral (select  
                  ref_44.username as c0, 
                  (select eid from test_bd.eids limit 1 offset 3)
                     as c1, 
                  ref_44.comment as c2
                from 
                  test_bd.user_post_comments as ref_44
                where false
                limit 167) as subq_19
          where subq_11.c1 is not NULL
          limit 178)))
  limit 117
;
SHOW profiles;