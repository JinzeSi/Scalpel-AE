SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_6.c0 as c0, 
  subq_1.c0 as c1, 
  subq_1.c0 as c2, 
  30 as c3, 
  subq_6.c3 as c4, 
  subq_1.c0 as c5, 
  subq_6.c10 as c6
from 
  (select  
        ref_3.email as c0
      from 
        (select  
                ref_1.id as c0, 
                ref_0.tags as c1, 
                8 as c2, 
                ref_1.created_at as c3
              from 
                test_bd.products as ref_0
                  inner join test_bd.users as ref_1
                  on (false)
              where (true) 
                and (((false) 
                    or ((((select birthdate from test_bd.user_profiles limit 1 offset 1)
                             is NULL) 
                        or ((true) 
                          and (true))) 
                      or (ref_1.created_at is NULL))) 
                  or ((EXISTS (
                      select  
                          ref_2.virtual_col as c0, 
                          ref_2.virtual_col as c1, 
                          ref_0.price as c2, 
                          ref_1.email as c3, 
                          ref_1.username as c4, 
                          ref_1.username as c5, 
                          ref_1.username as c6
                        from 
                          test_bd.eids as ref_2
                        where (ref_0.id is not NULL) 
                          and (ref_0.tags is NULL)
                        limit 53)) 
                    and (((select age from test_bd.employee limit 1 offset 30)
                           is not NULL) 
                      and (true))))
              limit 11) as subq_0
          inner join test_bd.users as ref_3
              right join test_bd.products as ref_4
              on ((ref_4.tags is not NULL) 
                  or ((((((EXISTS (
                              select  
                                  ref_5.comment as c0
                                from 
                                  test_bd.user_post_comments as ref_5
                                where false
                                limit 161)) 
                            or (ref_3.email is NULL)) 
                          or (true)) 
                        or ((ref_4.category is NULL) 
                          and (true))) 
                      and (ref_3.username is not NULL)) 
                    and (((ref_4.discount is not NULL) 
                        or ((ref_3.created_at is NULL) 
                          or ((((false) 
                                or (EXISTS (
                                  select  
                                      ref_3.email as c0, 
                                      ref_6.id as c1, 
                                      ref_6.coordinates as c2, 
                                      ref_3.id as c3, 
                                      ref_4.tags as c4
                                    from 
                                      test_bd.locations as ref_6
                                    where false
                                    limit 48))) 
                              or ((select age from test_bd.employee limit 1 offset 70)
                                   is not NULL)) 
                            or ((true) 
                              and (64 is NULL))))) 
                      or ((true) 
                        and (ref_4.tags is not NULL)))))
            right join test_bd.user_profiles as ref_7
            on (((ref_7.birthdate is not NULL) 
                  and (false)) 
                and ((ref_4.category is not NULL) 
                  and (((select name from test_bd.products limit 1 offset 4)
                         is not NULL) 
                    or (((EXISTS (
                          select  
                              ref_7.bio as c0, 
                              ref_3.created_at as c1
                            from 
                              test_bd.comments as ref_8
                            where true)) 
                        or (ref_3.created_at is not NULL)) 
                      and (ref_3.created_at is NULL)))))
          on ((ref_4.tags is NULL) 
              or (((false) 
                  or (false)) 
                or (((((false) 
                        and ((true) 
                          and ((EXISTS (
                              select  
                                  ref_7.profile_picture as c0, 
                                  ref_3.email as c1, 
                                  (select email from test_bd.users limit 1 offset 60)
                                     as c2, 
                                  ref_7.user_id as c3, 
                                  92 as c4, 
                                  ref_7.profile_picture as c5, 
                                  ref_7.user_id as c6
                                from 
                                  test_bd.products as ref_9
                                where (false) 
                                  and (70 is not NULL))) 
                            or ((true) 
                              or (ref_3.username is NULL))))) 
                      or (true)) 
                    or (true)) 
                  or (false))))
      where true
      limit 53) as subq_1,
  lateral (select  
        subq_4.c1 as c0, 
        subq_4.c2 as c1, 
        subq_1.c0 as c2, 
        (select email from test_bd.users limit 1 offset 3)
           as c3, 
        subq_1.c0 as c4, 
        subq_4.c3 as c5, 
        subq_1.c0 as c6, 
        subq_1.c0 as c7, 
        subq_4.c2 as c8, 
        subq_1.c0 as c9, 
        (select name from test_bd.locations limit 1 offset 3)
           as c10, 
        subq_1.c0 as c11, 
        subq_1.c0 as c12, 
        subq_4.c1 as c13, 
        subq_1.c0 as c14, 
        subq_4.c0 as c15, 
        subq_1.c0 as c16, 
        subq_4.c0 as c17, 
        subq_4.c2 as c18, 
        subq_4.c2 as c19, 
        subq_1.c0 as c20
      from 
        (select  
              ref_10.title as c0, 
              ref_10.comment as c1, 
              subq_3.c4 as c2, 
              subq_3.c2 as c3
            from 
              test_bd.user_post_comments as ref_10,
              lateral (select  
                    ref_10.username as c0, 
                    (select comment from test_bd.comments limit 1 offset 3)
                       as c1, 
                    subq_1.c0 as c2, 
                    (select title from test_bd.user_post_comments limit 1 offset 2)
                       as c3, 
                    subq_1.c0 as c4, 
                    subq_2.c4 as c5, 
                    ref_10.comment as c6
                  from 
                    test_bd.employee as ref_11,
                    lateral (select  
                          ref_10.title as c0, 
                          ref_10.username as c1, 
                          ref_11.id as c2, 
                          ref_10.comment as c3, 
                          ref_10.comment as c4
                        from 
                          test_bd.user_post_comments as ref_12
                        where false
                        limit 90) as subq_2
                  where true
                  limit 42) as subq_3
            where EXISTS (
              select  
                  ref_10.username as c0, 
                  subq_3.c0 as c1, 
                  ref_10.title as c2, 
                  subq_1.c0 as c3, 
                  ref_10.comment as c4, 
                  (select virtual_col from test_bd.eids limit 1 offset 1)
                     as c5, 
                  subq_1.c0 as c6, 
                  ref_13.user_id as c7, 
                  ref_10.title as c8, 
                  ref_10.comment as c9
                from 
                  test_bd.posts as ref_13
                where EXISTS (
                  select  
                      subq_1.c0 as c0, 
                      subq_1.c0 as c1, 
                      ref_13.content as c2, 
                      ref_10.title as c3, 
                      subq_3.c4 as c4, 
                      subq_3.c2 as c5, 
                      ref_13.user_id as c6, 
                      99 as c7, 
                      subq_3.c0 as c8, 
                      ref_13.user_id as c9, 
                      ref_13.content as c10, 
                      ref_14.birthdate as c11, 
                      ref_14.birthdate as c12
                    from 
                      test_bd.user_profiles as ref_14
                    where true
                    limit 97))
            limit 131) as subq_4
      where ((((true) 
              and (EXISTS (
                select  
                    subq_1.c0 as c0, 
                    (select created_at from test_bd.posts limit 1 offset 3)
                       as c1
                  from 
                    test_bd.products as ref_15
                  where ((ref_15.created_at is not NULL) 
                      or (false)) 
                    and (EXISTS (
                      select  
                          subq_5.c1 as c0, 
                          ref_15.name as c1, 
                          97 as c2, 
                          (select department_id from test_bd.employee limit 1 offset 5)
                             as c3, 
                          subq_4.c1 as c4, 
                          subq_1.c0 as c5
                        from 
                          test_bd.user_post_comments as ref_16,
                          lateral (select  
                                ref_17.created_at as c0, 
                                subq_4.c3 as c1
                              from 
                                test_bd.posts as ref_17
                              where (select id from test_bd.eids limit 1 offset 4)
                                   is NULL
                              limit 44) as subq_5
                        where ((true) 
                            or (false)) 
                          or ((true) 
                            and (true))
                        limit 115))
                  limit 129))) 
            and (true)) 
          and (subq_4.c1 is not NULL)) 
        or (subq_4.c2 is NULL)
      limit 110) as subq_6
where EXISTS (
  select  
      subq_1.c0 as c0, 
      subq_6.c13 as c1, 
      coalesce(subq_1.c0,
        subq_6.c3) as c2, 
      subq_1.c0 as c3, 
      subq_7.c2 as c4, 
      subq_1.c0 as c5, 
      subq_7.c3 as c6, 
      subq_6.c3 as c7, 
      23 as c8, 
      60 as c9, 
      subq_1.c0 as c10, 
      subq_6.c5 as c11, 
      subq_1.c0 as c12, 
      subq_1.c0 as c13
    from 
      (select  
            ref_18.id as c0, 
            ref_18.email as c1, 
            subq_1.c0 as c2, 
            subq_1.c0 as c3, 
            ref_18.username as c4, 
            ref_18.email as c5
          from 
            test_bd.users as ref_18
          where true) as subq_7
    where subq_6.c8 is not NULL)
limit 65;
SHOW profiles;