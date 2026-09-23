SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_17.c2 as c0, 
  ref_0.name as c1, 
  subq_8.c1 as c2, 
  case when subq_8.c0 is NULL then subq_8.c4 else subq_8.c4 end
     as c3, 
  ref_0.coordinates as c4, 
  subq_17.c2 as c5
from 
  test_bd.locations as ref_0
    right join (select  
          ref_1.user_id as c0, 
          ref_1.coordinates as c1, 
          ref_1.id as c2, 
          ref_1.user_id as c3, 
          ref_1.user_id as c4
        from 
          test_bd.locations as ref_1
        where (((((ref_1.coordinates is NULL) 
                  and (((ref_1.name is NULL) 
                      or ((((ref_1.name is NULL) 
                            or (false)) 
                          and (true)) 
                        or ((select comment from test_bd.comments limit 1 offset 1)
                             is not NULL))) 
                    and (ref_1.coordinates is not NULL))) 
                or (ref_1.user_id is NULL)) 
              and (((((false) 
                      or (ref_1.coordinates is not NULL)) 
                    or (true)) 
                  and (ref_1.id is not NULL)) 
                or (((EXISTS (
                      select  
                          ref_1.coordinates as c0, 
                          ref_1.user_id as c1, 
                          ref_1.user_id as c2, 
                          ref_1.name as c3, 
                          ref_2.comment as c4, 
                          ref_2.username as c5
                        from 
                          test_bd.user_post_comments as ref_2
                        where false
                        limit 98)) 
                    and ((((((EXISTS (
                                select  
                                    ref_3.eid as c0
                                  from 
                                    test_bd.eids as ref_3
                                  where ((false) 
                                      or (ref_3.virtual_col is not NULL)) 
                                    or ((EXISTS (
                                        select  
                                            subq_0.c4 as c0
                                          from 
                                            test_bd.user_profiles as ref_4,
                                            lateral (select  
                                                  ref_5.age as c0, 
                                                  ref_3.eid as c1, 
                                                  ref_3.id as c2, 
                                                  ref_5.hire_date as c3, 
                                                  ref_1.id as c4, 
                                                  ref_3.id as c5
                                                from 
                                                  test_bd.employee as ref_5
                                                where false
                                                limit 44) as subq_0
                                          where EXISTS (
                                            select  
                                                28 as c0, 
                                                subq_0.c2 as c1, 
                                                ref_6.id as c2, 
                                                3 as c3, 
                                                ref_4.profile_picture as c4
                                              from 
                                                test_bd.products as ref_6
                                              where false)
                                          limit 39)) 
                                      or ((((false) 
                                            and (false)) 
                                          and ((false) 
                                            and (75 is not NULL))) 
                                        and (false))))) 
                              and ((ref_1.name is NULL) 
                                or (42 is not NULL))) 
                            or (false)) 
                          and ((EXISTS (
                              select  
                                  ref_7.id as c0, 
                                  ref_7.tags as c1, 
                                  ref_1.coordinates as c2, 
                                  ref_1.user_id as c3, 
                                  ref_1.id as c4, 
                                  ref_1.name as c5, 
                                  ref_7.category as c6, 
                                  ref_7.tags as c7
                                from 
                                  test_bd.products as ref_7
                                where EXISTS (
                                  select  
                                      ref_8.bio as c0, 
                                      15 as c1
                                    from 
                                      test_bd.user_profiles as ref_8
                                    where ref_7.tags is not NULL)
                                limit 109)) 
                            or (true))) 
                        or (ref_1.coordinates is not NULL)) 
                      and (false))) 
                  or (false)))) 
            and ((((EXISTS (
                    select  
                        ref_9.profile_picture as c0, 
                        ref_1.id as c1
                      from 
                        test_bd.user_profiles as ref_9
                      where EXISTS (
                        select  
                            ref_9.birthdate as c0, 
                            ref_9.profile_picture as c1, 
                            ref_9.birthdate as c2, 
                            ref_1.id as c3, 
                            ref_9.user_id as c4, 
                            ref_1.id as c5
                          from 
                            test_bd.comments as ref_10
                          where true
                          limit 51))) 
                  or ((true) 
                    or (((EXISTS (
                          select  
                              (select id from test_bd.employee limit 1 offset 2)
                                 as c0, 
                              ref_11.username as c1, 
                              ref_11.created_at as c2, 
                              ref_1.name as c3, 
                              ref_1.coordinates as c4, 
                              ref_11.username as c5, 
                              99 as c6, 
                              (select created_at from test_bd.posts limit 1 offset 6)
                                 as c7, 
                              ref_1.id as c8, 
                              ref_1.id as c9, 
                              ref_1.user_id as c10, 
                              ref_11.id as c11, 
                              ref_1.id as c12
                            from 
                              test_bd.users as ref_11
                            where (EXISTS (
                                select  
                                    ref_1.coordinates as c0
                                  from 
                                    test_bd.eids as ref_12
                                  where false
                                  limit 97)) 
                              or (ref_1.coordinates is NULL))) 
                        and (EXISTS (
                          select  
                              ref_1.user_id as c0, 
                              ref_13.title as c1, 
                              ref_1.user_id as c2, 
                              ref_13.title as c3, 
                              ref_1.id as c4, 
                              ref_13.id as c5, 
                              ref_13.created_at as c6, 
                              ref_13.id as c7
                            from 
                              test_bd.posts as ref_13
                            where 33 is not NULL
                            limit 110))) 
                      or (EXISTS (
                        select  
                            ref_14.id as c0
                          from 
                            test_bd.users as ref_14
                          where false
                          limit 75))))) 
                and (ref_1.user_id is NULL)) 
              or (((ref_1.name is not NULL) 
                  or ((((false) 
                        and (false)) 
                      and (true)) 
                    and (((((EXISTS (
                              select  
                                  ref_15.coordinates as c0, 
                                  ref_15.name as c1, 
                                  subq_1.c0 as c2, 
                                  ref_1.name as c3, 
                                  ref_1.user_id as c4
                                from 
                                  test_bd.locations as ref_15,
                                  lateral (select  
                                        ref_15.user_id as c0, 
                                        ref_15.user_id as c1, 
                                        ref_1.id as c2, 
                                        ref_1.coordinates as c3, 
                                        ref_16.id as c4, 
                                        ref_15.user_id as c5, 
                                        ref_16.created_at as c6
                                      from 
                                        test_bd.users as ref_16
                                      where false
                                      limit 68) as subq_1
                                where EXISTS (
                                  select  
                                      ref_1.user_id as c0, 
                                      ref_15.id as c1, 
                                      ref_15.name as c2, 
                                      ref_1.name as c3, 
                                      ref_1.name as c4
                                    from 
                                      test_bd.comments as ref_17
                                    where true
                                    limit 138)
                                limit 93)) 
                            or ((ref_1.id is NULL) 
                              or ((((false) 
                                    or (false)) 
                                  and (EXISTS (
                                    select  
                                        ref_18.coordinates as c0, 
                                        ref_1.id as c1, 
                                        (select post_id from test_bd.comments limit 1 offset 3)
                                           as c2, 
                                        ref_18.user_id as c3, 
                                        ref_1.name as c4, 
                                        ref_18.id as c5
                                      from 
                                        test_bd.locations as ref_18
                                      where EXISTS (
                                        select  
                                            ref_19.years as c0, 
                                            ref_18.user_id as c1, 
                                            ref_18.coordinates as c2
                                          from 
                                            test_bd.employee as ref_19
                                          where (false) 
                                            or (false))))) 
                                and (true)))) 
                          and (EXISTS (
                            select  
                                subq_7.c0 as c0
                              from 
                                test_bd.user_profiles as ref_20,
                                lateral (select distinct 
                                      subq_3.c23 as c0, 
                                      subq_3.c12 as c1, 
                                      ref_21.id as c2, 
                                      ref_21.id as c3, 
                                      ref_21.virtual_col as c4, 
                                      ref_1.coordinates as c5, 
                                      ref_21.id as c6, 
                                      ref_1.name as c7, 
                                      subq_3.c1 as c8, 
                                      ref_20.profile_picture as c9
                                    from 
                                      test_bd.eids as ref_21,
                                      lateral (select  
                                            subq_2.c3 as c0, 
                                            ref_22.comment as c1, 
                                            ref_21.virtual_col as c2, 
                                            ref_22.comment as c3, 
                                            subq_2.c3 as c4, 
                                            ref_22.title as c5, 
                                            subq_2.c4 as c6, 
                                            ref_1.id as c7, 
                                            ref_20.profile_picture as c8, 
                                            ref_1.coordinates as c9, 
                                            ref_22.username as c10, 
                                            ref_1.coordinates as c11, 
                                            subq_2.c2 as c12, 
                                            ref_21.eid as c13, 
                                            ref_1.user_id as c14, 
                                            ref_1.user_id as c15, 
                                            ref_21.eid as c16, 
                                            ref_22.username as c17, 
                                            ref_22.title as c18, 
                                            ref_20.user_id as c19, 
                                            ref_20.user_id as c20, 
                                            ref_20.user_id as c21, 
                                            subq_2.c1 as c22, 
                                            ref_20.profile_picture as c23
                                          from 
                                            test_bd.user_post_comments as ref_22,
                                            lateral (select  
                                                  ref_23.id as c0, 
                                                  ref_23.id as c1, 
                                                  ref_23.id as c2, 
                                                  ref_23.virtual_col as c3, 
                                                  ref_22.comment as c4
                                                from 
                                                  test_bd.eids as ref_23
                                                where ref_20.user_id is NULL) as subq_2
                                          where (ref_1.user_id is NULL) 
                                            and (EXISTS (
                                              select  
                                                  ref_22.username as c0, 
                                                  ref_1.name as c1, 
                                                  ref_1.user_id as c2, 
                                                  ref_22.username as c3, 
                                                  ref_1.coordinates as c4, 
                                                  ref_24.created_at as c5, 
                                                  ref_20.user_id as c6, 
                                                  ref_1.name as c7
                                                from 
                                                  test_bd.products as ref_24
                                                where (EXISTS (
                                                    select  
                                                        ref_22.username as c0, 
                                                        ref_22.title as c1, 
                                                        ref_20.bio as c2, 
                                                        ref_1.coordinates as c3, 
                                                        ref_25.username as c4, 
                                                        ref_24.created_at as c5, 
                                                        ref_24.id as c6, 
                                                        (select hire_date from test_bd.employee limit 1 offset 4)
                                                           as c7, 
                                                        ref_22.comment as c8, 
                                                        ref_1.coordinates as c9, 
                                                        ref_25.username as c10, 
                                                        ref_1.user_id as c11, 
                                                        ref_22.username as c12, 
                                                        ref_25.title as c13, 
                                                        ref_21.id as c14
                                                      from 
                                                        test_bd.user_post_comments as ref_25
                                                      where (subq_2.c3 is not NULL) 
                                                        and (true)
                                                      limit 105)) 
                                                  or (ref_21.eid is not NULL)
                                                limit 104))
                                          limit 71) as subq_3
                                    where (false) 
                                      and (true)) as subq_4,
                                lateral (select  
                                      ref_1.coordinates as c0, 
                                      subq_4.c7 as c1, 
                                      subq_6.c0 as c2
                                    from 
                                      test_bd.products as ref_26,
                                      lateral (select  
                                            ref_26.tags as c0, 
                                            ref_27.created_at as c1, 
                                            subq_4.c3 as c2, 
                                            ref_27.username as c3, 
                                            ref_20.user_id as c4, 
                                            75 as c5, 
                                            ref_27.id as c6, 
                                            ref_27.email as c7, 
                                            ref_20.bio as c8, 
                                            ref_26.discount as c9, 
                                            (select title from test_bd.user_post_comments limit 1 offset 6)
                                               as c10, 
                                            ref_26.tags as c11, 
                                            ref_27.created_at as c12, 
                                            ref_20.profile_picture as c13, 
                                            subq_4.c0 as c14, 
                                            ref_1.id as c15, 
                                            ref_20.user_id as c16, 
                                            ref_1.coordinates as c17, 
                                            ref_26.tags as c18, 
                                            ref_26.category as c19, 
                                            ref_27.email as c20, 
                                            subq_4.c3 as c21, 
                                            ref_1.id as c22, 
                                            ref_20.profile_picture as c23, 
                                            ref_20.user_id as c24
                                          from 
                                            test_bd.users as ref_27
                                          where true) as subq_5,
                                      lateral (select  
                                            ref_26.id as c0, 
                                            54 as c1, 
                                            ref_28.user_id as c2
                                          from 
                                            test_bd.user_profiles as ref_28
                                          where false
                                          limit 63) as subq_6
                                    where subq_5.c9 is not NULL
                                    limit 143) as subq_7
                              where (subq_7.c1 is NULL) 
                                and ((false) 
                                  and (true))))) 
                        and (ref_1.coordinates is not NULL)) 
                      and (true)))) 
                and (true)))) 
          and (ref_1.id is not NULL)
        limit 132) as subq_8
    on (ref_0.user_id = subq_8.c0 ),
  lateral (select  
        ref_37.created_at as c0, 
        subq_8.c2 as c1, 
        case when (((subq_15.c4 is NULL) 
                or (true)) 
              or (((true) 
                  and (EXISTS (
                    select  
                        subq_12.c2 as c0, 
                        ref_37.comment as c1
                      from 
                        test_bd.eids as ref_45,
                        lateral (select  
                              subq_12.c2 as c0, 
                              subq_14.c0 as c1, 
                              ref_0.coordinates as c2, 
                              ref_0.name as c3, 
                              subq_14.c0 as c4
                            from 
                              test_bd.user_profiles as ref_46
                            where true
                            limit 105) as subq_16
                      where (((((((((false) 
                                        or (((EXISTS (
                                              select  
                                                  ref_0.user_id as c0, 
                                                  subq_13.c1 as c1
                                                from 
                                                  test_bd.users as ref_47
                                                where EXISTS (
                                                  select  
                                                      subq_16.c3 as c0, 
                                                      ref_37.post_id as c1
                                                    from 
                                                      test_bd.user_profiles as ref_48
                                                    where false
                                                    limit 98)
                                                limit 34)) 
                                            and (true)) 
                                          or (((ref_45.id is not NULL) 
                                              and (true)) 
                                            and ((false) 
                                              and ((true) 
                                                and ((true) 
                                                  or (true))))))) 
                                      and ((select id from test_bd.eids limit 1 offset 3)
                                           is not NULL)) 
                                    and (true)) 
                                  and (false)) 
                                and (EXISTS (
                                  select  
                                      74 as c0, 
                                      ref_45.id as c1
                                    from 
                                      test_bd.locations as ref_49
                                    where subq_15.c4 is not NULL
                                    limit 98))) 
                              and ((true) 
                                and (((false) 
                                    or (EXISTS (
                                      select  
                                          ref_45.eid as c0, 
                                          ref_50.user_id as c1, 
                                          32 as c2, 
                                          subq_16.c0 as c3, 
                                          subq_15.c8 as c4, 
                                          ref_45.virtual_col as c5, 
                                          subq_15.c5 as c6, 
                                          subq_12.c1 as c7, 
                                          subq_13.c1 as c8, 
                                          14 as c9, 
                                          ref_37.post_id as c10, 
                                          subq_8.c3 as c11, 
                                          subq_15.c8 as c12, 
                                          ref_37.id as c13, 
                                          subq_15.c7 as c14
                                        from 
                                          test_bd.comments as ref_50
                                        where true
                                        limit 67))) 
                                  and (((subq_14.c0 is NULL) 
                                      and (subq_16.c2 is not NULL)) 
                                    and (((subq_15.c7 is NULL) 
                                        and (false)) 
                                      and (subq_14.c0 is NULL)))))) 
                            and ((false) 
                              and (subq_14.c0 is not NULL))) 
                          or (ref_45.virtual_col is not NULL)) 
                        and (true)
                      limit 164))) 
                and (ref_37.post_id is NULL))) 
            and (true) then 63 else 63 end
           as c2
      from 
        (select  
                subq_8.c0 as c0, 
                ref_29.id as c1, 
                ref_0.user_id as c2
              from 
                test_bd.users as ref_29
              where (ref_0.id is NULL) 
                or ((((true) 
                      or (ref_0.coordinates is not NULL)) 
                    and (((false) 
                        or (false)) 
                      and ((false) 
                        or ((false) 
                          or (true))))) 
                  or (((true) 
                      and ((false) 
                        or (false))) 
                    or ((((EXISTS (
                            select  
                                (select title from test_bd.posts limit 1 offset 4)
                                   as c0, 
                                ref_29.created_at as c1
                              from 
                                test_bd.eids as ref_30
                              where ((ref_29.username is NULL) 
                                  or (true)) 
                                and (true)
                              limit 102)) 
                          or (false)) 
                        and (((EXISTS (
                              select  
                                  subq_8.c1 as c0, 
                                  ref_31.email as c1, 
                                  ref_0.user_id as c2, 
                                  ref_0.user_id as c3
                                from 
                                  test_bd.employee as ref_31
                                where ref_31.eid is NULL
                                limit 112)) 
                            and ((false) 
                              and (false))) 
                          or (EXISTS (
                            select  
                                ref_0.name as c0, 
                                subq_11.c0 as c1, 
                                ref_32.price as c2, 
                                ref_32.tags as c3, 
                                ref_32.category as c4, 
                                subq_11.c0 as c5, 
                                subq_11.c0 as c6
                              from 
                                test_bd.products as ref_32,
                                lateral (select  
                                      subq_10.c1 as c0
                                    from 
                                      test_bd.comments as ref_33,
                                      lateral (select  
                                            subq_8.c3 as c0, 
                                            ref_33.user_id as c1, 
                                            ref_33.comment as c2, 
                                            ref_34.id as c3, 
                                            ref_32.category as c4, 
                                            ref_32.created_at as c5, 
                                            ref_32.price as c6, 
                                            ref_32.name as c7, 
                                            ref_34.id as c8, 
                                            ref_29.username as c9, 
                                            ref_34.username as c10, 
                                            ref_33.post_id as c11
                                          from 
                                            test_bd.users as ref_34
                                          where ref_32.price is not NULL
                                          limit 48) as subq_9,
                                      lateral (select  
                                            74 as c0, 
                                            ref_33.user_id as c1, 
                                            ref_33.id as c2, 
                                            ref_29.username as c3, 
                                            ref_35.coordinates as c4, 
                                            ref_0.id as c5, 
                                            ref_0.name as c6, 
                                            ref_29.email as c7
                                          from 
                                            test_bd.locations as ref_35
                                          where true) as subq_10
                                    where ref_0.coordinates is NULL
                                    limit 155) as subq_11
                              where false)))) 
                      and (EXISTS (
                        select  
                            ref_36.id as c0
                          from 
                            test_bd.eids as ref_36
                          where false
                          limit 64)))))
              limit 108) as subq_12
          inner join test_bd.comments as ref_37
          on (false),
        lateral (select  
              subq_12.c2 as c0, 
              subq_12.c0 as c1, 
              subq_12.c2 as c2, 
              subq_12.c2 as c3, 
              (select eid from test_bd.eids limit 1 offset 2)
                 as c4, 
              ref_38.category as c5
            from 
              test_bd.products as ref_38
            where ref_38.discount is not NULL
            limit 29) as subq_13,
        lateral (select  
              ref_0.id as c0
            from 
              test_bd.posts as ref_39
            where (true) 
              or ((false) 
                or ((subq_12.c1 is NULL) 
                  or (false)))
            limit 54) as subq_14,
        lateral (select  
              subq_13.c0 as c0, 
              subq_13.c3 as c1, 
              (select email from test_bd.users limit 1 offset 50)
                 as c2, 
              ref_37.user_id as c3, 
              ref_40.user_id as c4, 
              ref_0.user_id as c5, 
              subq_14.c0 as c6, 
              subq_12.c1 as c7, 
              41 as c8
            from 
              test_bd.user_profiles as ref_40
            where (((true) 
                  and (((subq_12.c2 is NULL) 
                      or (EXISTS (
                        select  
                            ref_41.username as c0, 
                            subq_14.c0 as c1, 
                            ref_40.user_id as c2, 
                            subq_12.c0 as c3, 
                            ref_41.username as c4, 
                            (select title from test_bd.user_post_comments limit 1 offset 4)
                               as c5, 
                            subq_8.c2 as c6, 
                            subq_14.c0 as c7, 
                            ref_37.user_id as c8, 
                            subq_12.c0 as c9, 
                            subq_13.c2 as c10, 
                            ref_0.id as c11, 
                            subq_8.c1 as c12
                          from 
                            test_bd.user_post_comments as ref_41
                          where false
                          limit 159))) 
                    or (true))) 
                or ((EXISTS (
                    select  
                        12 as c0, 
                        subq_13.c2 as c1, 
                        ref_37.user_id as c2
                      from 
                        test_bd.user_post_comments as ref_42
                      where EXISTS (
                        select  
                            ref_42.comment as c0, 
                            subq_13.c0 as c1
                          from 
                            test_bd.locations as ref_43
                          where (EXISTS (
                              select  
                                  subq_14.c0 as c0
                                from 
                                  test_bd.eids as ref_44
                                where (ref_42.username is not NULL) 
                                  or (true))) 
                            and (false)
                          limit 123))) 
                  and (true))) 
              or (((false) 
                  and (false)) 
                and (23 is not NULL))
            limit 15) as subq_15
      where (EXISTS (
          select  
              ref_51.comment as c0
            from 
              test_bd.user_post_comments as ref_51
                right join test_bd.users as ref_52
                on (EXISTS (
                    select  
                        ref_53.name as c0, 
                        ref_0.user_id as c1, 
                        subq_13.c4 as c2, 
                        subq_14.c0 as c3, 
                        (select discount from test_bd.products limit 1 offset 6)
                           as c4, 
                        subq_8.c2 as c5, 
                        ref_0.id as c6, 
                        ref_37.id as c7, 
                        subq_8.c1 as c8, 
                        (select department_id from test_bd.employee limit 1 offset 46)
                           as c9, 
                        ref_0.user_id as c10, 
                        ref_52.username as c11, 
                        (select id from test_bd.products limit 1 offset 5)
                           as c12, 
                        ref_0.coordinates as c13, 
                        subq_15.c5 as c14, 
                        subq_13.c5 as c15, 
                        subq_12.c0 as c16, 
                        subq_14.c0 as c17
                      from 
                        test_bd.products as ref_53
                      where subq_14.c0 is not NULL))
            where ((((((((true) 
                            or (true)) 
                          or ((ref_37.user_id is NULL) 
                            and (subq_14.c0 is NULL))) 
                        and (47 is not NULL)) 
                      or (EXISTS (
                        select  
                            ref_52.username as c0
                          from 
                            test_bd.users as ref_54
                          where 77 is NULL
                          limit 125))) 
                    and (true)) 
                  and ((true) 
                    or (true))) 
                and (subq_14.c0 is not NULL)) 
              and (subq_12.c2 is NULL))) 
        and (subq_15.c5 is not NULL)) as subq_17
where subq_8.c3 is not NULL
limit 99;
SHOW profiles;