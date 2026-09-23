SET profiling=1;
EXPLAIN ANALYZE

select  
  case when (EXISTS (
        select  
            ref_15.tags as c0, 
            subq_1.c0 as c1, 
            subq_5.c0 as c2, 
            ref_14.username as c3, 
            ref_15.price as c4, 
            ref_15.category as c5
          from 
            test_bd.users as ref_14
              inner join test_bd.products as ref_15
              on (subq_1.c0 is NULL)
          where false)) 
      or ((EXISTS (
          select  
              subq_1.c0 as c0, 
              subq_1.c0 as c1
            from 
              test_bd.eids as ref_16
            where (subq_5.c0 is not NULL) 
              and ((false) 
                and (((select id from test_bd.locations limit 1 offset 4)
                       is NULL) 
                  and (ref_16.virtual_col is not NULL)))
            limit 65)) 
        and (EXISTS (
          select  
              subq_1.c0 as c0
            from 
              test_bd.posts as ref_17,
              lateral (select  
                    ref_17.updated_at as c0, 
                    ref_18.profile_picture as c1, 
                    subq_5.c2 as c2, 
                    subq_1.c0 as c3, 
                    subq_1.c0 as c4, 
                    ref_18.profile_picture as c5, 
                    subq_1.c0 as c6, 
                    subq_5.c6 as c7, 
                    (select title from test_bd.user_post_comments limit 1 offset 6)
                       as c8, 
                    (select id from test_bd.posts limit 1 offset 5)
                       as c9, 
                    ref_18.bio as c10, 
                    ref_18.user_id as c11, 
                    subq_1.c0 as c12, 
                    subq_1.c0 as c13, 
                    ref_17.updated_at as c14, 
                    subq_5.c0 as c15, 
                    ref_18.user_id as c16
                  from 
                    test_bd.user_profiles as ref_18
                  where true
                  limit 36) as subq_6
            where false
            limit 162))) then subq_1.c0 else subq_1.c0 end
     as c0, 
  subq_1.c0 as c1, 
  subq_1.c0 as c2, 
  73 as c3, 
  subq_1.c0 as c4, 
  subq_1.c0 as c5, 
  subq_1.c0 as c6
from 
  (select  
        (select virtual_col from test_bd.eids limit 1 offset 3)
           as c0
      from 
        test_bd.locations as ref_0
              inner join test_bd.posts as ref_1
              on ((ref_0.coordinates is not NULL) 
                  or ((false) 
                    or (false)))
            right join test_bd.posts as ref_2
              inner join test_bd.posts as ref_3
              on (ref_2.title = ref_3.title )
            on ((select virtual_col from test_bd.eids limit 1 offset 93)
                   is not NULL)
          inner join test_bd.users as ref_4
          on ((ref_2.content is not NULL) 
              or ((false) 
                or (true))),
        lateral (select  
              63 as c0
            from 
              test_bd.employee as ref_5
            where ref_4.email is not NULL
            limit 144) as subq_0
      where (ref_1.updated_at is not NULL) 
        or (EXISTS (
          select  
              ref_0.user_id as c0, 
              31 as c1, 
              ref_4.created_at as c2, 
              ref_1.id as c3, 
              ref_6.user_id as c4
            from 
              test_bd.user_profiles as ref_6
            where ref_0.name is NULL
            limit 76))) as subq_1,
  lateral (select  
        subq_1.c0 as c0, 
        subq_4.c0 as c1, 
        subq_4.c3 as c2, 
        subq_1.c0 as c3, 
        (select salary from test_bd.employee limit 1 offset 3)
           as c4, 
        subq_1.c0 as c5, 
        subq_4.c1 as c6, 
        subq_1.c0 as c7, 
        (select comment from test_bd.comments limit 1 offset 3)
           as c8, 
        subq_1.c0 as c9, 
        subq_1.c0 as c10
      from 
        (select  
              ref_7.hire_date as c0, 
              subq_1.c0 as c1, 
              subq_2.c15 as c2, 
              subq_1.c0 as c3, 
              ref_7.years as c4, 
              ref_7.department_id as c5
            from 
              test_bd.employee as ref_7,
              lateral (select  
                    ref_7.age as c0, 
                    ref_7.eid as c1, 
                    subq_1.c0 as c2, 
                    1 as c3, 
                    ref_8.birthdate as c4, 
                    ref_8.profile_picture as c5, 
                    subq_1.c0 as c6, 
                    subq_1.c0 as c7, 
                    73 as c8, 
                    ref_8.bio as c9, 
                    ref_7.email as c10, 
                    ref_8.birthdate as c11, 
                    ref_8.profile_picture as c12, 
                    ref_8.user_id as c13, 
                    36 as c14, 
                    subq_1.c0 as c15, 
                    ref_8.user_id as c16
                  from 
                    test_bd.user_profiles as ref_8
                  where ((true) 
                      or ((true) 
                        and (subq_1.c0 is NULL))) 
                    or (false)
                  limit 85) as subq_2
            where (((subq_1.c0 is not NULL) 
                  or ((false) 
                    and (EXISTS (
                      select  
                          ref_9.user_id as c0, 
                          ref_9.profile_picture as c1, 
                          (select tags from test_bd.products limit 1 offset 1)
                             as c2, 
                          ref_7.hire_date as c3, 
                          (select email from test_bd.users limit 1 offset 5)
                             as c4, 
                          (select user_id from test_bd.user_profiles limit 1 offset 27)
                             as c5, 
                          subq_2.c3 as c6, 
                          subq_2.c7 as c7, 
                          39 as c8
                        from 
                          test_bd.user_profiles as ref_9
                        where (ref_9.bio is not NULL) 
                          and ((true) 
                            and ((ref_7.age is not NULL) 
                              or (true))))))) 
                or (true)) 
              or (((((select age from test_bd.employee limit 1 offset 5)
                         is not NULL) 
                    or (EXISTS (
                      select  
                          ref_10.id as c0, 
                          subq_3.c4 as c1, 
                          subq_1.c0 as c2, 
                          subq_3.c3 as c3
                        from 
                          test_bd.locations as ref_10,
                          lateral (select  
                                ref_7.email as c0, 
                                subq_1.c0 as c1, 
                                subq_1.c0 as c2, 
                                33 as c3, 
                                subq_2.c3 as c4
                              from 
                                test_bd.products as ref_11
                              where true
                              limit 82) as subq_3
                        where false
                        limit 111))) 
                  or ((false) 
                    and ((((false) 
                          and ((subq_1.c0 is NULL) 
                            and (true))) 
                        or ((false) 
                          or (false))) 
                      or (EXISTS (
                        select  
                            subq_1.c0 as c0, 
                            subq_1.c0 as c1, 
                            ref_12.id as c2
                          from 
                            test_bd.locations as ref_12
                          where EXISTS (
                            select  
                                subq_1.c0 as c0, 
                                ref_13.created_at as c1, 
                                subq_2.c9 as c2
                              from 
                                test_bd.users as ref_13
                              where 69 is NULL
                              limit 42)))))) 
                or ((false) 
                  or (false)))
            limit 98) as subq_4
      where (((true) 
            and (subq_1.c0 is not NULL)) 
          and (false)) 
        and ((subq_1.c0 is not NULL) 
          or (true))
      limit 62) as subq_5
where (true) 
  and ((((((((((false) 
                    and (((((subq_1.c0 is NULL) 
                            or ((false) 
                              or (true))) 
                          or (subq_5.c7 is NULL)) 
                        or ((EXISTS (
                            select  
                                ref_19.username as c0, 
                                ref_19.id as c1
                              from 
                                test_bd.users as ref_19
                              where ((false) 
                                  or (false)) 
                                and ((subq_1.c0 is NULL) 
                                  or (true)))) 
                          and ((true) 
                            and (false)))) 
                      and (subq_1.c0 is NULL))) 
                  and (((true) 
                      or (subq_1.c0 is NULL)) 
                    and (((((subq_1.c0 is not NULL) 
                            or (subq_5.c6 is not NULL)) 
                          and ((EXISTS (
                              select  
                                  49 as c0, 
                                  ref_20.id as c1, 
                                  ref_20.post_id as c2, 
                                  (select comment from test_bd.comments limit 1 offset 5)
                                     as c3, 
                                  ref_20.comment as c4
                                from 
                                  test_bd.comments as ref_20
                                where subq_5.c9 is not NULL)) 
                            and (subq_5.c4 is NULL))) 
                        and ((subq_5.c8 is NULL) 
                          or ((false) 
                            and (subq_5.c1 is not NULL)))) 
                      and ((false) 
                        and (subq_5.c10 is NULL))))) 
                or (subq_1.c0 is NULL)) 
              or ((false) 
                or (EXISTS (
                  select  
                      ref_21.hire_date as c0, 
                      subq_5.c0 as c1, 
                      ref_21.age as c2
                    from 
                      test_bd.employee as ref_21
                    where true
                    limit 92)))) 
            and ((true) 
              or (((false) 
                  and (((((false) 
                          and (false)) 
                        and ((subq_1.c0 is not NULL) 
                          and ((EXISTS (
                              select  
                                  subq_5.c8 as c0, 
                                  ref_22.eid as c1, 
                                  ref_22.eid as c2, 
                                  ref_22.id as c3, 
                                  subq_5.c9 as c4, 
                                  subq_1.c0 as c5, 
                                  1 as c6, 
                                  ref_22.id as c7
                                from 
                                  test_bd.eids as ref_22
                                where true
                                limit 172)) 
                            or (true)))) 
                      or (EXISTS (
                        select  
                            subq_1.c0 as c0, 
                            subq_1.c0 as c1, 
                            subq_5.c6 as c2, 
                            (select user_id from test_bd.user_profiles limit 1 offset 6)
                               as c3, 
                            ref_23.username as c4, 
                            ref_23.comment as c5, 
                            ref_23.username as c6, 
                            (select email from test_bd.employee limit 1 offset 3)
                               as c7, 
                            subq_5.c7 as c8, 
                            subq_1.c0 as c9, 
                            subq_1.c0 as c10, 
                            ref_23.title as c11, 
                            subq_1.c0 as c12
                          from 
                            test_bd.user_post_comments as ref_23
                          where subq_5.c0 is NULL
                          limit 106))) 
                    and (EXISTS (
                      select  
                          (select id from test_bd.eids limit 1 offset 6)
                             as c0
                        from 
                          test_bd.user_post_comments as ref_24,
                          lateral (select  
                                subq_5.c3 as c0, 
                                ref_24.title as c1, 
                                ref_25.id as c2, 
                                (select email from test_bd.users limit 1 offset 6)
                                   as c3, 
                                subq_1.c0 as c4, 
                                subq_5.c0 as c5, 
                                subq_1.c0 as c6, 
                                subq_5.c0 as c7, 
                                59 as c8, 
                                subq_5.c5 as c9, 
                                ref_25.id as c10, 
                                ref_25.created_at as c11, 
                                ref_25.email as c12, 
                                ref_25.id as c13, 
                                ref_25.email as c14
                              from 
                                test_bd.users as ref_25
                              where subq_1.c0 is NULL
                              limit 51) as subq_7
                        where true
                        limit 67)))) 
                and (EXISTS (
                  select  
                      subq_5.c1 as c0, 
                      subq_1.c0 as c1, 
                      ref_26.updated_at as c2, 
                      68 as c3, 
                      subq_5.c5 as c4
                    from 
                      test_bd.posts as ref_26,
                      lateral (select  
                            ref_26.created_at as c0, 
                            ref_26.id as c1, 
                            ref_27.id as c2, 
                            subq_1.c0 as c3, 
                            subq_1.c0 as c4, 
                            ref_26.id as c5, 
                            ref_26.created_at as c6, 
                            ref_27.username as c7, 
                            subq_1.c0 as c8, 
                            ref_27.email as c9, 
                            ref_27.username as c10, 
                            subq_5.c6 as c11, 
                            ref_27.id as c12, 
                            ref_27.id as c13, 
                            subq_5.c2 as c14, 
                            ref_27.username as c15, 
                            subq_5.c8 as c16, 
                            ref_27.username as c17, 
                            ref_26.user_id as c18, 
                            ref_27.email as c19, 
                            ref_26.updated_at as c20, 
                            ref_26.user_id as c21, 
                            44 as c22, 
                            subq_5.c3 as c23, 
                            subq_1.c0 as c24, 
                            subq_1.c0 as c25, 
                            ref_26.updated_at as c26, 
                            ref_27.id as c27, 
                            ref_26.created_at as c28, 
                            ref_27.username as c29, 
                            ref_27.email as c30, 
                            85 as c31, 
                            ref_27.email as c32, 
                            ref_26.updated_at as c33, 
                            ref_27.created_at as c34
                          from 
                            test_bd.users as ref_27
                          where false) as subq_8,
                      lateral (select  
                            ref_28.name as c0
                          from 
                            test_bd.products as ref_28
                          where subq_5.c3 is not NULL) as subq_9
                    where (subq_1.c0 is not NULL) 
                      or (((true) 
                          or (false)) 
                        and (false))
                    limit 70))))) 
          and ((((false) 
                or ((((true) 
                      and ((true) 
                        and (true))) 
                    or (((EXISTS (
                          select  
                              ref_29.id as c0, 
                              ref_29.coordinates as c1, 
                              subq_1.c0 as c2
                            from 
                              test_bd.locations as ref_29
                            where true
                            limit 103)) 
                        or (true)) 
                      and (false))) 
                  or ((73 is NULL) 
                    and ((subq_5.c2 is not NULL) 
                      and (subq_1.c0 is not NULL))))) 
              or ((subq_5.c3 is not NULL) 
                and ((subq_1.c0 is NULL) 
                  or ((true) 
                    and (false))))) 
            or ((subq_1.c0 is NULL) 
              and (subq_5.c5 is not NULL)))) 
        or ((false) 
          and (subq_5.c6 is not NULL))) 
      or (subq_1.c0 is not NULL)) 
    or ((EXISTS (
        select  
            subq_5.c2 as c0, 
            subq_5.c4 as c1, 
            ref_30.name as c2
          from 
            test_bd.locations as ref_30
              left join test_bd.products as ref_31
              on (subq_5.c4 is not NULL)
          where (ref_30.user_id is NULL) 
            or ((false) 
              and (true)))) 
      or (true)))
limit 115;
SHOW profiles;