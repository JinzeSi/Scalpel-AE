SET profiling=1;
EXPLAIN ANALYZE

WITH 
jennifer_0 AS (select  
    coalesce(5,
      subq_2.c4) as c0, 
    case when (false) 
        or (40 is NULL) then subq_1.c5 else subq_1.c5 end
       as c1
  from 
    (select  
            10 as c0, 
            ref_1.user_id as c1
          from 
            test_bd.user_profiles as ref_0
              right join test_bd.locations as ref_1
                inner join test_bd.employee as ref_2
                  inner join test_bd.products as ref_3
                  on (true)
                on (true)
              on (ref_3.name is not NULL)
          where ((true) 
              or ((select tags from test_bd.products limit 1 offset 1)
                   is not NULL)) 
            or (((((ref_3.discount is not NULL) 
                    and (((ref_2.salary is not NULL) 
                        and ((false) 
                          and (ref_1.name is not NULL))) 
                      or (ref_2.email is NULL))) 
                  or (((((false) 
                          and (ref_0.birthdate is not NULL)) 
                        and (true)) 
                      or (true)) 
                    and ((false) 
                      or (ref_1.user_id is NULL)))) 
                or ((false) 
                  and ((((false) 
                        and ((ref_1.coordinates is not NULL) 
                          and ((EXISTS (
                              select  
                                  ref_2.hire_date as c0, 
                                  ref_3.tags as c1, 
                                  ref_2.email as c2, 
                                  10 as c3, 
                                  ref_1.name as c4, 
                                  ref_3.created_at as c5, 
                                  ref_3.created_at as c6
                                from 
                                  test_bd.products as ref_4
                                where EXISTS (
                                  select  
                                      ref_1.name as c0
                                    from 
                                      test_bd.eids as ref_5
                                    where (true) 
                                      or ((ref_2.hire_date is NULL) 
                                        or (false))))) 
                            and (true)))) 
                      and ((((EXISTS (
                              select  
                                  ref_6.tags as c0, 
                                  ref_1.user_id as c1, 
                                  ref_3.created_at as c2, 
                                  ref_0.bio as c3
                                from 
                                  test_bd.products as ref_6
                                where (true) 
                                  and (EXISTS (
                                    select  
                                        ref_6.name as c0, 
                                        ref_7.id as c1, 
                                        ref_6.name as c2
                                      from 
                                        test_bd.posts as ref_7
                                      where true))
                                limit 63)) 
                            or (false)) 
                          or (false)) 
                        or ((select title from test_bd.user_post_comments limit 1 offset 19)
                             is NULL))) 
                    or ((ref_1.id is not NULL) 
                      or (false))))) 
              and (EXISTS (
                select  
                    ref_0.profile_picture as c0
                  from 
                    test_bd.products as ref_8
                  where false
                  limit 70)))
          limit 131) as subq_0
      inner join (select  
            ref_9.coordinates as c0, 
            ref_9.id as c1, 
            ref_9.user_id as c2, 
            ref_9.id as c3, 
            ref_9.user_id as c4, 
            ref_9.id as c5, 
            ref_9.id as c6, 
            ref_9.user_id as c7, 
            ref_9.name as c8, 
            ref_9.name as c9, 
            ref_9.user_id as c10
          from 
            test_bd.locations as ref_9
          where ((ref_9.name is NULL) 
              or (EXISTS (
                select  
                    ref_10.eid as c0
                  from 
                    test_bd.eids as ref_10
                  where EXISTS (
                    select  
                        ref_10.id as c0, 
                        ref_9.coordinates as c1, 
                        ref_11.created_at as c2, 
                        (select virtual_col from test_bd.eids limit 1 offset 6)
                           as c3, 
                        (select user_id from test_bd.comments limit 1 offset 1)
                           as c4, 
                        ref_10.eid as c5, 
                        ref_11.user_id as c6, 
                        ref_9.coordinates as c7
                      from 
                        test_bd.comments as ref_11
                      where false
                      limit 38)))) 
            or (false)) as subq_1
      on (subq_1.c1 is not NULL),
    lateral (select  
          subq_1.c1 as c0, 
          ref_13.created_at as c1, 
          subq_0.c0 as c2, 
          46 as c3, 
          subq_0.c0 as c4, 
          ref_12.discount as c5, 
          subq_0.c1 as c6, 
          subq_0.c0 as c7, 
          ref_12.discount as c8, 
          subq_1.c8 as c9, 
          ref_13.user_id as c10, 
          subq_0.c1 as c11, 
          subq_0.c1 as c12, 
          ref_13.content as c13, 
          case when true then subq_0.c1 else subq_0.c1 end
             as c14, 
          subq_1.c8 as c15, 
          subq_0.c0 as c16, 
          ref_13.title as c17
        from 
          test_bd.products as ref_12
            right join test_bd.posts as ref_13
            on (((false) 
                  and (ref_12.created_at is not NULL)) 
                or (false))
        where subq_1.c8 is not NULL) as subq_2
  where subq_1.c5 is NULL
  limit 51)
select  
    99 as c0, 
    subq_4.c0 as c1, 
    subq_4.c0 as c2, 
    subq_4.c0 as c3, 
    subq_3.c0 as c4, 
    subq_4.c0 as c5
  from 
    (select  
          ref_14.age as c0, 
          ref_14.years as c1
        from 
          test_bd.employee as ref_14
        where ref_14.age is not NULL) as subq_3,
    lateral (select  
          subq_3.c0 as c0
        from 
          test_bd.users as ref_15
        where ((subq_3.c1 is not NULL) 
            or (((true) 
                or (EXISTS (
                  select  
                      ref_15.email as c0, 
                      (select coordinates from test_bd.locations limit 1 offset 6)
                         as c1
                    from 
                      test_bd.products as ref_16
                    where EXISTS (
                      select  
                          ref_17.hire_date as c0
                        from 
                          test_bd.employee as ref_17
                        where true
                        limit 92)
                    limit 34))) 
              and (((EXISTS (
                    select  
                        ref_15.id as c0, 
                        (select created_at from test_bd.products limit 1 offset 4)
                           as c1, 
                        ref_18.id as c2, 
                        ref_15.id as c3, 
                        ref_18.user_id as c4, 
                        ref_18.user_id as c5, 
                        ref_15.created_at as c6
                      from 
                        test_bd.locations as ref_18
                      where true)) 
                  and (((true) 
                      and (((true) 
                          or ((false) 
                            or (subq_3.c1 is not NULL))) 
                        and (ref_15.email is NULL))) 
                    and (true))) 
                or ((false) 
                  and ((EXISTS (
                      select  
                          ref_19.post_id as c0, 
                          ref_19.created_at as c1, 
                          ref_19.user_id as c2
                        from 
                          test_bd.comments as ref_19
                        where ((subq_3.c0 is NULL) 
                            and (false)) 
                          and (true)
                        limit 114)) 
                    and ((true) 
                      and (false))))))) 
          and ((subq_3.c1 is NULL) 
            or (false))
        limit 141) as subq_4
  where EXISTS (
    select  
        subq_3.c0 as c0
      from 
        test_bd.products as ref_20
      where subq_3.c0 is not NULL)
  limit 74
;
SHOW profiles;