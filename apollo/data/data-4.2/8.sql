SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c10 as c0, 
  subq_8.c8 as c1, 
  subq_0.c12 as c2, 
  subq_8.c0 as c3, 
  (select username from test_bd.user_post_comments limit 1 offset 5)
     as c4, 
  subq_0.c5 as c5, 
  subq_0.c25 as c6, 
  subq_12.c2 as c7, 
  subq_1.c0 as c8, 
  subq_0.c25 as c9, 
  (select bio from test_bd.user_profiles limit 1 offset 1)
     as c10, 
  subq_0.c14 as c11, 
  coalesce((select username from test_bd.user_post_comments limit 1 offset 2)
      ,
    subq_0.c17) as c12, 
  subq_0.c22 as c13
from 
  (select  
        ref_0.tags as c0, 
        ref_0.category as c1, 
        ref_0.price as c2, 
        ref_0.tags as c3, 
        ref_0.category as c4, 
        ref_0.discount as c5, 
        ref_0.price as c6, 
        ref_0.price as c7, 
        ref_0.discount as c8, 
        ref_0.id as c9, 
        ref_0.created_at as c10, 
        ref_0.created_at as c11, 
        case when false then ref_0.category else ref_0.category end
           as c12, 
        ref_0.discount as c13, 
        ref_0.created_at as c14, 
        ref_0.id as c15, 
        ref_0.name as c16, 
        ref_0.name as c17, 
        case when ref_0.tags is not NULL then ref_0.category else ref_0.category end
           as c18, 
        ref_0.tags as c19, 
        ref_0.price as c20, 
        ref_0.id as c21, 
        ref_0.discount as c22, 
        ref_0.name as c23, 
        ref_0.created_at as c24, 
        coalesce(ref_0.tags,
          ref_0.tags) as c25, 
        ref_0.discount as c26, 
        ref_0.price as c27
      from 
        test_bd.products as ref_0
      where true) as subq_0,
  lateral (select  
        ref_1.virtual_col as c0, 
        ref_1.virtual_col as c1, 
        ref_1.virtual_col as c2, 
        coalesce(subq_0.c21,
          subq_0.c21) as c3, 
        subq_0.c8 as c4
      from 
        test_bd.eids as ref_1
      where ((true) 
          and (ref_1.virtual_col is not NULL)) 
        or (ref_1.virtual_col is NULL)
      limit 77) as subq_1,
  lateral (select  
        (select coordinates from test_bd.locations limit 1 offset 45)
           as c0, 
        subq_0.c21 as c1, 
        (select eid from test_bd.eids limit 1 offset 6)
           as c2, 
        subq_0.c7 as c3, 
        ref_9.id as c4, 
        (select name from test_bd.locations limit 1 offset 1)
           as c5, 
        ref_4.age as c6, 
        subq_0.c23 as c7, 
        ref_9.user_id as c8, 
        ref_3.discount as c9, 
        subq_0.c14 as c10, 
        ref_3.price as c11, 
        subq_0.c26 as c12, 
        ref_2.category as c13, 
        ref_3.created_at as c14, 
        subq_0.c18 as c15, 
        subq_1.c3 as c16, 
        ref_9.id as c17, 
        case when false then ref_4.id else ref_4.id end
           as c18, 
        ref_4.salary as c19, 
        subq_1.c3 as c20, 
        ref_4.years as c21
      from 
        test_bd.products as ref_2
                left join test_bd.products as ref_3
                on (ref_2.category = ref_3.category )
              inner join test_bd.employee as ref_4
              on (((true) 
                    and (EXISTS (
                      select  
                          subq_1.c4 as c0, 
                          subq_1.c1 as c1, 
                          subq_0.c19 as c2
                        from 
                          test_bd.posts as ref_5
                        where ((false) 
                            and ((ref_5.title is NULL) 
                              or (((true) 
                                  or (EXISTS (
                                    select  
                                        subq_0.c2 as c0, 
                                        ref_6.id as c1, 
                                        ref_3.price as c2, 
                                        ref_3.category as c3
                                      from 
                                        test_bd.comments as ref_6
                                      where (false) 
                                        or (ref_2.id is NULL)
                                      limit 107))) 
                                and (EXISTS (
                                  select  
                                      ref_5.created_at as c0, 
                                      subq_0.c15 as c1
                                    from 
                                      test_bd.locations as ref_7
                                    where (false) 
                                      and (true)
                                    limit 134))))) 
                          and (EXISTS (
                            select  
                                ref_2.price as c0, 
                                ref_4.id as c1, 
                                ref_3.name as c2, 
                                ref_8.email as c3, 
                                ref_2.created_at as c4, 
                                ref_3.price as c5, 
                                ref_5.content as c6
                              from 
                                test_bd.employee as ref_8
                              where subq_0.c17 is not NULL
                              limit 126))
                        limit 143))) 
                  or (false))
            left join test_bd.locations as ref_9
            on (ref_2.category is NULL)
          right join test_bd.user_profiles as ref_10
          on (((false) 
                or (((ref_10.birthdate is NULL) 
                    and (EXISTS (
                      select  
                          ref_11.comment as c0
                        from 
                          test_bd.user_post_comments as ref_11
                        where EXISTS (
                          select  
                              ref_3.category as c0, 
                              ref_2.created_at as c1, 
                              (select id from test_bd.comments limit 1 offset 2)
                                 as c2, 
                              ref_10.birthdate as c3, 
                              ref_9.coordinates as c4, 
                              ref_10.birthdate as c5, 
                              ref_9.coordinates as c6, 
                              subq_1.c4 as c7, 
                              ref_3.created_at as c8, 
                              14 as c9, 
                              ref_2.category as c10, 
                              ref_4.email as c11, 
                              subq_0.c8 as c12, 
                              ref_9.user_id as c13, 
                              ref_3.id as c14, 
                              ref_12.name as c15
                            from 
                              test_bd.products as ref_12
                            where ref_11.username is not NULL)
                        limit 121))) 
                  or ((false) 
                    or (false)))) 
              and (((select username from test_bd.user_post_comments limit 1 offset 2)
                     is NULL) 
                and ((ref_4.age is NULL) 
                  or ((ref_3.id is not NULL) 
                    or ((false) 
                      and (((((true) 
                              and (EXISTS (
                                select  
                                    subq_5.c1 as c0, 
                                    subq_0.c2 as c1, 
                                    ref_9.coordinates as c2, 
                                    ref_2.created_at as c3, 
                                    ref_4.age as c4, 
                                    ref_10.bio as c5, 
                                    subq_2.c0 as c6, 
                                    subq_5.c9 as c7, 
                                    (select title from test_bd.user_post_comments limit 1 offset 2)
                                       as c8
                                  from 
                                    test_bd.user_profiles as ref_13,
                                    lateral (select  
                                          ref_10.profile_picture as c0, 
                                          65 as c1, 
                                          ref_14.tags as c2
                                        from 
                                          test_bd.products as ref_14
                                        where (((ref_4.salary is not NULL) 
                                              and ((false) 
                                                or (false))) 
                                            and (ref_2.id is not NULL)) 
                                          or (true)) as subq_2,
                                    lateral (select  
                                          (select created_at from test_bd.products limit 1 offset 4)
                                             as c0, 
                                          subq_0.c13 as c1, 
                                          ref_9.id as c2, 
                                          15 as c3, 
                                          ref_3.price as c4, 
                                          52 as c5, 
                                          ref_3.tags as c6, 
                                          subq_0.c18 as c7, 
                                          ref_15.tags as c8, 
                                          ref_4.department_id as c9, 
                                          ref_10.user_id as c10, 
                                          (select price from test_bd.products limit 1 offset 6)
                                             as c11, 
                                          ref_4.eid as c12, 
                                          ref_3.id as c13, 
                                          ref_10.profile_picture as c14, 
                                          subq_1.c3 as c15, 
                                          subq_0.c17 as c16, 
                                          subq_2.c2 as c17, 
                                          ref_10.profile_picture as c18, 
                                          subq_2.c0 as c19, 
                                          (select name from test_bd.products limit 1 offset 3)
                                             as c20, 
                                          ref_10.user_id as c21, 
                                          ref_3.id as c22
                                        from 
                                          test_bd.products as ref_15
                                        where (true) 
                                          and (((EXISTS (
                                                select  
                                                    ref_3.created_at as c0, 
                                                    (select user_id from test_bd.locations limit 1 offset 5)
                                                       as c1, 
                                                    ref_2.category as c2, 
                                                    ref_9.name as c3, 
                                                    subq_1.c2 as c4, 
                                                    ref_9.name as c5, 
                                                    subq_2.c0 as c6, 
                                                    ref_16.bio as c7, 
                                                    ref_16.user_id as c8, 
                                                    ref_10.bio as c9, 
                                                    ref_2.tags as c10
                                                  from 
                                                    test_bd.user_profiles as ref_16,
                                                    lateral (select  
                                                          subq_2.c1 as c0
                                                        from 
                                                          test_bd.user_profiles as ref_17
                                                        where EXISTS (
                                                          select  
                                                              ref_13.bio as c0
                                                            from 
                                                              test_bd.user_profiles as ref_18
                                                            where ((true) 
                                                                or (false)) 
                                                              or (((true) 
                                                                  and (ref_15.tags is NULL)) 
                                                                and (ref_9.coordinates is not NULL)))
                                                        limit 56) as subq_3
                                                  where false)) 
                                              and (EXISTS (
                                                select  
                                                    subq_2.c1 as c0, 
                                                    ref_15.id as c1, 
                                                    ref_9.id as c2, 
                                                    subq_0.c17 as c3
                                                  from 
                                                    test_bd.user_post_comments as ref_19,
                                                    lateral (select  
                                                          ref_9.user_id as c0, 
                                                          subq_1.c1 as c1, 
                                                          subq_1.c3 as c2, 
                                                          ref_10.profile_picture as c3, 
                                                          subq_0.c2 as c4, 
                                                          ref_9.id as c5, 
                                                          ref_9.id as c6, 
                                                          76 as c7, 
                                                          (select price from test_bd.products limit 1 offset 2)
                                                             as c8, 
                                                          ref_13.profile_picture as c9, 
                                                          ref_10.profile_picture as c10, 
                                                          ref_3.discount as c11, 
                                                          ref_15.category as c12, 
                                                          ref_20.bio as c13, 
                                                          ref_3.created_at as c14, 
                                                          ref_9.coordinates as c15, 
                                                          ref_9.coordinates as c16, 
                                                          ref_9.coordinates as c17
                                                        from 
                                                          test_bd.user_profiles as ref_20
                                                        where (false) 
                                                          and ((true) 
                                                            and (((EXISTS (
                                                                  select  
                                                                      ref_20.birthdate as c0, 
                                                                      (select bio from test_bd.user_profiles limit 1 offset 3)
                                                                         as c1, 
                                                                      ref_9.name as c2, 
                                                                      ref_9.name as c3, 
                                                                      subq_1.c0 as c4, 
                                                                      ref_13.profile_picture as c5, 
                                                                      (select department_id from test_bd.employee limit 1 offset 31)
                                                                         as c6, 
                                                                      64 as c7
                                                                    from 
                                                                      test_bd.user_profiles as ref_21
                                                                    where true
                                                                    limit 41)) 
                                                                and (false)) 
                                                              and (((false) 
                                                                  or (((select id from test_bd.eids limit 1 offset 1)
                                                                         is not NULL) 
                                                                    and ((true) 
                                                                      and (subq_1.c2 is NULL)))) 
                                                                and (ref_20.bio is not NULL))))
                                                        limit 48) as subq_4
                                                  where true
                                                  limit 152))) 
                                            or (ref_13.profile_picture is NULL))
                                        limit 101) as subq_5
                                  where subq_0.c19 is not NULL))) 
                            or (EXISTS (
                              select  
                                  ref_22.tags as c0, 
                                  subq_0.c0 as c1, 
                                  ref_9.name as c2, 
                                  (select id from test_bd.products limit 1 offset 96)
                                     as c3, 
                                  subq_1.c4 as c4, 
                                  (select profile_picture from test_bd.user_profiles limit 1 offset 1)
                                     as c5, 
                                  ref_22.id as c6, 
                                  subq_0.c23 as c7, 
                                  ref_9.name as c8, 
                                  63 as c9, 
                                  ref_9.name as c10, 
                                  7 as c11, 
                                  ref_9.user_id as c12, 
                                  ref_10.profile_picture as c13, 
                                  ref_10.profile_picture as c14, 
                                  ref_2.created_at as c15, 
                                  45 as c16, 
                                  ref_2.created_at as c17, 
                                  ref_4.salary as c18, 
                                  ref_3.discount as c19, 
                                  ref_4.hire_date as c20, 
                                  subq_1.c3 as c21, 
                                  ref_22.discount as c22, 
                                  ref_10.profile_picture as c23
                                from 
                                  test_bd.products as ref_22
                                where ((false) 
                                    or (false)) 
                                  and (false)
                                limit 46))) 
                          and ((true) 
                            or ((false) 
                              or ((EXISTS (
                                  select  
                                      ref_4.hire_date as c0, 
                                      ref_10.profile_picture as c1, 
                                      ref_9.name as c2, 
                                      subq_0.c24 as c3, 
                                      ref_4.email as c4, 
                                      ref_10.profile_picture as c5, 
                                      100 as c6, 
                                      ref_10.bio as c7, 
                                      ref_9.name as c8, 
                                      subq_1.c2 as c9, 
                                      subq_1.c4 as c10, 
                                      subq_7.c0 as c11, 
                                      ref_9.coordinates as c12, 
                                      (select eid from test_bd.employee limit 1 offset 6)
                                         as c13, 
                                      ref_9.id as c14, 
                                      subq_0.c3 as c15, 
                                      subq_0.c4 as c16, 
                                      ref_23.tags as c17, 
                                      93 as c18, 
                                      subq_7.c0 as c19, 
                                      ref_3.price as c20, 
                                      ref_10.user_id as c21, 
                                      ref_10.birthdate as c22, 
                                      ref_23.id as c23
                                    from 
                                      test_bd.products as ref_23,
                                      lateral (select  
                                            ref_4.department_id as c0
                                          from 
                                            test_bd.employee as ref_24
                                          where EXISTS (
                                            select  
                                                subq_6.c3 as c0, 
                                                subq_1.c4 as c1
                                              from 
                                                test_bd.users as ref_25,
                                                lateral (select  
                                                      ref_4.age as c0, 
                                                      ref_26.eid as c1, 
                                                      ref_26.eid as c2, 
                                                      ref_25.username as c3
                                                    from 
                                                      test_bd.employee as ref_26
                                                    where 15 is NULL) as subq_6
                                              where true
                                              limit 113)
                                          limit 67) as subq_7
                                    where EXISTS (
                                      select  
                                          ref_27.profile_picture as c0, 
                                          ref_10.birthdate as c1, 
                                          (select email from test_bd.users limit 1 offset 4)
                                             as c2
                                        from 
                                          test_bd.user_profiles as ref_27
                                        where (false) 
                                          or ((ref_23.created_at is NULL) 
                                            or (true))
                                        limit 129))) 
                                and ((true) 
                                  and (EXISTS (
                                    select  
                                        ref_4.id as c0, 
                                        subq_1.c3 as c1, 
                                        subq_0.c16 as c2, 
                                        ref_3.id as c3
                                      from 
                                        test_bd.locations as ref_28
                                      where false
                                      limit 96))))))) 
                        or ((false) 
                          and (EXISTS (
                            select  
                                subq_1.c2 as c0, 
                                24 as c1, 
                                ref_4.department_id as c2, 
                                subq_1.c4 as c3, 
                                ref_9.user_id as c4, 
                                ref_3.category as c5
                              from 
                                test_bd.locations as ref_29
                              where true
                              limit 99)))))))))
      where ref_2.discount is NULL
      limit 193) as subq_8,
  lateral (select  
        subq_8.c9 as c0, 
        ref_31.created_at as c1, 
        subq_1.c3 as c2
      from 
        test_bd.users as ref_30
          inner join test_bd.products as ref_31
          on (((((((true) 
                        or (true)) 
                      or (false)) 
                    or (((subq_1.c1 is NULL) 
                        and (EXISTS (
                          select  
                              ref_30.created_at as c0, 
                              subq_0.c6 as c1, 
                              ref_32.user_id as c2
                            from 
                              test_bd.comments as ref_32
                            where true
                            limit 83))) 
                      or (ref_30.email is not NULL))) 
                  and (true)) 
                and ((EXISTS (
                    select  
                        ref_30.email as c0
                      from 
                        test_bd.user_post_comments as ref_33,
                        lateral (select  
                              ref_31.id as c0, 
                              subq_1.c4 as c1, 
                              ref_34.created_at as c2, 
                              ref_30.email as c3, 
                              subq_1.c1 as c4, 
                              ref_30.created_at as c5, 
                              ref_34.updated_at as c6, 
                              subq_1.c4 as c7, 
                              subq_1.c0 as c8, 
                              ref_33.username as c9, 
                              subq_1.c0 as c10, 
                              subq_1.c3 as c11, 
                              15 as c12
                            from 
                              test_bd.posts as ref_34
                            where EXISTS (
                              select  
                                  (select title from test_bd.user_post_comments limit 1 offset 4)
                                     as c0, 
                                  ref_31.tags as c1, 
                                  ref_34.id as c2
                                from 
                                  test_bd.employee as ref_35
                                where false
                                limit 177)
                            limit 131) as subq_9
                      where (true) 
                        and (subq_8.c10 is NULL)
                      limit 106)) 
                  and ((subq_0.c15 is NULL) 
                    and (false)))) 
              and (EXISTS (
                select  
                    ref_30.email as c0, 
                    ref_36.eid as c1, 
                    subq_0.c5 as c2, 
                    subq_0.c6 as c3, 
                    subq_1.c2 as c4
                  from 
                    test_bd.employee as ref_36
                  where (true) 
                    or (((EXISTS (
                          select  
                              ref_37.price as c0, 
                              ref_36.email as c1, 
                              ref_30.username as c2, 
                              ref_37.tags as c3, 
                              (select id from test_bd.products limit 1 offset 2)
                                 as c4
                            from 
                              test_bd.products as ref_37,
                              lateral (select  
                                    ref_30.email as c0, 
                                    ref_30.email as c1, 
                                    ref_37.id as c2, 
                                    subq_0.c27 as c3, 
                                    subq_1.c3 as c4
                                  from 
                                    test_bd.posts as ref_38
                                  where (EXISTS (
                                      select  
                                          (select username from test_bd.user_post_comments limit 1 offset 5)
                                             as c0, 
                                          subq_1.c4 as c1, 
                                          (select user_id from test_bd.locations limit 1 offset 4)
                                             as c2, 
                                          ref_37.price as c3, 
                                          subq_1.c2 as c4, 
                                          ref_37.price as c5
                                        from 
                                          test_bd.employee as ref_39,
                                          lateral (select  
                                                subq_1.c4 as c0, 
                                                subq_0.c19 as c1
                                              from 
                                                test_bd.user_post_comments as ref_40
                                              where true
                                              limit 73) as subq_10
                                        where true
                                        limit 131)) 
                                    and (true)
                                  limit 132) as subq_11
                            where subq_11.c1 is not NULL
                            limit 149)) 
                        or ((((select created_at from test_bd.posts limit 1 offset 2)
                                 is NULL) 
                            and ((false) 
                              or (true))) 
                          or ((ref_30.email is not NULL) 
                            or ((((false) 
                                  or (ref_30.created_at is NULL)) 
                                and (true)) 
                              or (subq_0.c20 is NULL))))) 
                      and (ref_31.discount is NULL))
                  limit 142)))
      where subq_1.c2 is NULL
      limit 68) as subq_12
where subq_1.c1 is NULL;
SHOW profiles;