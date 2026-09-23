SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_1.c0 as c0, 
  ref_2.hire_date as c1, 
  ref_2.email as c2, 
  coalesce(subq_1.c2,
    case when ((((((true) 
                  and (true)) 
                or (EXISTS (
                  select  
                      ref_2.department_id as c0, 
                      ref_8.tags as c1, 
                      ref_2.eid as c2, 
                      ref_8.id as c3
                    from 
                      test_bd.products as ref_8,
                      lateral (select  
                            ref_2.department_id as c0, 
                            ref_9.salary as c1, 
                            ref_2.id as c2, 
                            10 as c3, 
                            subq_1.c0 as c4
                          from 
                            test_bd.employee as ref_9
                          where (false) 
                            or (true)) as subq_2
                    where (ref_2.id is not NULL) 
                      or (((subq_2.c2 is not NULL) 
                          or (true)) 
                        and (false))))) 
              and ((true) 
                or (ref_2.years is NULL))) 
            or (ref_2.hire_date is not NULL)) 
          or ((((EXISTS (
                  select  
                      ref_2.email as c0, 
                      (select id from test_bd.eids limit 1 offset 99)
                         as c1, 
                      subq_1.c2 as c2, 
                      ref_2.department_id as c3, 
                      24 as c4, 
                      (select coordinates from test_bd.locations limit 1 offset 4)
                         as c5, 
                      ref_10.virtual_col as c6, 
                      65 as c7, 
                      ref_10.virtual_col as c8, 
                      ref_10.id as c9
                    from 
                      test_bd.eids as ref_10
                    where ((subq_1.c4 is NULL) 
                        and ((false) 
                          and (((EXISTS (
                                select  
                                    ref_10.virtual_col as c0, 
                                    ref_2.age as c1, 
                                    99 as c2, 
                                    ref_2.age as c3
                                  from 
                                    test_bd.users as ref_11
                                  where true)) 
                              and ((true) 
                                and (false))) 
                            and ((EXISTS (
                                select  
                                    ref_2.age as c0, 
                                    ref_12.username as c1, 
                                    ref_12.title as c2
                                  from 
                                    test_bd.user_post_comments as ref_12
                                  where (((ref_2.eid is NULL) 
                                        or ((73 is not NULL) 
                                          and ((false) 
                                            or (false)))) 
                                      or (false)) 
                                    or ((true) 
                                      and (((true) 
                                          and (false)) 
                                        and ((true) 
                                          and (ref_10.virtual_col is not NULL))))
                                  limit 112)) 
                              and (ref_2.department_id is NULL))))) 
                      and ((false) 
                        or ((subq_1.c4 is not NULL) 
                          or (((false) 
                              and (((EXISTS (
                                    select  
                                        ref_10.eid as c0, 
                                        ref_2.department_id as c1, 
                                        ref_10.virtual_col as c2, 
                                        ref_10.virtual_col as c3, 
                                        subq_1.c4 as c4
                                      from 
                                        test_bd.products as ref_13
                                      where false)) 
                                  or ((EXISTS (
                                      select  
                                          ref_14.username as c0, 
                                          subq_1.c1 as c1, 
                                          ref_14.id as c2, 
                                          ref_2.eid as c3, 
                                          ref_2.age as c4, 
                                          ref_14.id as c5, 
                                          ref_10.id as c6
                                        from 
                                          test_bd.users as ref_14
                                        where (ref_10.id is NULL) 
                                          and (true)
                                        limit 160)) 
                                    or (false))) 
                                or (EXISTS (
                                  select  
                                      ref_15.user_id as c0, 
                                      ref_10.virtual_col as c1
                                    from 
                                      test_bd.posts as ref_15
                                    where subq_1.c4 is not NULL)))) 
                            and ((true) 
                              or ((EXISTS (
                                  select  
                                      subq_1.c1 as c0
                                    from 
                                      test_bd.user_profiles as ref_16
                                    where false
                                    limit 47)) 
                                or (false))))))
                    limit 103)) 
                and (true)) 
              or (ref_2.salary is NULL)) 
            or (subq_1.c2 is not NULL))) 
        and (EXISTS (
          select  
              ref_17.id as c0, 
              ref_2.email as c1
            from 
              test_bd.comments as ref_17,
              lateral (select  
                    ref_17.comment as c0, 
                    ref_18.id as c1, 
                    ref_17.post_id as c2, 
                    ref_17.id as c3
                  from 
                    test_bd.posts as ref_18
                  where (true) 
                    or (((false) 
                        and ((subq_1.c3 is not NULL) 
                          or (ref_2.eid is NULL))) 
                      and (ref_17.user_id is NULL))
                  limit 86) as subq_3
            where (EXISTS (
                select  
                    subq_3.c2 as c0
                  from 
                    test_bd.user_profiles as ref_19
                  where false)) 
              or (false)
            limit 119)) then subq_1.c2 else subq_1.c2 end
      ) as c3, 
  subq_1.c3 as c4, 
  ref_2.id as c5, 
  ref_2.id as c6, 
  ref_2.eid as c7, 
  case when true then ref_2.department_id else ref_2.department_id end
     as c8, 
  ref_2.years as c9, 
  (select user_id from test_bd.user_profiles limit 1 offset 16)
     as c10, 
  (select comment from test_bd.comments limit 1 offset 2)
     as c11, 
  subq_1.c0 as c12, 
  subq_1.c0 as c13, 
  ref_2.id as c14, 
  ref_2.eid as c15, 
  subq_1.c4 as c16, 
  ref_2.department_id as c17, 
  ref_2.salary as c18, 
  ref_2.department_id as c19, 
  coalesce(case when ((true) 
          or (subq_1.c1 is NULL)) 
        and (subq_1.c1 is NULL) then ref_2.age else ref_2.age end
      ,
    subq_1.c0) as c20, 
  subq_1.c0 as c21, 
  ref_2.age as c22, 
  subq_1.c1 as c23, 
  100 as c24
from 
  (select  
          ref_0.id as c0, 
          ref_0.user_id as c1, 
          subq_0.c0 as c2, 
          subq_0.c2 as c3, 
          ref_0.coordinates as c4
        from 
          test_bd.locations as ref_0,
          lateral (select  
                ref_0.name as c0, 
                ref_0.id as c1, 
                ref_0.coordinates as c2
              from 
                test_bd.user_post_comments as ref_1
              where (ref_0.id is NULL) 
                or (false)
              limit 161) as subq_0
        where subq_0.c1 is not NULL) as subq_1
    right join test_bd.employee as ref_2
    on ((((EXISTS (
              select  
                  ref_3.created_at as c0, 
                  ref_2.id as c1, 
                  ref_2.eid as c2, 
                  ref_2.eid as c3, 
                  ref_2.years as c4, 
                  ref_3.username as c5, 
                  ref_3.email as c6, 
                  ref_2.age as c7, 
                  ref_2.years as c8, 
                  ref_2.id as c9, 
                  subq_1.c0 as c10
                from 
                  test_bd.users as ref_3
                where true
                limit 69)) 
            and ((((false) 
                  and ((((EXISTS (
                          select distinct 
                              subq_1.c2 as c0, 
                              subq_1.c2 as c1, 
                              ref_2.hire_date as c2, 
                              subq_1.c0 as c3, 
                              ref_2.id as c4, 
                              ref_2.eid as c5
                            from 
                              test_bd.users as ref_4
                            where EXISTS (
                              select  
                                  53 as c0
                                from 
                                  test_bd.eids as ref_5
                                where ((false) 
                                    or (false)) 
                                  and ((true) 
                                    or (((true) 
                                        and ((true) 
                                          and ((ref_4.created_at is not NULL) 
                                            and (EXISTS (
                                              select  
                                                  ref_4.email as c0, 
                                                  ref_5.id as c1, 
                                                  ref_4.id as c2, 
                                                  ref_5.id as c3, 
                                                  subq_1.c2 as c4, 
                                                  ref_2.salary as c5
                                                from 
                                                  test_bd.locations as ref_6
                                                where ((ref_2.eid is NULL) 
                                                    and ((false) 
                                                      or ((false) 
                                                        or (true)))) 
                                                  and (subq_1.c1 is NULL)
                                                limit 150))))) 
                                      and ((false) 
                                        and (subq_1.c3 is not NULL))))
                                limit 189))) 
                        and (EXISTS (
                          select  
                              subq_1.c2 as c0, 
                              ref_7.user_id as c1, 
                              ref_7.name as c2, 
                              (select user_id from test_bd.comments limit 1 offset 1)
                                 as c3, 
                              ref_7.name as c4, 
                              ref_2.id as c5
                            from 
                              test_bd.locations as ref_7
                            where (false) 
                              or (true)
                            limit 144))) 
                      or (subq_1.c1 is not NULL)) 
                    and (subq_1.c1 is NULL))) 
                and ((false) 
                  or (false))) 
              and (true))) 
          or (true)) 
        or (ref_2.salary is NULL))
where (false) 
  or (((false) 
      or (((true) 
          or (((((((subq_1.c2 is NULL) 
                      and (subq_1.c4 is NULL)) 
                    and (subq_1.c1 is not NULL)) 
                  or (false)) 
                or (true)) 
              and ((EXISTS (
                  select  
                      ref_20.virtual_col as c0
                    from 
                      test_bd.eids as ref_20
                    where ((select id from test_bd.products limit 1 offset 2)
                           is NULL) 
                      and ((true) 
                        or (((ref_20.eid is not NULL) 
                            and (false)) 
                          and (EXISTS (
                            select  
                                ref_2.years as c0, 
                                ref_2.email as c1, 
                                ref_20.eid as c2, 
                                ref_2.department_id as c3
                              from 
                                test_bd.user_profiles as ref_21
                              where (EXISTS (
                                  select  
                                      subq_1.c2 as c0, 
                                      ref_20.eid as c1, 
                                      ref_2.email as c2, 
                                      ref_21.user_id as c3, 
                                      ref_21.profile_picture as c4, 
                                      ref_21.bio as c5, 
                                      ref_2.id as c6, 
                                      ref_2.years as c7, 
                                      ref_21.profile_picture as c8
                                    from 
                                      test_bd.user_post_comments as ref_22
                                    where true
                                    limit 77)) 
                                or (false)))))
                    limit 75)) 
                or (false))) 
            and (87 is NULL))) 
        and (subq_1.c1 is not NULL))) 
    and (subq_1.c3 is NULL))
limit 38;
SHOW profiles;