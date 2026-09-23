SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_8.c0 as c0, 
  case when coalesce(subq_8.c0,
        subq_8.c0) is not NULL then subq_3.c11 else subq_3.c11 end
     as c1, 
  subq_3.c13 as c2, 
  coalesce(coalesce(subq_3.c6,
      coalesce(subq_3.c13,
        subq_3.c0)),
    subq_3.c6) as c3, 
  subq_3.c15 as c4, 
  subq_3.c2 as c5
from 
  (select  
        ref_1.title as c0, 
        ref_0.virtual_col as c1, 
        ref_0.eid as c2, 
        ref_0.id as c3, 
        case when ((((EXISTS (
                    select  
                        ref_0.eid as c0, 
                        subq_0.c0 as c1, 
                        ref_2.username as c2, 
                        subq_0.c22 as c3
                      from 
                        test_bd.user_post_comments as ref_2,
                        lateral (select  
                              ref_3.id as c0, 
                              ref_1.title as c1, 
                              ref_3.user_id as c2, 
                              ref_0.id as c3, 
                              ref_3.user_id as c4, 
                              ref_0.eid as c5, 
                              ref_3.name as c6, 
                              ref_1.username as c7, 
                              ref_2.title as c8, 
                              ref_3.coordinates as c9, 
                              ref_3.name as c10, 
                              ref_1.title as c11, 
                              62 as c12, 
                              ref_2.title as c13, 
                              ref_2.title as c14, 
                              ref_1.title as c15, 
                              ref_2.title as c16, 
                              ref_2.username as c17, 
                              ref_0.id as c18, 
                              ref_2.title as c19, 
                              ref_1.comment as c20, 
                              ref_3.id as c21, 
                              ref_3.coordinates as c22, 
                              ref_0.id as c23, 
                              ref_0.id as c24, 
                              62 as c25, 
                              ref_1.username as c26, 
                              ref_0.virtual_col as c27, 
                              ref_1.comment as c28, 
                              ref_2.title as c29, 
                              ref_2.comment as c30, 
                              ref_0.id as c31, 
                              ref_3.coordinates as c32, 
                              ref_0.virtual_col as c33
                            from 
                              test_bd.locations as ref_3
                            where ref_3.name is not NULL
                            limit 164) as subq_0
                      where true)) 
                  and ((ref_1.comment is NULL) 
                    or (ref_1.comment is NULL))) 
                and (EXISTS (
                  select  
                      ref_0.eid as c0
                    from 
                      test_bd.user_profiles as ref_4
                    where false
                    limit 130))) 
              or (EXISTS (
                select  
                    subq_2.c0 as c0, 
                    (select username from test_bd.user_post_comments limit 1 offset 1)
                       as c1
                  from 
                    test_bd.users as ref_5,
                    lateral (select  
                          ref_1.comment as c0, 
                          ref_1.comment as c1
                        from 
                          test_bd.user_post_comments as ref_6
                        where true
                        limit 82) as subq_1,
                    lateral (select  
                          subq_1.c1 as c0, 
                          ref_1.username as c1, 
                          17 as c2, 
                          ref_1.username as c3, 
                          ref_7.created_at as c4, 
                          ref_7.discount as c5
                        from 
                          test_bd.products as ref_7
                        where true
                        limit 180) as subq_2
                  where ref_1.username is not NULL
                  limit 81))) 
            or (((ref_0.eid is not NULL) 
                and ((ref_1.comment is NULL) 
                  and (((false) 
                      and (false)) 
                    and ((false) 
                      and (true))))) 
              and (true)) then ref_1.title else ref_1.title end
           as c4, 
        ref_0.virtual_col as c5, 
        ref_1.title as c6, 
        ref_1.comment as c7, 
        ref_0.virtual_col as c8, 
        ref_1.title as c9, 
        ref_0.eid as c10, 
        ref_0.virtual_col as c11, 
        ref_0.id as c12, 
        ref_1.title as c13, 
        ref_0.eid as c14, 
        16 as c15, 
        ref_0.virtual_col as c16
      from 
        test_bd.eids as ref_0
          right join test_bd.user_post_comments as ref_1
          on (ref_1.username is NULL)
      where coalesce(ref_0.id,
          ref_0.virtual_col) is NULL) as subq_3,
  lateral (select  
        subq_3.c7 as c0
      from 
        test_bd.locations as ref_8,
        lateral (select  
              ref_9.created_at as c0, 
              subq_3.c0 as c1, 
              subq_3.c6 as c2, 
              subq_3.c8 as c3, 
              subq_3.c3 as c4, 
              subq_3.c14 as c5
            from 
              test_bd.users as ref_9
            where (((((ref_9.username is not NULL) 
                      or (subq_3.c5 is not NULL)) 
                    or (EXISTS (
                      select  
                          ref_8.coordinates as c0
                        from 
                          test_bd.employee as ref_10,
                          lateral (select  
                                subq_3.c5 as c0
                              from 
                                test_bd.eids as ref_11
                              where false) as subq_4
                        where ((EXISTS (
                              select  
                                  subq_4.c0 as c0, 
                                  subq_4.c0 as c1, 
                                  ref_9.id as c2, 
                                  subq_4.c0 as c3, 
                                  ref_9.id as c4, 
                                  ref_9.id as c5, 
                                  (select created_at from test_bd.comments limit 1 offset 2)
                                     as c6, 
                                  ref_10.age as c7, 
                                  ref_9.created_at as c8, 
                                  ref_12.name as c9, 
                                  subq_4.c0 as c10, 
                                  ref_12.user_id as c11, 
                                  ref_8.name as c12, 
                                  subq_4.c0 as c13, 
                                  subq_4.c0 as c14
                                from 
                                  test_bd.locations as ref_12,
                                  lateral (select  
                                        subq_4.c0 as c0, 
                                        ref_12.user_id as c1, 
                                        ref_9.id as c2
                                      from 
                                        test_bd.eids as ref_13
                                      where subq_3.c11 is NULL) as subq_5
                                where false
                                limit 143)) 
                            or (((EXISTS (
                                  select  
                                      ref_14.updated_at as c0, 
                                      ref_14.content as c1, 
                                      ref_8.user_id as c2, 
                                      ref_10.eid as c3, 
                                      subq_4.c0 as c4, 
                                      ref_14.updated_at as c5, 
                                      ref_10.department_id as c6, 
                                      subq_4.c0 as c7
                                    from 
                                      test_bd.posts as ref_14,
                                      lateral (select  
                                            subq_3.c3 as c0, 
                                            ref_10.years as c1, 
                                            ref_8.name as c2, 
                                            (select salary from test_bd.employee limit 1 offset 6)
                                               as c3, 
                                            ref_10.id as c4, 
                                            ref_10.email as c5, 
                                            (select id from test_bd.users limit 1 offset 6)
                                               as c6, 
                                            ref_8.name as c7
                                          from 
                                            test_bd.products as ref_15
                                          where subq_3.c1 is NULL
                                          limit 64) as subq_6
                                    where (true) 
                                      or (true)
                                    limit 38)) 
                                and (false)) 
                              and (false))) 
                          and (((select profile_picture from test_bd.user_profiles limit 1 offset 5)
                                 is not NULL) 
                            or (true))
                        limit 59))) 
                  and (true)) 
                and ((select user_id from test_bd.user_profiles limit 1 offset 1)
                     is not NULL)) 
              or (false)
            limit 171) as subq_7
      where (((true) 
            and (((EXISTS (
                  select  
                      (select user_id from test_bd.user_profiles limit 1 offset 4)
                         as c0
                    from 
                      test_bd.locations as ref_16
                    where true
                    limit 131)) 
                or (((EXISTS (
                      select  
                          ref_8.name as c0, 
                          ref_17.created_at as c1, 
                          subq_3.c5 as c2, 
                          subq_7.c4 as c3, 
                          ref_17.id as c4, 
                          ref_17.price as c5, 
                          subq_7.c5 as c6, 
                          ref_17.name as c7, 
                          ref_8.id as c8, 
                          ref_8.name as c9, 
                          subq_3.c4 as c10, 
                          ref_8.id as c11, 
                          subq_3.c2 as c12, 
                          subq_7.c2 as c13, 
                          subq_3.c15 as c14, 
                          ref_8.user_id as c15, 
                          subq_7.c5 as c16, 
                          ref_8.id as c17, 
                          ref_8.name as c18, 
                          87 as c19
                        from 
                          test_bd.products as ref_17
                        where (true) 
                          and (((ref_8.coordinates is not NULL) 
                              or (true)) 
                            or (false))
                        limit 102)) 
                    or ((((subq_3.c3 is not NULL) 
                          and (false)) 
                        and ((true) 
                          or (false))) 
                      and ((subq_3.c10 is NULL) 
                        and (false)))) 
                  or ((((ref_8.user_id is not NULL) 
                        and (true)) 
                      and (true)) 
                    and ((((ref_8.id is not NULL) 
                          and (true)) 
                        and ((ref_8.user_id is not NULL) 
                          and (((false) 
                              and (subq_7.c5 is not NULL)) 
                            or ((false) 
                              and (((false) 
                                  or (true)) 
                                or (subq_3.c9 is NULL)))))) 
                      and (ref_8.id is not NULL))))) 
              and (false))) 
          and ((ref_8.id is NULL) 
            or (true))) 
        and (((true) 
            or ((subq_7.c2 is NULL) 
              and (false))) 
          or (((EXISTS (
                select  
                    (select content from test_bd.posts limit 1 offset 2)
                       as c0, 
                    subq_7.c2 as c1, 
                    ref_18.username as c2, 
                    7 as c3, 
                    ref_18.username as c4, 
                    subq_7.c1 as c5
                  from 
                    test_bd.user_post_comments as ref_18
                  where subq_7.c2 is not NULL)) 
              or (false)) 
            and (subq_7.c1 is not NULL)))
      limit 137) as subq_8
where subq_8.c0 is not NULL
limit 154;
SHOW profiles;