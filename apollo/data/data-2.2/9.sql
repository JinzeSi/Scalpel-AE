SET profiling=1;
EXPLAIN ANALYZE

select  
  79 as c0, 
  ref_0.bio as c1, 
  ref_0.user_id as c2, 
  subq_1.c1 as c3
from 
  test_bd.user_profiles as ref_0,
  lateral (select  
        ref_2.hire_date as c0, 
        ref_2.age as c1, 
        ref_0.bio as c2, 
        ref_2.department_id as c3
      from 
        (select  
                28 as c0, 
                (select email from test_bd.users limit 1 offset 5)
                   as c1, 
                ref_1.created_at as c2, 
                ref_1.email as c3, 
                ref_0.user_id as c4, 
                ref_0.birthdate as c5, 
                ref_1.email as c6, 
                48 as c7, 
                ref_1.created_at as c8
              from 
                test_bd.users as ref_1
              where (false) 
                and (true)) as subq_0
          right join test_bd.employee as ref_2
          on (ref_0.user_id is not NULL)
      where ref_0.bio is NULL
      limit 13) as subq_1
where ((EXISTS (
      select  
          93 as c0, 
          subq_2.c2 as c1, 
          (select created_at from test_bd.users limit 1 offset 6)
             as c2, 
          45 as c3
        from 
          test_bd.employee as ref_3,
          lateral (select  
                ref_4.user_id as c0, 
                ref_3.department_id as c1, 
                (select tags from test_bd.products limit 1 offset 4)
                   as c2, 
                ref_4.bio as c3, 
                ref_0.birthdate as c4, 
                subq_1.c3 as c5, 
                ref_0.birthdate as c6, 
                ref_3.id as c7, 
                ref_4.birthdate as c8
              from 
                test_bd.user_profiles as ref_4
              where subq_1.c2 is NULL) as subq_2
        where (false) 
          and (((ref_3.department_id is not NULL) 
              and (EXISTS (
                select  
                    ref_0.birthdate as c0, 
                    ref_0.profile_picture as c1
                  from 
                    test_bd.eids as ref_5
                  where EXISTS (
                    select  
                        subq_1.c1 as c0, 
                        subq_2.c0 as c1, 
                        ref_5.virtual_col as c2, 
                        ref_5.id as c3, 
                        subq_2.c5 as c4, 
                        ref_0.profile_picture as c5, 
                        subq_1.c2 as c6
                      from 
                        test_bd.posts as ref_6
                      where EXISTS (
                        select  
                            subq_2.c3 as c0
                          from 
                            test_bd.user_post_comments as ref_7
                          where true
                          limit 54)
                      limit 18)))) 
            or (((false) 
                and ((EXISTS (
                    select  
                        subq_1.c1 as c0, 
                        ref_8.id as c1, 
                        ref_0.bio as c2
                      from 
                        test_bd.users as ref_8
                      where EXISTS (
                        select  
                            ref_8.created_at as c0, 
                            ref_9.username as c1, 
                            subq_3.c4 as c2, 
                            ref_3.id as c3, 
                            subq_3.c9 as c4, 
                            ref_9.username as c5, 
                            ref_0.birthdate as c6, 
                            ref_8.id as c7, 
                            ref_8.id as c8, 
                            subq_2.c0 as c9, 
                            subq_2.c3 as c10, 
                            ref_8.username as c11, 
                            ref_9.created_at as c12, 
                            ref_0.profile_picture as c13, 
                            subq_3.c4 as c14, 
                            subq_1.c2 as c15, 
                            ref_0.user_id as c16, 
                            subq_3.c8 as c17, 
                            (select comment from test_bd.user_post_comments limit 1 offset 4)
                               as c18, 
                            subq_3.c5 as c19, 
                            subq_1.c1 as c20, 
                            ref_8.email as c21, 
                            subq_3.c2 as c22, 
                            subq_3.c4 as c23, 
                            subq_1.c1 as c24, 
                            subq_2.c6 as c25, 
                            ref_3.eid as c26, 
                            ref_0.user_id as c27
                          from 
                            test_bd.users as ref_9,
                            lateral (select  
                                  60 as c0, 
                                  ref_8.id as c1, 
                                  ref_9.created_at as c2, 
                                  subq_1.c3 as c3, 
                                  ref_0.user_id as c4, 
                                  ref_10.bio as c5, 
                                  ref_3.years as c6, 
                                  ref_0.birthdate as c7, 
                                  ref_0.profile_picture as c8, 
                                  subq_1.c1 as c9
                                from 
                                  test_bd.user_profiles as ref_10
                                where EXISTS (
                                  select  
                                      (select virtual_col from test_bd.eids limit 1 offset 24)
                                         as c0, 
                                      ref_11.user_id as c1, 
                                      subq_1.c0 as c2, 
                                      ref_9.created_at as c3, 
                                      (select comment from test_bd.user_post_comments limit 1 offset 1)
                                         as c4, 
                                      ref_3.salary as c5, 
                                      ref_10.bio as c6, 
                                      ref_8.email as c7, 
                                      ref_10.user_id as c8, 
                                      subq_2.c7 as c9
                                    from 
                                      test_bd.locations as ref_11
                                    where true)) as subq_3
                          where (true) 
                            and (((ref_3.age is NULL) 
                                and (false)) 
                              or (ref_9.id is NULL))))) 
                  or (((((false) 
                          and (false)) 
                        and ((false) 
                          or (true))) 
                      and (false)) 
                    and (subq_2.c0 is NULL)))) 
              or (false)))
        limit 76)) 
    or (EXISTS (
      select  
          ref_26.discount as c0, 
          ref_12.email as c1, 
          ref_12.id as c2, 
          ref_17.title as c3, 
          subq_1.c2 as c4, 
          ref_12.created_at as c5, 
          subq_1.c2 as c6, 
          ref_17.title as c7, 
          (select id from test_bd.posts limit 1 offset 97)
             as c8, 
          subq_1.c0 as c9, 
          ref_13.id as c10, 
          ref_12.username as c11, 
          ref_26.tags as c12, 
          ref_13.virtual_col as c13, 
          (select user_id from test_bd.locations limit 1 offset 5)
             as c14, 
          subq_1.c2 as c15, 
          ref_13.eid as c16
        from 
          test_bd.users as ref_12
                left join test_bd.eids as ref_13
                on ((false) 
                    or (EXISTS (
                      select  
                          ref_13.eid as c0, 
                          ref_12.username as c1, 
                          ref_12.email as c2, 
                          (select eid from test_bd.employee limit 1 offset 5)
                             as c3, 
                          36 as c4, 
                          ref_14.name as c5, 
                          subq_1.c1 as c6, 
                          (select comment from test_bd.user_post_comments limit 1 offset 4)
                             as c7
                        from 
                          test_bd.locations as ref_14
                        where ((ref_14.coordinates is not NULL) 
                            and (EXISTS (
                              select  
                                  ref_14.user_id as c0, 
                                  ref_13.eid as c1, 
                                  ref_15.email as c2, 
                                  ref_12.id as c3, 
                                  ref_12.created_at as c4, 
                                  ref_0.profile_picture as c5, 
                                  66 as c6
                                from 
                                  test_bd.users as ref_15
                                where ref_14.name is not NULL
                                limit 48))) 
                          and (EXISTS (
                            select  
                                ref_13.id as c0, 
                                subq_1.c2 as c1, 
                                ref_13.eid as c2, 
                                ref_13.id as c3, 
                                ref_13.id as c4, 
                                ref_12.id as c5, 
                                ref_12.email as c6
                              from 
                                test_bd.comments as ref_16
                              where ((true) 
                                  or (ref_12.email is not NULL)) 
                                and (((false) 
                                    and (ref_13.id is NULL)) 
                                  and (ref_0.birthdate is NULL))
                              limit 173)))))
              inner join test_bd.posts as ref_17
              on ((false) 
                  or ((EXISTS (
                      select  
                          ref_18.user_id as c0, 
                          subq_1.c2 as c1, 
                          ref_12.email as c2, 
                          ref_13.eid as c3, 
                          ref_12.username as c4
                        from 
                          test_bd.posts as ref_18,
                          lateral (select  
                                ref_17.content as c0, 
                                ref_13.virtual_col as c1, 
                                subq_1.c3 as c2, 
                                ref_17.id as c3, 
                                (select title from test_bd.user_post_comments limit 1 offset 5)
                                   as c4, 
                                ref_18.updated_at as c5
                              from 
                                test_bd.posts as ref_19
                              where true
                              limit 116) as subq_4
                        where ((((false) 
                                and (EXISTS (
                                  select  
                                      ref_12.username as c0, 
                                      subq_1.c0 as c1, 
                                      ref_13.id as c2, 
                                      ref_17.created_at as c3, 
                                      ref_17.content as c4, 
                                      55 as c5, 
                                      ref_0.birthdate as c6
                                    from 
                                      test_bd.users as ref_20
                                    where (true) 
                                      and (ref_13.virtual_col is NULL)
                                    limit 50))) 
                              and ((true) 
                                and ((EXISTS (
                                    select  
                                        90 as c0, 
                                        ref_12.id as c1
                                      from 
                                        test_bd.user_profiles as ref_21
                                      where true
                                      limit 40)) 
                                  or ((((EXISTS (
                                          select  
                                              ref_22.virtual_col as c0
                                            from 
                                              test_bd.eids as ref_22
                                            where (select id from test_bd.comments limit 1 offset 1)
                                                 is not NULL
                                            limit 71)) 
                                        and ((ref_13.virtual_col is not NULL) 
                                          or (false))) 
                                      and (((ref_13.eid is not NULL) 
                                          or (false)) 
                                        or (ref_13.eid is not NULL))) 
                                    or (subq_1.c3 is NULL))))) 
                            or (EXISTS (
                              select  
                                  ref_23.age as c0, 
                                  subq_1.c1 as c1, 
                                  ref_0.user_id as c2, 
                                  ref_13.id as c3, 
                                  subq_4.c5 as c4, 
                                  ref_18.updated_at as c5
                                from 
                                  test_bd.employee as ref_23
                                where ((ref_23.age is not NULL) 
                                    and ((false) 
                                      or (ref_23.years is not NULL))) 
                                  or (true)
                                limit 120))) 
                          and ((EXISTS (
                              select  
                                  ref_13.virtual_col as c0, 
                                  ref_17.id as c1, 
                                  subq_4.c5 as c2
                                from 
                                  test_bd.eids as ref_24
                                where true)) 
                            and (subq_1.c3 is not NULL))
                        limit 92)) 
                    or (EXISTS (
                      select  
                          ref_12.username as c0, 
                          ref_0.bio as c1, 
                          ref_17.title as c2, 
                          ref_13.virtual_col as c3
                        from 
                          test_bd.locations as ref_25
                        where true
                        limit 83))))
            right join test_bd.products as ref_26
            on (false)
        where (ref_12.username is not NULL) 
          or ((((((true) 
                    and ((false) 
                      and ((EXISTS (
                          select  
                              ref_27.updated_at as c0, 
                              ref_12.email as c1, 
                              ref_27.id as c2, 
                              ref_0.birthdate as c3, 
                              ref_0.birthdate as c4, 
                              ref_0.user_id as c5
                            from 
                              test_bd.posts as ref_27
                            where false)) 
                        or (false)))) 
                  and ((ref_0.bio is not NULL) 
                    or (ref_12.username is NULL))) 
                or ((((EXISTS (
                        select  
                            (select title from test_bd.posts limit 1 offset 6)
                               as c0
                          from 
                            test_bd.users as ref_28
                          where (true) 
                            and (ref_17.created_at is NULL)
                          limit 102)) 
                      or ((true) 
                        and (ref_13.virtual_col is not NULL))) 
                    and (((ref_26.name is not NULL) 
                        and (EXISTS (
                          select  
                              ref_12.id as c0
                            from 
                              test_bd.employee as ref_29
                            where 63 is not NULL
                            limit 111))) 
                      and (false))) 
                  or ((select post_id from test_bd.comments limit 1 offset 12)
                       is not NULL))) 
              and (EXISTS (
                select  
                    ref_17.updated_at as c0, 
                    ref_12.username as c1
                  from 
                    test_bd.comments as ref_30
                  where EXISTS (
                    select  
                        ref_26.created_at as c0, 
                        subq_1.c2 as c1, 
                        ref_31.bio as c2
                      from 
                        test_bd.user_profiles as ref_31
                      where ref_0.profile_picture is NULL
                      limit 93)))) 
            and (EXISTS (
              select  
                  ref_12.email as c0, 
                  ref_17.content as c1, 
                  ref_26.tags as c2, 
                  ref_0.user_id as c3, 
                  (select post_id from test_bd.comments limit 1 offset 1)
                     as c4, 
                  subq_1.c1 as c5, 
                  subq_1.c1 as c6, 
                  ref_0.user_id as c7
                from 
                  test_bd.locations as ref_32
                where (ref_0.birthdate is not NULL) 
                  and ((false) 
                    and (((ref_13.virtual_col is NULL) 
                        or (false)) 
                      or (false))))))
        limit 138))) 
  and (case when (EXISTS (
          select  
              ref_0.user_id as c0, 
              ref_35.birthdate as c1, 
              ref_35.bio as c2, 
              ref_0.birthdate as c3, 
              (select user_id from test_bd.locations limit 1 offset 3)
                 as c4
            from 
              test_bd.users as ref_33
                inner join test_bd.products as ref_34
                  left join test_bd.user_profiles as ref_35
                  on (ref_34.id = ref_35.user_id )
                on (ref_33.id = ref_34.id ),
              lateral (select  
                    ref_33.created_at as c0, 
                    subq_1.c1 as c1, 
                    46 as c2, 
                    ref_33.username as c3, 
                    ref_35.profile_picture as c4, 
                    ref_36.username as c5, 
                    ref_33.username as c6, 
                    subq_1.c2 as c7, 
                    ref_35.bio as c8, 
                    ref_34.tags as c9, 
                    ref_36.created_at as c10
                  from 
                    test_bd.users as ref_36
                  where ref_35.birthdate is NULL
                  limit 97) as subq_5
            where EXISTS (
              select  
                  ref_37.title as c0
                from 
                  test_bd.user_post_comments as ref_37,
                  lateral (select  
                        ref_38.title as c0, 
                        ref_38.content as c1, 
                        ref_0.profile_picture as c2, 
                        ref_0.bio as c3, 
                        subq_5.c8 as c4, 
                        subq_5.c7 as c5, 
                        ref_0.user_id as c6, 
                        ref_33.id as c7
                      from 
                        test_bd.posts as ref_38
                      where true
                      limit 113) as subq_6
                where true
                limit 104))) 
        and (((EXISTS (
              select  
                  ref_39.post_id as c0, 
                  ref_0.profile_picture as c1, 
                  ref_0.bio as c2, 
                  ref_0.user_id as c3
                from 
                  test_bd.comments as ref_39
                where (true) 
                  or (true)
                limit 94)) 
            and (true)) 
          or ((((true) 
                or (subq_1.c0 is NULL)) 
              or (subq_1.c0 is not NULL)) 
            or (false))) then subq_1.c2 else subq_1.c2 end
       is not NULL);
SHOW profiles;