SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_2.c1 as c0, 
  (select id from test_bd.users limit 1 offset 4)
     as c1
from 
  (select  
        (select category from test_bd.products limit 1 offset 5)
           as c0, 
        ref_7.id as c1, 
        case when true then ref_6.created_at else ref_6.created_at end
           as c2
      from 
        test_bd.user_profiles as ref_0
          left join test_bd.products as ref_1
                left join test_bd.comments as ref_2
                on (EXISTS (
                    select  
                        ref_2.id as c0
                      from 
                        test_bd.products as ref_3
                      where ((false) 
                          and (ref_2.created_at is not NULL)) 
                        or (((ref_1.id is not NULL) 
                            or ((false) 
                              or (ref_1.discount is not NULL))) 
                          or ((true) 
                            and ((true) 
                              or ((false) 
                                or (ref_2.post_id is not NULL)))))
                      limit 102))
              inner join test_bd.user_post_comments as ref_4
              on ((EXISTS (
                    select  
                        ref_1.category as c0, 
                        ref_4.title as c1, 
                        ref_5.created_at as c2, 
                        ref_5.category as c3, 
                        ref_2.post_id as c4
                      from 
                        test_bd.products as ref_5
                      where true
                      limit 119)) 
                  and ((false) 
                    and ((ref_1.id is NULL) 
                      or (true))))
            inner join test_bd.users as ref_6
              left join test_bd.posts as ref_7
                inner join test_bd.users as ref_8
                on (47 is not NULL)
              on (true)
            on (EXISTS (
                select  
                    ref_7.id as c0, 
                    ref_7.content as c1, 
                    ref_9.profile_picture as c2, 
                    ref_9.bio as c3, 
                    ref_4.title as c4, 
                    ref_1.name as c5, 
                    ref_2.created_at as c6, 
                    ref_7.updated_at as c7, 
                    ref_6.username as c8, 
                    (select id from test_bd.posts limit 1 offset 1)
                       as c9, 
                    ref_4.title as c10
                  from 
                    test_bd.user_profiles as ref_9
                  where true
                  limit 116))
          on (ref_0.user_id = ref_8.id ),
        lateral (select  
              ref_8.created_at as c0, 
              ref_7.created_at as c1, 
              ref_10.created_at as c2, 
              ref_8.email as c3, 
              ref_6.created_at as c4, 
              ref_2.id as c5, 
              ref_0.birthdate as c6, 
              ref_7.content as c7, 
              ref_6.email as c8, 
              ref_1.tags as c9, 
              ref_10.id as c10
            from 
              test_bd.posts as ref_10
            where EXISTS (
              select  
                  ref_4.username as c0, 
                  26 as c1, 
                  ref_7.content as c2, 
                  ref_11.id as c3, 
                  ref_6.id as c4, 
                  ref_2.post_id as c5, 
                  ref_4.title as c6, 
                  ref_11.updated_at as c7, 
                  ref_1.price as c8, 
                  ref_6.email as c9, 
                  ref_0.bio as c10, 
                  ref_7.title as c11
                from 
                  test_bd.posts as ref_11
                where EXISTS (
                  select  
                      ref_6.created_at as c0, 
                      ref_6.id as c1, 
                      ref_8.created_at as c2, 
                      ref_6.id as c3, 
                      ref_12.id as c4, 
                      ref_10.title as c5
                    from 
                      test_bd.eids as ref_12
                    where (select id from test_bd.products limit 1 offset 82)
                         is not NULL)
                limit 70)
            limit 49) as subq_0
      where (EXISTS (
          select  
              ref_6.username as c0, 
              ref_13.name as c1, 
              (select user_id from test_bd.posts limit 1 offset 3)
                 as c2
            from 
              test_bd.locations as ref_13
            where false
            limit 90)) 
        or (((((((false) 
                    or (true)) 
                  and (ref_2.user_id is NULL)) 
                or (false)) 
              or (EXISTS (
                select  
                    ref_7.user_id as c0
                  from 
                    test_bd.user_profiles as ref_14
                  where (79 is not NULL) 
                    and ((EXISTS (
                        select  
                            ref_1.price as c0, 
                            ref_6.id as c1, 
                            ref_2.comment as c2, 
                            ref_7.title as c3, 
                            ref_1.name as c4, 
                            ref_7.created_at as c5, 
                            subq_0.c7 as c6, 
                            ref_15.comment as c7, 
                            ref_8.email as c8, 
                            ref_14.birthdate as c9, 
                            ref_14.bio as c10, 
                            ref_0.bio as c11, 
                            ref_15.created_at as c12, 
                            (select id from test_bd.locations limit 1 offset 4)
                               as c13, 
                            ref_14.birthdate as c14, 
                            subq_0.c0 as c15
                          from 
                            test_bd.comments as ref_15
                          where EXISTS (
                            select  
                                subq_0.c3 as c0, 
                                ref_0.birthdate as c1, 
                                ref_1.name as c2, 
                                ref_1.tags as c3, 
                                ref_0.birthdate as c4, 
                                ref_16.name as c5, 
                                ref_7.content as c6
                              from 
                                test_bd.locations as ref_16
                              where false
                              limit 119)
                          limit 146)) 
                      or (((EXISTS (
                            select  
                                ref_2.comment as c0
                              from 
                                test_bd.products as ref_17
                              where false
                              limit 39)) 
                          and (EXISTS (
                            select  
                                ref_18.email as c0
                              from 
                                test_bd.employee as ref_18
                              where false))) 
                        or ((EXISTS (
                            select  
                                subq_0.c8 as c0, 
                                ref_1.price as c1
                              from 
                                test_bd.user_profiles as ref_19
                              where ref_4.comment is NULL
                              limit 174)) 
                          and (true))))))) 
            or (EXISTS (
              select  
                  ref_4.comment as c0, 
                  ref_0.user_id as c1
                from 
                  test_bd.user_post_comments as ref_20
                where ((33 is not NULL) 
                    and (EXISTS (
                      select  
                          ref_2.id as c0, 
                          80 as c1, 
                          ref_2.id as c2, 
                          subq_0.c5 as c3, 
                          ref_20.username as c4
                        from 
                          test_bd.employee as ref_21,
                          lateral (select  
                                (select id from test_bd.locations limit 1 offset 6)
                                   as c0, 
                                ref_2.created_at as c1, 
                                (select created_at from test_bd.users limit 1 offset 6)
                                   as c2, 
                                92 as c3, 
                                ref_7.title as c4
                              from 
                                test_bd.products as ref_22
                              where true
                              limit 127) as subq_1
                        where EXISTS (
                          select  
                              ref_4.comment as c0, 
                              subq_1.c2 as c1, 
                              ref_4.username as c2, 
                              ref_0.birthdate as c3
                            from 
                              test_bd.locations as ref_23
                            where true
                            limit 94)
                        limit 93))) 
                  or (ref_0.user_id is NULL)
                limit 102))) 
          and (false))
      limit 83) as subq_2
where true
limit 160;
SHOW profiles;