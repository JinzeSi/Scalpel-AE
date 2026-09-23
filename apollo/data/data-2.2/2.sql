SET profiling=1;
EXPLAIN ANALYZE

select  
  coalesce(subq_2.c5,
    subq_2.c4) as c0, 
  subq_2.c5 as c1, 
  subq_2.c4 as c2, 
  subq_2.c3 as c3, 
  subq_2.c1 as c4, 
  (select username from test_bd.user_post_comments limit 1 offset 1)
     as c5, 
  subq_2.c4 as c6, 
  subq_2.c0 as c7
from 
  (select  
        subq_0.c2 as c0, 
        ref_3.user_id as c1, 
        ref_5.hire_date as c2, 
        ref_3.user_id as c3, 
        ref_1.user_id as c4, 
        ref_5.age as c5
      from 
        test_bd.locations as ref_0
          inner join test_bd.posts as ref_1
                  left join test_bd.posts as ref_2
                  on (ref_1.created_at = ref_2.created_at )
                inner join test_bd.comments as ref_3
                on (true)
              right join test_bd.locations as ref_4
              on (ref_1.title is not NULL)
            inner join test_bd.employee as ref_5
            on (ref_4.user_id is NULL)
          on (ref_3.post_id is not NULL),
        lateral (select  
              ref_4.name as c0, 
              ref_3.comment as c1, 
              ref_4.user_id as c2, 
              ref_1.id as c3
            from 
              test_bd.user_profiles as ref_6
            where (ref_4.coordinates is not NULL) 
              or (ref_0.id is NULL)
            limit 94) as subq_0
      where (EXISTS (
          select  
              ref_2.created_at as c0, 
              ref_1.user_id as c1, 
              ref_5.id as c2, 
              subq_1.c1 as c3
            from 
              test_bd.employee as ref_7,
              lateral (select  
                    ref_2.created_at as c0, 
                    subq_0.c2 as c1, 
                    subq_0.c3 as c2
                  from 
                    test_bd.users as ref_8
                  where ((ref_1.created_at is NULL) 
                      or (((false) 
                          or (true)) 
                        and (true))) 
                    or (EXISTS (
                      select  
                          ref_2.updated_at as c0, 
                          ref_9.user_id as c1, 
                          ref_9.user_id as c2, 
                          ref_3.id as c3, 
                          ref_3.created_at as c4
                        from 
                          test_bd.user_profiles as ref_9
                        where ref_7.hire_date is not NULL
                        limit 111))
                  limit 8) as subq_1
            where EXISTS (
              select  
                  (select salary from test_bd.employee limit 1 offset 5)
                     as c0, 
                  ref_0.coordinates as c1, 
                  ref_4.name as c2
                from 
                  test_bd.posts as ref_10
                where subq_1.c0 is NULL
                limit 173))) 
        or ((((ref_3.created_at is not NULL) 
              or (true)) 
            and (true)) 
          and ((false) 
            and (((false) 
                and (ref_5.salary is NULL)) 
              and ((true) 
                or (false)))))
      limit 172) as subq_2
where ((EXISTS (
      select  
          ref_12.id as c0, 
          ref_12.user_id as c1, 
          ref_11.comment as c2, 
          (select id from test_bd.eids limit 1 offset 40)
             as c3, 
          ref_12.updated_at as c4
        from 
          test_bd.user_post_comments as ref_11
            left join test_bd.posts as ref_12
            on ((((EXISTS (
                      select  
                          subq_2.c0 as c0, 
                          ref_12.content as c1, 
                          ref_11.title as c2, 
                          ref_12.updated_at as c3, 
                          ref_12.content as c4
                        from 
                          test_bd.users as ref_13
                        where true
                        limit 78)) 
                    or ((true) 
                      or ((false) 
                        and ((true) 
                          and ((((((((true) 
                                        or ((EXISTS (
                                            select  
                                                ref_12.title as c0, 
                                                ref_14.hire_date as c1, 
                                                ref_12.title as c2
                                              from 
                                                test_bd.employee as ref_14
                                              where ((true) 
                                                  and (false)) 
                                                and (true)
                                              limit 53)) 
                                          or (true))) 
                                      or (ref_12.id is NULL)) 
                                    or (false)) 
                                  or (EXISTS (
                                    select  
                                        ref_11.username as c0, 
                                        ref_12.created_at as c1, 
                                        ref_15.post_id as c2
                                      from 
                                        test_bd.comments as ref_15
                                      where EXISTS (
                                        select  
                                            40 as c0, 
                                            ref_15.post_id as c1, 
                                            ref_15.comment as c2, 
                                            ref_16.department_id as c3
                                          from 
                                            test_bd.employee as ref_16
                                          where true)
                                      limit 141))) 
                                and ((true) 
                                  or (true))) 
                              or (EXISTS (
                                select  
                                    ref_12.id as c0, 
                                    ref_11.title as c1, 
                                    37 as c2, 
                                    ref_11.title as c3, 
                                    ref_12.user_id as c4, 
                                    subq_2.c3 as c5
                                  from 
                                    test_bd.employee as ref_17
                                  where (EXISTS (
                                      select  
                                          ref_17.email as c0, 
                                          (select id from test_bd.users limit 1 offset 36)
                                             as c1, 
                                          ref_18.id as c2, 
                                          subq_2.c4 as c3, 
                                          ref_17.years as c4, 
                                          ref_18.eid as c5, 
                                          subq_4.c1 as c6, 
                                          ref_18.eid as c7, 
                                          ref_17.email as c8, 
                                          ref_12.content as c9, 
                                          subq_2.c3 as c10, 
                                          ref_18.id as c11, 
                                          ref_17.hire_date as c12, 
                                          subq_4.c1 as c13, 
                                          ref_17.salary as c14, 
                                          subq_2.c4 as c15, 
                                          ref_12.updated_at as c16, 
                                          (select birthdate from test_bd.user_profiles limit 1 offset 4)
                                             as c17, 
                                          ref_12.created_at as c18, 
                                          (select bio from test_bd.user_profiles limit 1 offset 2)
                                             as c19
                                        from 
                                          test_bd.eids as ref_18,
                                          lateral (select  
                                                subq_3.c0 as c0, 
                                                ref_19.category as c1
                                              from 
                                                test_bd.products as ref_19,
                                                lateral (select  
                                                      ref_12.created_at as c0, 
                                                      subq_2.c4 as c1, 
                                                      ref_17.eid as c2, 
                                                      ref_12.content as c3, 
                                                      ref_17.years as c4
                                                    from 
                                                      test_bd.comments as ref_20
                                                    where (false) 
                                                      or (EXISTS (
                                                        select  
                                                            ref_17.department_id as c0, 
                                                            subq_2.c1 as c1, 
                                                            ref_18.virtual_col as c2
                                                          from 
                                                            test_bd.users as ref_21
                                                          where false))
                                                    limit 86) as subq_3
                                              where false
                                              limit 88) as subq_4
                                        where true
                                        limit 119)) 
                                    and (subq_2.c4 is not NULL)
                                  limit 184))) 
                            and (false)))))) 
                  and (EXISTS (
                    select  
                        ref_12.user_id as c0, 
                        ref_11.comment as c1, 
                        subq_2.c2 as c2, 
                        ref_22.hire_date as c3, 
                        ref_22.eid as c4, 
                        ref_11.title as c5, 
                        ref_12.content as c6, 
                        ref_22.department_id as c7, 
                        ref_22.eid as c8, 
                        ref_11.title as c9, 
                        subq_2.c3 as c10, 
                        subq_2.c5 as c11, 
                        subq_2.c0 as c12, 
                        subq_2.c2 as c13, 
                        ref_12.user_id as c14
                      from 
                        test_bd.employee as ref_22
                      where ref_12.user_id is not NULL))) 
                or (((((ref_12.updated_at is NULL) 
                        or (((EXISTS (
                              select  
                                  ref_23.comment as c0, 
                                  (select category from test_bd.products limit 1 offset 2)
                                     as c1, 
                                  ref_12.created_at as c2, 
                                  ref_11.title as c3, 
                                  ref_11.username as c4, 
                                  ref_23.username as c5, 
                                  ref_11.comment as c6
                                from 
                                  test_bd.user_post_comments as ref_23
                                where false)) 
                            or (((false) 
                                and ((false) 
                                  and (EXISTS (
                                    select  
                                        ref_24.salary as c0, 
                                        ref_24.years as c1, 
                                        subq_2.c4 as c2, 
                                        ref_24.salary as c3, 
                                        subq_2.c5 as c4, 
                                        ref_12.content as c5, 
                                        ref_24.salary as c6, 
                                        subq_2.c2 as c7, 
                                        (select user_id from test_bd.posts limit 1 offset 3)
                                           as c8, 
                                        ref_11.title as c9
                                      from 
                                        test_bd.employee as ref_24
                                      where (true) 
                                        and (EXISTS (
                                          select  
                                              ref_11.comment as c0, 
                                              ref_11.username as c1, 
                                              subq_2.c3 as c2, 
                                              ref_12.id as c3, 
                                              (select content from test_bd.posts limit 1 offset 46)
                                                 as c4, 
                                              ref_12.id as c5, 
                                              (select username from test_bd.users limit 1 offset 6)
                                                 as c6, 
                                              ref_12.user_id as c7, 
                                              8 as c8, 
                                              ref_24.salary as c9, 
                                              ref_11.username as c10, 
                                              ref_24.years as c11, 
                                              ref_25.price as c12, 
                                              ref_12.content as c13, 
                                              subq_2.c1 as c14, 
                                              subq_2.c0 as c15, 
                                              ref_24.years as c16, 
                                              ref_11.title as c17, 
                                              ref_12.title as c18, 
                                              (select id from test_bd.products limit 1 offset 3)
                                                 as c19
                                            from 
                                              test_bd.products as ref_25
                                            where true
                                            limit 114))
                                      limit 111)))) 
                              and (subq_2.c4 is not NULL))) 
                          and (false))) 
                      or (false)) 
                    and (subq_2.c0 is not NULL)) 
                  or (EXISTS (
                    select  
                        ref_12.title as c0, 
                        ref_11.username as c1, 
                        ref_26.id as c2, 
                        ref_26.tags as c3, 
                        ref_11.comment as c4, 
                        8 as c5, 
                        ref_12.content as c6
                      from 
                        test_bd.products as ref_26
                      where (false) 
                        and (true)
                      limit 72))))
        where true
        limit 6)) 
    and ((subq_2.c3 is NULL) 
      and (((((false) 
              and (EXISTS (
                select  
                    subq_2.c1 as c0, 
                    ref_27.title as c1, 
                    ref_27.title as c2, 
                    subq_2.c5 as c3, 
                    subq_2.c2 as c4, 
                    ref_27.username as c5, 
                    ref_27.title as c6
                  from 
                    test_bd.user_post_comments as ref_27
                  where ((((true) 
                          and ((true) 
                            or (ref_27.title is NULL))) 
                        or (false)) 
                      or (false)) 
                    and ((((((EXISTS (
                                select  
                                    ref_27.comment as c0, 
                                    (select id from test_bd.users limit 1 offset 4)
                                       as c1, 
                                    ref_28.created_at as c2, 
                                    62 as c3, 
                                    subq_2.c1 as c4, 
                                    ref_28.user_id as c5, 
                                    ref_27.comment as c6, 
                                    subq_2.c4 as c7, 
                                    ref_28.updated_at as c8
                                  from 
                                    test_bd.posts as ref_28
                                  where false
                                  limit 38)) 
                              and ((EXISTS (
                                  select  
                                      ref_27.title as c0, 
                                      ref_29.eid as c1, 
                                      subq_2.c1 as c2, 
                                      subq_2.c2 as c3, 
                                      ref_29.virtual_col as c4, 
                                      subq_2.c3 as c5, 
                                      subq_2.c4 as c6, 
                                      ref_27.username as c7
                                    from 
                                      test_bd.eids as ref_29
                                    where true
                                    limit 104)) 
                                or ((((true) 
                                      and (false)) 
                                    and (false)) 
                                  and (true)))) 
                            or (true)) 
                          or (true)) 
                        and (((((false) 
                                or (true)) 
                              or (((subq_2.c2 is not NULL) 
                                  and (ref_27.username is not NULL)) 
                                or (((false) 
                                    and (ref_27.username is not NULL)) 
                                  and (false)))) 
                            or (true)) 
                          or (ref_27.comment is not NULL))) 
                      and (ref_27.title is NULL))
                  limit 89))) 
            or (((subq_2.c5 is not NULL) 
                or ((false) 
                  or (subq_2.c5 is NULL))) 
              and (((EXISTS (
                    select  
                        ref_30.salary as c0, 
                        ref_30.department_id as c1, 
                        subq_2.c0 as c2, 
                        subq_2.c5 as c3, 
                        subq_2.c2 as c4, 
                        48 as c5, 
                        ref_30.id as c6, 
                        ref_30.age as c7, 
                        ref_30.eid as c8
                      from 
                        test_bd.employee as ref_30
                      where ref_30.department_id is NULL
                      limit 151)) 
                  and (subq_2.c1 is not NULL)) 
                and (true)))) 
          or (EXISTS (
            select  
                subq_2.c3 as c0
              from 
                test_bd.posts as ref_31,
                lateral (select  
                      ref_31.content as c0
                    from 
                      test_bd.comments as ref_32
                    where false
                    limit 141) as subq_5
              where false
              limit 122))) 
        or ((false) 
          and ((subq_2.c2 is not NULL) 
            or ((EXISTS (
                select  
                    subq_2.c3 as c0, 
                    (select username from test_bd.users limit 1 offset 3)
                       as c1, 
                    ref_33.tags as c2
                  from 
                    test_bd.products as ref_33,
                    lateral (select  
                          ref_33.price as c0, 
                          ref_34.comment as c1, 
                          ref_33.id as c2, 
                          subq_2.c5 as c3, 
                          subq_2.c1 as c4
                        from 
                          test_bd.user_post_comments as ref_34
                        where EXISTS (
                          select  
                              ref_33.discount as c0, 
                              ref_34.comment as c1, 
                              subq_2.c4 as c2
                            from 
                              test_bd.users as ref_35,
                              lateral (select  
                                    ref_36.eid as c0, 
                                    ref_33.discount as c1, 
                                    subq_2.c0 as c2, 
                                    subq_2.c4 as c3, 
                                    ref_35.id as c4, 
                                    subq_2.c2 as c5, 
                                    (select username from test_bd.user_post_comments limit 1 offset 1)
                                       as c6, 
                                    ref_33.created_at as c7, 
                                    ref_35.email as c8
                                  from 
                                    test_bd.eids as ref_36
                                  where (EXISTS (
                                      select  
                                          ref_37.price as c0, 
                                          ref_34.username as c1, 
                                          ref_37.id as c2, 
                                          subq_2.c3 as c3
                                        from 
                                          test_bd.products as ref_37
                                        where false)) 
                                    and (ref_35.id is not NULL)
                                  limit 12) as subq_6
                            where false
                            limit 63)
                        limit 134) as subq_7
                  where subq_7.c2 is not NULL
                  limit 139)) 
              or ((true) 
                and (false)))))))) 
  and ((EXISTS (
      select  
          subq_2.c3 as c0, 
          subq_2.c2 as c1, 
          ref_38.profile_picture as c2, 
          ref_38.birthdate as c3, 
          70 as c4, 
          subq_2.c0 as c5, 
          ref_38.profile_picture as c6, 
          subq_2.c2 as c7, 
          subq_2.c1 as c8, 
          subq_2.c2 as c9
        from 
          test_bd.user_profiles as ref_38
        where (true) 
          and ((select comment from test_bd.user_post_comments limit 1 offset 5)
               is NULL)
        limit 18)) 
    or (false))
limit 128;
SHOW profiles;