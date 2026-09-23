SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_7.c1 as c0
from 
  (select  
        (select id from test_bd.eids limit 1 offset 6)
           as c0, 
        (select department_id from test_bd.employee limit 1 offset 14)
           as c1, 
        subq_1.c3 as c2
      from 
        (select  
              ref_0.id as c0, 
              ref_0.virtual_col as c1
            from 
              test_bd.eids as ref_0
            where ((ref_0.eid is NULL) 
                and ((ref_0.virtual_col is NULL) 
                  and (false))) 
              or (ref_0.virtual_col is NULL)) as subq_0,
        lateral (select  
              subq_0.c1 as c0, 
              14 as c1, 
              subq_0.c0 as c2, 
              ref_1.id as c3
            from 
              test_bd.employee as ref_1
            where (ref_1.eid is NULL) 
              or (subq_0.c1 is not NULL)
            limit 120) as subq_1,
        lateral (select  
              subq_1.c0 as c0, 
              ref_3.user_id as c1, 
              ref_2.content as c2, 
              ref_3.birthdate as c3, 
              (select comment from test_bd.user_post_comments limit 1 offset 2)
                 as c4, 
              ref_3.bio as c5, 
              ref_3.bio as c6, 
              ref_3.bio as c7
            from 
              test_bd.posts as ref_2
                inner join test_bd.user_profiles as ref_3
                on (false)
            where ((((false) 
                    and ((EXISTS (
                        select  
                            ref_3.birthdate as c0, 
                            subq_0.c1 as c1, 
                            ref_2.updated_at as c2, 
                            subq_0.c1 as c3, 
                            subq_1.c1 as c4, 
                            ref_2.content as c5
                          from 
                            test_bd.employee as ref_4
                          where false
                          limit 178)) 
                      or (EXISTS (
                        select  
                            ref_2.id as c0, 
                            ref_5.id as c1
                          from 
                            test_bd.eids as ref_5
                          where ((true) 
                              or (true)) 
                            or ((ref_3.user_id is NULL) 
                              or (EXISTS (
                                select  
                                    ref_3.user_id as c0, 
                                    ref_6.category as c1, 
                                    ref_6.tags as c2, 
                                    (select post_id from test_bd.comments limit 1 offset 60)
                                       as c3, 
                                    subq_1.c0 as c4
                                  from 
                                    test_bd.products as ref_6
                                  where false)))
                          limit 91)))) 
                  and ((((false) 
                        and ((((((ref_2.id is NULL) 
                                  and (ref_2.title is not NULL)) 
                                and ((true) 
                                  and (EXISTS (
                                    select  
                                        ref_2.user_id as c0, 
                                        ref_7.salary as c1, 
                                        subq_1.c0 as c2, 
                                        subq_1.c1 as c3, 
                                        subq_2.c0 as c4, 
                                        ref_7.email as c5
                                      from 
                                        test_bd.employee as ref_7,
                                        lateral (select  
                                              subq_0.c0 as c0, 
                                              ref_8.email as c1, 
                                              ref_3.user_id as c2
                                            from 
                                              test_bd.users as ref_8
                                            where ref_7.email is NULL
                                            limit 63) as subq_2
                                      where (((EXISTS (
                                              select  
                                                  subq_3.c3 as c0, 
                                                  subq_2.c2 as c1
                                                from 
                                                  test_bd.employee as ref_9,
                                                  lateral (select  
                                                        ref_9.hire_date as c0, 
                                                        subq_0.c0 as c1, 
                                                        ref_9.id as c2, 
                                                        subq_0.c0 as c3, 
                                                        subq_1.c0 as c4
                                                      from 
                                                        test_bd.locations as ref_10
                                                      where true
                                                      limit 86) as subq_3
                                                where true
                                                limit 65)) 
                                            and ((false) 
                                              and ((subq_2.c0 is not NULL) 
                                                or (true)))) 
                                          and (ref_3.profile_picture is not NULL)) 
                                        and (EXISTS (
                                          select  
                                              ref_3.bio as c0, 
                                              ref_7.hire_date as c1, 
                                              ref_11.tags as c2, 
                                              76 as c3, 
                                              subq_0.c0 as c4
                                            from 
                                              test_bd.products as ref_11
                                            where true
                                            limit 86))
                                      limit 121)))) 
                              and ((select eid from test_bd.employee limit 1 offset 3)
                                   is NULL)) 
                            or ((ref_2.content is NULL) 
                              and (EXISTS (
                                select  
                                    ref_3.bio as c0
                                  from 
                                    test_bd.products as ref_12
                                  where ((((EXISTS (
                                            select  
                                                subq_0.c1 as c0, 
                                                subq_4.c2 as c1
                                              from 
                                                test_bd.comments as ref_13,
                                                lateral (select  
                                                      ref_2.content as c0, 
                                                      subq_1.c1 as c1, 
                                                      ref_2.updated_at as c2, 
                                                      subq_0.c0 as c3
                                                    from 
                                                      test_bd.eids as ref_14
                                                    where true) as subq_4
                                              where (((((ref_12.tags is not NULL) 
                                                        and (true)) 
                                                      and (((false) 
                                                          or (((true) 
                                                              or (((subq_1.c3 is NULL) 
                                                                  and (false)) 
                                                                or (false))) 
                                                            or ((true) 
                                                              and (false)))) 
                                                        or (ref_12.created_at is NULL))) 
                                                    or (subq_1.c2 is not NULL)) 
                                                  and (false)) 
                                                and (false))) 
                                          and (((subq_1.c3 is not NULL) 
                                              and (false)) 
                                            and (ref_3.profile_picture is not NULL))) 
                                        and (false)) 
                                      and (false)) 
                                    and (((subq_0.c1 is not NULL) 
                                        and (ref_2.updated_at is not NULL)) 
                                      and (true)))))) 
                          and (true))) 
                      and ((subq_0.c0 is NULL) 
                        and ((true) 
                          and (true)))) 
                    and ((((EXISTS (
                            select  
                                (select eid from test_bd.eids limit 1 offset 3)
                                   as c0, 
                                subq_5.c0 as c1, 
                                subq_1.c3 as c2, 
                                subq_1.c2 as c3, 
                                ref_15.created_at as c4, 
                                ref_15.user_id as c5, 
                                subq_5.c0 as c6
                              from 
                                test_bd.posts as ref_15,
                                lateral (select  
                                      ref_15.updated_at as c0
                                    from 
                                      test_bd.locations as ref_16
                                    where false) as subq_5
                              where ref_15.id is NULL)) 
                          and ((true) 
                            or (subq_1.c0 is not NULL))) 
                        or (((58 is not NULL) 
                            or ((true) 
                              and ((true) 
                                and (EXISTS (
                                  select  
                                      subq_0.c0 as c0, 
                                      subq_0.c0 as c1, 
                                      subq_1.c0 as c2, 
                                      ref_2.title as c3, 
                                      ref_17.title as c4, 
                                      7 as c5, 
                                      ref_3.birthdate as c6, 
                                      ref_2.user_id as c7, 
                                      subq_0.c0 as c8, 
                                      subq_1.c3 as c9, 
                                      subq_1.c1 as c10, 
                                      subq_1.c3 as c11
                                    from 
                                      test_bd.posts as ref_17
                                    where false
                                    limit 21))))) 
                          and (((false) 
                              or (((((subq_1.c0 is NULL) 
                                      or (ref_3.birthdate is not NULL)) 
                                    or (true)) 
                                  or (subq_0.c0 is NULL)) 
                                or ((true) 
                                  or (subq_1.c1 is not NULL)))) 
                            or ((subq_0.c0 is NULL) 
                              and ((false) 
                                and (false)))))) 
                      or (ref_2.updated_at is not NULL)))) 
                or ((subq_0.c1 is not NULL) 
                  or (false))) 
              and ((true) 
                or (((false) 
                    or (subq_1.c3 is not NULL)) 
                  or (89 is not NULL)))
            limit 44) as subq_6
      where subq_6.c2 is not NULL
      limit 77) as subq_7
where ((((EXISTS (
          select  
              ref_18.content as c0, 
              ref_18.user_id as c1, 
              subq_7.c1 as c2, 
              subq_7.c2 as c3
            from 
              test_bd.posts as ref_18
            where true
            limit 86)) 
        and (true)) 
      and (subq_7.c2 is not NULL)) 
    or (subq_7.c2 is not NULL)) 
  and ((EXISTS (
      select  
          ref_19.id as c0
        from 
          test_bd.products as ref_19
        where EXISTS (
          select  
              subq_7.c0 as c0, 
              ref_19.created_at as c1, 
              ref_20.id as c2, 
              subq_7.c1 as c3
            from 
              test_bd.employee as ref_20,
              lateral (select  
                    (select category from test_bd.products limit 1 offset 3)
                       as c0, 
                    ref_21.virtual_col as c1, 
                    ref_21.eid as c2, 
                    ref_19.id as c3, 
                    ref_19.tags as c4, 
                    subq_7.c2 as c5
                  from 
                    test_bd.eids as ref_21
                  where (EXISTS (
                      select  
                          ref_22.user_id as c0, 
                          ref_21.virtual_col as c1
                        from 
                          test_bd.locations as ref_22
                        where true)) 
                    and (EXISTS (
                      select  
                          ref_23.price as c0, 
                          ref_19.name as c1, 
                          ref_19.category as c2
                        from 
                          test_bd.products as ref_23
                        where ref_23.id is not NULL))
                  limit 63) as subq_8
            where EXISTS (
              select  
                  subq_7.c0 as c0, 
                  subq_7.c0 as c1
                from 
                  test_bd.user_profiles as ref_24
                where ((ref_19.created_at is NULL) 
                    or (((((((subq_7.c0 is not NULL) 
                                or (((true) 
                                    or (false)) 
                                  or ((EXISTS (
                                      select  
                                          ref_25.id as c0, 
                                          (select id from test_bd.products limit 1 offset 2)
                                             as c1, 
                                          ref_25.username as c2, 
                                          ref_24.birthdate as c3, 
                                          79 as c4, 
                                          ref_25.username as c5, 
                                          subq_7.c2 as c6
                                        from 
                                          test_bd.users as ref_25
                                        where (false) 
                                          and ((subq_8.c1 is not NULL) 
                                            or (EXISTS (
                                              select  
                                                  subq_10.c0 as c0, 
                                                  subq_8.c4 as c1, 
                                                  ref_26.id as c2, 
                                                  subq_10.c1 as c3, 
                                                  subq_7.c1 as c4, 
                                                  subq_8.c3 as c5, 
                                                  ref_26.tags as c6, 
                                                  subq_10.c0 as c7, 
                                                  subq_10.c1 as c8, 
                                                  subq_7.c0 as c9, 
                                                  subq_8.c5 as c10, 
                                                  subq_10.c1 as c11
                                                from 
                                                  test_bd.products as ref_26,
                                                  lateral (select  
                                                        ref_24.bio as c0, 
                                                        ref_20.years as c1
                                                      from 
                                                        test_bd.locations as ref_27,
                                                        lateral (select  
                                                              ref_27.name as c0
                                                            from 
                                                              test_bd.locations as ref_28
                                                            where true) as subq_9
                                                      where (select title from test_bd.user_post_comments limit 1 offset 5)
                                                           is not NULL
                                                      limit 53) as subq_10
                                                where ((true) 
                                                    or (false)) 
                                                  and (false)
                                                limit 149))))) 
                                    and (EXISTS (
                                      select  
                                          ref_29.comment as c0, 
                                          subq_11.c0 as c1, 
                                          ref_24.profile_picture as c2, 
                                          ref_20.years as c3, 
                                          subq_8.c2 as c4
                                        from 
                                          test_bd.user_post_comments as ref_29,
                                          lateral (select  
                                                ref_19.tags as c0
                                              from 
                                                test_bd.user_post_comments as ref_30
                                              where false
                                              limit 97) as subq_11
                                        where EXISTS (
                                          select  
                                              subq_8.c4 as c0, 
                                              ref_29.comment as c1, 
                                              subq_7.c2 as c2, 
                                              subq_11.c0 as c3
                                            from 
                                              test_bd.eids as ref_31
                                            where subq_8.c2 is NULL
                                            limit 123)
                                        limit 145))))) 
                              and ((true) 
                                and (true))) 
                            or (((true) 
                                or (ref_24.bio is not NULL)) 
                              and (subq_8.c5 is not NULL))) 
                          or ((true) 
                            or ((ref_20.hire_date is not NULL) 
                              or (true)))) 
                        and (subq_7.c0 is not NULL)) 
                      and (subq_7.c1 is not NULL))) 
                  or (false)))
        limit 153)) 
    or ((((subq_7.c2 is NULL) 
          or (EXISTS (
            select  
                subq_7.c1 as c0, 
                (select username from test_bd.user_post_comments limit 1 offset 3)
                   as c1, 
                27 as c2, 
                subq_7.c2 as c3
              from 
                test_bd.eids as ref_32
              where ((((false) 
                      or ((ref_32.id is NULL) 
                        or (subq_7.c0 is not NULL))) 
                    or (ref_32.virtual_col is not NULL)) 
                  or (true)) 
                or (subq_7.c1 is NULL)))) 
        and (true)) 
      and (subq_7.c2 is not NULL)))
limit 66;
SHOW profiles;