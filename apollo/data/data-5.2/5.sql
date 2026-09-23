SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c0 as c0, 
  subq_0.c2 as c1, 
  subq_0.c2 as c2, 
  coalesce(subq_0.c1,
    subq_0.c1) as c3, 
  coalesce(case when case when subq_0.c1 is not NULL then subq_0.c2 else subq_0.c2 end
           is not NULL then subq_0.c2 else subq_0.c2 end
      ,
    subq_0.c2) as c4
from 
  (select  
        ref_0.email as c0, 
        ref_0.username as c1, 
        ref_0.created_at as c2
      from 
        test_bd.users as ref_0
      where ref_0.created_at is NULL) as subq_0
where (subq_0.c2 is not NULL) 
  or (EXISTS (
    select  
        ref_1.hire_date as c0
      from 
        test_bd.employee as ref_1
          left join test_bd.products as ref_2
          on (((ref_1.hire_date is not NULL) 
                and (false)) 
              or (false))
      where EXISTS (
        select  
            ref_3.created_at as c0, 
            ref_3.user_id as c1
          from 
            test_bd.posts as ref_3
              left join test_bd.employee as ref_4
              on (ref_3.user_id = ref_4.age )
          where ((ref_3.user_id is not NULL) 
              and (ref_4.eid is not NULL)) 
            or ((EXISTS (
                select  
                    subq_2.c3 as c0
                  from 
                    test_bd.employee as ref_5,
                    lateral (select  
                          ref_6.email as c0
                        from 
                          test_bd.users as ref_6
                        where (ref_5.eid is NULL) 
                          or (ref_2.tags is not NULL)
                        limit 94) as subq_1,
                    lateral (select  
                          ref_5.email as c0, 
                          ref_5.years as c1, 
                          ref_4.hire_date as c2, 
                          ref_2.category as c3, 
                          ref_1.department_id as c4, 
                          ref_7.eid as c5, 
                          ref_2.category as c6
                        from 
                          test_bd.employee as ref_7
                        where ((false) 
                            and (true)) 
                          or (true)
                        limit 113) as subq_2
                  where ref_4.years is not NULL
                  limit 112)) 
              and (EXISTS (
                select  
                    ref_1.id as c0, 
                    ref_8.bio as c1, 
                    subq_0.c2 as c2, 
                    ref_4.department_id as c3, 
                    subq_10.c11 as c4, 
                    ref_3.title as c5
                  from 
                    test_bd.user_profiles as ref_8,
                    lateral (select  
                          ref_4.department_id as c0, 
                          ref_9.virtual_col as c1, 
                          (select created_at from test_bd.posts limit 1 offset 2)
                             as c2, 
                          1 as c3, 
                          ref_9.eid as c4, 
                          ref_4.salary as c5, 
                          ref_2.id as c6, 
                          (select content from test_bd.posts limit 1 offset 6)
                             as c7, 
                          ref_3.user_id as c8, 
                          ref_3.created_at as c9, 
                          ref_9.id as c10, 
                          ref_1.salary as c11, 
                          (select id from test_bd.locations limit 1 offset 4)
                             as c12, 
                          ref_9.virtual_col as c13, 
                          ref_4.id as c14
                        from 
                          test_bd.eids as ref_9
                        where ((false) 
                            or (true)) 
                          and (EXISTS (
                            select  
                                ref_2.tags as c0, 
                                subq_9.c7 as c1, 
                                subq_4.c0 as c2
                              from 
                                test_bd.eids as ref_10,
                                lateral (select  
                                      ref_9.id as c0, 
                                      ref_1.salary as c1, 
                                      subq_0.c2 as c2, 
                                      ref_9.virtual_col as c3
                                    from 
                                      test_bd.eids as ref_11,
                                      lateral (select  
                                            ref_8.user_id as c0, 
                                            ref_1.age as c1, 
                                            ref_12.coordinates as c2, 
                                            ref_8.user_id as c3, 
                                            ref_4.email as c4, 
                                            ref_2.discount as c5, 
                                            subq_0.c0 as c6, 
                                            ref_11.id as c7, 
                                            ref_9.id as c8, 
                                            ref_8.bio as c9, 
                                            ref_2.name as c10, 
                                            ref_8.birthdate as c11, 
                                            ref_8.profile_picture as c12, 
                                            ref_9.id as c13, 
                                            ref_4.eid as c14, 
                                            ref_4.salary as c15, 
                                            ref_2.name as c16, 
                                            (select email from test_bd.users limit 1 offset 6)
                                               as c17, 
                                            ref_1.hire_date as c18, 
                                            (select department_id from test_bd.employee limit 1 offset 6)
                                               as c19, 
                                            subq_0.c0 as c20, 
                                            ref_8.profile_picture as c21, 
                                            ref_1.salary as c22, 
                                            ref_11.eid as c23, 
                                            ref_9.id as c24, 
                                            ref_11.virtual_col as c25, 
                                            (select bio from test_bd.user_profiles limit 1 offset 5)
                                               as c26, 
                                            ref_2.tags as c27, 
                                            ref_3.updated_at as c28, 
                                            ref_12.user_id as c29, 
                                            ref_2.id as c30, 
                                            ref_11.id as c31
                                          from 
                                            test_bd.locations as ref_12
                                          where (ref_1.salary is NULL) 
                                            or (false)
                                          limit 105) as subq_3
                                    where (false) 
                                      or (((true) 
                                          and (false)) 
                                        and (ref_11.id is not NULL))
                                    limit 87) as subq_4,
                                lateral (select  
                                      ref_4.hire_date as c0, 
                                      ref_9.virtual_col as c1
                                    from 
                                      test_bd.posts as ref_13,
                                      lateral (select  
                                            ref_13.user_id as c0, 
                                            ref_4.email as c1, 
                                            ref_10.virtual_col as c2
                                          from 
                                            test_bd.posts as ref_14
                                          where 31 is NULL
                                          limit 151) as subq_5,
                                      lateral (select  
                                            ref_2.tags as c0, 
                                            ref_4.eid as c1, 
                                            ref_15.tags as c2, 
                                            ref_1.department_id as c3, 
                                            ref_8.bio as c4, 
                                            ref_1.department_id as c5, 
                                            (select title from test_bd.user_post_comments limit 1 offset 1)
                                               as c6, 
                                            ref_15.price as c7, 
                                            subq_0.c0 as c8, 
                                            ref_9.id as c9, 
                                            ref_4.years as c10, 
                                            subq_5.c0 as c11, 
                                            ref_8.profile_picture as c12, 
                                            ref_1.age as c13, 
                                            ref_8.bio as c14, 
                                            subq_0.c1 as c15, 
                                            ref_15.id as c16, 
                                            subq_0.c1 as c17, 
                                            ref_4.department_id as c18, 
                                            ref_13.user_id as c19
                                          from 
                                            test_bd.products as ref_15
                                          where (false) 
                                            or (ref_4.email is not NULL)) as subq_6
                                    where ((true) 
                                        and (true)) 
                                      or (ref_4.email is not NULL)
                                    limit 59) as subq_7,
                                lateral (select  
                                      ref_3.created_at as c0, 
                                      70 as c1, 
                                      ref_1.id as c2, 
                                      ref_16.created_at as c3, 
                                      ref_4.department_id as c4, 
                                      (select discount from test_bd.products limit 1 offset 5)
                                         as c5, 
                                      ref_16.id as c6, 
                                      ref_4.eid as c7, 
                                      subq_4.c1 as c8, 
                                      subq_4.c0 as c9
                                    from 
                                      test_bd.posts as ref_16,
                                      lateral (select  
                                            ref_1.department_id as c0, 
                                            subq_4.c3 as c1, 
                                            ref_17.content as c2, 
                                            ref_9.id as c3, 
                                            ref_9.eid as c4, 
                                            ref_16.user_id as c5
                                          from 
                                            test_bd.posts as ref_17
                                          where true) as subq_8
                                    where ref_8.bio is NULL
                                    limit 60) as subq_9
                              where (EXISTS (
                                  select  
                                      ref_10.virtual_col as c0
                                    from 
                                      test_bd.products as ref_18
                                    where false
                                    limit 156)) 
                                or (true)
                              limit 127))) as subq_10
                  where true)))
          limit 96)
      limit 90))
limit 75;
SHOW profiles;