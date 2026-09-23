SET profiling=1;
EXPLAIN ANALYZE
select  
  case when ref_0.name is NULL then case when case when EXISTS (
            select  
                ref_0.user_id as c0, 
                ref_4.user_id as c1, 
                ref_4.id as c2, 
                ref_3.eid as c3, 
                ref_4.user_id as c4, 
                ref_0.coordinates as c5, 
                ref_4.coordinates as c6, 
                ref_3.eid as c7, 
                ref_4.user_id as c8, 
                ref_3.virtual_col as c9, 
                ref_0.id as c10, 
                subq_1.c0 as c11
              from 
                test_bd.eids as ref_3
                  inner join test_bd.locations as ref_4
                  on ((EXISTS (
                        select  
                            ref_3.virtual_col as c0, 
                            ref_3.eid as c1, 
                            ref_4.user_id as c2, 
                            subq_1.c0 as c3, 
                            ref_0.id as c4, 
                            ref_0.user_id as c5, 
                            ref_0.coordinates as c6, 
                            ref_4.id as c7, 
                            subq_1.c0 as c8, 
                            (select content from test_bd.posts limit 1 offset 3)
                               as c9, 
                            ref_3.id as c10, 
                            ref_3.eid as c11, 
                            ref_0.user_id as c12, 
                            ref_5.user_id as c13, 
                            ref_0.name as c14, 
                            ref_0.coordinates as c15, 
                            ref_4.id as c16, 
                            ref_5.coordinates as c17, 
                            subq_1.c0 as c18, 
                            subq_1.c0 as c19, 
                            ref_5.name as c20, 
                            88 as c21, 
                            ref_3.virtual_col as c22, 
                            ref_0.user_id as c23, 
                            ref_0.user_id as c24, 
                            ref_4.id as c25
                          from 
                            test_bd.locations as ref_5
                          where (true) 
                            and ((false) 
                              and (ref_3.eid is NULL))
                          limit 139)) 
                      or (subq_1.c0 is NULL))
              where ref_4.name is not NULL
              limit 135) then subq_1.c0 else subq_1.c0 end
           is not NULL then subq_1.c0 else subq_1.c0 end
       else case when case when EXISTS (
            select  
                ref_0.user_id as c0, 
                ref_4.user_id as c1, 
                ref_4.id as c2, 
                ref_3.eid as c3, 
                ref_4.user_id as c4, 
                ref_0.coordinates as c5, 
                ref_4.coordinates as c6, 
                ref_3.eid as c7, 
                ref_4.user_id as c8, 
                ref_3.virtual_col as c9, 
                ref_0.id as c10, 
                subq_1.c0 as c11
              from 
                test_bd.eids as ref_3
                  inner join test_bd.locations as ref_4
                  on ((EXISTS (
                        select  
                            ref_3.virtual_col as c0, 
                            ref_3.eid as c1, 
                            ref_4.user_id as c2, 
                            subq_1.c0 as c3, 
                            ref_0.id as c4, 
                            ref_0.user_id as c5, 
                            ref_0.coordinates as c6, 
                            ref_4.id as c7, 
                            subq_1.c0 as c8, 
                            (select content from test_bd.posts limit 1 offset 3)
                               as c9, 
                            ref_3.id as c10, 
                            ref_3.eid as c11, 
                            ref_0.user_id as c12, 
                            ref_5.user_id as c13, 
                            ref_0.name as c14, 
                            ref_0.coordinates as c15, 
                            ref_4.id as c16, 
                            ref_5.coordinates as c17, 
                            subq_1.c0 as c18, 
                            subq_1.c0 as c19, 
                            ref_5.name as c20, 
                            88 as c21, 
                            ref_3.virtual_col as c22, 
                            ref_0.user_id as c23, 
                            ref_0.user_id as c24, 
                            ref_4.id as c25
                          from 
                            test_bd.locations as ref_5
                          where (true) 
                            and ((false) 
                              and (ref_3.eid is NULL))
                          limit 139)) 
                      or (subq_1.c0 is NULL))
              where ref_4.name is not NULL
              limit 135) then subq_1.c0 else subq_1.c0 end
           is not NULL then subq_1.c0 else subq_1.c0 end
       end
     as c0, 
  subq_1.c0 as c1, 
  ref_0.coordinates as c2, 
  case when EXISTS (
      select  
          ref_6.title as c0
        from 
          test_bd.user_post_comments as ref_6
        where true
        limit 64) then case when false then 6 else 6 end
       else case when false then 6 else 6 end
       end
     as c3, 
  12 as c4, 
  (select name from test_bd.locations limit 1 offset 5)
     as c5, 
  subq_1.c0 as c6, 
  87 as c7, 
  coalesce(case when ((subq_1.c0 is not NULL) 
          and (((ref_0.id is not NULL) 
              or (EXISTS (
                select  
                    ref_0.user_id as c0, 
                    ref_7.comment as c1, 
                    ref_7.id as c2, 
                    ref_0.id as c3, 
                    subq_1.c0 as c4, 
                    subq_1.c0 as c5, 
                    subq_1.c0 as c6, 
                    (select user_id from test_bd.user_profiles limit 1 offset 1)
                       as c7, 
                    subq_2.c4 as c8, 
                    ref_0.id as c9
                  from 
                    test_bd.comments as ref_7,
                    lateral (select  
                          ref_0.user_id as c0, 
                          subq_1.c0 as c1, 
                          ref_7.created_at as c2, 
                          ref_7.id as c3, 
                          subq_1.c0 as c4, 
                          ref_0.coordinates as c5, 
                          ref_8.name as c6
                        from 
                          test_bd.locations as ref_8
                        where (EXISTS (
                            select  
                                ref_8.id as c0, 
                                ref_0.user_id as c1, 
                                ref_9.created_at as c2, 
                                (select id from test_bd.comments limit 1 offset 1)
                                   as c3, 
                                ref_8.coordinates as c4, 
                                ref_8.name as c5, 
                                66 as c6
                              from 
                                test_bd.users as ref_9
                              where ((false) 
                                  and (EXISTS (
                                    select  
                                        ref_9.created_at as c0
                                      from 
                                        test_bd.locations as ref_10
                                      where subq_1.c0 is not NULL
                                      limit 99))) 
                                or (false)
                              limit 86)) 
                          and (((ref_7.user_id is NULL) 
                              and (true)) 
                            or (EXISTS (
                              select  
                                  ref_8.coordinates as c0, 
                                  ref_8.user_id as c1, 
                                  ref_11.eid as c2, 
                                  (select email from test_bd.users limit 1 offset 4)
                                     as c3, 
                                  subq_1.c0 as c4, 
                                  subq_1.c0 as c5
                                from 
                                  test_bd.employee as ref_11
                                where ((EXISTS (
                                      select  
                                          ref_7.user_id as c0
                                        from 
                                          test_bd.posts as ref_12
                                        where false)) 
                                    and (true)) 
                                  and ((false) 
                                    or (((true) 
                                        or ((ref_8.id is not NULL) 
                                          or ((true) 
                                            and (true)))) 
                                      or (EXISTS (
                                        select  
                                            subq_1.c0 as c0, 
                                            ref_0.name as c1, 
                                            ref_0.coordinates as c2, 
                                            ref_11.salary as c3, 
                                            (select id from test_bd.comments limit 1 offset 2)
                                               as c4, 
                                            ref_11.email as c5, 
                                            ref_0.name as c6, 
                                            (select id from test_bd.locations limit 1 offset 2)
                                               as c7, 
                                            subq_1.c0 as c8, 
                                            ref_0.id as c9, 
                                            subq_1.c0 as c10
                                          from 
                                            test_bd.products as ref_13
                                          where (EXISTS (
                                              select  
                                                  subq_1.c0 as c0, 
                                                  ref_8.user_id as c1, 
                                                  ref_7.id as c2, 
                                                  (select eid from test_bd.eids limit 1 offset 5)
                                                     as c3, 
                                                  ref_11.email as c4, 
                                                  ref_11.id as c5, 
                                                  ref_0.user_id as c6, 
                                                  ref_0.id as c7, 
                                                  ref_8.id as c8, 
                                                  ref_0.name as c9, 
                                                  ref_11.id as c10, 
                                                  ref_14.eid as c11, 
                                                  ref_7.post_id as c12, 
                                                  ref_11.years as c13, 
                                                  ref_13.tags as c14, 
                                                  ref_11.hire_date as c15, 
                                                  ref_0.user_id as c16, 
                                                  ref_13.name as c17, 
                                                  subq_1.c0 as c18
                                                from 
                                                  test_bd.eids as ref_14
                                                where (38 is NULL) 
                                                  or (false))) 
                                            and (false)))))
                                limit 76)))
                        limit 99) as subq_2
                  where false
                  limit 88))) 
            or (EXISTS (
              select  
                  subq_1.c0 as c0, 
                  subq_1.c0 as c1, 
                  ref_0.coordinates as c2
                from 
                  test_bd.employee as ref_15
                where (ref_15.age is NULL) 
                  or ((EXISTS (
                      select  
                          ref_0.name as c0, 
                          subq_1.c0 as c1, 
                          ref_0.id as c2, 
                          32 as c3, 
                          ref_0.name as c4, 
                          ref_0.id as c5, 
                          subq_1.c0 as c6, 
                          subq_1.c0 as c7, 
                          ref_15.email as c8, 
                          subq_1.c0 as c9, 
                          subq_1.c0 as c10, 
                          ref_15.eid as c11, 
                          ref_15.hire_date as c12, 
                          ref_15.id as c13, 
                          subq_1.c0 as c14, 
                          ref_15.id as c15
                        from 
                          test_bd.user_post_comments as ref_16
                        where false)) 
                    and ((true) 
                      and (ref_0.id is not NULL)))
                limit 76)))) 
        and ((select username from test_bd.user_post_comments limit 1 offset 3)
             is NULL) then subq_1.c0 else subq_1.c0 end
      ,
    ref_0.id) as c8, 
  ref_0.id as c9, 
  ref_0.name as c10, 
  ref_0.id as c11, 
  subq_1.c0 as c12, 
  ref_0.id as c13, 
  ref_0.coordinates as c14, 
  ref_0.user_id as c15
from 
  test_bd.locations as ref_0,
  lateral (select  
        ref_0.id as c0
      from 
        test_bd.eids as ref_1,
        lateral (select  
              ref_0.user_id as c0, 
              ref_1.virtual_col as c1, 
              ref_0.name as c2
            from 
              test_bd.users as ref_2
            where ref_0.id is NULL
            limit 122) as subq_0
      where (false) 
        and ((ref_0.name is NULL) 
          or (false))
      limit 85) as subq_1
where (((((ref_0.user_id is not NULL) 
          or (((false) 
              or (((((((((true) 
                              and (subq_1.c0 is not NULL)) 
                            and (true)) 
                          or (EXISTS (
                            select  
                                ref_17.comment as c0, 
                                subq_1.c0 as c1, 
                                subq_1.c0 as c2, 
                                ref_0.user_id as c3, 
                                ref_17.title as c4, 
                                ref_17.username as c5, 
                                subq_1.c0 as c6, 
                                ref_17.comment as c7, 
                                ref_0.name as c8, 
                                (select salary from test_bd.employee limit 1 offset 4)
                                   as c9, 
                                ref_0.id as c10, 
                                ref_0.user_id as c11, 
                                ref_0.id as c12, 
                                ref_17.comment as c13, 
                                ref_17.title as c14, 
                                50 as c15, 
                                subq_1.c0 as c16
                              from 
                                test_bd.user_post_comments as ref_17
                              where false
                              limit 29))) 
                        and (((EXISTS (
                              select  
                                  92 as c0
                                from 
                                  test_bd.products as ref_18
                                where true
                                limit 100)) 
                            and (EXISTS (
                              select  
                                  subq_1.c0 as c0, 
                                  subq_1.c0 as c1, 
                                  subq_1.c0 as c2, 
                                  subq_1.c0 as c3, 
                                  ref_19.years as c4, 
                                  ref_0.user_id as c5, 
                                  94 as c6, 
                                  95 as c7, 
                                  ref_19.years as c8, 
                                  ref_19.id as c9, 
                                  ref_19.age as c10, 
                                  ref_19.eid as c11, 
                                  ref_0.user_id as c12, 
                                  ref_0.id as c13, 
                                  ref_0.coordinates as c14, 
                                  ref_0.user_id as c15, 
                                  subq_1.c0 as c16, 
                                  ref_0.id as c17, 
                                  ref_0.id as c18, 
                                  ref_0.coordinates as c19, 
                                  ref_19.age as c20, 
                                  subq_1.c0 as c21, 
                                  ref_0.id as c22, 
                                  ref_19.department_id as c23, 
                                  ref_19.eid as c24, 
                                  subq_1.c0 as c25, 
                                  ref_0.user_id as c26, 
                                  ref_19.eid as c27, 
                                  ref_19.department_id as c28, 
                                  subq_1.c0 as c29, 
                                  ref_19.id as c30
                                from 
                                  test_bd.employee as ref_19
                                where ref_19.years is not NULL
                                limit 148))) 
                          and (false))) 
                      and (EXISTS (
                        select  
                            subq_1.c0 as c0, 
                            ref_0.coordinates as c1, 
                            ref_20.eid as c2
                          from 
                            test_bd.eids as ref_20
                          where EXISTS (
                            select  
                                ref_21.virtual_col as c0, 
                                ref_0.name as c1
                              from 
                                test_bd.eids as ref_21
                              where ref_0.id is not NULL
                              limit 105)
                          limit 87))) 
                    or ((false) 
                      and (((false) 
                          and (false)) 
                        or (ref_0.coordinates is NULL)))) 
                  or (((true) 
                      and ((ref_0.id is not NULL) 
                        and ((((ref_0.id is not NULL) 
                              and (true)) 
                            and (EXISTS (
                              select  
                                  ref_0.id as c0, 
                                  subq_1.c0 as c1, 
                                  subq_1.c0 as c2, 
                                  ref_0.id as c3, 
                                  ref_0.name as c4
                                from 
                                  test_bd.eids as ref_22
                                where (false) 
                                  and ((false) 
                                    or (ref_0.name is NULL))
                                limit 117))) 
                          and (subq_1.c0 is NULL)))) 
                    and (true))) 
                and ((EXISTS (
                    select  
                        ref_23.updated_at as c0, 
                        ref_0.id as c1, 
                        ref_23.title as c2, 
                        ref_23.created_at as c3
                      from 
                        test_bd.posts as ref_23
                      where EXISTS (
                        select  
                            ref_0.user_id as c0, 
                            2 as c1, 
                            ref_0.name as c2, 
                            ref_0.name as c3, 
                            subq_3.c2 as c4
                          from 
                            test_bd.user_profiles as ref_24,
                            lateral (select  
                                  89 as c0, 
                                  ref_0.coordinates as c1, 
                                  ref_25.user_id as c2, 
                                  ref_24.birthdate as c3, 
                                  ref_23.user_id as c4
                                from 
                                  test_bd.locations as ref_25
                                where (EXISTS (
                                    select  
                                        ref_0.id as c0, 
                                        62 as c1, 
                                        ref_25.user_id as c2, 
                                        ref_24.bio as c3, 
                                        subq_1.c0 as c4, 
                                        ref_23.created_at as c5, 
                                        ref_25.user_id as c6, 
                                        ref_0.coordinates as c7
                                      from 
                                        test_bd.comments as ref_26
                                      where true
                                      limit 122)) 
                                  and ((select department_id from test_bd.employee limit 1 offset 5)
                                       is NULL)) as subq_3,
                            lateral (select  
                                  subq_1.c0 as c0, 
                                  subq_5.c6 as c1, 
                                  ref_23.content as c2, 
                                  ref_0.coordinates as c3
                                from 
                                  test_bd.user_profiles as ref_27,
                                  lateral (select  
                                        ref_27.birthdate as c0, 
                                        ref_28.discount as c1, 
                                        ref_24.bio as c2, 
                                        (select user_id from test_bd.comments limit 1 offset 4)
                                           as c3, 
                                        (select title from test_bd.user_post_comments limit 1 offset 6)
                                           as c4, 
                                        ref_23.content as c5, 
                                        subq_1.c0 as c6, 
                                        ref_24.user_id as c7, 
                                        ref_23.title as c8, 
                                        subq_1.c0 as c9, 
                                        ref_28.price as c10, 
                                        ref_24.birthdate as c11, 
                                        ref_27.birthdate as c12, 
                                        ref_23.id as c13
                                      from 
                                        test_bd.products as ref_28
                                      where (false) 
                                        or ((EXISTS (
                                            select  
                                                ref_24.profile_picture as c0, 
                                                ref_24.bio as c1, 
                                                ref_27.user_id as c2, 
                                                (select comment from test_bd.comments limit 1 offset 6)
                                                   as c3, 
                                                (select eid from test_bd.eids limit 1 offset 2)
                                                   as c4, 
                                                subq_3.c1 as c5, 
                                                ref_29.id as c6, 
                                                ref_28.name as c7, 
                                                ref_0.user_id as c8, 
                                                ref_27.user_id as c9, 
                                                ref_28.discount as c10, 
                                                subq_3.c3 as c11, 
                                                subq_4.c0 as c12, 
                                                (select title from test_bd.user_post_comments limit 1 offset 5)
                                                   as c13, 
                                                ref_27.user_id as c14, 
                                                subq_3.c0 as c15, 
                                                ref_27.birthdate as c16
                                              from 
                                                test_bd.users as ref_29,
                                                lateral (select  
                                                      ref_24.user_id as c0, 
                                                      subq_3.c4 as c1
                                                    from 
                                                      test_bd.employee as ref_30
                                                    where ref_28.tags is not NULL
                                                    limit 118) as subq_4
                                              where ref_23.created_at is NULL)) 
                                          or ((true) 
                                            or (true)))
                                      limit 61) as subq_5
                                where true
                                limit 27) as subq_6
                          where false
                          limit 87)
                      limit 53)) 
                  and (((false) 
                      or (ref_0.user_id is NULL)) 
                    or (true))))) 
            or (ref_0.name is not NULL))) 
        and (false)) 
      and (subq_1.c0 is not NULL)) 
    or ((ref_0.user_id is NULL) 
      or (subq_1.c0 is NULL))) 
  and ((EXISTS (
      select  
          ref_0.coordinates as c0, 
          ref_0.user_id as c1, 
          ref_0.coordinates as c2, 
          ref_31.id as c3, 
          ref_31.created_at as c4, 
          67 as c5, 
          ref_31.username as c6, 
          48 as c7, 
          8 as c8, 
          ref_0.id as c9, 
          ref_31.username as c10
        from 
          test_bd.users as ref_31
        where subq_1.c0 is not NULL
        limit 88)) 
    and (ref_0.user_id is NULL))
limit 143;
SHOW profiles;