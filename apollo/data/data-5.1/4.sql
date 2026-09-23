SET profiling=1;
EXPLAIN ANALYZE
select  
  ref_0.content as c0, 
  subq_0.c0 as c1, 
  ref_0.content as c2, 
  ref_0.updated_at as c3, 
  subq_0.c0 as c4, 
  subq_0.c0 as c5, 
  ref_0.title as c6, 
  subq_0.c0 as c7, 
  ref_0.title as c8, 
  ref_0.created_at as c9, 
  subq_0.c0 as c10, 
  ref_0.id as c11, 
  subq_0.c0 as c12
from 
  test_bd.posts as ref_0,
  lateral (select  
        ref_2.years as c0
      from 
        test_bd.user_profiles as ref_1
          inner join test_bd.employee as ref_2
          on ((EXISTS (
                select  
                    ref_1.birthdate as c0, 
                    ref_3.discount as c1, 
                    39 as c2
                  from 
                    test_bd.products as ref_3
                  where ref_0.title is NULL
                  limit 157)) 
              or ((false) 
                or ((ref_1.bio is NULL) 
                  and (false))))
      where ((true) 
          and (EXISTS (
            select  
                ref_1.bio as c0, 
                ref_4.category as c1, 
                ref_0.id as c2, 
                ref_4.discount as c3
              from 
                test_bd.products as ref_4
              where EXISTS (
                select  
                    ref_5.created_at as c0, 
                    ref_4.name as c1, 
                    ref_2.email as c2, 
                    ref_1.bio as c3
                  from 
                    test_bd.products as ref_5
                  where false)
              limit 92))) 
        and (true)
      limit 90) as subq_0
where EXISTS (
  select  
      subq_13.c0 as c0
    from 
      test_bd.employee as ref_6
          left join test_bd.user_post_comments as ref_7
              right join test_bd.user_post_comments as ref_8
              on ((ref_8.username is not NULL) 
                  and (ref_7.title is NULL))
            right join test_bd.posts as ref_9
            on (true)
          on ((((EXISTS (
                    select  
                        subq_0.c0 as c0, 
                        subq_0.c0 as c1, 
                        ref_8.username as c2, 
                        ref_7.title as c3, 
                        ref_6.age as c4, 
                        ref_9.title as c5, 
                        ref_8.comment as c6, 
                        ref_9.created_at as c7, 
                        ref_7.comment as c8, 
                        ref_8.username as c9, 
                        ref_9.content as c10, 
                        ref_0.id as c11
                      from 
                        test_bd.eids as ref_10
                      where (((false) 
                            or ((ref_7.comment is NULL) 
                              and (EXISTS (
                                select  
                                    ref_10.virtual_col as c0, 
                                    27 as c1, 
                                    ref_10.id as c2, 
                                    ref_10.virtual_col as c3, 
                                    ref_9.title as c4, 
                                    ref_11.id as c5, 
                                    ref_9.user_id as c6, 
                                    ref_0.id as c7, 
                                    ref_0.updated_at as c8, 
                                    (select user_id from test_bd.user_profiles limit 1 offset 6)
                                       as c9, 
                                    ref_7.comment as c10
                                  from 
                                    test_bd.eids as ref_11
                                  where true)))) 
                          and (true)) 
                        and ((ref_10.virtual_col is NULL) 
                          or (false)))) 
                  or (EXISTS (
                    select  
                        ref_8.title as c0
                      from 
                        test_bd.locations as ref_12
                      where false))) 
                and (ref_9.id is not NULL)) 
              and (EXISTS (
                select  
                    ref_8.username as c0, 
                    ref_8.username as c1, 
                    subq_0.c0 as c2, 
                    ref_9.title as c3
                  from 
                    test_bd.user_profiles as ref_13
                  where (EXISTS (
                      select  
                          ref_6.age as c0, 
                          ref_14.user_id as c1, 
                          ref_7.username as c2, 
                          (select updated_at from test_bd.posts limit 1 offset 34)
                             as c3, 
                          ref_8.comment as c4, 
                          subq_0.c0 as c5, 
                          subq_0.c0 as c6, 
                          ref_6.department_id as c7, 
                          ref_7.title as c8, 
                          ref_7.title as c9
                        from 
                          test_bd.user_profiles as ref_14
                        where ((EXISTS (
                              select  
                                  ref_14.birthdate as c0, 
                                  ref_7.title as c1, 
                                  ref_14.user_id as c2, 
                                  ref_0.created_at as c3, 
                                  ref_8.comment as c4
                                from 
                                  test_bd.products as ref_15
                                where true)) 
                            or (false)) 
                          or ((ref_0.title is NULL) 
                            or (false))
                        limit 134)) 
                    or ((((false) 
                          and (EXISTS (
                            select  
                                ref_16.created_at as c0, 
                                subq_0.c0 as c1, 
                                (select comment from test_bd.user_post_comments limit 1 offset 6)
                                   as c2, 
                                ref_6.email as c3, 
                                ref_13.birthdate as c4, 
                                ref_16.tags as c5, 
                                ref_16.name as c6, 
                                ref_0.updated_at as c7, 
                                ref_13.profile_picture as c8, 
                                ref_13.profile_picture as c9, 
                                subq_0.c0 as c10, 
                                ref_13.bio as c11, 
                                ref_13.birthdate as c12, 
                                ref_8.title as c13, 
                                ref_6.years as c14
                              from 
                                test_bd.products as ref_16
                              where ((false) 
                                  and (false)) 
                                and ((ref_7.username is not NULL) 
                                  and ((EXISTS (
                                      select  
                                          ref_9.content as c0, 
                                          subq_0.c0 as c1, 
                                          ref_17.user_id as c2, 
                                          ref_0.title as c3, 
                                          1 as c4, 
                                          ref_13.birthdate as c5, 
                                          ref_7.username as c6, 
                                          ref_9.user_id as c7, 
                                          ref_6.age as c8, 
                                          ref_6.id as c9, 
                                          86 as c10, 
                                          ref_0.user_id as c11, 
                                          ref_13.profile_picture as c12, 
                                          ref_6.department_id as c13, 
                                          ref_13.user_id as c14, 
                                          ref_13.user_id as c15, 
                                          ref_17.bio as c16, 
                                          ref_8.username as c17, 
                                          ref_0.created_at as c18, 
                                          subq_0.c0 as c19
                                        from 
                                          test_bd.user_profiles as ref_17
                                        where (true) 
                                          and (false)
                                        limit 119)) 
                                    and ((true) 
                                      and (false))))
                              limit 139))) 
                        and (subq_0.c0 is NULL)) 
                      or ((true) 
                        and (EXISTS (
                          select  
                              ref_18.title as c0, 
                              ref_9.created_at as c1, 
                              ref_13.bio as c2
                            from 
                              test_bd.user_post_comments as ref_18
                            where (EXISTS (
                                select  
                                    ref_19.comment as c0, 
                                    ref_8.title as c1, 
                                    ref_19.title as c2, 
                                    ref_19.comment as c3
                                  from 
                                    test_bd.user_post_comments as ref_19
                                  where EXISTS (
                                    select  
                                        ref_20.price as c0, 
                                        ref_20.name as c1, 
                                        ref_6.hire_date as c2, 
                                        ref_6.years as c3, 
                                        (select virtual_col from test_bd.eids limit 1 offset 28)
                                           as c4, 
                                        ref_8.title as c5
                                      from 
                                        test_bd.products as ref_20
                                      where true
                                      limit 123)
                                  limit 65)) 
                              or (true)
                            limit 71)))))))
        left join (select  
              ref_0.title as c0, 
              subq_0.c0 as c1
            from 
              test_bd.users as ref_21,
              lateral (select  
                    (select birthdate from test_bd.user_profiles limit 1 offset 6)
                       as c0, 
                    ref_21.email as c1, 
                    subq_0.c0 as c2, 
                    subq_0.c0 as c3
                  from 
                    test_bd.comments as ref_22
                  where ((((((EXISTS (
                                select  
                                    subq_10.c1 as c0, 
                                    subq_10.c8 as c1
                                  from 
                                    test_bd.employee as ref_23,
                                    lateral (select  
                                          ref_22.post_id as c0, 
                                          ref_22.created_at as c1, 
                                          ref_0.created_at as c2
                                        from 
                                          test_bd.posts as ref_24,
                                          lateral (select  
                                                ref_25.username as c0
                                              from 
                                                test_bd.users as ref_25
                                              where true
                                              limit 89) as subq_1,
                                          lateral (select  
                                                subq_0.c0 as c0, 
                                                ref_24.updated_at as c1, 
                                                ref_24.updated_at as c2, 
                                                ref_22.comment as c3
                                              from 
                                                test_bd.user_profiles as ref_26
                                              where true) as subq_2
                                        where ((true) 
                                            and (EXISTS (
                                              select  
                                                  subq_1.c0 as c0, 
                                                  ref_27.hire_date as c1
                                                from 
                                                  test_bd.employee as ref_27
                                                where (true) 
                                                  or (false)))) 
                                          or (((EXISTS (
                                                select  
                                                    ref_22.post_id as c0, 
                                                    subq_2.c1 as c1, 
                                                    subq_1.c0 as c2, 
                                                    subq_0.c0 as c3, 
                                                    ref_21.id as c4, 
                                                    ref_0.user_id as c5
                                                  from 
                                                    test_bd.comments as ref_28
                                                  where (true) 
                                                    and (EXISTS (
                                                      select  
                                                          ref_22.post_id as c0, 
                                                          (select created_at from test_bd.posts limit 1 offset 1)
                                                             as c1, 
                                                          subq_0.c0 as c2, 
                                                          ref_21.created_at as c3, 
                                                          subq_0.c0 as c4
                                                        from 
                                                          test_bd.user_post_comments as ref_29,
                                                          lateral (select  
                                                                ref_29.title as c0
                                                              from 
                                                                test_bd.employee as ref_30
                                                              where (false) 
                                                                or (true)
                                                              limit 151) as subq_3,
                                                          lateral (select  
                                                                subq_3.c0 as c0, 
                                                                subq_3.c0 as c1
                                                              from 
                                                                test_bd.eids as ref_31
                                                              where false) as subq_4
                                                        where (true) 
                                                          and (EXISTS (
                                                            select  
                                                                ref_28.comment as c0, 
                                                                ref_24.content as c1, 
                                                                subq_4.c1 as c2, 
                                                                subq_0.c0 as c3
                                                              from 
                                                                test_bd.eids as ref_32
                                                              where false
                                                              limit 143)))))) 
                                              or ((EXISTS (
                                                  select  
                                                      ref_21.username as c0, 
                                                      subq_5.c7 as c1, 
                                                      ref_22.comment as c2, 
                                                      subq_5.c8 as c3, 
                                                      (select id from test_bd.users limit 1 offset 3)
                                                         as c4, 
                                                      ref_21.username as c5, 
                                                      ref_21.id as c6, 
                                                      ref_33.comment as c7, 
                                                      (select eid from test_bd.employee limit 1 offset 3)
                                                         as c8, 
                                                      ref_22.post_id as c9, 
                                                      subq_1.c0 as c10, 
                                                      subq_1.c0 as c11
                                                    from 
                                                      test_bd.user_post_comments as ref_33,
                                                      lateral (select  
                                                            subq_2.c0 as c0, 
                                                            ref_21.email as c1, 
                                                            ref_0.title as c2, 
                                                            subq_0.c0 as c3, 
                                                            ref_0.user_id as c4, 
                                                            ref_21.id as c5, 
                                                            subq_0.c0 as c6, 
                                                            ref_0.created_at as c7, 
                                                            subq_1.c0 as c8
                                                          from 
                                                            test_bd.users as ref_34
                                                          where true
                                                          limit 129) as subq_5
                                                    where true)) 
                                                and (EXISTS (
                                                  select  
                                                      60 as c0, 
                                                      ref_0.created_at as c1, 
                                                      subq_6.c6 as c2
                                                    from 
                                                      test_bd.comments as ref_35,
                                                      lateral (select  
                                                            ref_0.content as c0, 
                                                            96 as c1, 
                                                            ref_23.department_id as c2, 
                                                            subq_0.c0 as c3, 
                                                            subq_1.c0 as c4, 
                                                            subq_2.c2 as c5, 
                                                            subq_2.c1 as c6, 
                                                            ref_21.username as c7
                                                          from 
                                                            test_bd.user_profiles as ref_36
                                                          where false) as subq_6
                                                    where ((true) 
                                                        or (true)) 
                                                      or (true))))) 
                                            and (subq_0.c0 is not NULL))
                                        limit 104) as subq_7,
                                    lateral (select  
                                          subq_9.c5 as c0, 
                                          ref_0.title as c1, 
                                          subq_9.c3 as c2, 
                                          subq_7.c1 as c3, 
                                          subq_0.c0 as c4, 
                                          ref_37.eid as c5, 
                                          subq_9.c2 as c6, 
                                          ref_22.comment as c7, 
                                          ref_21.id as c8
                                        from 
                                          test_bd.eids as ref_37,
                                          lateral (select  
                                                subq_8.c0 as c0, 
                                                ref_21.id as c1, 
                                                ref_22.post_id as c2, 
                                                subq_0.c0 as c3, 
                                                ref_0.content as c4, 
                                                54 as c5
                                              from 
                                                test_bd.user_profiles as ref_38,
                                                lateral (select  
                                                      ref_21.created_at as c0, 
                                                      ref_39.name as c1
                                                    from 
                                                      test_bd.locations as ref_39
                                                    where (true) 
                                                      and (false)
                                                    limit 102) as subq_8
                                              where subq_8.c0 is not NULL) as subq_9
                                        where false
                                        limit 86) as subq_10,
                                    lateral (select  
                                          subq_7.c1 as c0, 
                                          ref_0.created_at as c1, 
                                          subq_7.c2 as c2
                                        from 
                                          test_bd.locations as ref_40
                                        where true) as subq_11
                                  where false
                                  limit 69)) 
                              or (ref_0.created_at is NULL)) 
                            and (false)) 
                          or (ref_21.created_at is NULL)) 
                        or (ref_21.email is NULL)) 
                      or (false)) 
                    or (subq_0.c0 is not NULL)
                  limit 117) as subq_12
            where subq_0.c0 is NULL) as subq_13
        on (ref_9.title is not NULL),
      lateral (select  
            (select id from test_bd.users limit 1 offset 4)
               as c0, 
            ref_8.title as c1, 
            ref_41.comment as c2, 
            ref_8.title as c3, 
            ref_6.department_id as c4, 
            subq_0.c0 as c5, 
            ref_9.created_at as c6, 
            ref_6.id as c7, 
            (select email from test_bd.users limit 1 offset 5)
               as c8, 
            ref_6.years as c9
          from 
            test_bd.user_post_comments as ref_41,
            lateral (select  
                  subq_13.c0 as c0, 
                  subq_13.c1 as c1, 
                  89 as c2
                from 
                  test_bd.users as ref_42,
                  lateral (select  
                        subq_13.c0 as c0, 
                        ref_7.comment as c1, 
                        ref_9.id as c2, 
                        ref_8.username as c3, 
                        subq_0.c0 as c4, 
                        ref_8.comment as c5, 
                        ref_7.username as c6, 
                        (select user_id from test_bd.locations limit 1 offset 2)
                           as c7, 
                        ref_8.comment as c8, 
                        58 as c9, 
                        ref_43.user_id as c10, 
                        ref_41.username as c11, 
                        ref_6.age as c12, 
                        (select profile_picture from test_bd.user_profiles limit 1 offset 4)
                           as c13, 
                        ref_9.updated_at as c14
                      from 
                        test_bd.user_profiles as ref_43
                      where subq_0.c0 is NULL) as subq_14
                where (EXISTS (
                    select  
                        subq_19.c2 as c0, 
                        ref_7.username as c1, 
                        ref_0.updated_at as c2, 
                        ref_0.updated_at as c3, 
                        ref_8.comment as c4, 
                        27 as c5, 
                        subq_16.c1 as c6, 
                        (select id from test_bd.eids limit 1 offset 93)
                           as c7
                      from 
                        test_bd.user_profiles as ref_44,
                        lateral (select  
                              ref_0.updated_at as c0, 
                              ref_7.username as c1, 
                              ref_44.user_id as c2
                            from 
                              test_bd.comments as ref_45
                            where ((EXISTS (
                                  select  
                                      subq_14.c10 as c0, 
                                      ref_42.created_at as c1, 
                                      91 as c2, 
                                      (select user_id from test_bd.user_profiles limit 1 offset 4)
                                         as c3, 
                                      ref_45.created_at as c4, 
                                      ref_9.content as c5, 
                                      27 as c6, 
                                      ref_9.user_id as c7
                                    from 
                                      test_bd.user_post_comments as ref_46,
                                      lateral (select  
                                            ref_42.created_at as c0, 
                                            ref_7.username as c1, 
                                            ref_9.title as c2, 
                                            ref_41.title as c3
                                          from 
                                            test_bd.comments as ref_47
                                          where false
                                          limit 99) as subq_15
                                    where EXISTS (
                                      select  
                                          ref_45.id as c0
                                        from 
                                          test_bd.user_profiles as ref_48
                                        where (((true) 
                                              and (false)) 
                                            or (100 is NULL)) 
                                          and (subq_0.c0 is NULL)
                                        limit 126))) 
                                or (ref_6.age is not NULL)) 
                              or (ref_0.updated_at is not NULL)
                            limit 110) as subq_16,
                        lateral (select  
                              ref_42.username as c0, 
                              subq_13.c1 as c1, 
                              ref_6.years as c2
                            from 
                              test_bd.employee as ref_49
                            where EXISTS (
                              select  
                                  ref_49.eid as c0, 
                                  ref_6.salary as c1, 
                                  ref_8.title as c2, 
                                  subq_14.c8 as c3, 
                                  ref_50.user_id as c4, 
                                  ref_42.email as c5, 
                                  ref_8.title as c6, 
                                  ref_6.eid as c7, 
                                  34 as c8, 
                                  (select comment from test_bd.user_post_comments limit 1 offset 5)
                                     as c9, 
                                  ref_41.title as c10, 
                                  ref_44.bio as c11, 
                                  ref_7.title as c12, 
                                  ref_8.username as c13, 
                                  ref_42.created_at as c14, 
                                  ref_42.username as c15, 
                                  subq_13.c0 as c16, 
                                  ref_8.username as c17, 
                                  subq_14.c0 as c18, 
                                  75 as c19
                                from 
                                  test_bd.user_profiles as ref_50
                                where (EXISTS (
                                    select  
                                        subq_16.c1 as c0, 
                                        subq_13.c0 as c1, 
                                        ref_51.category as c2, 
                                        subq_16.c0 as c3, 
                                        subq_16.c1 as c4
                                      from 
                                        test_bd.products as ref_51
                                      where (true) 
                                        and (true)
                                      limit 38)) 
                                  or ((subq_0.c0 is NULL) 
                                    and (((EXISTS (
                                          select  
                                              subq_16.c2 as c0, 
                                              ref_6.years as c1, 
                                              subq_16.c2 as c2, 
                                              subq_18.c2 as c3, 
                                              subq_0.c0 as c4, 
                                              ref_0.content as c5, 
                                              subq_14.c4 as c6, 
                                              subq_13.c0 as c7
                                            from 
                                              test_bd.user_post_comments as ref_52,
                                              lateral (select  
                                                    ref_42.username as c0, 
                                                    (select comment from test_bd.comments limit 1 offset 2)
                                                       as c1, 
                                                    ref_49.years as c2, 
                                                    ref_9.content as c3, 
                                                    (select comment from test_bd.user_post_comments limit 1 offset 6)
                                                       as c4, 
                                                    ref_52.title as c5
                                                  from 
                                                    test_bd.eids as ref_53,
                                                    lateral (select  
                                                          ref_9.id as c0, 
                                                          subq_13.c0 as c1, 
                                                          (select comment from test_bd.user_post_comments limit 1 offset 5)
                                                             as c2
                                                        from 
                                                          test_bd.user_post_comments as ref_54
                                                        where (EXISTS (
                                                            select  
                                                                ref_0.user_id as c0
                                                              from 
                                                                test_bd.comments as ref_55
                                                              where true
                                                              limit 120)) 
                                                          and (false)) as subq_17
                                                  where false
                                                  limit 128) as subq_18
                                            where (select user_id from test_bd.posts limit 1 offset 2)
                                                 is NULL)) 
                                        and ((true) 
                                          and ((false) 
                                            or ((true) 
                                              or ((ref_42.id is not NULL) 
                                                or ((true) 
                                                  or (true))))))) 
                                      or ((((true) 
                                            and ((EXISTS (
                                                select  
                                                    subq_0.c0 as c0
                                                  from 
                                                    test_bd.comments as ref_56
                                                  where true
                                                  limit 96)) 
                                              and (true))) 
                                          and (true)) 
                                        or (true))))
                                limit 91)
                            limit 91) as subq_19
                      where false
                      limit 189)) 
                  and (((true) 
                      and (true)) 
                    or (ref_0.id is NULL))
                limit 100) as subq_20
          where (((select salary from test_bd.employee limit 1 offset 2)
                   is NULL) 
              and (((EXISTS (
                    select  
                        (select created_at from test_bd.users limit 1 offset 1)
                           as c0
                      from 
                        test_bd.comments as ref_57
                      where ref_41.username is not NULL
                      limit 69)) 
                  or (false)) 
                or (((EXISTS (
                      select  
                          (select user_id from test_bd.posts limit 1 offset 6)
                             as c0, 
                          subq_20.c1 as c1, 
                          ref_7.title as c2, 
                          ref_58.coordinates as c3, 
                          (select user_id from test_bd.user_profiles limit 1 offset 6)
                             as c4
                        from 
                          test_bd.locations as ref_58
                        where ref_58.user_id is not NULL
                        limit 76)) 
                    and (true)) 
                  or (((false) 
                      or (EXISTS (
                        select  
                            ref_41.title as c0, 
                            ref_0.title as c1, 
                            ref_6.hire_date as c2, 
                            subq_20.c1 as c3, 
                            ref_6.eid as c4, 
                            ref_0.title as c5, 
                            subq_13.c0 as c6, 
                            ref_9.created_at as c7, 
                            subq_0.c0 as c8, 
                            ref_0.id as c9, 
                            ref_0.created_at as c10
                          from 
                            test_bd.posts as ref_59
                          where (false) 
                            or (false)
                          limit 128))) 
                    or (false))))) 
            and ((true) 
              or (true))
          limit 149) as subq_21
    where ((ref_8.username is not NULL) 
        or ((((((ref_7.username is NULL) 
                  and (false)) 
                or (EXISTS (
                  select  
                      ref_9.updated_at as c0, 
                      ref_60.coordinates as c1, 
                      ref_9.created_at as c2, 
                      subq_21.c0 as c3, 
                      subq_21.c5 as c4, 
                      ref_8.comment as c5, 
                      (select content from test_bd.posts limit 1 offset 1)
                         as c6, 
                      subq_21.c5 as c7, 
                      subq_21.c6 as c8
                    from 
                      test_bd.locations as ref_60
                    where true))) 
              and (subq_0.c0 is not NULL)) 
            or (EXISTS (
              select  
                  subq_21.c1 as c0, 
                  subq_21.c2 as c1
                from 
                  test_bd.user_profiles as ref_61
                where ((((true) 
                        and ((ref_6.eid is not NULL) 
                          or (true))) 
                      and ((((ref_8.comment is NULL) 
                            and (false)) 
                          or (false)) 
                        or (true))) 
                    or (false)) 
                  or (((false) 
                      and (EXISTS (
                        select  
                            ref_8.comment as c0, 
                            2 as c1
                          from 
                            test_bd.comments as ref_62,
                            lateral (select  
                                  ref_6.department_id as c0, 
                                  ref_7.title as c1, 
                                  (select id from test_bd.users limit 1 offset 7)
                                     as c2
                                from 
                                  test_bd.users as ref_63
                                where false
                                limit 123) as subq_22
                          where (EXISTS (
                              select  
                                  subq_21.c3 as c0
                                from 
                                  test_bd.user_post_comments as ref_64
                                where (false) 
                                  and (subq_13.c0 is not NULL))) 
                            or (ref_0.content is not NULL)
                          limit 83))) 
                    or (false))
                limit 192))) 
          and (((((true) 
                  and (true)) 
                and ((true) 
                  or ((((subq_0.c0 is NULL) 
                        or (((ref_0.user_id is not NULL) 
                            or ((ref_0.id is not NULL) 
                              or ((((false) 
                                    and ((ref_6.age is not NULL) 
                                      and (false))) 
                                  or ((false) 
                                    and (subq_21.c3 is NULL))) 
                                or (false)))) 
                          and ((false) 
                            or (((true) 
                                or (false)) 
                              and (false))))) 
                      or (subq_13.c1 is not NULL)) 
                    and (false)))) 
              or (true)) 
            and (EXISTS (
              select  
                  subq_21.c0 as c0, 
                  ref_0.updated_at as c1
                from 
                  test_bd.user_profiles as ref_65
                where (select username from test_bd.users limit 1 offset 1)
                     is NULL
                limit 132))))) 
      and (ref_8.title is NULL)
    limit 55)
limit 42;
SHOW profiles;