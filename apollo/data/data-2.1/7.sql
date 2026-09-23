SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.user_id as c0, 
  (select coordinates from test_bd.locations limit 1 offset 1)
     as c1
from 
  test_bd.user_profiles as ref_0
where (EXISTS (
    select  
        subq_0.c1 as c0, 
        ref_1.years as c1, 
        ref_2.id as c2, 
        ref_1.salary as c3
      from 
        test_bd.employee as ref_1
            inner join test_bd.comments as ref_2
            on (((false) 
                  and (ref_0.user_id is not NULL)) 
                or (22 is not NULL))
          right join (select  
                ref_3.bio as c0, 
                ref_3.user_id as c1, 
                ref_0.birthdate as c2, 
                ref_0.birthdate as c3, 
                ref_3.profile_picture as c4
              from 
                test_bd.user_profiles as ref_3
              where false
              limit 132) as subq_0
          on (false)
      where (true) 
        and ((false) 
          and (false))
      limit 95)) 
  or (((ref_0.user_id is not NULL) 
      or (EXISTS (
        select  
            ref_4.comment as c0, 
            ref_4.post_id as c1, 
            ref_4.comment as c2, 
            ref_4.post_id as c3, 
            ref_4.id as c4, 
            ref_4.comment as c5, 
            ref_0.user_id as c6, 
            ref_4.created_at as c7, 
            ref_0.birthdate as c8, 
            ref_4.id as c9, 
            ref_0.bio as c10, 
            ref_0.birthdate as c11, 
            ref_0.profile_picture as c12, 
            ref_4.created_at as c13, 
            ref_4.comment as c14, 
            ref_0.user_id as c15, 
            ref_4.created_at as c16, 
            98 as c17, 
            ref_4.comment as c18, 
            ref_0.profile_picture as c19, 
            ref_0.user_id as c20, 
            ref_0.profile_picture as c21, 
            ref_0.bio as c22, 
            ref_0.profile_picture as c23, 
            ref_0.birthdate as c24, 
            (select post_id from test_bd.comments limit 1 offset 1)
               as c25, 
            ref_0.bio as c26
          from 
            test_bd.comments as ref_4
          where (ref_4.post_id is NULL) 
            and ((ref_0.birthdate is NULL) 
              or ((((((true) 
                        and ((false) 
                          and (((false) 
                              and (ref_0.bio is not NULL)) 
                            or (EXISTS (
                              select  
                                  ref_5.coordinates as c0, 
                                  ref_5.coordinates as c1
                                from 
                                  test_bd.locations as ref_5
                                where (true) 
                                  or ((EXISTS (
                                      select  
                                          ref_5.coordinates as c0, 
                                          (select user_id from test_bd.comments limit 1 offset 1)
                                             as c1, 
                                          ref_4.comment as c2, 
                                          ref_0.user_id as c3, 
                                          ref_4.comment as c4, 
                                          subq_2.c2 as c5, 
                                          ref_6.name as c6, 
                                          subq_1.c0 as c7
                                        from 
                                          test_bd.locations as ref_6,
                                          lateral (select  
                                                ref_6.user_id as c0, 
                                                ref_5.user_id as c1, 
                                                ref_4.post_id as c2, 
                                                ref_6.user_id as c3
                                              from 
                                                test_bd.locations as ref_7
                                              where (true) 
                                                and (EXISTS (
                                                  select  
                                                      ref_7.coordinates as c0
                                                    from 
                                                      test_bd.posts as ref_8
                                                    where true
                                                    limit 26))
                                              limit 70) as subq_1,
                                          lateral (select  
                                                subq_1.c0 as c0, 
                                                ref_0.profile_picture as c1, 
                                                ref_4.comment as c2, 
                                                15 as c3, 
                                                ref_4.user_id as c4, 
                                                ref_5.user_id as c5, 
                                                ref_5.user_id as c6
                                              from 
                                                test_bd.user_profiles as ref_9
                                              where false) as subq_2
                                        where (false) 
                                          and (false)
                                        limit 82)) 
                                    or (ref_4.created_at is not NULL))
                                limit 101))))) 
                      and (EXISTS (
                        select  
                            ref_0.bio as c0, 
                            ref_0.birthdate as c1, 
                            ref_10.username as c2, 
                            ref_0.user_id as c3, 
                            ref_4.post_id as c4, 
                            ref_0.user_id as c5
                          from 
                            test_bd.users as ref_10
                          where true))) 
                    or (EXISTS (
                      select  
                          ref_11.comment as c0, 
                          ref_4.id as c1, 
                          ref_11.username as c2, 
                          ref_0.bio as c3, 
                          ref_4.user_id as c4, 
                          ref_0.user_id as c5, 
                          ref_11.title as c6, 
                          55 as c7
                        from 
                          test_bd.user_post_comments as ref_11
                        where ref_0.profile_picture is not NULL
                        limit 140))) 
                  or (((ref_4.comment is not NULL) 
                      or (false)) 
                    and ((select updated_at from test_bd.posts limit 1 offset 60)
                         is not NULL))) 
                and (((true) 
                    or ((true) 
                      or (true))) 
                  and (true))))))) 
    and ((ref_0.profile_picture is NULL) 
      or ((true) 
        and ((true) 
          and (EXISTS (
            select  
                subq_3.c6 as c0, 
                ref_0.profile_picture as c1
              from 
                test_bd.eids as ref_12,
                lateral (select  
                      ref_0.birthdate as c0, 
                      ref_0.bio as c1, 
                      ref_12.eid as c2, 
                      (select user_id from test_bd.comments limit 1 offset 85)
                         as c3, 
                      ref_13.id as c4, 
                      ref_13.virtual_col as c5, 
                      ref_0.profile_picture as c6
                    from 
                      test_bd.eids as ref_13
                    where true) as subq_3
              where ref_0.bio is NULL))))))
limit 55;
SHOW profiles;