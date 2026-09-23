SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_42.title as c0, 
  ref_8.bio as c1
from 
  (select  
            ref_0.birthdate as c0, 
            (select name from test_bd.locations limit 1 offset 2)
               as c1, 
            ref_0.birthdate as c2
          from 
            test_bd.user_profiles as ref_0
          where (((((true) 
                    or ((select id from test_bd.eids limit 1 offset 3)
                         is NULL)) 
                  and (ref_0.profile_picture is NULL)) 
                and ((((false) 
                      or (ref_0.profile_picture is NULL)) 
                    and ((((false) 
                          or ((true) 
                            and ((true) 
                              and ((false) 
                                and (false))))) 
                        or (((EXISTS (
                              select  
                                  ref_1.bio as c0
                                from 
                                  test_bd.user_profiles as ref_1
                                where ((((true) 
                                        and (((((false) 
                                                or (EXISTS (
                                                  select  
                                                      ref_2.hire_date as c0, 
                                                      ref_2.hire_date as c1, 
                                                      ref_2.years as c2, 
                                                      ref_2.years as c3, 
                                                      ref_2.years as c4, 
                                                      ref_2.salary as c5, 
                                                      94 as c6, 
                                                      ref_2.department_id as c7, 
                                                      ref_0.user_id as c8, 
                                                      ref_2.years as c9, 
                                                      ref_1.user_id as c10
                                                    from 
                                                      test_bd.employee as ref_2
                                                    where true
                                                    limit 48))) 
                                              and (false)) 
                                            and (false)) 
                                          and (((true) 
                                              or (false)) 
                                            or ((false) 
                                              or (false))))) 
                                      or (((false) 
                                          or (true)) 
                                        and (ref_1.profile_picture is not NULL))) 
                                    or (true)) 
                                  or (ref_1.user_id is not NULL)
                                limit 101)) 
                            or (false)) 
                          or (ref_0.user_id is NULL))) 
                      or (true))) 
                  and ((((false) 
                        and (ref_0.birthdate is not NULL)) 
                      and (ref_0.birthdate is not NULL)) 
                    and ((false) 
                      and (((true) 
                          and (ref_0.bio is NULL)) 
                        and (ref_0.profile_picture is NULL)))))) 
              and (EXISTS (
                select  
                    ref_0.bio as c0, 
                    ref_0.profile_picture as c1, 
                    ref_3.tags as c2, 
                    ref_3.discount as c3, 
                    ref_0.user_id as c4, 
                    ref_3.category as c5, 
                    ref_0.birthdate as c6, 
                    ref_0.bio as c7, 
                    ref_3.discount as c8, 
                    ref_3.tags as c9, 
                    ref_3.name as c10
                  from 
                    test_bd.products as ref_3
                  where (ref_3.tags is NULL) 
                    or ((ref_3.name is not NULL) 
                      and (((false) 
                          and ((true) 
                            or (((((select created_at from test_bd.users limit 1 offset 5)
                                       is NULL) 
                                  and ((false) 
                                    or ((true) 
                                      and ((((((((false) 
                                                    and (false)) 
                                                  or (ref_3.discount is not NULL)) 
                                                or ((false) 
                                                  or (false))) 
                                              or (ref_3.discount is NULL)) 
                                            or ((true) 
                                              and (true))) 
                                          or (ref_0.profile_picture is not NULL)) 
                                        or (false))))) 
                                or ((EXISTS (
                                    select  
                                        ref_0.birthdate as c0, 
                                        ref_4.title as c1, 
                                        ref_0.profile_picture as c2, 
                                        ref_4.content as c3, 
                                        ref_4.id as c4, 
                                        ref_3.price as c5, 
                                        ref_0.bio as c6, 
                                        (select user_id from test_bd.locations limit 1 offset 3)
                                           as c7, 
                                        ref_4.content as c8, 
                                        ref_4.title as c9
                                      from 
                                        test_bd.posts as ref_4
                                      where (false) 
                                        and (false)
                                      limit 101)) 
                                  and ((((select salary from test_bd.employee limit 1 offset 1)
                                           is NULL) 
                                      or ((true) 
                                        and ((((true) 
                                              and (true)) 
                                            or (false)) 
                                          and (false)))) 
                                    or (ref_3.created_at is not NULL)))) 
                              and ((true) 
                                and ((true) 
                                  or (((ref_3.price is not NULL) 
                                      or ((false) 
                                        and (ref_3.discount is not NULL))) 
                                    and (ref_0.profile_picture is not NULL))))))) 
                        and (true)))
                  limit 84))) 
            or (false)
          limit 158) as subq_0
      right join (select  
              ref_5.discount as c0, 
              ref_5.price as c1, 
              ref_5.discount as c2, 
              ref_5.discount as c3
            from 
              test_bd.products as ref_5
            where ref_5.name is not NULL
            limit 52) as subq_1
        right join test_bd.comments as ref_6
            inner join test_bd.user_post_comments as ref_7
              inner join test_bd.user_profiles as ref_8
              on (EXISTS (
                  select  
                      ref_8.profile_picture as c0, 
                      ref_8.birthdate as c1, 
                      ref_8.profile_picture as c2
                    from 
                      test_bd.users as ref_9
                    where EXISTS (
                      select  
                          ref_8.profile_picture as c0
                        from 
                          test_bd.employee as ref_10
                        where ((EXISTS (
                              select  
                                  ref_10.years as c0, 
                                  ref_10.id as c1, 
                                  ref_8.birthdate as c2, 
                                  ref_7.comment as c3, 
                                  ref_10.id as c4, 
                                  ref_8.profile_picture as c5
                                from 
                                  test_bd.comments as ref_11
                                where EXISTS (
                                  select  
                                      ref_10.age as c0
                                    from 
                                      test_bd.employee as ref_12
                                    where false
                                    limit 149))) 
                            or (((true) 
                                or (EXISTS (
                                  select  
                                      ref_10.age as c0, 
                                      (select eid from test_bd.eids limit 1 offset 1)
                                         as c1
                                    from 
                                      test_bd.eids as ref_13
                                    where EXISTS (
                                      select  
                                          ref_8.bio as c0, 
                                          subq_2.c9 as c1, 
                                          ref_14.username as c2, 
                                          ref_7.username as c3, 
                                          ref_14.created_at as c4, 
                                          ref_8.user_id as c5
                                        from 
                                          test_bd.users as ref_14,
                                          lateral (select  
                                                ref_10.eid as c0, 
                                                ref_10.years as c1, 
                                                ref_7.comment as c2, 
                                                ref_8.profile_picture as c3, 
                                                (select comment from test_bd.user_post_comments limit 1 offset 6)
                                                   as c4, 
                                                (select id from test_bd.comments limit 1 offset 5)
                                                   as c5, 
                                                ref_10.salary as c6, 
                                                ref_9.created_at as c7, 
                                                ref_9.email as c8, 
                                                (select coordinates from test_bd.locations limit 1 offset 4)
                                                   as c9, 
                                                ref_10.hire_date as c10, 
                                                ref_10.years as c11, 
                                                ref_13.id as c12
                                              from 
                                                test_bd.eids as ref_15
                                              where true) as subq_2
                                        where false)
                                    limit 14))) 
                              or (false))) 
                          and (EXISTS (
                            select  
                                ref_7.comment as c0, 
                                ref_7.username as c1, 
                                ref_8.bio as c2, 
                                ref_10.email as c3, 
                                ref_10.age as c4, 
                                ref_10.age as c5, 
                                ref_9.email as c6, 
                                ref_16.post_id as c7
                              from 
                                test_bd.comments as ref_16
                              where (((((false) 
                                        and (EXISTS (
                                          select  
                                              ref_7.username as c0
                                            from 
                                              test_bd.eids as ref_17
                                            where ((((ref_9.email is not NULL) 
                                                    or (EXISTS (
                                                      select  
                                                          ref_17.virtual_col as c0, 
                                                          30 as c1, 
                                                          ref_10.eid as c2
                                                        from 
                                                          test_bd.comments as ref_18
                                                        where true))) 
                                                  and (((false) 
                                                      and (false)) 
                                                    and (true))) 
                                                and (true)) 
                                              or (EXISTS (
                                                select  
                                                    ref_19.name as c0, 
                                                    ref_8.bio as c1, 
                                                    ref_10.age as c2, 
                                                    ref_16.post_id as c3, 
                                                    ref_10.age as c4, 
                                                    ref_17.id as c5
                                                  from 
                                                    test_bd.products as ref_19
                                                  where (true) 
                                                    or (ref_10.salary is not NULL)
                                                  limit 136))
                                            limit 188))) 
                                      or (true)) 
                                    and (ref_8.bio is NULL)) 
                                  and (EXISTS (
                                    select  
                                        ref_20.email as c0, 
                                        ref_9.email as c1, 
                                        ref_20.email as c2, 
                                        ref_9.email as c3, 
                                        ref_16.created_at as c4
                                      from 
                                        test_bd.users as ref_20
                                      where true
                                      limit 72))) 
                                and ((((true) 
                                      and (true)) 
                                    and (EXISTS (
                                      select  
                                          ref_16.comment as c0, 
                                          ref_9.id as c1, 
                                          ref_7.title as c2, 
                                          ref_21.years as c3, 
                                          ref_16.comment as c4
                                        from 
                                          test_bd.employee as ref_21
                                        where EXISTS (
                                          select  
                                              ref_7.username as c0, 
                                              ref_16.id as c1, 
                                              ref_22.years as c2, 
                                              ref_9.created_at as c3, 
                                              ref_16.post_id as c4, 
                                              ref_8.user_id as c5, 
                                              ref_8.profile_picture as c6, 
                                              ref_16.user_id as c7, 
                                              ref_9.email as c8, 
                                              ref_21.eid as c9, 
                                              ref_10.id as c10, 
                                              ref_22.age as c11, 
                                              71 as c12
                                            from 
                                              test_bd.employee as ref_22
                                            where (false) 
                                              or (false)
                                            limit 137)
                                        limit 177))) 
                                  or (((EXISTS (
                                        select  
                                            ref_8.bio as c0, 
                                            ref_10.department_id as c1, 
                                            ref_10.eid as c2
                                          from 
                                            test_bd.locations as ref_23
                                          where true
                                          limit 72)) 
                                      or (ref_8.birthdate is NULL)) 
                                    and (ref_9.id is NULL)))
                              limit 190)))))
            on (ref_6.comment = ref_8.bio )
          inner join test_bd.locations as ref_24
          on (ref_8.birthdate is NULL)
        on ((EXISTS (
              select  
                  ref_7.title as c0, 
                  ref_25.user_id as c1
                from 
                  test_bd.user_profiles as ref_25
                where EXISTS (
                  select  
                      ref_8.birthdate as c0, 
                      ref_24.coordinates as c1, 
                      45 as c2, 
                      ref_26.user_id as c3
                    from 
                      test_bd.locations as ref_26
                    where true
                    limit 104)
                limit 89)) 
            or (ref_7.comment is NULL))
      on (((subq_0.c1 is not NULL) 
            and (((((subq_1.c3 is NULL) 
                    or (ref_24.user_id is NULL)) 
                  and ((ref_24.user_id is not NULL) 
                    and (EXISTS (
                      select  
                          ref_24.coordinates as c0, 
                          subq_0.c1 as c1, 
                          ref_27.eid as c2
                        from 
                          test_bd.eids as ref_27
                        where (EXISTS (
                            select  
                                subq_0.c0 as c0, 
                                ref_6.comment as c1
                              from 
                                test_bd.employee as ref_28
                              where false
                              limit 40)) 
                          or (false)
                        limit 31)))) 
                and (((EXISTS (
                      select  
                          ref_29.birthdate as c0
                        from 
                          test_bd.user_profiles as ref_29,
                          lateral (select  
                                ref_8.bio as c0, 
                                ref_29.birthdate as c1, 
                                ref_29.profile_picture as c2, 
                                ref_30.username as c3
                              from 
                                test_bd.users as ref_30
                              where false
                              limit 106) as subq_3
                        where ref_24.coordinates is NULL
                        limit 59)) 
                    or ((true) 
                      and (true))) 
                  and (true))) 
              or ((((ref_8.birthdate is NULL) 
                    and (true)) 
                  and (((EXISTS (
                        select  
                            subq_1.c3 as c0, 
                            subq_1.c2 as c1, 
                            ref_31.user_id as c2
                          from 
                            test_bd.user_profiles as ref_31
                          where ref_6.created_at is NULL)) 
                      or ((false) 
                        or (true))) 
                    and (ref_8.bio is NULL))) 
                or (false)))) 
          or (((subq_0.c2 is NULL) 
              or ((EXISTS (
                  select  
                      subq_0.c1 as c0, 
                      ref_24.name as c1, 
                      subq_0.c2 as c2, 
                      1 as c3, 
                      ref_8.profile_picture as c4, 
                      (select birthdate from test_bd.user_profiles limit 1 offset 4)
                         as c5, 
                      subq_1.c0 as c6, 
                      subq_1.c0 as c7
                    from 
                      test_bd.user_profiles as ref_32
                    where (ref_7.comment is NULL) 
                      and (false))) 
                or (((((EXISTS (
                          select  
                              subq_1.c3 as c0, 
                              (select years from test_bd.employee limit 1 offset 6)
                                 as c1, 
                              ref_7.comment as c2, 
                              ref_24.coordinates as c3, 
                              subq_0.c1 as c4, 
                              ref_8.birthdate as c5, 
                              subq_1.c0 as c6, 
                              ref_33.username as c7, 
                              ref_6.id as c8, 
                              ref_24.coordinates as c9, 
                              ref_24.user_id as c10, 
                              subq_1.c1 as c11
                            from 
                              test_bd.users as ref_33
                            where true)) 
                        and (false)) 
                      and (false)) 
                    and (((false) 
                        or (EXISTS (
                          select  
                              ref_24.name as c0, 
                              ref_8.birthdate as c1, 
                              subq_1.c2 as c2, 
                              7 as c3, 
                              ref_8.bio as c4, 
                              subq_1.c2 as c5, 
                              ref_34.created_at as c6, 
                              23 as c7, 
                              ref_6.comment as c8
                            from 
                              test_bd.posts as ref_34
                            where true
                            limit 59))) 
                      or (((ref_6.post_id is not NULL) 
                          or ((false) 
                            or (EXISTS (
                              select  
                                  ref_8.bio as c0, 
                                  ref_8.bio as c1, 
                                  ref_6.created_at as c2, 
                                  subq_0.c2 as c3, 
                                  32 as c4, 
                                  subq_1.c2 as c5, 
                                  ref_6.created_at as c6, 
                                  42 as c7
                                from 
                                  test_bd.comments as ref_35
                                where EXISTS (
                                  select  
                                      subq_1.c0 as c0, 
                                      subq_0.c2 as c1, 
                                      83 as c2, 
                                      ref_36.virtual_col as c3, 
                                      ref_8.birthdate as c4, 
                                      ref_35.created_at as c5, 
                                      ref_24.user_id as c6
                                    from 
                                      test_bd.eids as ref_36
                                    where true))))) 
                        and (76 is NULL)))) 
                  and ((subq_0.c0 is NULL) 
                    or ((((true) 
                          or (true)) 
                        and (true)) 
                      or (((true) 
                          or ((ref_24.user_id is NULL) 
                            or ((false) 
                              and (false)))) 
                        or ((subq_1.c2 is not NULL) 
                          and (((((true) 
                                  and ((EXISTS (
                                      select  
                                          ref_6.id as c0, 
                                          ref_6.post_id as c1, 
                                          ref_24.user_id as c2, 
                                          ref_7.comment as c3, 
                                          (select id from test_bd.eids limit 1 offset 1)
                                             as c4
                                        from 
                                          test_bd.locations as ref_37
                                        where true)) 
                                    or (((false) 
                                        and (true)) 
                                      or ((EXISTS (
                                          select  
                                              ref_38.discount as c0, 
                                              ref_38.discount as c1, 
                                              subq_0.c2 as c2
                                            from 
                                              test_bd.products as ref_38
                                            where EXISTS (
                                              select  
                                                  subq_1.c3 as c0, 
                                                  (select created_at from test_bd.comments limit 1 offset 3)
                                                     as c1, 
                                                  ref_7.comment as c2, 
                                                  ref_8.bio as c3, 
                                                  ref_8.birthdate as c4
                                                from 
                                                  test_bd.comments as ref_39
                                                where true))) 
                                        or (((40 is not NULL) 
                                            or ((subq_0.c2 is NULL) 
                                              or (ref_7.comment is not NULL))) 
                                          or ((false) 
                                            and (ref_8.birthdate is NULL))))))) 
                                or ((false) 
                                  or (ref_24.id is not NULL))) 
                              and (subq_0.c1 is not NULL)) 
                            and (EXISTS (
                              select  
                                  (select hire_date from test_bd.employee limit 1 offset 3)
                                     as c0, 
                                  ref_8.user_id as c1, 
                                  ref_6.user_id as c2, 
                                  ref_24.user_id as c3, 
                                  subq_0.c0 as c4, 
                                  75 as c5
                                from 
                                  test_bd.user_post_comments as ref_40
                                where ((true) 
                                    or (EXISTS (
                                      select  
                                          subq_1.c1 as c0, 
                                          ref_7.title as c1, 
                                          ref_6.created_at as c2, 
                                          57 as c3, 
                                          ref_7.username as c4, 
                                          ref_40.title as c5
                                        from 
                                          test_bd.employee as ref_41
                                        where (true) 
                                          or (ref_6.post_id is not NULL)
                                        limit 133))) 
                                  or (((true) 
                                      or ((false) 
                                        and (true))) 
                                    and (subq_1.c1 is not NULL))
                                limit 108)))))))))) 
            or (true)))
    left join test_bd.user_post_comments as ref_42
    on ((subq_0.c0 is not NULL) 
        or (ref_7.title is NULL))
where ((EXISTS (
      select  
          ref_8.profile_picture as c0
        from 
          test_bd.products as ref_43
        where EXISTS (
          select  
              subq_1.c2 as c0, 
              ref_24.id as c1, 
              ref_44.comment as c2, 
              ref_44.title as c3, 
              ref_8.user_id as c4, 
              ref_8.profile_picture as c5, 
              (select virtual_col from test_bd.eids limit 1 offset 3)
                 as c6, 
              ref_44.comment as c7, 
              ref_7.title as c8
            from 
              test_bd.user_post_comments as ref_44
            where ref_8.profile_picture is NULL
            limit 90)
        limit 102)) 
    and (EXISTS (
      select  
          ref_42.comment as c0, 
          ref_7.title as c1, 
          subq_0.c1 as c2, 
          ref_45.title as c3, 
          ref_8.profile_picture as c4, 
          (select id from test_bd.posts limit 1 offset 4)
             as c5, 
          ref_8.bio as c6
        from 
          test_bd.posts as ref_45
        where (((((select comment from test_bd.user_post_comments limit 1 offset 3)
                     is NULL) 
                or (EXISTS (
                  select  
                      subq_0.c1 as c0
                    from 
                      test_bd.products as ref_46
                    where true
                    limit 166))) 
              or (false)) 
            or (ref_24.user_id is NULL)) 
          and (ref_45.updated_at is not NULL)
        limit 111))) 
  or ((subq_0.c0 is NULL) 
    or (ref_8.bio is NULL));
SHOW profiles;