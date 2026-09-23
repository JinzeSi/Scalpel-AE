SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_2.user_id as c0, 
  ref_6.created_at as c1
from 
  test_bd.eids as ref_0
    right join (select  
              ref_1.comment as c0, 
              ref_1.username as c1
            from 
              test_bd.user_post_comments as ref_1
            where true
            limit 29) as subq_0
        left join test_bd.locations as ref_2
          inner join test_bd.employee as ref_3
          on ((((ref_3.hire_date is not NULL) 
                  and ((true) 
                    or ((EXISTS (
                        select  
                            ref_4.updated_at as c0, 
                            ref_2.id as c1, 
                            ref_4.updated_at as c2, 
                            55 as c3, 
                            (select tags from test_bd.products limit 1 offset 4)
                               as c4, 
                            (select user_id from test_bd.posts limit 1 offset 4)
                               as c5, 
                            ref_3.salary as c6, 
                            ref_2.user_id as c7, 
                            ref_2.coordinates as c8, 
                            (select id from test_bd.locations limit 1 offset 5)
                               as c9, 
                            ref_2.id as c10, 
                            ref_3.age as c11
                          from 
                            test_bd.posts as ref_4
                          where ref_3.eid is not NULL
                          limit 102)) 
                      or (ref_3.email is not NULL)))) 
                and ((ref_3.hire_date is not NULL) 
                  or (true))) 
              and (ref_2.id is not NULL))
        on (subq_0.c1 = ref_2.name )
      right join test_bd.products as ref_5
        right join test_bd.products as ref_6
          inner join test_bd.posts as ref_7
          on ((ref_7.title is not NULL) 
              or (((ref_6.tags is NULL) 
                  or ((ref_6.discount is NULL) 
                    and (((false) 
                        and (((EXISTS (
                              select  
                                  (select content from test_bd.posts limit 1 offset 5)
                                     as c0, 
                                  38 as c1, 
                                  ref_7.title as c2, 
                                  ref_8.eid as c3, 
                                  ref_7.updated_at as c4, 
                                  ref_8.eid as c5, 
                                  ref_7.updated_at as c6, 
                                  ref_6.price as c7, 
                                  ref_8.id as c8
                                from 
                                  test_bd.eids as ref_8
                                where true
                                limit 140)) 
                            or (((false) 
                                and ((((false) 
                                      and (false)) 
                                    and (ref_6.name is not NULL)) 
                                  and (false))) 
                              or ((ref_6.discount is NULL) 
                                and (ref_6.category is NULL)))) 
                          or (((false) 
                              or (EXISTS (
                                select  
                                    ref_7.title as c0, 
                                    ref_6.created_at as c1, 
                                    ref_9.salary as c2, 
                                    (select username from test_bd.user_post_comments limit 1 offset 50)
                                       as c3, 
                                    ref_6.category as c4, 
                                    ref_6.discount as c5, 
                                    ref_9.hire_date as c6, 
                                    ref_6.price as c7, 
                                    ref_7.created_at as c8
                                  from 
                                    test_bd.employee as ref_9
                                  where true
                                  limit 143))) 
                            or (false)))) 
                      and (ref_7.id is NULL)))) 
                and (ref_6.name is NULL)))
        on (ref_5.price is NULL)
      on ((select virtual_col from test_bd.eids limit 1 offset 62)
             is not NULL)
    on (false)
where ((true) 
    or (((true) 
        or ((((((ref_0.eid is NULL) 
                  or (false)) 
                and (((ref_2.name is NULL) 
                    and (false)) 
                  or (false))) 
              and (false)) 
            and (28 is NULL)) 
          or (ref_7.updated_at is not NULL))) 
      or (((((true) 
              and (((EXISTS (
                    select  
                        (select post_id from test_bd.comments limit 1 offset 3)
                           as c0, 
                        ref_10.title as c1, 
                        ref_5.price as c2
                      from 
                        test_bd.posts as ref_10
                      where false)) 
                  and ((EXISTS (
                      select  
                          subq_0.c1 as c0, 
                          ref_7.created_at as c1, 
                          ref_0.id as c2, 
                          ref_11.id as c3, 
                          ref_11.id as c4, 
                          ref_6.tags as c5
                        from 
                          test_bd.locations as ref_11
                        where false
                        limit 52)) 
                    or (ref_0.id is NULL))) 
                or ((false) 
                  and (ref_0.virtual_col is NULL)))) 
            or (((((ref_6.discount is NULL) 
                    and (EXISTS (
                      select  
                          ref_2.coordinates as c0, 
                          ref_6.price as c1, 
                          ref_12.created_at as c2
                        from 
                          test_bd.users as ref_12
                        where (true) 
                          and (EXISTS (
                            select  
                                (select years from test_bd.employee limit 1 offset 4)
                                   as c0, 
                                ref_12.email as c1
                              from 
                                test_bd.user_post_comments as ref_13
                              where false
                              limit 177))
                        limit 176))) 
                  and (((EXISTS (
                        select  
                            ref_3.years as c0, 
                            ref_0.virtual_col as c1, 
                            subq_3.c1 as c2, 
                            (select updated_at from test_bd.posts limit 1 offset 5)
                               as c3
                          from 
                            test_bd.products as ref_14,
                            lateral (select  
                                  ref_0.eid as c0, 
                                  ref_3.email as c1, 
                                  (select email from test_bd.employee limit 1 offset 2)
                                     as c2, 
                                  ref_5.id as c3
                                from 
                                  test_bd.employee as ref_15,
                                  lateral (select  
                                        ref_7.title as c0, 
                                        ref_16.price as c1, 
                                        ref_14.id as c2, 
                                        ref_15.hire_date as c3, 
                                        ref_14.discount as c4, 
                                        ref_7.created_at as c5, 
                                        ref_5.discount as c6
                                      from 
                                        test_bd.products as ref_16
                                      where false
                                      limit 176) as subq_1,
                                  lateral (select  
                                        ref_7.content as c0, 
                                        ref_17.title as c1, 
                                        ref_3.years as c2, 
                                        ref_14.price as c3
                                      from 
                                        test_bd.user_post_comments as ref_17
                                      where (EXISTS (
                                          select  
                                              ref_7.title as c0, 
                                              ref_17.username as c1, 
                                              ref_7.created_at as c2, 
                                              ref_18.tags as c3, 
                                              ref_15.email as c4, 
                                              ref_18.tags as c5, 
                                              ref_17.username as c6, 
                                              ref_5.discount as c7, 
                                              ref_2.user_id as c8, 
                                              ref_2.name as c9, 
                                              ref_18.id as c10, 
                                              ref_17.username as c11, 
                                              ref_0.eid as c12, 
                                              (select title from test_bd.posts limit 1 offset 6)
                                                 as c13, 
                                              (select created_at from test_bd.products limit 1 offset 6)
                                                 as c14
                                            from 
                                              test_bd.products as ref_18
                                            where false
                                            limit 97)) 
                                        and ((true) 
                                          and (true))
                                      limit 46) as subq_2
                                where (true) 
                                  and ((subq_1.c0 is NULL) 
                                    and ((false) 
                                      or (false)))
                                limit 186) as subq_3
                          where true
                          limit 97)) 
                      and (ref_6.category is not NULL)) 
                    or ((((false) 
                          and (true)) 
                        and (ref_7.id is not NULL)) 
                      or (((EXISTS (
                            select  
                                (select email from test_bd.employee limit 1 offset 85)
                                   as c0, 
                                subq_0.c1 as c1, 
                                ref_3.salary as c2, 
                                ref_19.user_id as c3, 
                                (select birthdate from test_bd.user_profiles limit 1 offset 4)
                                   as c4
                              from 
                                test_bd.locations as ref_19
                              where ((true) 
                                  and (((true) 
                                      or (EXISTS (
                                        select  
                                            ref_6.discount as c0, 
                                            2 as c1, 
                                            ref_3.id as c2
                                          from 
                                            test_bd.locations as ref_20,
                                            lateral (select  
                                                  ref_20.name as c0, 
                                                  ref_19.user_id as c1, 
                                                  ref_20.id as c2, 
                                                  6 as c3, 
                                                  ref_0.eid as c4
                                                from 
                                                  test_bd.users as ref_21
                                                where false
                                                limit 63) as subq_4
                                          where true))) 
                                    and ((true) 
                                      or ((false) 
                                        or ((true) 
                                          and (ref_6.discount is not NULL)))))) 
                                and (((false) 
                                    and ((((EXISTS (
                                            select  
                                                ref_6.discount as c0, 
                                                ref_7.id as c1, 
                                                subq_0.c0 as c2, 
                                                subq_0.c1 as c3, 
                                                ref_19.user_id as c4, 
                                                subq_0.c1 as c5, 
                                                ref_22.name as c6, 
                                                subq_0.c0 as c7, 
                                                subq_0.c1 as c8
                                              from 
                                                test_bd.locations as ref_22,
                                                lateral (select  
                                                      ref_7.created_at as c0, 
                                                      ref_19.id as c1
                                                    from 
                                                      test_bd.user_post_comments as ref_23
                                                    where true) as subq_5
                                              where true
                                              limit 166)) 
                                          and (((true) 
                                              and ((select coordinates from test_bd.locations limit 1 offset 6)
                                                   is not NULL)) 
                                            and (ref_6.discount is not NULL))) 
                                        and (true)) 
                                      or (subq_0.c0 is not NULL))) 
                                  or ((((true) 
                                        and (false)) 
                                      and (ref_19.coordinates is not NULL)) 
                                    or (((((false) 
                                            or ((true) 
                                              or (EXISTS (
                                                select  
                                                    ref_5.name as c0, 
                                                    subq_6.c0 as c1, 
                                                    subq_0.c0 as c2, 
                                                    subq_0.c1 as c3, 
                                                    ref_7.user_id as c4, 
                                                    53 as c5, 
                                                    ref_0.id as c6, 
                                                    ref_5.name as c7
                                                  from 
                                                    test_bd.users as ref_24,
                                                    lateral (select  
                                                          ref_24.created_at as c0
                                                        from 
                                                          test_bd.employee as ref_25
                                                        where true) as subq_6
                                                  where true
                                                  limit 49)))) 
                                          and (((ref_7.updated_at is not NULL) 
                                              and (((true) 
                                                  and (EXISTS (
                                                    select  
                                                        subq_0.c1 as c0, 
                                                        ref_19.id as c1
                                                      from 
                                                        test_bd.employee as ref_26
                                                      where ((((EXISTS (
                                                                select  
                                                                    ref_26.hire_date as c0, 
                                                                    34 as c1
                                                                  from 
                                                                    test_bd.user_post_comments as ref_27,
                                                                    lateral (select  
                                                                          ref_6.price as c0, 
                                                                          subq_0.c1 as c1, 
                                                                          ref_0.virtual_col as c2, 
                                                                          ref_2.user_id as c3, 
                                                                          ref_3.email as c4, 
                                                                          ref_2.id as c5, 
                                                                          ref_27.title as c6, 
                                                                          ref_19.name as c7, 
                                                                          ref_26.eid as c8, 
                                                                          ref_7.id as c9, 
                                                                          subq_7.c0 as c10
                                                                        from 
                                                                          test_bd.posts as ref_28,
                                                                          lateral (select  
                                                                                ref_19.coordinates as c0, 
                                                                                ref_28.title as c1, 
                                                                                ref_19.user_id as c2, 
                                                                                ref_28.user_id as c3
                                                                              from 
                                                                                test_bd.employee as ref_29
                                                                              where true) as subq_7
                                                                        where ref_26.age is NULL
                                                                        limit 127) as subq_8
                                                                  where (EXISTS (
                                                                      select  
                                                                          ref_26.id as c0, 
                                                                          ref_5.name as c1, 
                                                                          ref_2.id as c2, 
                                                                          ref_5.discount as c3
                                                                        from 
                                                                          test_bd.posts as ref_30,
                                                                          lateral (select  
                                                                                ref_31.department_id as c0, 
                                                                                ref_5.discount as c1, 
                                                                                ref_7.created_at as c2, 
                                                                                ref_6.id as c3
                                                                              from 
                                                                                test_bd.employee as ref_31
                                                                              where ((true) 
                                                                                  and (false)) 
                                                                                or (true)
                                                                              limit 64) as subq_9
                                                                        where false)) 
                                                                    and ((false) 
                                                                      or (((false) 
                                                                          or (ref_27.title is not NULL)) 
                                                                        or (false)))
                                                                  limit 151)) 
                                                              or (EXISTS (
                                                                select  
                                                                    ref_6.discount as c0, 
                                                                    ref_2.coordinates as c1, 
                                                                    ref_2.name as c2, 
                                                                    ref_2.coordinates as c3, 
                                                                    ref_6.created_at as c4, 
                                                                    ref_0.id as c5, 
                                                                    ref_0.virtual_col as c6, 
                                                                    ref_3.id as c7, 
                                                                    ref_5.id as c8, 
                                                                    ref_7.content as c9, 
                                                                    16 as c10, 
                                                                    ref_0.virtual_col as c11, 
                                                                    ref_32.user_id as c12, 
                                                                    ref_0.id as c13, 
                                                                    ref_26.id as c14, 
                                                                    ref_6.discount as c15, 
                                                                    ref_26.id as c16, 
                                                                    ref_3.years as c17
                                                                  from 
                                                                    test_bd.comments as ref_32
                                                                  where ref_3.department_id is NULL
                                                                  limit 4))) 
                                                            or (true)) 
                                                          or (false)) 
                                                        or ((ref_3.department_id is not NULL) 
                                                          and (true))
                                                      limit 134))) 
                                                and ((true) 
                                                  or (true)))) 
                                            or (false))) 
                                        or (true)) 
                                      and (ref_6.created_at is not NULL))))
                              limit 52)) 
                          or (ref_2.id is not NULL)) 
                        or (true))))) 
                or ((ref_3.eid is not NULL) 
                  or (false))) 
              or (ref_3.id is not NULL))) 
          and (ref_2.name is NULL)) 
        and (((select email from test_bd.employee limit 1 offset 3)
               is not NULL) 
          and ((select content from test_bd.posts limit 1 offset 1)
               is not NULL))))) 
  or ((((false) 
        or ((EXISTS (
            select  
                ref_3.salary as c0, 
                ref_7.updated_at as c1, 
                ref_0.virtual_col as c2, 
                (select birthdate from test_bd.user_profiles limit 1 offset 1)
                   as c3, 
                ref_33.user_id as c4, 
                ref_0.id as c5, 
                ref_2.name as c6
              from 
                test_bd.user_profiles as ref_33
              where true
              limit 13)) 
          or (EXISTS (
            select  
                ref_34.coordinates as c0
              from 
                test_bd.locations as ref_34
              where ((false) 
                  or ((false) 
                    and ((false) 
                      or (((ref_6.created_at is not NULL) 
                          or (ref_6.tags is NULL)) 
                        and (((true) 
                            or (((((select profile_picture from test_bd.user_profiles limit 1 offset 5)
                                       is not NULL) 
                                  or (EXISTS (
                                    select  
                                        ref_7.created_at as c0, 
                                        subq_0.c0 as c1, 
                                        ref_0.virtual_col as c2, 
                                        subq_11.c5 as c3, 
                                        subq_0.c0 as c4, 
                                        (select years from test_bd.employee limit 1 offset 3)
                                           as c5, 
                                        (select username from test_bd.user_post_comments limit 1 offset 4)
                                           as c6, 
                                        ref_7.user_id as c7, 
                                        ref_34.coordinates as c8
                                      from 
                                        test_bd.users as ref_35,
                                        lateral (select  
                                              subq_0.c1 as c0, 
                                              ref_0.eid as c1, 
                                              ref_0.id as c2, 
                                              ref_36.price as c3, 
                                              ref_7.user_id as c4
                                            from 
                                              test_bd.products as ref_36
                                            where ref_34.user_id is not NULL
                                            limit 50) as subq_10,
                                        lateral (select  
                                              ref_6.tags as c0, 
                                              ref_35.created_at as c1, 
                                              42 as c2, 
                                              ref_5.category as c3, 
                                              ref_0.virtual_col as c4, 
                                              ref_5.category as c5, 
                                              ref_2.name as c6, 
                                              ref_3.department_id as c7, 
                                              ref_0.eid as c8, 
                                              ref_6.name as c9
                                            from 
                                              test_bd.products as ref_37
                                            where EXISTS (
                                              select  
                                                  ref_7.title as c0, 
                                                  ref_38.age as c1, 
                                                  ref_37.name as c2, 
                                                  ref_7.id as c3, 
                                                  ref_34.name as c4, 
                                                  ref_37.created_at as c5, 
                                                  ref_35.id as c6, 
                                                  ref_3.salary as c7
                                                from 
                                                  test_bd.employee as ref_38
                                                where (EXISTS (
                                                    select  
                                                        ref_6.price as c0, 
                                                        ref_2.id as c1, 
                                                        ref_0.eid as c2, 
                                                        ref_2.coordinates as c3, 
                                                        subq_10.c2 as c4, 
                                                        ref_0.id as c5, 
                                                        ref_37.tags as c6
                                                      from 
                                                        test_bd.locations as ref_39
                                                      where false
                                                      limit 37)) 
                                                  or (ref_34.name is not NULL))) as subq_11
                                      where false))) 
                                or ((((true) 
                                      and ((false) 
                                        or (EXISTS (
                                          select  
                                              ref_2.id as c0, 
                                              ref_34.user_id as c1, 
                                              ref_34.coordinates as c2, 
                                              ref_40.title as c3
                                            from 
                                              test_bd.user_post_comments as ref_40
                                            where EXISTS (
                                              select  
                                                  ref_0.eid as c0, 
                                                  ref_2.user_id as c1, 
                                                  ref_41.id as c2, 
                                                  ref_2.user_id as c3, 
                                                  ref_3.salary as c4, 
                                                  ref_3.eid as c5, 
                                                  ref_34.user_id as c6, 
                                                  ref_41.coordinates as c7, 
                                                  ref_7.updated_at as c8, 
                                                  ref_34.user_id as c9, 
                                                  ref_7.user_id as c10
                                                from 
                                                  test_bd.locations as ref_41
                                                where (true) 
                                                  and ((false) 
                                                    or ((true) 
                                                      and (true)))
                                                limit 106))))) 
                                    and (((false) 
                                        and (true)) 
                                      or (ref_3.eid is not NULL))) 
                                  or ((false) 
                                    and (EXISTS (
                                      select  
                                          ref_5.category as c0, 
                                          ref_2.id as c1
                                        from 
                                          test_bd.posts as ref_42,
                                          lateral (select  
                                                ref_34.id as c0, 
                                                ref_34.name as c1
                                              from 
                                                test_bd.locations as ref_43
                                              where false
                                              limit 142) as subq_12,
                                          lateral (select  
                                                ref_7.user_id as c0, 
                                                subq_0.c1 as c1, 
                                                ref_44.eid as c2, 
                                                ref_42.created_at as c3, 
                                                ref_44.virtual_col as c4
                                              from 
                                                test_bd.eids as ref_44
                                              where true
                                              limit 38) as subq_13
                                        where (true) 
                                          or ((false) 
                                            and ((true) 
                                              and ((true) 
                                                and ((ref_34.id is not NULL) 
                                                  or (true)))))
                                        limit 97))))) 
                              and (false))) 
                          and (false)))))) 
                and ((false) 
                  and ((((false) 
                        or ((ref_6.id is NULL) 
                          and (true))) 
                      and ((false) 
                        or ((((select username from test_bd.users limit 1 offset 4)
                                 is not NULL) 
                            and ((false) 
                              and (ref_7.id is NULL))) 
                          and (false)))) 
                    or (false)))
              limit 151)))) 
      or (subq_0.c0 is NULL)) 
    or ((((ref_5.id is not NULL) 
          and (ref_2.id is NULL)) 
        or (ref_0.eid is not NULL)) 
      and (false)))
limit 92;
SHOW profiles;