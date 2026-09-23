SET profiling=1;
EXPLAIN ANALYZE

select  
  coalesce(subq_2.c5,
    subq_0.c7) as c0, 
  (select bio from test_bd.user_profiles limit 1 offset 3)
     as c1, 
  subq_2.c3 as c2, 
  subq_2.c4 as c3, 
  subq_0.c5 as c4, 
  subq_2.c5 as c5, 
  subq_0.c2 as c6, 
  subq_2.c2 as c7, 
  case when (subq_0.c1 is not NULL) 
      or (false) then subq_0.c1 else subq_0.c1 end
     as c8, 
  subq_0.c4 as c9, 
  subq_2.c5 as c10, 
  case when ((false) 
        and (((((subq_2.c3 is NULL) 
                and ((true) 
                  or (false))) 
              or ((true) 
                and (subq_2.c1 is NULL))) 
            and ((55 is NULL) 
              or (false))) 
          or (subq_0.c2 is not NULL))) 
      or (subq_2.c0 is not NULL) then subq_2.c4 else subq_2.c4 end
     as c11, 
  subq_0.c7 as c12, 
  subq_2.c3 as c13, 
  subq_2.c5 as c14, 
  subq_2.c3 as c15, 
  case when EXISTS (
      select  
          ref_10.user_id as c0, 
          subq_0.c8 as c1, 
          subq_0.c3 as c2, 
          ref_10.name as c3, 
          subq_2.c5 as c4, 
          ref_10.name as c5, 
          ref_10.name as c6, 
          ref_10.name as c7, 
          ref_10.name as c8, 
          ref_10.user_id as c9, 
          ref_10.coordinates as c10, 
          subq_0.c8 as c11, 
          ref_10.coordinates as c12, 
          ref_10.user_id as c13, 
          subq_2.c4 as c14
        from 
          test_bd.locations as ref_10
        where (((subq_0.c0 is NULL) 
              or ((true) 
                and (((((subq_2.c5 is not NULL) 
                        or (subq_0.c3 is NULL)) 
                      or ((ref_10.user_id is not NULL) 
                        or (((EXISTS (
                              select  
                                  subq_2.c5 as c0, 
                                  subq_2.c2 as c1, 
                                  subq_0.c6 as c2
                                from 
                                  test_bd.locations as ref_11
                                where (false) 
                                  or (ref_11.id is NULL))) 
                            and (subq_2.c1 is NULL)) 
                          or (false)))) 
                    and (((true) 
                        and (true)) 
                      or ((subq_0.c2 is not NULL) 
                        or (EXISTS (
                          select  
                              ref_10.coordinates as c0, 
                              subq_2.c3 as c1, 
                              ref_10.id as c2, 
                              ref_10.name as c3, 
                              subq_2.c3 as c4, 
                              (select profile_picture from test_bd.user_profiles limit 1 offset 1)
                                 as c5, 
                              ref_10.coordinates as c6, 
                              subq_0.c6 as c7, 
                              ref_10.coordinates as c8, 
                              subq_0.c7 as c9, 
                              subq_2.c1 as c10, 
                              subq_0.c2 as c11, 
                              subq_2.c2 as c12, 
                              66 as c13
                            from 
                              test_bd.posts as ref_12
                            where (false) 
                              or (EXISTS (
                                select  
                                    ref_12.id as c0, 
                                    ref_13.comment as c1, 
                                    subq_0.c5 as c2
                                  from 
                                    test_bd.user_post_comments as ref_13
                                  where ref_13.comment is not NULL
                                  limit 109))
                            limit 151))))) 
                  and (true)))) 
            and (subq_0.c5 is NULL)) 
          or ((((true) 
                or (((ref_10.coordinates is NULL) 
                    or (true)) 
                  or (true))) 
              and ((ref_10.id is not NULL) 
                or (EXISTS (
                  select  
                      ref_10.user_id as c0, 
                      ref_14.price as c1, 
                      ref_14.price as c2, 
                      subq_0.c3 as c3, 
                      subq_0.c5 as c4, 
                      ref_14.id as c5, 
                      ref_10.id as c6, 
                      ref_14.category as c7
                    from 
                      test_bd.products as ref_14
                    where ((false) 
                        and (false)) 
                      or (subq_0.c2 is NULL))))) 
            and (EXISTS (
              select  
                  (select user_id from test_bd.comments limit 1 offset 1)
                     as c0, 
                  subq_2.c5 as c1, 
                  subq_0.c2 as c2, 
                  subq_2.c0 as c3, 
                  ref_15.username as c4, 
                  ref_10.id as c5, 
                  ref_15.created_at as c6, 
                  subq_0.c4 as c7, 
                  ref_15.username as c8, 
                  subq_0.c7 as c9, 
                  ref_15.email as c10
                from 
                  test_bd.users as ref_15
                where false
                limit 88)))) then (select username from test_bd.user_post_comments limit 1 offset 6)
       else (select username from test_bd.user_post_comments limit 1 offset 6)
       end
     as c16, 
  subq_0.c5 as c17, 
  subq_2.c4 as c18
from 
  (select  
        ref_0.id as c0, 
        coalesce((select salary from test_bd.employee limit 1 offset 3)
            ,
          null) as c1, 
        ref_0.created_at as c2, 
        ref_0.comment as c3, 
        case when ((EXISTS (
                select  
                    ref_0.id as c0, 
                    ref_0.user_id as c1, 
                    ref_1.email as c2, 
                    ref_1.created_at as c3
                  from 
                    test_bd.users as ref_1
                  where (true) 
                    and ((false) 
                      or ((false) 
                        or ((ref_0.created_at is not NULL) 
                          and (false)))))) 
              or (false)) 
            or (ref_0.id is not NULL) then ref_0.created_at else ref_0.created_at end
           as c4, 
        (select id from test_bd.comments limit 1 offset 5)
           as c5, 
        ref_0.user_id as c6, 
        ref_0.comment as c7, 
        ref_0.comment as c8
      from 
        test_bd.comments as ref_0
      where (EXISTS (
          select  
              ref_0.post_id as c0, 
              ref_0.id as c1
            from 
              test_bd.employee as ref_2
            where ((true) 
                or (((false) 
                    and (true)) 
                  and ((((ref_0.post_id is NULL) 
                        or (ref_0.id is not NULL)) 
                      or (ref_0.comment is NULL)) 
                    or ((ref_2.hire_date is NULL) 
                      or ((((false) 
                            or (ref_0.user_id is NULL)) 
                          or ((((true) 
                                or ((select virtual_col from test_bd.eids limit 1 offset 3)
                                     is not NULL)) 
                              or (((false) 
                                  or (((true) 
                                      or (ref_2.id is NULL)) 
                                    and (ref_0.comment is not NULL))) 
                                or (ref_2.age is NULL))) 
                            and (((((false) 
                                    or (EXISTS (
                                      select  
                                          ref_2.eid as c0, 
                                          ref_0.created_at as c1, 
                                          ref_2.eid as c2
                                        from 
                                          test_bd.comments as ref_3
                                        where ref_2.eid is NULL
                                        limit 162))) 
                                  or (EXISTS (
                                    select  
                                        35 as c0
                                      from 
                                        test_bd.comments as ref_4
                                      where (true) 
                                        and (false)
                                      limit 46))) 
                                and ((true) 
                                  or (ref_2.age is not NULL))) 
                              or ((ref_2.department_id is NULL) 
                                or (((ref_0.id is not NULL) 
                                    or (ref_0.comment is not NULL)) 
                                  and (ref_0.created_at is NULL)))))) 
                        and (EXISTS (
                          select  
                              ref_0.comment as c0, 
                              ref_5.id as c1, 
                              ref_2.hire_date as c2
                            from 
                              test_bd.comments as ref_5
                            where EXISTS (
                              select  
                                  ref_5.id as c0, 
                                  75 as c1, 
                                  ref_0.id as c2, 
                                  ref_2.eid as c3, 
                                  (select profile_picture from test_bd.user_profiles limit 1 offset 6)
                                     as c4, 
                                  25 as c5, 
                                  ref_6.name as c6, 
                                  ref_0.post_id as c7, 
                                  ref_2.hire_date as c8, 
                                  ref_2.years as c9, 
                                  21 as c10
                                from 
                                  test_bd.locations as ref_6
                                where false
                                limit 46)))))))) 
              or (((true) 
                  or (ref_0.post_id is NULL)) 
                or (ref_0.post_id is NULL))
            limit 111)) 
        or (ref_0.comment is NULL)
      limit 124) as subq_0,
  lateral (select  
        subq_1.c0 as c0, 
        subq_1.c3 as c1, 
        subq_1.c0 as c2, 
        subq_1.c1 as c3, 
        subq_0.c2 as c4, 
        coalesce(subq_0.c8,
          null) as c5
      from 
        (select  
              subq_0.c8 as c0, 
              subq_0.c1 as c1, 
              57 as c2, 
              subq_0.c0 as c3
            from 
              test_bd.eids as ref_7
            where (ref_7.id is NULL) 
              and ((((subq_0.c4 is NULL) 
                    and ((((false) 
                          and (((EXISTS (
                                select  
                                    37 as c0, 
                                    ref_8.profile_picture as c1, 
                                    ref_8.profile_picture as c2, 
                                    ref_8.bio as c3, 
                                    subq_0.c4 as c4, 
                                    subq_0.c2 as c5, 
                                    80 as c6, 
                                    ref_8.profile_picture as c7, 
                                    ref_7.virtual_col as c8, 
                                    subq_0.c2 as c9, 
                                    subq_0.c5 as c10, 
                                    subq_0.c4 as c11
                                  from 
                                    test_bd.user_profiles as ref_8
                                  where false
                                  limit 87)) 
                              and (ref_7.eid is not NULL)) 
                            or (subq_0.c2 is NULL))) 
                        and (((((true) 
                                and ((ref_7.id is NULL) 
                                  or (EXISTS (
                                    select  
                                        ref_9.department_id as c0, 
                                        subq_0.c2 as c1, 
                                        ref_9.age as c2, 
                                        ref_9.age as c3, 
                                        ref_7.id as c4, 
                                        (select virtual_col from test_bd.eids limit 1 offset 3)
                                           as c5, 
                                        (select bio from test_bd.user_profiles limit 1 offset 3)
                                           as c6, 
                                        subq_0.c5 as c7, 
                                        subq_0.c2 as c8
                                      from 
                                        test_bd.employee as ref_9
                                      where false
                                      limit 108)))) 
                              and ((true) 
                                or (subq_0.c0 is not NULL))) 
                            and (false)) 
                          or ((((subq_0.c0 is not NULL) 
                                or ((false) 
                                  or ((ref_7.virtual_col is NULL) 
                                    and ((ref_7.id is not NULL) 
                                      or ((select profile_picture from test_bd.user_profiles limit 1 offset 76)
                                           is NULL))))) 
                              or (true)) 
                            and (false)))) 
                      or ((ref_7.eid is NULL) 
                        and (ref_7.id is NULL)))) 
                  or (false)) 
                and ((false) 
                  and (true)))
            limit 95) as subq_1
      where (true) 
        or (subq_1.c0 is not NULL)
      limit 156) as subq_2
where subq_2.c2 is not NULL
limit 128;
SHOW profiles;