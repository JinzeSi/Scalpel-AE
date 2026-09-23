SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_0.c6 as c0, 
  subq_0.c1 as c1, 
  subq_9.c0 as c2, 
  subq_9.c0 as c3, 
  subq_0.c4 as c4
from 
  (select  
        ref_0.username as c0, 
        7 as c1, 
        ref_0.username as c2, 
        ref_0.title as c3, 
        ref_0.username as c4, 
        (select eid from test_bd.eids limit 1 offset 73)
           as c5, 
        ref_0.comment as c6
      from 
        test_bd.user_post_comments as ref_0
      where ((ref_0.username is NULL) 
          or ((46 is not NULL) 
            and ((ref_0.title is NULL) 
              and (true)))) 
        or ((ref_0.title is not NULL) 
          and ((EXISTS (
              select  
                  ref_1.id as c0, 
                  ref_1.user_id as c1, 
                  ref_1.id as c2
                from 
                  test_bd.comments as ref_1
                where ((ref_1.user_id is not NULL) 
                    or (false)) 
                  and (false))) 
            or (EXISTS (
              select  
                  ref_0.username as c0, 
                  (select name from test_bd.locations limit 1 offset 1)
                     as c1, 
                  ref_0.username as c2, 
                  ref_0.username as c3, 
                  ref_2.id as c4, 
                  ref_2.id as c5, 
                  ref_2.content as c6, 
                  ref_0.username as c7, 
                  ref_0.username as c8, 
                  ref_0.comment as c9, 
                  ref_0.username as c10, 
                  ref_0.title as c11, 
                  ref_0.username as c12, 
                  ref_2.user_id as c13
                from 
                  test_bd.posts as ref_2
                where (ref_0.title is not NULL) 
                  and (ref_0.title is not NULL)
                limit 98))))
      limit 94) as subq_0,
  lateral (select  
        ref_5.email as c0
      from 
        test_bd.user_profiles as ref_3
              right join test_bd.locations as ref_4
                inner join test_bd.users as ref_5
                on ((EXISTS (
                      select  
                          ref_5.email as c0, 
                          ref_4.user_id as c1, 
                          ref_6.name as c2
                        from 
                          test_bd.locations as ref_6
                        where ((true) 
                            or (false)) 
                          or (true)
                        limit 111)) 
                    and (((true) 
                        and ((ref_5.id is NULL) 
                          and (false))) 
                      or (((true) 
                          and (false)) 
                        or (EXISTS (
                          select  
                              ref_4.name as c0, 
                              ref_4.name as c1, 
                              subq_0.c4 as c2
                            from 
                              test_bd.users as ref_7
                            where true)))))
              on (ref_3.bio is NULL)
            inner join test_bd.locations as ref_8
            on (ref_4.id = ref_8.id )
          inner join test_bd.employee as ref_9
          on (((true) 
                or (true)) 
              or (EXISTS (
                select  
                    subq_0.c3 as c0, 
                    ref_9.hire_date as c1, 
                    (select username from test_bd.user_post_comments limit 1 offset 2)
                       as c2, 
                    subq_0.c5 as c3, 
                    ref_9.email as c4, 
                    ref_5.created_at as c5, 
                    ref_5.username as c6, 
                    (select title from test_bd.user_post_comments limit 1 offset 3)
                       as c7, 
                    ref_9.email as c8
                  from 
                    test_bd.locations as ref_10
                  where false
                  limit 96))),
        lateral (select  
              subq_0.c6 as c0
            from 
              test_bd.user_post_comments as ref_11
            where EXISTS (
              select  
                  subq_7.c6 as c0, 
                  ref_5.created_at as c1, 
                  ref_8.id as c2, 
                  ref_8.coordinates as c3, 
                  ref_12.age as c4, 
                  ref_3.user_id as c5, 
                  ref_4.id as c6, 
                  ref_4.coordinates as c7
                from 
                  test_bd.employee as ref_12,
                  lateral (select  
                        subq_1.c5 as c0, 
                        ref_4.user_id as c1, 
                        ref_12.id as c2, 
                        ref_4.user_id as c3, 
                        ref_8.coordinates as c4, 
                        ref_11.comment as c5, 
                        ref_8.user_id as c6, 
                        ref_12.salary as c7, 
                        (select comment from test_bd.comments limit 1 offset 1)
                           as c8, 
                        ref_11.username as c9, 
                        ref_13.created_at as c10
                      from 
                        test_bd.comments as ref_13,
                        lateral (select  
                              ref_5.email as c0, 
                              52 as c1, 
                              ref_9.email as c2, 
                              ref_9.hire_date as c3, 
                              ref_9.years as c4, 
                              ref_13.user_id as c5, 
                              (select birthdate from test_bd.user_profiles limit 1 offset 1)
                                 as c6, 
                              ref_5.id as c7
                            from 
                              test_bd.employee as ref_14
                            where ref_14.years is NULL
                            limit 74) as subq_1,
                        lateral (select  
                              ref_4.id as c0, 
                              subq_0.c5 as c1, 
                              ref_15.comment as c2, 
                              ref_5.username as c3, 
                              ref_9.id as c4, 
                              ref_4.user_id as c5
                            from 
                              test_bd.comments as ref_15,
                              lateral (select  
                                    ref_9.years as c0, 
                                    ref_16.comment as c1, 
                                    ref_8.name as c2, 
                                    ref_13.id as c3, 
                                    ref_15.post_id as c4, 
                                    subq_1.c5 as c5, 
                                    ref_8.id as c6, 
                                    ref_16.title as c7
                                  from 
                                    test_bd.user_post_comments as ref_16
                                  where false) as subq_2
                            where true) as subq_3
                      where ((((ref_9.id is NULL) 
                              and (ref_11.username is not NULL)) 
                            and (true)) 
                          or (((subq_3.c1 is NULL) 
                              and ((false) 
                                and ((true) 
                                  and ((ref_13.user_id is not NULL) 
                                    or (ref_5.id is NULL))))) 
                            and (92 is NULL))) 
                        or ((((false) 
                              and ((EXISTS (
                                  select  
                                      ref_3.bio as c0, 
                                      subq_1.c7 as c1, 
                                      ref_12.id as c2, 
                                      ref_12.email as c3
                                    from 
                                      test_bd.comments as ref_17,
                                      lateral (select  
                                            ref_4.name as c0, 
                                            subq_0.c2 as c1
                                          from 
                                            test_bd.user_post_comments as ref_18
                                          where true
                                          limit 61) as subq_4
                                    where (true) 
                                      or (((EXISTS (
                                            select  
                                                ref_3.bio as c0
                                              from 
                                                test_bd.user_post_comments as ref_19,
                                                lateral (select  
                                                      48 as c0, 
                                                      ref_11.comment as c1
                                                    from 
                                                      test_bd.products as ref_20
                                                    where (false) 
                                                      and (false)
                                                    limit 70) as subq_5,
                                                lateral (select  
                                                      98 as c0, 
                                                      ref_13.post_id as c1
                                                    from 
                                                      test_bd.users as ref_21
                                                    where (select name from test_bd.locations limit 1 offset 5)
                                                         is not NULL
                                                    limit 104) as subq_6
                                              where (true) 
                                                or (false)
                                              limit 95)) 
                                          and ((88 is NULL) 
                                            or ((true) 
                                              or (true)))) 
                                        or (true))
                                    limit 76)) 
                                and (false))) 
                            and (subq_0.c4 is NULL)) 
                          or (false))
                      limit 113) as subq_7
                where (true) 
                  and (((EXISTS (
                        select  
                            ref_12.salary as c0, 
                            ref_9.id as c1, 
                            ref_5.username as c2, 
                            ref_8.name as c3, 
                            ref_8.coordinates as c4, 
                            subq_7.c5 as c5, 
                            ref_4.id as c6, 
                            subq_7.c4 as c7, 
                            ref_5.id as c8, 
                            ref_8.id as c9, 
                            subq_0.c0 as c10, 
                            (select department_id from test_bd.employee limit 1 offset 5)
                               as c11, 
                            ref_12.hire_date as c12, 
                            ref_9.salary as c13, 
                            ref_22.virtual_col as c14, 
                            ref_3.profile_picture as c15, 
                            ref_3.birthdate as c16, 
                            ref_3.profile_picture as c17, 
                            ref_3.bio as c18, 
                            61 as c19, 
                            ref_4.name as c20, 
                            ref_22.eid as c21, 
                            ref_5.username as c22
                          from 
                            test_bd.eids as ref_22
                          where (select title from test_bd.user_post_comments limit 1 offset 76)
                               is not NULL
                          limit 152)) 
                      or (false)) 
                    or (ref_9.email is not NULL))
                limit 163)
            limit 84) as subq_8
      where (ref_3.profile_picture is not NULL) 
        and (((ref_4.id is not NULL) 
            or (ref_9.department_id is NULL)) 
          and (EXISTS (
            select  
                ref_8.user_id as c0
              from 
                test_bd.user_profiles as ref_23
              where (false) 
                or (ref_8.user_id is NULL)
              limit 117)))
      limit 113) as subq_9
where (subq_0.c0 is not NULL) 
  or (case when false then subq_9.c0 else subq_9.c0 end
       is NULL);
SHOW profiles;