SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_1.c2 as c0, 
  subq_1.c1 as c1, 
  subq_1.c1 as c2, 
  case when (subq_1.c0 is not NULL) 
      and (subq_1.c1 is not NULL) then subq_1.c1 else subq_1.c1 end
     as c3, 
  subq_1.c1 as c4
from 
  (select  
        subq_0.c4 as c0, 
        subq_0.c2 as c1, 
        subq_0.c1 as c2
      from 
        (select  
              (select user_id from test_bd.posts limit 1 offset 6)
                 as c0, 
              ref_1.user_id as c1, 
              ref_0.user_id as c2, 
              ref_1.coordinates as c3, 
              ref_1.id as c4
            from 
              test_bd.comments as ref_0
                left join test_bd.locations as ref_1
                on (ref_0.user_id is not NULL)
            where ref_1.coordinates is not NULL
            limit 124) as subq_0
      where EXISTS (
        select  
            subq_0.c4 as c0, 
            49 as c1, 
            ref_2.eid as c2, 
            subq_0.c0 as c3, 
            ref_2.id as c4, 
            subq_0.c1 as c5, 
            ref_2.id as c6, 
            78 as c7, 
            subq_0.c3 as c8
          from 
            test_bd.eids as ref_2
          where (subq_0.c3 is NULL) 
            or (false)
          limit 76)
      limit 136) as subq_1
where ((EXISTS (
      select  
          ref_3.profile_picture as c0, 
          subq_1.c2 as c1
        from 
          test_bd.user_profiles as ref_3
        where subq_1.c1 is not NULL
        limit 143)) 
    or ((64 is NULL) 
      and (subq_1.c2 is not NULL))) 
  or (((subq_1.c0 is not NULL) 
      or (EXISTS (
        select  
            ref_4.id as c0, 
            ref_4.user_id as c1, 
            ref_4.content as c2, 
            ref_4.updated_at as c3, 
            ref_4.user_id as c4, 
            subq_1.c1 as c5, 
            ref_4.created_at as c6, 
            subq_1.c0 as c7, 
            subq_1.c0 as c8
          from 
            test_bd.posts as ref_4
          where ((((false) 
                  and ((subq_1.c0 is NULL) 
                    and (ref_4.updated_at is not NULL))) 
                or (EXISTS (
                  select  
                      subq_1.c0 as c0, 
                      subq_1.c0 as c1, 
                      ref_5.coordinates as c2, 
                      ref_4.updated_at as c3, 
                      ref_4.updated_at as c4, 
                      subq_1.c2 as c5, 
                      ref_5.user_id as c6, 
                      subq_1.c2 as c7, 
                      subq_1.c1 as c8, 
                      subq_1.c0 as c9
                    from 
                      test_bd.locations as ref_5
                    where (subq_1.c2 is NULL) 
                      or (EXISTS (
                        select  
                            subq_1.c0 as c0, 
                            ref_6.user_id as c1, 
                            ref_5.name as c2, 
                            subq_1.c0 as c3, 
                            subq_1.c0 as c4, 
                            ref_4.created_at as c5, 
                            ref_5.id as c6, 
                            ref_6.birthdate as c7, 
                            subq_1.c2 as c8, 
                            (select profile_picture from test_bd.user_profiles limit 1 offset 5)
                               as c9, 
                            ref_4.id as c10, 
                            subq_1.c1 as c11, 
                            ref_6.profile_picture as c12, 
                            ref_5.id as c13, 
                            ref_4.user_id as c14, 
                            subq_1.c0 as c15, 
                            ref_6.user_id as c16, 
                            (select birthdate from test_bd.user_profiles limit 1 offset 4)
                               as c17, 
                            ref_4.updated_at as c18, 
                            ref_6.bio as c19
                          from 
                            test_bd.user_profiles as ref_6
                          where EXISTS (
                            select  
                                ref_4.updated_at as c0, 
                                ref_7.user_id as c1, 
                                92 as c2
                              from 
                                test_bd.locations as ref_7
                              where false
                              limit 77)))))) 
              or ((EXISTS (
                  select  
                      7 as c0, 
                      subq_2.c3 as c1, 
                      64 as c2, 
                      ref_8.title as c3, 
                      ref_8.comment as c4, 
                      (select salary from test_bd.employee limit 1 offset 17)
                         as c5, 
                      subq_1.c0 as c6, 
                      subq_2.c6 as c7
                    from 
                      test_bd.user_post_comments as ref_8,
                      lateral (select  
                            ref_4.created_at as c0, 
                            (select id from test_bd.locations limit 1 offset 39)
                               as c1, 
                            ref_8.username as c2, 
                            ref_8.comment as c3, 
                            ref_9.comment as c4, 
                            ref_4.updated_at as c5, 
                            ref_4.content as c6, 
                            ref_4.title as c7, 
                            ref_9.id as c8
                          from 
                            test_bd.comments as ref_9
                          where (true) 
                            or (ref_4.updated_at is NULL)
                          limit 66) as subq_2
                    where true
                    limit 166)) 
                and (ref_4.created_at is not NULL))) 
            or (true)))) 
    and ((((((subq_1.c2 is NULL) 
              and (subq_1.c1 is NULL)) 
            or ((true) 
              and ((select name from test_bd.products limit 1 offset 94)
                   is NULL))) 
          or ((subq_1.c1 is NULL) 
            or (EXISTS (
              select  
                  subq_1.c1 as c0, 
                  subq_1.c0 as c1, 
                  subq_1.c2 as c2, 
                  ref_10.id as c3, 
                  ref_10.id as c4, 
                  ref_10.id as c5, 
                  ref_10.id as c6, 
                  ref_10.user_id as c7
                from 
                  test_bd.posts as ref_10
                where (ref_10.created_at is not NULL) 
                  and ((subq_1.c2 is NULL) 
                    or (false))
                limit 116)))) 
        or ((subq_1.c2 is NULL) 
          or (subq_1.c0 is NULL))) 
      or ((subq_1.c1 is not NULL) 
        or (EXISTS (
          select  
              59 as c0, 
              (select id from test_bd.products limit 1 offset 6)
                 as c1, 
              subq_1.c2 as c2, 
              ref_11.post_id as c3, 
              subq_1.c1 as c4, 
              subq_1.c0 as c5, 
              subq_1.c0 as c6, 
              ref_11.id as c7, 
              ref_11.user_id as c8, 
              (select virtual_col from test_bd.eids limit 1 offset 53)
                 as c9, 
              ref_11.post_id as c10
            from 
              test_bd.comments as ref_11
            where 86 is NULL)))))
limit 114;
SHOW profiles;