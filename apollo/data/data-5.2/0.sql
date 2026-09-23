SET profiling=1;
EXPLAIN ANALYZE
select  
  case when (EXISTS (
        select  
            subq_5.c4 as c0, 
            subq_4.c0 as c1, 
            48 as c2, 
            3 as c3, 
            ref_11.email as c4, 
            subq_4.c0 as c5, 
            subq_4.c5 as c6, 
            subq_4.c5 as c7, 
            ref_11.id as c8, 
            50 as c9, 
            ref_11.id as c10, 
            ref_11.id as c11, 
            subq_5.c5 as c12
          from 
            test_bd.users as ref_11,
            lateral (select  
                  ref_11.id as c0, 
                  ref_11.username as c1, 
                  83 as c2, 
                  subq_4.c5 as c3, 
                  subq_4.c0 as c4, 
                  ref_11.username as c5, 
                  ref_12.email as c6, 
                  46 as c7, 
                  ref_12.email as c8, 
                  subq_4.c2 as c9, 
                  subq_4.c3 as c10, 
                  ref_11.username as c11, 
                  ref_12.email as c12, 
                  subq_4.c4 as c13, 
                  ref_11.id as c14, 
                  98 as c15, 
                  ref_11.email as c16
                from 
                  test_bd.users as ref_12
                where subq_4.c5 is NULL) as subq_5
          where true
          limit 70)) 
      and (((subq_4.c3 is not NULL) 
          and (false)) 
        and ((subq_4.c1 is not NULL) 
          or ((true) 
            and (subq_4.c5 is NULL)))) then subq_4.c3 else subq_4.c3 end
     as c0, 
  case when false then subq_4.c0 else subq_4.c0 end
     as c1, 
  subq_4.c3 as c2, 
  subq_4.c0 as c3, 
  subq_4.c3 as c4, 
  subq_4.c5 as c5, 
  subq_4.c4 as c6, 
  subq_4.c0 as c7
from 
  (select  
        case when EXISTS (
            select  
                ref_1.created_at as c0, 
                ref_0.user_id as c1, 
                25 as c2, 
                ref_1.created_at as c3, 
                ref_1.id as c4, 
                ref_0.content as c5, 
                (select username from test_bd.users limit 1 offset 6)
                   as c6, 
                ref_0.content as c7, 
                ref_1.email as c8, 
                ref_0.updated_at as c9
              from 
                test_bd.users as ref_1
              where (((((select username from test_bd.users limit 1 offset 4)
                           is not NULL) 
                      or (((((ref_1.username is not NULL) 
                              or (false)) 
                            or ((EXISTS (
                                select  
                                    (select comment from test_bd.user_post_comments limit 1 offset 9)
                                       as c0, 
                                    ref_0.created_at as c1, 
                                    ref_2.username as c2
                                  from 
                                    test_bd.users as ref_2
                                  where false
                                  limit 80)) 
                              and (false))) 
                          and ((false) 
                            or (ref_1.id is not NULL))) 
                        or (false))) 
                    and (((ref_0.created_at is NULL) 
                        and (((false) 
                            and (true)) 
                          or (EXISTS (
                            select  
                                ref_0.created_at as c0, 
                                ref_0.updated_at as c1, 
                                ref_0.created_at as c2
                              from 
                                test_bd.user_post_comments as ref_3
                              where true)))) 
                      or (ref_0.created_at is NULL))) 
                  and (EXISTS (
                    select  
                        ref_4.profile_picture as c0, 
                        ref_0.created_at as c1, 
                        (select content from test_bd.posts limit 1 offset 3)
                           as c2, 
                        ref_4.profile_picture as c3
                      from 
                        test_bd.user_profiles as ref_4
                      where (true) 
                        and (ref_4.profile_picture is not NULL)
                      limit 151))) 
                or ((ref_0.title is not NULL) 
                  or ((((EXISTS (
                          select  
                              ref_0.updated_at as c0, 
                              ref_1.username as c1
                            from 
                              test_bd.user_profiles as ref_5
                            where ref_1.email is NULL)) 
                        and ((true) 
                          or ((true) 
                            or (false)))) 
                      and ((ref_1.email is NULL) 
                        and (((ref_0.updated_at is NULL) 
                            and (((EXISTS (
                                  select  
                                      ref_0.title as c0, 
                                      ref_6.id as c1, 
                                      (select age from test_bd.employee limit 1 offset 1)
                                         as c2, 
                                      ref_6.created_at as c3, 
                                      ref_0.user_id as c4, 
                                      ref_1.username as c5, 
                                      ref_1.created_at as c6
                                    from 
                                      test_bd.products as ref_6,
                                      lateral (select  
                                            31 as c0
                                          from 
                                            test_bd.user_post_comments as ref_7
                                          where (false) 
                                            or (ref_6.category is NULL)) as subq_0,
                                      lateral (select  
                                            6 as c0, 
                                            subq_2.c0 as c1, 
                                            ref_1.email as c2, 
                                            ref_8.virtual_col as c3, 
                                            subq_2.c5 as c4, 
                                            subq_0.c0 as c5, 
                                            subq_2.c6 as c6, 
                                            subq_0.c0 as c7
                                          from 
                                            test_bd.eids as ref_8,
                                            lateral (select  
                                                  ref_0.created_at as c0, 
                                                  ref_8.eid as c1
                                                from 
                                                  test_bd.employee as ref_9
                                                where true
                                                limit 142) as subq_1,
                                            lateral (select  
                                                  ref_1.email as c0, 
                                                  ref_1.email as c1, 
                                                  ref_10.username as c2, 
                                                  ref_10.id as c3, 
                                                  ref_8.eid as c4, 
                                                  ref_0.created_at as c5, 
                                                  ref_6.created_at as c6
                                                from 
                                                  test_bd.users as ref_10
                                                where (subq_1.c1 is not NULL) 
                                                  and (ref_1.username is NULL)
                                                limit 46) as subq_2
                                          where ref_1.email is not NULL
                                          limit 73) as subq_3
                                    where (false) 
                                      and (ref_0.created_at is not NULL))) 
                                and ((false) 
                                  and (true))) 
                              or (ref_0.user_id is not NULL))) 
                          and (false)))) 
                    or (false)))
              limit 70) then ref_0.content else ref_0.content end
           as c0, 
        ref_0.updated_at as c1, 
        ref_0.created_at as c2, 
        ref_0.user_id as c3, 
        ref_0.title as c4, 
        ref_0.user_id as c5
      from 
        test_bd.posts as ref_0
      where (ref_0.updated_at is not NULL) 
        and (ref_0.user_id is not NULL)
      limit 146) as subq_4
where (EXISTS (
    select  
        ref_13.hire_date as c0, 
        subq_4.c0 as c1, 
        ref_13.department_id as c2
      from 
        test_bd.employee as ref_13
      where (subq_4.c5 is NULL) 
        or (((ref_13.age is NULL) 
            and (false)) 
          or ((true) 
            or (EXISTS (
              select  
                  ref_14.post_id as c0, 
                  subq_4.c1 as c1, 
                  subq_4.c4 as c2, 
                  ref_13.email as c3, 
                  ref_13.hire_date as c4, 
                  ref_13.eid as c5, 
                  subq_4.c5 as c6, 
                  ref_14.id as c7, 
                  ref_14.post_id as c8
                from 
                  test_bd.comments as ref_14
                where (true) 
                  and (ref_13.email is not NULL)
                limit 112)))))) 
  or (EXISTS (
    select  
        ref_15.discount as c0, 
        99 as c1, 
        ref_15.price as c2
      from 
        test_bd.products as ref_15
      where (EXISTS (
          select  
              ref_15.price as c0, 
              ref_15.category as c1
            from 
              test_bd.posts as ref_16
            where ((ref_15.category is NULL) 
                or ((false) 
                  and (EXISTS (
                    select  
                        ref_15.price as c0, 
                        subq_4.c3 as c1, 
                        ref_17.comment as c2, 
                        subq_6.c2 as c3, 
                        ref_16.created_at as c4, 
                        ref_17.comment as c5, 
                        ref_16.id as c6, 
                        subq_4.c1 as c7, 
                        ref_16.created_at as c8, 
                        (select id from test_bd.eids limit 1 offset 5)
                           as c9, 
                        ref_16.content as c10, 
                        ref_16.user_id as c11, 
                        ref_17.username as c12, 
                        ref_17.title as c13, 
                        ref_17.comment as c14, 
                        subq_4.c4 as c15, 
                        subq_4.c0 as c16, 
                        ref_17.username as c17, 
                        ref_16.title as c18, 
                        ref_17.title as c19, 
                        subq_6.c5 as c20, 
                        subq_6.c13 as c21, 
                        ref_15.category as c22, 
                        ref_16.id as c23, 
                        ref_16.content as c24, 
                        subq_4.c3 as c25, 
                        ref_17.comment as c26, 
                        (select eid from test_bd.eids limit 1 offset 4)
                           as c27, 
                        ref_17.title as c28, 
                        ref_15.category as c29
                      from 
                        test_bd.user_post_comments as ref_17,
                        lateral (select  
                              ref_15.category as c0, 
                              ref_17.username as c1, 
                              subq_4.c5 as c2, 
                              ref_16.title as c3, 
                              (select email from test_bd.users limit 1 offset 5)
                                 as c4, 
                              ref_16.created_at as c5, 
                              (select id from test_bd.employee limit 1 offset 1)
                                 as c6, 
                              subq_4.c4 as c7, 
                              55 as c8, 
                              ref_15.created_at as c9, 
                              ref_15.name as c10, 
                              subq_4.c0 as c11, 
                              ref_15.name as c12, 
                              ref_18.updated_at as c13, 
                              ref_16.title as c14
                            from 
                              test_bd.posts as ref_18
                            where (ref_17.title is not NULL) 
                              or (true)) as subq_6
                      where (false) 
                        and (ref_17.title is NULL)
                      limit 93)))) 
              or ((subq_4.c4 is NULL) 
                and (36 is NULL))
            limit 96)) 
        or (false)
      limit 152));
SHOW profiles;