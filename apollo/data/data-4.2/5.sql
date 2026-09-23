SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_2.c6 as c0, 
  subq_2.c1 as c1, 
  subq_2.c3 as c2, 
  subq_2.c8 as c3, 
  subq_2.c3 as c4, 
  subq_2.c8 as c5
from 
  (select  
        ref_5.title as c0, 
        ref_0.created_at as c1, 
        ref_6.email as c2, 
        ref_1.virtual_col as c3, 
        case when false then ref_7.id else ref_7.id end
           as c4, 
        ref_2.birthdate as c5, 
        ref_5.username as c6, 
        ref_6.username as c7, 
        ref_0.created_at as c8
      from 
        test_bd.users as ref_0
              right join test_bd.eids as ref_1
              on (ref_0.id = ref_1.eid )
            inner join test_bd.user_profiles as ref_2
            on ((((EXISTS (
                      select  
                          ref_3.id as c0
                        from 
                          test_bd.locations as ref_3
                        where false
                        limit 106)) 
                    and (ref_2.birthdate is not NULL)) 
                  and (EXISTS (
                    select  
                        ref_4.id as c0, 
                        ref_2.birthdate as c1, 
                        ref_0.created_at as c2, 
                        ref_1.id as c3, 
                        ref_0.created_at as c4, 
                        (select created_at from test_bd.products limit 1 offset 6)
                           as c5, 
                        ref_1.id as c6
                      from 
                        test_bd.comments as ref_4
                      where ref_2.user_id is not NULL))) 
                and (true))
          right join test_bd.user_post_comments as ref_5
              inner join test_bd.users as ref_6
              on (ref_5.username = ref_6.email )
            inner join test_bd.eids as ref_7
            on (((((ref_5.username is not NULL) 
                      or (true)) 
                    or ((true) 
                      or (((EXISTS (
                            select  
                                ref_6.id as c0, 
                                ref_5.comment as c1, 
                                subq_0.c6 as c2, 
                                ref_5.comment as c3, 
                                subq_0.c1 as c4, 
                                ref_5.comment as c5, 
                                ref_7.eid as c6
                              from 
                                test_bd.eids as ref_8,
                                lateral (select  
                                      (select salary from test_bd.employee limit 1 offset 6)
                                         as c0, 
                                      ref_7.virtual_col as c1, 
                                      ref_7.eid as c2, 
                                      ref_5.username as c3, 
                                      ref_8.eid as c4, 
                                      (select virtual_col from test_bd.eids limit 1 offset 66)
                                         as c5, 
                                      75 as c6, 
                                      ref_8.eid as c7, 
                                      ref_5.comment as c8, 
                                      ref_6.id as c9, 
                                      ref_6.created_at as c10
                                    from 
                                      test_bd.user_post_comments as ref_9
                                    where false
                                    limit 32) as subq_0
                              where EXISTS (
                                select  
                                    ref_8.eid as c0, 
                                    (select coordinates from test_bd.locations limit 1 offset 6)
                                       as c1, 
                                    ref_6.email as c2, 
                                    56 as c3, 
                                    ref_8.eid as c4, 
                                    37 as c5, 
                                    ref_8.virtual_col as c6, 
                                    subq_0.c3 as c7, 
                                    ref_5.title as c8, 
                                    ref_8.eid as c9, 
                                    ref_7.eid as c10
                                  from 
                                    test_bd.employee as ref_10
                                  where ref_6.created_at is NULL
                                  limit 107)
                              limit 140)) 
                          and ((((true) 
                                and ((true) 
                                  and (true))) 
                              or (ref_5.comment is not NULL)) 
                            and (true))) 
                        or (false)))) 
                  and (88 is NULL)) 
                or (true))
          on ((EXISTS (
                select  
                    ref_2.birthdate as c0, 
                    ref_1.id as c1, 
                    ref_7.eid as c2, 
                    ref_5.username as c3, 
                    ref_1.eid as c4, 
                    ref_1.eid as c5, 
                    ref_11.coordinates as c6, 
                    ref_7.virtual_col as c7, 
                    ref_2.profile_picture as c8, 
                    (select username from test_bd.users limit 1 offset 6)
                       as c9, 
                    ref_2.profile_picture as c10, 
                    ref_2.user_id as c11, 
                    ref_0.email as c12
                  from 
                    test_bd.locations as ref_11
                  where EXISTS (
                    select  
                        ref_0.username as c0, 
                        ref_7.id as c1, 
                        ref_7.virtual_col as c2, 
                        ref_5.title as c3, 
                        ref_7.virtual_col as c4
                      from 
                        test_bd.products as ref_12
                      where (((EXISTS (
                              select  
                                  ref_13.user_id as c0, 
                                  ref_2.bio as c1, 
                                  42 as c2, 
                                  ref_1.id as c3
                                from 
                                  test_bd.locations as ref_13,
                                  lateral (select  
                                        ref_1.eid as c0, 
                                        ref_7.id as c1, 
                                        ref_14.hire_date as c2, 
                                        ref_0.username as c3, 
                                        ref_14.eid as c4, 
                                        ref_6.id as c5
                                      from 
                                        test_bd.employee as ref_14
                                      where ref_7.id is not NULL
                                      limit 21) as subq_1
                                where (ref_0.email is NULL) 
                                  or (false))) 
                            and ((((false) 
                                  and (EXISTS (
                                    select  
                                        ref_0.created_at as c0, 
                                        ref_6.created_at as c1, 
                                        ref_15.username as c2, 
                                        ref_5.username as c3, 
                                        ref_1.virtual_col as c4, 
                                        ref_7.virtual_col as c5, 
                                        ref_1.id as c6
                                      from 
                                        test_bd.users as ref_15
                                      where ref_5.title is NULL
                                      limit 95))) 
                                and (false)) 
                              and (false))) 
                          and (true)) 
                        or (true)))) 
              and ((((ref_6.username is not NULL) 
                    and (ref_5.username is NULL)) 
                  or (true)) 
                and (ref_1.id is NULL)))
      where ref_5.username is not NULL
      limit 135) as subq_2
where (((((false) 
          or ((true) 
            and ((subq_2.c5 is NULL) 
              or (subq_2.c6 is NULL)))) 
        and (true)) 
      and (((EXISTS (
            select  
                ref_16.id as c0
              from 
                test_bd.users as ref_16,
                lateral (select  
                      ref_17.title as c0, 
                      (select name from test_bd.locations limit 1 offset 1)
                         as c1, 
                      ref_17.id as c2, 
                      ref_17.user_id as c3, 
                      subq_2.c4 as c4, 
                      ref_17.content as c5, 
                      subq_2.c7 as c6
                    from 
                      test_bd.posts as ref_17
                    where EXISTS (
                      select  
                          ref_16.created_at as c0, 
                          ref_16.username as c1, 
                          ref_18.id as c2
                        from 
                          test_bd.products as ref_18
                        where (subq_2.c0 is NULL) 
                          and (ref_18.discount is NULL)
                        limit 105)
                    limit 141) as subq_3
              where ref_16.email is not NULL)) 
          or (false)) 
        or (((select tags from test_bd.products limit 1 offset 1)
               is NULL) 
          and (EXISTS (
            select  
                subq_2.c0 as c0, 
                (select eid from test_bd.employee limit 1 offset 6)
                   as c1, 
                subq_2.c8 as c2, 
                ref_19.username as c3, 
                ref_19.username as c4, 
                ref_19.email as c5
              from 
                test_bd.users as ref_19
              where (true) 
                and ((false) 
                  or (((((true) 
                          or ((subq_2.c2 is NULL) 
                            and (((true) 
                                and (false)) 
                              and ((ref_19.username is NULL) 
                                and (true))))) 
                        or (false)) 
                      and (ref_19.created_at is NULL)) 
                    and ((true) 
                      and (subq_2.c5 is not NULL))))
              limit 119))))) 
    or (subq_2.c6 is not NULL)) 
  or (subq_2.c7 is NULL)
limit 43;
SHOW profiles;