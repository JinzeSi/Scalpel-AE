SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_1.c1 as c0, 
  subq_4.c3 as c1, 
  subq_13.c2 as c2, 
  subq_4.c4 as c3, 
  subq_13.c2 as c4, 
  subq_13.c1 as c5, 
  subq_1.c0 as c6, 
  subq_1.c1 as c7, 
  subq_1.c1 as c8, 
  subq_1.c0 as c9, 
  subq_13.c1 as c10, 
  subq_13.c1 as c11, 
  subq_13.c1 as c12, 
  42 as c13, 
  subq_13.c2 as c14
from 
  (select  
        ref_0.comment as c0, 
        ref_1.content as c1
      from 
        test_bd.comments as ref_0
            inner join test_bd.posts as ref_1
            on (ref_0.post_id = ref_1.id )
          inner join test_bd.locations as ref_2
          on ((((EXISTS (
                    select  
                        ref_1.updated_at as c0, 
                        (select tags from test_bd.products limit 1 offset 1)
                           as c1, 
                        ref_1.updated_at as c2, 
                        ref_1.user_id as c3, 
                        ref_3.email as c4, 
                        ref_0.created_at as c5, 
                        (select user_id from test_bd.user_profiles limit 1 offset 1)
                           as c6, 
                        ref_0.id as c7, 
                        subq_0.c0 as c8, 
                        ref_3.id as c9, 
                        ref_3.created_at as c10, 
                        (select eid from test_bd.eids limit 1 offset 3)
                           as c11, 
                        (select virtual_col from test_bd.eids limit 1 offset 5)
                           as c12, 
                        ref_2.name as c13
                      from 
                        test_bd.users as ref_3,
                        lateral (select  
                              ref_2.id as c0
                            from 
                              test_bd.locations as ref_4
                            where true
                            limit 70) as subq_0
                      where ((false) 
                          and (((false) 
                              or (false)) 
                            or (subq_0.c0 is not NULL))) 
                        or (ref_2.name is NULL)
                      limit 36)) 
                  and ((EXISTS (
                      select  
                          ref_2.name as c0
                        from 
                          test_bd.posts as ref_5
                        where (14 is NULL) 
                          or (ref_1.content is not NULL))) 
                    or (false))) 
                or ((true) 
                  and (EXISTS (
                    select  
                        ref_2.user_id as c0, 
                        ref_1.user_id as c1, 
                        ref_1.updated_at as c2, 
                        ref_1.updated_at as c3, 
                        ref_1.created_at as c4, 
                        (select id from test_bd.users limit 1 offset 47)
                           as c5, 
                        ref_1.title as c6, 
                        ref_0.comment as c7, 
                        61 as c8, 
                        ref_6.virtual_col as c9, 
                        ref_2.id as c10, 
                        (select title from test_bd.user_post_comments limit 1 offset 40)
                           as c11, 
                        ref_1.created_at as c12
                      from 
                        test_bd.eids as ref_6
                      where ref_6.eid is not NULL)))) 
              and (EXISTS (
                select  
                    ref_0.post_id as c0, 
                    ref_2.id as c1
                  from 
                    test_bd.posts as ref_7
                  where ((true) 
                      or ((EXISTS (
                          select  
                              ref_0.user_id as c0, 
                              ref_0.created_at as c1, 
                              ref_7.updated_at as c2, 
                              ref_8.content as c3, 
                              ref_0.post_id as c4
                            from 
                              test_bd.posts as ref_8
                            where ref_0.post_id is not NULL)) 
                        or (ref_7.created_at is NULL))) 
                    or (((true) 
                        or (ref_0.post_id is NULL)) 
                      or (true))
                  limit 176)))
      where ref_0.created_at is NULL
      limit 73) as subq_1,
  lateral (select  
        subq_3.c0 as c0, 
        subq_1.c1 as c1, 
        subq_3.c0 as c2, 
        subq_1.c0 as c3, 
        coalesce(subq_3.c1,
          subq_3.c1) as c4
      from 
        (select  
              ref_9.id as c0, 
              subq_2.c2 as c1
            from 
              test_bd.comments as ref_9,
              lateral (select  
                    43 as c0, 
                    ref_9.id as c1, 
                    subq_1.c0 as c2, 
                    ref_10.email as c3
                  from 
                    test_bd.users as ref_10
                  where (ref_10.created_at is NULL) 
                    or (subq_1.c0 is NULL)
                  limit 123) as subq_2
            where EXISTS (
              select  
                  ref_9.user_id as c0, 
                  subq_2.c3 as c1, 
                  ref_9.comment as c2, 
                  subq_1.c1 as c3, 
                  ref_11.bio as c4, 
                  subq_2.c3 as c5, 
                  55 as c6, 
                  ref_11.birthdate as c7, 
                  ref_11.birthdate as c8
                from 
                  test_bd.user_profiles as ref_11
                where (subq_1.c0 is not NULL) 
                  and (true)
                limit 165)) as subq_3
      where (subq_1.c1 is not NULL) 
        or (((subq_1.c1 is not NULL) 
            or ((select id from test_bd.eids limit 1 offset 31)
                 is NULL)) 
          and (true))
      limit 59) as subq_4,
  lateral (select  
        8 as c0, 
        subq_1.c0 as c1, 
        subq_4.c4 as c2
      from 
        test_bd.eids as ref_12
            inner join test_bd.locations as ref_13
            on (ref_12.virtual_col = ref_13.id )
          inner join test_bd.comments as ref_14
          on (subq_1.c0 is not NULL)
      where ((ref_12.eid is NULL) 
          or ((true) 
            or (ref_13.id is not NULL))) 
        or (((((EXISTS (
                  select  
                      89 as c0
                    from 
                      test_bd.locations as ref_15
                    where (true) 
                      and (ref_15.id is not NULL))) 
                or (subq_1.c1 is NULL)) 
              or (EXISTS (
                select  
                    ref_13.id as c0, 
                    ref_14.comment as c1, 
                    ref_13.coordinates as c2, 
                    subq_1.c0 as c3, 
                    ref_13.name as c4, 
                    subq_1.c1 as c5, 
                    subq_1.c1 as c6, 
                    ref_14.comment as c7
                  from 
                    test_bd.posts as ref_16
                  where ((((true) 
                          or (false)) 
                        or (subq_1.c0 is not NULL)) 
                      or (EXISTS (
                        select  
                            ref_12.virtual_col as c0, 
                            21 as c1, 
                            ref_12.id as c2
                          from 
                            test_bd.locations as ref_17
                          where ref_16.content is not NULL
                          limit 152))) 
                    or (EXISTS (
                      select distinct 
                          ref_14.created_at as c0, 
                          subq_4.c2 as c1, 
                          ref_13.user_id as c2, 
                          ref_13.coordinates as c3, 
                          subq_1.c1 as c4
                        from 
                          test_bd.user_profiles as ref_18
                        where false))
                  limit 50))) 
            and ((EXISTS (
                select  
                    subq_8.c1 as c0
                  from 
                    test_bd.posts as ref_19,
                    lateral (select  
                          ref_14.comment as c0, 
                          ref_20.age as c1, 
                          (select eid from test_bd.eids limit 1 offset 6)
                             as c2
                        from 
                          test_bd.employee as ref_20,
                          lateral (select  
                                subq_1.c0 as c0, 
                                subq_1.c1 as c1, 
                                ref_12.eid as c2, 
                                ref_19.content as c3, 
                                subq_4.c2 as c4, 
                                subq_5.c2 as c5, 
                                ref_21.user_id as c6, 
                                subq_4.c0 as c7, 
                                ref_20.salary as c8, 
                                subq_5.c1 as c9, 
                                ref_20.years as c10, 
                                subq_1.c1 as c11, 
                                ref_14.id as c12, 
                                ref_12.eid as c13
                              from 
                                test_bd.posts as ref_21,
                                lateral (select  
                                      ref_14.created_at as c0, 
                                      ref_14.comment as c1, 
                                      ref_14.id as c2
                                    from 
                                      test_bd.users as ref_22
                                    where false) as subq_5,
                                lateral (select  
                                      ref_12.eid as c0, 
                                      ref_21.created_at as c1, 
                                      ref_13.coordinates as c2
                                    from 
                                      test_bd.products as ref_23
                                    where ((subq_5.c0 is NULL) 
                                        and (true)) 
                                      and (false)
                                    limit 78) as subq_6
                              where (subq_4.c2 is NULL) 
                                and ((false) 
                                  and ((false) 
                                    or (false)))
                              limit 58) as subq_7
                        where true
                        limit 77) as subq_8
                  where subq_1.c0 is NULL
                  limit 75)) 
              or (EXISTS (
                select  
                    ref_24.user_id as c0, 
                    96 as c1, 
                    subq_11.c1 as c2, 
                    subq_1.c0 as c3, 
                    ref_13.user_id as c4, 
                    ref_12.eid as c5, 
                    ref_24.id as c6, 
                    ref_13.user_id as c7, 
                    subq_10.c0 as c8, 
                    ref_13.name as c9, 
                    subq_11.c1 as c10
                  from 
                    test_bd.posts as ref_24,
                    lateral (select  
                          ref_13.name as c0
                        from 
                          test_bd.eids as ref_25,
                          lateral (select  
                                ref_14.post_id as c0, 
                                ref_25.eid as c1, 
                                ref_14.created_at as c2, 
                                subq_1.c1 as c3, 
                                (select title from test_bd.user_post_comments limit 1 offset 4)
                                   as c4, 
                                ref_25.id as c5, 
                                subq_1.c0 as c6, 
                                ref_14.post_id as c7, 
                                ref_26.id as c8, 
                                ref_24.content as c9, 
                                subq_1.c0 as c10, 
                                ref_24.id as c11, 
                                ref_13.coordinates as c12
                              from 
                                test_bd.posts as ref_26
                              where 48 is not NULL) as subq_9
                        where false
                        limit 107) as subq_10,
                    lateral (select  
                          ref_24.id as c0, 
                          ref_12.virtual_col as c1, 
                          8 as c2, 
                          subq_1.c1 as c3
                        from 
                          test_bd.posts as ref_27
                        where false) as subq_11
                  where ref_24.title is NULL
                  limit 96)))) 
          and (EXISTS (
            select  
                ref_13.name as c0, 
                subq_1.c0 as c1, 
                subq_1.c0 as c2
              from 
                test_bd.users as ref_28
              where ((EXISTS (
                    select  
                        ref_28.username as c0, 
                        ref_29.updated_at as c1, 
                        ref_12.eid as c2
                      from 
                        test_bd.posts as ref_29
                      where EXISTS (
                        select  
                            ref_30.username as c0, 
                            ref_29.content as c1, 
                            (select id from test_bd.eids limit 1 offset 6)
                               as c2, 
                            ref_14.post_id as c3, 
                            ref_29.created_at as c4, 
                            subq_4.c2 as c5
                          from 
                            test_bd.user_post_comments as ref_30
                          where false
                          limit 116)
                      limit 183)) 
                  or (subq_4.c3 is NULL)) 
                and (((true) 
                    or (ref_12.id is not NULL)) 
                  or ((EXISTS (
                      select  
                          ref_14.user_id as c0, 
                          subq_1.c0 as c1, 
                          ref_12.id as c2, 
                          84 as c3, 
                          ref_28.email as c4, 
                          subq_12.c2 as c5
                        from 
                          test_bd.products as ref_31,
                          lateral (select  
                                ref_13.user_id as c0, 
                                ref_14.user_id as c1, 
                                (select birthdate from test_bd.user_profiles limit 1 offset 80)
                                   as c2, 
                                ref_14.comment as c3, 
                                (select id from test_bd.locations limit 1 offset 1)
                                   as c4, 
                                ref_28.email as c5, 
                                subq_1.c1 as c6, 
                                subq_4.c4 as c7, 
                                subq_1.c0 as c8
                              from 
                                test_bd.employee as ref_32
                              where true
                              limit 136) as subq_12
                        where ((ref_28.created_at is not NULL) 
                            or (false)) 
                          and ((select comment from test_bd.user_post_comments limit 1 offset 4)
                               is not NULL))) 
                    or (((true) 
                        or (((false) 
                            or (ref_14.comment is not NULL)) 
                          or (subq_1.c1 is NULL))) 
                      or (((true) 
                          or (EXISTS (
                            select  
                                ref_12.id as c0, 
                                subq_4.c3 as c1, 
                                subq_1.c1 as c2, 
                                ref_33.name as c3
                              from 
                                test_bd.products as ref_33
                              where true
                              limit 78))) 
                        or (((true) 
                            or (false)) 
                          or (false))))))
              limit 98)))
      limit 62) as subq_13
where (EXISTS (
    select  
        coalesce((select id from test_bd.employee limit 1 offset 4)
            ,
          subq_13.c0) as c0, 
        subq_4.c3 as c1, 
        subq_1.c1 as c2
      from 
        test_bd.products as ref_34
      where ((((subq_1.c1 is NULL) 
              or (true)) 
            or (subq_13.c2 is not NULL)) 
          or (true)) 
        or (false))) 
  and (true)
limit 48;
SHOW profiles;