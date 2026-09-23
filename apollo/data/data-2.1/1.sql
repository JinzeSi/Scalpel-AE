SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.title as c0, 
  ref_0.comment as c1
from 
  test_bd.user_post_comments as ref_0
where ((((select coordinates from test_bd.locations limit 1 offset 3)
           is not NULL) 
      and (EXISTS (
        select  
            ref_0.comment as c0, 
            ref_1.created_at as c1, 
            ref_1.id as c2, 
            ref_1.created_at as c3, 
            ref_1.created_at as c4, 
            ref_0.username as c5, 
            ref_1.email as c6, 
            ref_0.comment as c7, 
            ref_1.created_at as c8, 
            ref_0.title as c9, 
            ref_0.username as c10, 
            ref_1.created_at as c11
          from 
            test_bd.users as ref_1
          where ref_0.username is NULL))) 
    or ((ref_0.username is NULL) 
      and (EXISTS (
        select  
            ref_2.category as c0
          from 
            test_bd.products as ref_2
          where ref_2.id is NULL)))) 
  or ((EXISTS (
      select  
          (select user_id from test_bd.comments limit 1 offset 57)
             as c0, 
          ref_3.eid as c1, 
          ref_3.virtual_col as c2, 
          ref_7.user_id as c3, 
          ref_7.created_at as c4, 
          ref_7.content as c5, 
          ref_0.username as c6, 
          ref_3.virtual_col as c7, 
          (select bio from test_bd.user_profiles limit 1 offset 2)
             as c8, 
          subq_1.c0 as c9, 
          22 as c10
        from 
          test_bd.eids as ref_3
                right join test_bd.posts as ref_4
                on ((((true) 
                        and (false)) 
                      and (false)) 
                    or (EXISTS (
                      select  
                          ref_0.title as c0, 
                          ref_5.id as c1, 
                          ref_5.id as c2, 
                          83 as c3, 
                          ref_0.username as c4, 
                          ref_0.comment as c5
                        from 
                          test_bd.users as ref_5
                        where EXISTS (
                          select  
                              ref_0.comment as c0, 
                              ref_3.virtual_col as c1
                            from 
                              test_bd.products as ref_6
                            where ref_6.discount is not NULL
                            limit 91)
                        limit 57)))
              inner join test_bd.posts as ref_7
                right join test_bd.user_profiles as ref_8
                on ((EXISTS (
                      select  
                          ref_9.user_id as c0, 
                          ref_9.coordinates as c1, 
                          ref_8.birthdate as c2, 
                          ref_9.id as c3, 
                          ref_0.title as c4, 
                          ref_0.username as c5
                        from 
                          test_bd.locations as ref_9
                        where (83 is NULL) 
                          or (true)
                        limit 78)) 
                    or ((false) 
                      and (((true) 
                          or (true)) 
                        and ((ref_8.bio is not NULL) 
                          or (100 is not NULL)))))
              on (ref_3.id = ref_7.id )
            inner join test_bd.posts as ref_10
            on (EXISTS (
                select  
                    ref_7.id as c0, 
                    ref_10.user_id as c1
                  from 
                    test_bd.posts as ref_11,
                    lateral (select  
                          20 as c0
                        from 
                          test_bd.user_post_comments as ref_12
                        where ((ref_10.content is not NULL) 
                            or (true)) 
                          and (ref_10.content is NULL)) as subq_0
                  where ref_8.user_id is NULL)),
          lateral (select  
                ref_3.eid as c0
              from 
                test_bd.eids as ref_13
              where true
              limit 32) as subq_1
        where EXISTS (
          select  
              (select id from test_bd.locations limit 1 offset 3)
                 as c0, 
              ref_3.virtual_col as c1, 
              ref_7.id as c2, 
              ref_10.created_at as c3, 
              ref_0.username as c4, 
              ref_14.id as c5, 
              ref_3.eid as c6, 
              ref_4.id as c7, 
              ref_14.id as c8, 
              ref_15.user_id as c9, 
              ref_4.id as c10, 
              ref_7.id as c11, 
              ref_4.id as c12, 
              (select username from test_bd.user_post_comments limit 1 offset 4)
                 as c13, 
              ref_14.id as c14, 
              ref_0.comment as c15
            from 
              test_bd.eids as ref_14
                inner join test_bd.posts as ref_15
                on (ref_14.id is NULL)
            where (EXISTS (
                select  
                    ref_10.user_id as c0, 
                    ref_3.eid as c1, 
                    ref_15.created_at as c2, 
                    ref_8.bio as c3, 
                    ref_14.id as c4, 
                    50 as c5, 
                    ref_0.title as c6, 
                    ref_8.profile_picture as c7, 
                    ref_0.comment as c8
                  from 
                    test_bd.user_post_comments as ref_16
                  where (((ref_0.username is NULL) 
                        or ((false) 
                          and (ref_3.id is NULL))) 
                      and ((true) 
                        and (false))) 
                    or (((select virtual_col from test_bd.eids limit 1 offset 23)
                           is NULL) 
                      or (EXISTS (
                        select  
                            ref_10.title as c0, 
                            ref_4.created_at as c1, 
                            48 as c2, 
                            ref_15.created_at as c3, 
                            99 as c4, 
                            42 as c5, 
                            (select created_at from test_bd.users limit 1 offset 5)
                               as c6, 
                            ref_3.eid as c7, 
                            ref_3.eid as c8, 
                            ref_0.comment as c9, 
                            60 as c10, 
                            ref_3.virtual_col as c11, 
                            ref_17.comment as c12, 
                            ref_0.title as c13, 
                            ref_8.user_id as c14, 
                            ref_16.comment as c15, 
                            ref_14.id as c16, 
                            ref_14.eid as c17
                          from 
                            test_bd.user_post_comments as ref_17
                          where ((((ref_8.user_id is not NULL) 
                                  or (ref_10.updated_at is not NULL)) 
                                or (false)) 
                              or (ref_8.user_id is NULL)) 
                            and (((false) 
                                or ((ref_3.virtual_col is not NULL) 
                                  or (false))) 
                              and ((EXISTS (
                                  select  
                                      ref_15.id as c0, 
                                      ref_0.comment as c1, 
                                      ref_7.created_at as c2
                                    from 
                                      test_bd.posts as ref_18
                                    where ref_8.bio is NULL
                                    limit 125)) 
                                and ((ref_7.updated_at is not NULL) 
                                  or (false))))))))) 
              and ((ref_0.username is NULL) 
                or (ref_4.title is NULL)))
        limit 124)) 
    or (((ref_0.username is not NULL) 
        and (EXISTS (
          select  
              ref_0.title as c0, 
              ref_0.title as c1, 
              ref_19.user_id as c2, 
              ref_0.username as c3, 
              ref_0.title as c4, 
              ref_19.birthdate as c5, 
              ref_0.title as c6, 
              ref_0.username as c7, 
              ref_0.title as c8, 
              ref_0.title as c9
            from 
              test_bd.user_profiles as ref_19
            where false))) 
      or (false)));
SHOW profiles;