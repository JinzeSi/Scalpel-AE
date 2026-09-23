SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_5.c1 as c0, 
  subq_5.c2 as c1, 
  subq_5.c2 as c2, 
  subq_5.c1 as c3
from 
  (select  
        ref_0.price as c0, 
        ref_1.created_at as c1, 
        ref_0.id as c2
      from 
        test_bd.products as ref_0
          inner join test_bd.comments as ref_1
          on (ref_0.created_at = ref_1.created_at )
      where EXISTS (
        select  
            ref_2.id as c0, 
            ref_3.title as c1, 
            ref_3.title as c2, 
            ref_3.comment as c3
          from 
            test_bd.products as ref_2
                inner join test_bd.user_post_comments as ref_3
                on (ref_2.name = ref_3.title )
              left join test_bd.eids as ref_4
              on (false)
          where EXISTS (
            select  
                ref_0.category as c0, 
                ref_3.title as c1, 
                ref_1.comment as c2, 
                ref_0.discount as c3, 
                ref_0.discount as c4, 
                ref_2.created_at as c5, 
                (select email from test_bd.employee limit 1 offset 2)
                   as c6, 
                ref_4.eid as c7, 
                ref_1.user_id as c8, 
                ref_2.created_at as c9
              from 
                test_bd.user_profiles as ref_5
              where ((((ref_1.post_id is NULL) 
                      and (((false) 
                          or (false)) 
                        or ((((ref_2.id is not NULL) 
                              or (true)) 
                            and (true)) 
                          and ((ref_1.user_id is not NULL) 
                            or (ref_1.id is not NULL))))) 
                    and ((((ref_4.virtual_col is NULL) 
                          or (ref_4.eid is NULL)) 
                        or ((ref_5.user_id is NULL) 
                          or (ref_4.id is not NULL))) 
                      and (((true) 
                          and (((ref_3.username is NULL) 
                              and ((ref_5.profile_picture is not NULL) 
                                or ((ref_4.id is not NULL) 
                                  or (((true) 
                                      and (((true) 
                                          and (EXISTS (
                                            select  
                                                ref_3.title as c0, 
                                                ref_0.discount as c1, 
                                                ref_1.post_id as c2
                                              from 
                                                test_bd.user_profiles as ref_6
                                              where EXISTS (
                                                select  
                                                    1 as c0, 
                                                    ref_1.post_id as c1, 
                                                    ref_0.price as c2, 
                                                    (select birthdate from test_bd.user_profiles limit 1 offset 6)
                                                       as c3
                                                  from 
                                                    test_bd.products as ref_7
                                                  where (true) 
                                                    or (EXISTS (
                                                      select  
                                                          (select updated_at from test_bd.posts limit 1 offset 5)
                                                             as c0, 
                                                          ref_5.user_id as c1, 
                                                          ref_7.tags as c2, 
                                                          ref_1.user_id as c3, 
                                                          ref_5.profile_picture as c4, 
                                                          ref_8.virtual_col as c5
                                                        from 
                                                          test_bd.eids as ref_8
                                                        where true
                                                        limit 99))
                                                  limit 72)
                                              limit 61))) 
                                        or (true))) 
                                    or (EXISTS (
                                      select  
                                          subq_0.c2 as c0, 
                                          ref_0.category as c1
                                        from 
                                          test_bd.locations as ref_9,
                                          lateral (select  
                                                ref_1.comment as c0, 
                                                ref_2.name as c1, 
                                                ref_5.bio as c2
                                              from 
                                                test_bd.user_post_comments as ref_10
                                              where ref_1.comment is not NULL) as subq_0
                                        where (EXISTS (
                                            select  
                                                92 as c0, 
                                                (select created_at from test_bd.users limit 1 offset 6)
                                                   as c1, 
                                                ref_2.name as c2, 
                                                subq_2.c0 as c3, 
                                                subq_4.c8 as c4
                                              from 
                                                test_bd.employee as ref_11,
                                                lateral (select  
                                                      subq_1.c2 as c0
                                                    from 
                                                      test_bd.locations as ref_12,
                                                      lateral (select  
                                                            70 as c0, 
                                                            subq_0.c2 as c1, 
                                                            ref_12.coordinates as c2, 
                                                            ref_9.name as c3
                                                          from 
                                                            test_bd.posts as ref_13
                                                          where ref_11.id is not NULL
                                                          limit 118) as subq_1
                                                    where ref_5.profile_picture is NULL
                                                    limit 48) as subq_2,
                                                lateral (select  
                                                      ref_11.email as c0, 
                                                      ref_11.age as c1, 
                                                      ref_1.comment as c2, 
                                                      subq_0.c1 as c3, 
                                                      ref_11.department_id as c4, 
                                                      ref_11.years as c5, 
                                                      ref_14.title as c6, 
                                                      ref_2.id as c7, 
                                                      subq_0.c2 as c8, 
                                                      subq_0.c2 as c9, 
                                                      subq_3.c1 as c10, 
                                                      22 as c11, 
                                                      ref_11.department_id as c12, 
                                                      subq_3.c0 as c13, 
                                                      ref_5.user_id as c14
                                                    from 
                                                      test_bd.user_post_comments as ref_14,
                                                      lateral (select  
                                                            ref_15.title as c0, 
                                                            ref_15.comment as c1, 
                                                            ref_14.title as c2, 
                                                            ref_11.years as c3, 
                                                            subq_0.c0 as c4, 
                                                            ref_2.created_at as c5, 
                                                            (select created_at from test_bd.users limit 1 offset 60)
                                                               as c6, 
                                                            65 as c7, 
                                                            ref_5.user_id as c8, 
                                                            ref_11.id as c9, 
                                                            (select name from test_bd.locations limit 1 offset 4)
                                                               as c10
                                                          from 
                                                            test_bd.user_post_comments as ref_15
                                                          where true
                                                          limit 147) as subq_3
                                                    where ref_1.id is not NULL
                                                    limit 62) as subq_4
                                              where false
                                              limit 114)) 
                                          and (true)
                                        limit 93)))))) 
                            and (true))) 
                        or ((74 is not NULL) 
                          or (((true) 
                              or (false)) 
                            or (ref_0.created_at is not NULL)))))) 
                  or (ref_1.id is not NULL)) 
                or (ref_1.user_id is NULL))
          limit 108)) as subq_5
where true;
SHOW profiles;