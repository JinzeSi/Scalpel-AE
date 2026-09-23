SET profiling=1;
EXPLAIN ANALYZE

select  
  (select category from test_bd.products limit 1 offset 21)
     as c0, 
  subq_5.c0 as c1, 
  subq_7.c6 as c2
from 
  (select  
        case when ref_1.name is not NULL then ref_7.created_at else ref_7.created_at end
           as c0
      from 
        test_bd.employee as ref_0
          right join test_bd.products as ref_1
              inner join test_bd.comments as ref_2
                inner join test_bd.users as ref_3
                on (EXISTS (
                    select  
                        ref_3.email as c0, 
                        ref_3.email as c1, 
                        36 as c2, 
                        ref_4.price as c3, 
                        ref_4.tags as c4, 
                        6 as c5, 
                        ref_3.id as c6, 
                        ref_4.created_at as c7, 
                        ref_4.id as c8, 
                        ref_3.username as c9, 
                        ref_3.email as c10, 
                        (select bio from test_bd.user_profiles limit 1 offset 1)
                           as c11, 
                        ref_4.name as c12, 
                        ref_2.user_id as c13, 
                        ref_2.post_id as c14, 
                        22 as c15, 
                        ref_2.post_id as c16, 
                        ref_2.created_at as c17, 
                        ref_4.id as c18, 
                        ref_2.comment as c19, 
                        40 as c20, 
                        ref_2.user_id as c21, 
                        ref_2.comment as c22, 
                        ref_4.category as c23, 
                        ref_3.username as c24, 
                        ref_4.category as c25, 
                        ref_3.email as c26, 
                        ref_3.id as c27, 
                        ref_3.email as c28
                      from 
                        test_bd.products as ref_4
                      where (true) 
                        or (EXISTS (
                          select  
                              ref_5.salary as c0, 
                              ref_4.id as c1, 
                              ref_2.post_id as c2, 
                              ref_2.user_id as c3, 
                              ref_3.created_at as c4, 
                              ref_2.id as c5, 
                              ref_4.id as c6, 
                              ref_2.comment as c7, 
                              ref_3.created_at as c8, 
                              ref_4.tags as c9, 
                              ref_3.username as c10, 
                              ref_2.created_at as c11, 
                              ref_4.name as c12, 
                              ref_4.tags as c13, 
                              ref_2.comment as c14
                            from 
                              test_bd.employee as ref_5
                            where false
                            limit 133))))
              on (ref_1.id = ref_3.id )
            inner join test_bd.eids as ref_6
              inner join test_bd.posts as ref_7
              on (ref_6.eid = ref_7.id )
            on (true)
          on ((((true) 
                  and ((select price from test_bd.products limit 1 offset 5)
                       is NULL)) 
                or (true)) 
              and (false))
      where (((EXISTS (
              select  
                  ref_2.user_id as c0, 
                  (select user_id from test_bd.comments limit 1 offset 47)
                     as c1, 
                  26 as c2, 
                  ref_6.id as c3
                from 
                  test_bd.employee as ref_8,
                  lateral (select  
                        ref_7.updated_at as c0
                      from 
                        test_bd.locations as ref_9
                      where (((EXISTS (
                              select  
                                  ref_10.user_id as c0
                                from 
                                  test_bd.locations as ref_10
                                where false
                                limit 167)) 
                            and (ref_6.virtual_col is not NULL)) 
                          and (((ref_9.name is NULL) 
                              and (false)) 
                            or (false))) 
                        or (false)
                      limit 81) as subq_0
                where ((ref_1.name is NULL) 
                    and (ref_7.content is not NULL)) 
                  or (((false) 
                      or ((ref_2.post_id is not NULL) 
                        and ((ref_2.comment is not NULL) 
                          and (ref_3.username is not NULL)))) 
                    and (false)))) 
            or (true)) 
          or (ref_3.email is not NULL)) 
        and ((true) 
          and (EXISTS (
            select  
                ref_0.hire_date as c0, 
                ref_11.email as c1, 
                ref_0.salary as c2, 
                ref_2.id as c3, 
                ref_3.email as c4, 
                ref_11.id as c5, 
                ref_2.comment as c6, 
                ref_0.department_id as c7, 
                ref_7.updated_at as c8, 
                ref_2.created_at as c9, 
                ref_1.category as c10, 
                ref_1.discount as c11
              from 
                test_bd.users as ref_11
              where ((((((ref_1.name is NULL) 
                          and ((true) 
                            or ((ref_1.discount is NULL) 
                              and (ref_11.email is not NULL)))) 
                        and (ref_6.eid is not NULL)) 
                      or (false)) 
                    or ((ref_1.discount is NULL) 
                      or (EXISTS (
                        select  
                            ref_3.email as c0
                          from 
                            test_bd.user_profiles as ref_12
                          where (true) 
                            or (EXISTS (
                              select  
                                  ref_2.id as c0, 
                                  ref_1.id as c1, 
                                  ref_1.tags as c2, 
                                  ref_3.created_at as c3, 
                                  ref_11.id as c4
                                from 
                                  test_bd.comments as ref_13,
                                  lateral (select  
                                        ref_13.created_at as c0, 
                                        ref_6.virtual_col as c1, 
                                        subq_2.c1 as c2, 
                                        ref_3.id as c3, 
                                        ref_0.eid as c4
                                      from 
                                        test_bd.users as ref_14,
                                        lateral (select  
                                              ref_12.profile_picture as c0, 
                                              ref_11.email as c1
                                            from 
                                              test_bd.locations as ref_15,
                                              lateral (select  
                                                    41 as c0, 
                                                    ref_0.eid as c1
                                                  from 
                                                    test_bd.eids as ref_16
                                                  where (false) 
                                                    and (true)
                                                  limit 94) as subq_1
                                            where false
                                            limit 124) as subq_2
                                      where false
                                      limit 86) as subq_3,
                                  lateral (select  
                                        ref_7.content as c0, 
                                        ref_3.created_at as c1, 
                                        ref_0.id as c2, 
                                        ref_0.email as c3, 
                                        ref_1.created_at as c4
                                      from 
                                        test_bd.comments as ref_17
                                      where ref_0.eid is not NULL
                                      limit 177) as subq_4
                                where ref_6.eid is not NULL))
                          limit 90)))) 
                  or (true)) 
                or ((false) 
                  or (1 is not NULL))
              limit 91)))
      limit 58) as subq_5,
  lateral (select  
        subq_6.c1 as c0, 
        subq_6.c1 as c1, 
        subq_5.c0 as c2, 
        subq_6.c1 as c3, 
        subq_5.c0 as c4, 
        subq_5.c0 as c5, 
        subq_6.c1 as c6, 
        subq_6.c0 as c7, 
        65 as c8, 
        subq_6.c0 as c9, 
        subq_6.c0 as c10, 
        subq_6.c1 as c11, 
        subq_6.c1 as c12, 
        25 as c13, 
        subq_5.c0 as c14, 
        subq_5.c0 as c15, 
        subq_6.c0 as c16, 
        coalesce(subq_6.c0,
          subq_6.c0) as c17, 
        subq_6.c0 as c18, 
        subq_6.c0 as c19, 
        subq_5.c0 as c20, 
        subq_6.c1 as c21, 
        subq_5.c0 as c22, 
        subq_5.c0 as c23
      from 
        (select  
              ref_18.eid as c0, 
              subq_5.c0 as c1
            from 
              test_bd.eids as ref_18
            where ((subq_5.c0 is NULL) 
                or ((subq_5.c0 is not NULL) 
                  and (true))) 
              and ((((select id from test_bd.comments limit 1 offset 47)
                       is NULL) 
                  or (false)) 
                and ((EXISTS (
                    select  
                        ref_19.user_id as c0, 
                        ref_18.eid as c1, 
                        subq_5.c0 as c2
                      from 
                        test_bd.locations as ref_19
                      where (ref_19.id is not NULL) 
                        or (false))) 
                  and ((subq_5.c0 is NULL) 
                    or (((false) 
                        or (subq_5.c0 is not NULL)) 
                      or ((subq_5.c0 is NULL) 
                        and (EXISTS (
                          select  
                              ref_18.eid as c0, 
                              ref_20.title as c1, 
                              ref_18.id as c2, 
                              ref_20.created_at as c3, 
                              ref_20.id as c4
                            from 
                              test_bd.posts as ref_20
                            where (true) 
                              or (ref_20.id is NULL)
                            limit 137)))))))
            limit 103) as subq_6
      where (false) 
        or (false)
      limit 71) as subq_7
where (((((subq_5.c0 is NULL) 
          and (true)) 
        and (subq_7.c17 is not NULL)) 
      or (((subq_7.c8 is not NULL) 
          or ((false) 
            or (((select created_at from test_bd.users limit 1 offset 2)
                   is NULL) 
              and (((((false) 
                      and (true)) 
                    or (EXISTS (
                      select  
                          subq_7.c5 as c0, 
                          subq_7.c21 as c1, 
                          subq_7.c19 as c2, 
                          subq_7.c4 as c3, 
                          (select user_id from test_bd.locations limit 1 offset 5)
                             as c4, 
                          88 as c5
                        from 
                          test_bd.employee as ref_21
                        where EXISTS (
                          select  
                              subq_5.c0 as c0, 
                              subq_7.c20 as c1, 
                              ref_22.birthdate as c2, 
                              subq_5.c0 as c3, 
                              ref_22.profile_picture as c4, 
                              ref_22.bio as c5, 
                              subq_7.c16 as c6, 
                              subq_5.c0 as c7, 
                              subq_7.c13 as c8, 
                              ref_22.birthdate as c9, 
                              ref_21.years as c10, 
                              ref_22.birthdate as c11, 
                              ref_21.salary as c12, 
                              subq_5.c0 as c13, 
                              ref_21.hire_date as c14, 
                              ref_21.age as c15, 
                              ref_22.birthdate as c16, 
                              ref_21.department_id as c17
                            from 
                              test_bd.user_profiles as ref_22
                            where (ref_22.user_id is not NULL) 
                              and (((false) 
                                  or (true)) 
                                and (((false) 
                                    or (EXISTS (
                                      select  
                                          ref_23.comment as c0, 
                                          subq_7.c14 as c1, 
                                          subq_5.c0 as c2
                                        from 
                                          test_bd.user_post_comments as ref_23
                                        where true
                                        limit 161))) 
                                  or ((true) 
                                    or (ref_22.birthdate is not NULL))))
                            limit 99)
                        limit 104))) 
                  or ((false) 
                    or (EXISTS (
                      select  
                          subq_8.c1 as c0, 
                          subq_8.c0 as c1, 
                          subq_8.c1 as c2, 
                          subq_7.c8 as c3
                        from 
                          test_bd.users as ref_24,
                          lateral (select distinct 
                                ref_25.birthdate as c0, 
                                ref_25.profile_picture as c1, 
                                (select birthdate from test_bd.user_profiles limit 1 offset 63)
                                   as c2
                              from 
                                test_bd.user_profiles as ref_25
                              where EXISTS (
                                select  
                                    ref_25.profile_picture as c0, 
                                    ref_26.title as c1, 
                                    ref_26.title as c2, 
                                    ref_26.title as c3, 
                                    ref_25.bio as c4, 
                                    ref_25.birthdate as c5, 
                                    ref_26.created_at as c6, 
                                    subq_7.c4 as c7, 
                                    ref_24.email as c8, 
                                    subq_7.c0 as c9, 
                                    ref_26.title as c10, 
                                    ref_24.username as c11
                                  from 
                                    test_bd.posts as ref_26
                                  where subq_5.c0 is NULL)
                              limit 64) as subq_8
                        where false
                        limit 150)))) 
                and ((subq_7.c11 is NULL) 
                  and (((subq_5.c0 is not NULL) 
                      and ((subq_5.c0 is NULL) 
                        and (true))) 
                    or (subq_7.c11 is not NULL))))))) 
        or (subq_5.c0 is NULL))) 
    and ((((((subq_7.c18 is NULL) 
              and (false)) 
            or (((false) 
                or ((EXISTS (
                    select  
                        ref_27.years as c0, 
                        subq_7.c17 as c1
                      from 
                        test_bd.employee as ref_27
                      where false
                      limit 83)) 
                  or ((false) 
                    and (subq_5.c0 is not NULL)))) 
              or (true))) 
          or (((subq_5.c0 is not NULL) 
              and ((false) 
                or (false))) 
            and (subq_5.c0 is NULL))) 
        or ((((((select eid from test_bd.eids limit 1 offset 4)
                     is NULL) 
                or (((true) 
                    and ((((((true) 
                              or (true)) 
                            or (false)) 
                          and (false)) 
                        and (subq_7.c16 is not NULL)) 
                      and ((false) 
                        or (subq_5.c0 is NULL)))) 
                  or (subq_7.c11 is NULL))) 
              and (subq_7.c22 is NULL)) 
            or (true)) 
          and ((subq_5.c0 is not NULL) 
            and ((subq_7.c21 is NULL) 
              and ((true) 
                or (true)))))) 
      and ((subq_7.c0 is NULL) 
        or (subq_5.c0 is NULL)))) 
  or (EXISTS (
    select  
        subq_9.c3 as c0, 
        subq_7.c3 as c1, 
        subq_9.c3 as c2, 
        subq_9.c0 as c3
      from 
        (select  
              ref_28.profile_picture as c0, 
              ref_28.profile_picture as c1, 
              subq_5.c0 as c2, 
              ref_29.user_id as c3
            from 
              test_bd.user_profiles as ref_28
                left join test_bd.user_profiles as ref_29
                on (((((EXISTS (
                            select  
                                ref_30.coordinates as c0
                              from 
                                test_bd.locations as ref_30
                              where subq_5.c0 is not NULL
                              limit 128)) 
                          or (subq_5.c0 is NULL)) 
                        and (false)) 
                      or ((EXISTS (
                          select  
                              subq_7.c2 as c0
                            from 
                              test_bd.locations as ref_31
                            where false)) 
                        or ((subq_7.c5 is not NULL) 
                          and (false)))) 
                    or ((true) 
                      and (true)))
            where false) as subq_9
      where EXISTS (
        select  
            subq_11.c3 as c0, 
            ref_32.content as c1, 
            subq_7.c3 as c2, 
            subq_7.c12 as c3, 
            6 as c4, 
            subq_5.c0 as c5, 
            subq_11.c7 as c6
          from 
            test_bd.posts as ref_32,
            lateral (select  
                  ref_32.id as c0, 
                  subq_7.c9 as c1, 
                  ref_33.post_id as c2, 
                  subq_9.c0 as c3, 
                  subq_9.c1 as c4, 
                  subq_7.c6 as c5, 
                  subq_9.c0 as c6, 
                  ref_33.comment as c7, 
                  subq_10.c1 as c8
                from 
                  test_bd.comments as ref_33,
                  lateral (select  
                        ref_32.updated_at as c0, 
                        subq_9.c3 as c1
                      from 
                        test_bd.user_profiles as ref_34
                      where ref_32.content is not NULL) as subq_10
                where true
                limit 51) as subq_11
          where (((true) 
                or (((EXISTS (
                      select  
                          subq_9.c1 as c0, 
                          subq_5.c0 as c1, 
                          subq_9.c2 as c2, 
                          subq_9.c0 as c3
                        from 
                          test_bd.users as ref_35
                        where false
                        limit 65)) 
                    and (ref_32.updated_at is NULL)) 
                  or ((true) 
                    and (false)))) 
              and ((((select id from test_bd.locations limit 1 offset 6)
                       is NULL) 
                  and (false)) 
                and ((((EXISTS (
                        select  
                            (select username from test_bd.users limit 1 offset 13)
                               as c0, 
                            subq_9.c2 as c1, 
                            subq_7.c18 as c2, 
                            subq_9.c2 as c3, 
                            subq_9.c3 as c4, 
                            subq_9.c2 as c5
                          from 
                            test_bd.users as ref_36
                          where EXISTS (
                            select  
                                ref_32.title as c0, 
                                ref_37.content as c1, 
                                subq_5.c0 as c2
                              from 
                                test_bd.posts as ref_37
                              where ((ref_37.id is not NULL) 
                                  or (((EXISTS (
                                        select  
                                            subq_13.c0 as c0, 
                                            subq_9.c0 as c1, 
                                            ref_32.content as c2, 
                                            subq_13.c1 as c3, 
                                            subq_9.c2 as c4
                                          from 
                                            test_bd.posts as ref_38,
                                            lateral (select  
                                                  subq_12.c15 as c0, 
                                                  subq_7.c5 as c1
                                                from 
                                                  test_bd.comments as ref_39,
                                                  lateral (select  
                                                        52 as c0, 
                                                        subq_9.c1 as c1, 
                                                        ref_32.id as c2, 
                                                        ref_38.updated_at as c3, 
                                                        (select comment from test_bd.user_post_comments limit 1 offset 3)
                                                           as c4, 
                                                        ref_38.id as c5, 
                                                        ref_32.created_at as c6, 
                                                        ref_39.user_id as c7, 
                                                        ref_40.comment as c8, 
                                                        subq_7.c10 as c9, 
                                                        ref_40.post_id as c10, 
                                                        subq_5.c0 as c11, 
                                                        ref_40.comment as c12, 
                                                        ref_37.title as c13, 
                                                        subq_5.c0 as c14, 
                                                        ref_37.updated_at as c15, 
                                                        ref_40.post_id as c16
                                                      from 
                                                        test_bd.comments as ref_40
                                                      where ((select id from test_bd.eids limit 1 offset 5)
                                                             is not NULL) 
                                                        and ((false) 
                                                          or ((false) 
                                                            and (false)))
                                                      limit 82) as subq_12
                                                where true
                                                limit 98) as subq_13
                                          where ((true) 
                                              or (true)) 
                                            or (EXISTS (
                                              select  
                                                  ref_32.content as c0, 
                                                  ref_32.updated_at as c1, 
                                                  subq_9.c3 as c2, 
                                                  (select profile_picture from test_bd.user_profiles limit 1 offset 6)
                                                     as c3
                                                from 
                                                  test_bd.user_post_comments as ref_41
                                                where (EXISTS (
                                                    select  
                                                        subq_11.c8 as c0
                                                      from 
                                                        test_bd.user_profiles as ref_42,
                                                        lateral (select  
                                                              subq_5.c0 as c0, 
                                                              ref_41.username as c1, 
                                                              ref_41.title as c2, 
                                                              subq_5.c0 as c3, 
                                                              subq_9.c1 as c4, 
                                                              ref_41.title as c5, 
                                                              ref_37.id as c6, 
                                                              ref_37.created_at as c7, 
                                                              ref_43.hire_date as c8, 
                                                              88 as c9, 
                                                              ref_32.id as c10, 
                                                              ref_41.comment as c11, 
                                                              subq_11.c3 as c12
                                                            from 
                                                              test_bd.employee as ref_43
                                                            where true) as subq_14
                                                      where true
                                                      limit 130)) 
                                                  or (((false) 
                                                      or (EXISTS (
                                                        select  
                                                            ref_32.title as c0, 
                                                            subq_5.c0 as c1, 
                                                            ref_36.created_at as c2
                                                          from 
                                                            test_bd.user_post_comments as ref_44
                                                          where (((true) 
                                                                and ((((true) 
                                                                      or (true)) 
                                                                    and ((select eid from test_bd.eids limit 1 offset 1)
                                                                         is not NULL)) 
                                                                  and (true))) 
                                                              or (true)) 
                                                            and (EXISTS (
                                                              select  
                                                                  ref_45.id as c0, 
                                                                  ref_44.username as c1, 
                                                                  ref_45.comment as c2, 
                                                                  subq_7.c23 as c3, 
                                                                  subq_13.c1 as c4, 
                                                                  ref_38.user_id as c5, 
                                                                  46 as c6, 
                                                                  2 as c7
                                                                from 
                                                                  test_bd.comments as ref_45
                                                                where (ref_41.title is NULL) 
                                                                  and ((subq_7.c11 is not NULL) 
                                                                    and (false))))
                                                          limit 86))) 
                                                    and (subq_9.c0 is not NULL))
                                                limit 82))
                                          limit 153)) 
                                      or (false)) 
                                    and (EXISTS (
                                      select distinct 
                                          47 as c0, 
                                          subq_9.c1 as c1, 
                                          ref_37.user_id as c2
                                        from 
                                          test_bd.products as ref_46
                                        where true
                                        limit 65)))) 
                                and (8 is NULL)))) 
                      or (false)) 
                    or (false)) 
                  or (subq_5.c0 is NULL)))) 
            or (EXISTS (
              select  
                  ref_47.username as c0, 
                  64 as c1, 
                  subq_7.c3 as c2, 
                  subq_9.c1 as c3, 
                  subq_11.c2 as c4, 
                  subq_5.c0 as c5, 
                  ref_32.created_at as c6, 
                  (select content from test_bd.posts limit 1 offset 3)
                     as c7, 
                  subq_9.c1 as c8, 
                  subq_11.c1 as c9, 
                  ref_32.title as c10, 
                  subq_11.c2 as c11, 
                  ref_32.title as c12, 
                  subq_5.c0 as c13, 
                  ref_47.title as c14, 
                  69 as c15
                from 
                  test_bd.user_post_comments as ref_47
                where false)))));
SHOW profiles;