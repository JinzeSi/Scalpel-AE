SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_8.c6 as c0, 
  subq_3.c0 as c1, 
  subq_8.c8 as c2, 
  subq_8.c2 as c3, 
  subq_8.c8 as c4, 
  case when ((subq_8.c5 is NULL) 
        and (true)) 
      and ((((((EXISTS (
                  select  
                      subq_8.c8 as c0, 
                      subq_8.c8 as c1
                    from 
                      test_bd.employee as ref_35
                    where ref_35.id is NULL
                    limit 114)) 
                and ((true) 
                  or (EXISTS (
                    select  
                        ref_36.content as c0, 
                        ref_36.updated_at as c1
                      from 
                        test_bd.posts as ref_36
                      where (((ref_36.updated_at is NULL) 
                            or (((EXISTS (
                                  select  
                                      subq_3.c2 as c0, 
                                      subq_8.c6 as c1, 
                                      ref_36.title as c2, 
                                      subq_8.c3 as c3, 
                                      ref_36.user_id as c4
                                    from 
                                      test_bd.comments as ref_37
                                    where EXISTS (
                                      select  
                                          ref_38.coordinates as c0, 
                                          subq_3.c2 as c1, 
                                          ref_38.id as c2, 
                                          ref_36.title as c3, 
                                          ref_37.post_id as c4, 
                                          (select user_id from test_bd.posts limit 1 offset 3)
                                             as c5, 
                                          ref_38.id as c6
                                        from 
                                          test_bd.locations as ref_38
                                        where (((true) 
                                              and (((true) 
                                                  and (true)) 
                                                or (ref_37.id is not NULL))) 
                                            or (ref_38.coordinates is not NULL)) 
                                          and (EXISTS (
                                            select  
                                                ref_36.content as c0, 
                                                subq_9.c3 as c1, 
                                                subq_8.c2 as c2, 
                                                ref_36.id as c3, 
                                                subq_8.c5 as c4, 
                                                ref_36.updated_at as c5, 
                                                subq_3.c2 as c6, 
                                                ref_37.post_id as c7, 
                                                ref_38.id as c8, 
                                                ref_37.post_id as c9, 
                                                ref_36.id as c10, 
                                                subq_3.c0 as c11, 
                                                ref_38.name as c12, 
                                                subq_3.c1 as c13, 
                                                subq_8.c5 as c14, 
                                                subq_3.c2 as c15, 
                                                subq_3.c1 as c16, 
                                                subq_9.c1 as c17, 
                                                subq_8.c8 as c18
                                              from 
                                                test_bd.eids as ref_39,
                                                lateral (select  
                                                      ref_39.virtual_col as c0, 
                                                      subq_8.c0 as c1, 
                                                      subq_8.c8 as c2, 
                                                      ref_38.id as c3, 
                                                      ref_38.coordinates as c4
                                                    from 
                                                      test_bd.locations as ref_40
                                                    where false
                                                    limit 131) as subq_9
                                              where false
                                              limit 97))
                                        limit 71))) 
                                or ((true) 
                                  and (ref_36.title is NULL))) 
                              or (true))) 
                          and (subq_8.c0 is not NULL)) 
                        or (subq_3.c1 is NULL)
                      limit 163)))) 
              and (EXISTS (
                select  
                    ref_41.username as c0, 
                    subq_8.c3 as c1, 
                    subq_3.c2 as c2, 
                    ref_41.title as c3, 
                    subq_8.c0 as c4
                  from 
                    test_bd.user_post_comments as ref_41
                  where (subq_3.c1 is NULL) 
                    and (subq_8.c0 is not NULL)
                  limit 17))) 
            and ((EXISTS (
                select  
                    ref_42.bio as c0, 
                    ref_42.user_id as c1
                  from 
                    test_bd.user_profiles as ref_42
                  where EXISTS (
                    select  
                        ref_43.profile_picture as c0, 
                        ref_42.birthdate as c1
                      from 
                        test_bd.user_profiles as ref_43,
                        lateral (select  
                              subq_8.c5 as c0, 
                              ref_44.email as c1
                            from 
                              test_bd.employee as ref_44
                            where false) as subq_10
                      where false
                      limit 87))) 
              or ((subq_8.c3 is NULL) 
                or (false)))) 
          or (false)) 
        or ((false) 
          or ((true) 
            and (((subq_3.c1 is not NULL) 
                or (EXISTS (
                  select  
                      ref_45.user_id as c0, 
                      subq_8.c0 as c1
                    from 
                      test_bd.locations as ref_45
                    where subq_8.c5 is NULL))) 
              or ((EXISTS (
                  select  
                      subq_3.c1 as c0, 
                      (select id from test_bd.employee limit 1 offset 2)
                         as c1, 
                      subq_8.c2 as c2
                    from 
                      test_bd.user_profiles as ref_46
                    where (((EXISTS (
                            select  
                                (select price from test_bd.products limit 1 offset 1)
                                   as c0, 
                                ref_47.profile_picture as c1
                              from 
                                test_bd.user_profiles as ref_47
                              where (true) 
                                or (1 is NULL))) 
                          and (((false) 
                              or (((true) 
                                  and ((select virtual_col from test_bd.eids limit 1 offset 45)
                                       is not NULL)) 
                                and (57 is not NULL))) 
                            and ((false) 
                              and (subq_8.c3 is NULL)))) 
                        and ((EXISTS (
                            select  
                                ref_48.profile_picture as c0, 
                                subq_3.c2 as c1, 
                                ref_46.birthdate as c2, 
                                subq_3.c2 as c3, 
                                subq_3.c1 as c4, 
                                ref_48.user_id as c5, 
                                ref_46.user_id as c6, 
                                subq_3.c2 as c7
                              from 
                                test_bd.user_profiles as ref_48
                              where ref_48.profile_picture is NULL)) 
                          and ((ref_46.profile_picture is NULL) 
                            and (subq_8.c5 is NULL)))) 
                      and (ref_46.birthdate is not NULL)
                    limit 115)) 
                and (false)))))) then subq_3.c1 else subq_3.c1 end
     as c5, 
  subq_3.c1 as c6, 
  coalesce(subq_8.c0,
    subq_8.c2) as c7, 
  subq_3.c0 as c8, 
  subq_8.c2 as c9, 
  case when (EXISTS (
        select  
            ref_49.age as c0, 
            subq_8.c5 as c1, 
            subq_8.c6 as c2, 
            subq_8.c2 as c3
          from 
            test_bd.employee as ref_49
          where (((subq_3.c0 is NULL) 
                and (subq_8.c8 is NULL)) 
              or (false)) 
            or (false)
          limit 94)) 
      or ((true) 
        and (subq_8.c4 is NULL)) then subq_3.c0 else subq_3.c0 end
     as c10, 
  subq_3.c1 as c11, 
  subq_8.c8 as c12, 
  subq_3.c2 as c13, 
  subq_3.c2 as c14, 
  subq_8.c7 as c15, 
  subq_8.c4 as c16, 
  subq_8.c0 as c17, 
  subq_8.c2 as c18, 
  subq_3.c2 as c19, 
  subq_3.c0 as c20, 
  case when subq_8.c5 is not NULL then subq_8.c4 else subq_8.c4 end
     as c21, 
  case when ((((subq_8.c2 is not NULL) 
            or ((true) 
              or ((subq_8.c4 is NULL) 
                and (false)))) 
          and (EXISTS (
            select  
                subq_3.c1 as c0, 
                subq_12.c10 as c1, 
                subq_8.c3 as c2, 
                subq_8.c6 as c3, 
                ref_50.title as c4, 
                subq_3.c1 as c5, 
                subq_8.c6 as c6, 
                subq_12.c2 as c7, 
                subq_3.c0 as c8, 
                subq_8.c0 as c9, 
                subq_8.c6 as c10, 
                ref_50.comment as c11, 
                subq_3.c2 as c12, 
                33 as c13, 
                subq_12.c3 as c14, 
                ref_50.username as c15, 
                ref_50.username as c16, 
                subq_3.c2 as c17, 
                ref_50.title as c18, 
                subq_8.c4 as c19
              from 
                test_bd.user_post_comments as ref_50,
                lateral (select  
                      subq_3.c1 as c0, 
                      subq_3.c1 as c1, 
                      84 as c2, 
                      ref_51.email as c3, 
                      ref_51.id as c4, 
                      ref_51.email as c5, 
                      subq_11.c7 as c6, 
                      ref_51.id as c7, 
                      subq_8.c0 as c8, 
                      ref_51.email as c9, 
                      ref_50.username as c10, 
                      subq_11.c3 as c11, 
                      ref_51.email as c12, 
                      ref_51.email as c13, 
                      subq_11.c2 as c14, 
                      ref_51.email as c15, 
                      ref_50.comment as c16, 
                      subq_3.c2 as c17, 
                      subq_3.c1 as c18, 
                      (select birthdate from test_bd.user_profiles limit 1 offset 74)
                         as c19, 
                      subq_11.c6 as c20, 
                      50 as c21, 
                      subq_11.c0 as c22
                    from 
                      test_bd.users as ref_51,
                      lateral (select  
                            70 as c0, 
                            96 as c1, 
                            ref_50.username as c2, 
                            ref_52.birthdate as c3, 
                            ref_52.user_id as c4, 
                            78 as c5, 
                            ref_52.bio as c6, 
                            subq_8.c4 as c7, 
                            ref_50.title as c8
                          from 
                            test_bd.user_profiles as ref_52
                          where (((EXISTS (
                                  select  
                                      ref_50.title as c0, 
                                      (select username from test_bd.users limit 1 offset 5)
                                         as c1, 
                                      subq_3.c2 as c2, 
                                      ref_52.bio as c3
                                    from 
                                      test_bd.employee as ref_53
                                    where true)) 
                                or (((false) 
                                    or ((false) 
                                      and ((false) 
                                        and ((((true) 
                                              and (subq_8.c2 is not NULL)) 
                                            and (false)) 
                                          or (subq_3.c0 is not NULL))))) 
                                  and ((false) 
                                    and (EXISTS (
                                      select  
                                          ref_52.profile_picture as c0, 
                                          ref_51.username as c1, 
                                          ref_52.user_id as c2, 
                                          subq_8.c0 as c3
                                        from 
                                          test_bd.user_profiles as ref_54
                                        where true
                                        limit 94))))) 
                              or (true)) 
                            or (true)) as subq_11
                    where ref_50.title is not NULL) as subq_12
              where EXISTS (
                select  
                    subq_12.c5 as c0, 
                    ref_55.name as c1, 
                    ref_50.comment as c2, 
                    subq_3.c2 as c3, 
                    subq_12.c1 as c4, 
                    ref_50.title as c5, 
                    subq_8.c8 as c6, 
                    ref_50.comment as c7, 
                    subq_12.c14 as c8, 
                    ref_55.id as c9
                  from 
                    test_bd.locations as ref_55
                  where ref_50.title is NULL)
              limit 166))) 
        and (false)) 
      or (EXISTS (
        select  
            subq_8.c4 as c0, 
            subq_3.c0 as c1, 
            (select salary from test_bd.employee limit 1 offset 6)
               as c2, 
            7 as c3, 
            ref_56.user_id as c4, 
            subq_8.c1 as c5, 
            subq_3.c0 as c6, 
            ref_56.profile_picture as c7, 
            (select comment from test_bd.user_post_comments limit 1 offset 4)
               as c8
          from 
            test_bd.user_profiles as ref_56
          where ((((false) 
                  and ((false) 
                    and (subq_3.c0 is not NULL))) 
                and (EXISTS (
                  select  
                      42 as c0, 
                      subq_3.c0 as c1, 
                      ref_57.birthdate as c2, 
                      subq_8.c0 as c3, 
                      ref_57.user_id as c4, 
                      ref_56.bio as c5, 
                      subq_8.c3 as c6, 
                      ref_56.profile_picture as c7, 
                      subq_3.c2 as c8, 
                      subq_8.c8 as c9, 
                      ref_56.user_id as c10, 
                      subq_3.c0 as c11, 
                      ref_56.user_id as c12
                    from 
                      test_bd.user_profiles as ref_57
                    where ((ref_56.user_id is not NULL) 
                        or (true)) 
                      or ((subq_8.c7 is not NULL) 
                        or (EXISTS (
                          select  
                              subq_3.c2 as c0
                            from 
                              test_bd.products as ref_58
                            where EXISTS (
                              select  
                                  (select created_at from test_bd.users limit 1 offset 6)
                                     as c0, 
                                  ref_58.name as c1, 
                                  subq_8.c2 as c2, 
                                  ref_56.profile_picture as c3, 
                                  subq_3.c2 as c4, 
                                  ref_56.bio as c5, 
                                  ref_59.user_id as c6, 
                                  ref_59.title as c7, 
                                  subq_8.c3 as c8, 
                                  ref_56.birthdate as c9, 
                                  ref_59.updated_at as c10, 
                                  ref_57.profile_picture as c11, 
                                  2 as c12, 
                                  (select post_id from test_bd.comments limit 1 offset 6)
                                     as c13, 
                                  subq_8.c5 as c14, 
                                  ref_56.bio as c15, 
                                  subq_3.c2 as c16, 
                                  ref_56.profile_picture as c17, 
                                  ref_58.id as c18
                                from 
                                  test_bd.posts as ref_59
                                where 2 is NULL
                                limit 55)
                            limit 74)))))) 
              and (EXISTS (
                select  
                    ref_60.user_id as c0, 
                    ref_56.profile_picture as c1, 
                    (select user_id from test_bd.user_profiles limit 1 offset 1)
                       as c2, 
                    subq_3.c2 as c3
                  from 
                    test_bd.user_profiles as ref_60
                  where (((true) 
                        or (((true) 
                            or (EXISTS (
                              select  
                                  subq_8.c4 as c0, 
                                  ref_60.profile_picture as c1, 
                                  ref_56.bio as c2, 
                                  38 as c3, 
                                  ref_60.bio as c4, 
                                  (select updated_at from test_bd.posts limit 1 offset 6)
                                     as c5, 
                                  ref_56.bio as c6, 
                                  ref_60.birthdate as c7, 
                                  96 as c8, 
                                  ref_61.tags as c9, 
                                  ref_56.user_id as c10
                                from 
                                  test_bd.products as ref_61
                                where (true) 
                                  or (ref_56.user_id is NULL)
                                limit 105))) 
                          or (EXISTS (
                            select  
                                ref_56.birthdate as c0, 
                                subq_3.c2 as c1, 
                                subq_8.c0 as c2, 
                                ref_62.title as c3, 
                                subq_3.c0 as c4, 
                                ref_62.comment as c5, 
                                97 as c6, 
                                subq_3.c1 as c7
                              from 
                                test_bd.user_post_comments as ref_62
                              where (select eid from test_bd.employee limit 1 offset 45)
                                   is not NULL
                              limit 78)))) 
                      and (true)) 
                    and ((true) 
                      or (((((ref_56.profile_picture is NULL) 
                              and (false)) 
                            or ((((false) 
                                  and (EXISTS (
                                    select  
                                        subq_3.c2 as c0, 
                                        subq_3.c1 as c1
                                      from 
                                        test_bd.posts as ref_63
                                      where true
                                      limit 74))) 
                                or (EXISTS (
                                  select  
                                      ref_56.bio as c0, 
                                      ref_60.user_id as c1, 
                                      ref_64.virtual_col as c2, 
                                      subq_3.c0 as c3, 
                                      ref_64.id as c4, 
                                      ref_60.profile_picture as c5, 
                                      30 as c6, 
                                      subq_8.c7 as c7
                                    from 
                                      test_bd.eids as ref_64
                                    where ref_60.birthdate is NULL
                                    limit 27))) 
                              and (EXISTS (
                                select  
                                    ref_56.user_id as c0, 
                                    (select id from test_bd.eids limit 1 offset 89)
                                       as c1, 
                                    subq_3.c1 as c2, 
                                    subq_3.c2 as c3, 
                                    ref_60.birthdate as c4, 
                                    27 as c5, 
                                    subq_3.c1 as c6, 
                                    ref_56.birthdate as c7, 
                                    ref_56.user_id as c8
                                  from 
                                    test_bd.posts as ref_65
                                  where true)))) 
                          or (true)) 
                        or (EXISTS (
                          select  
                              ref_60.bio as c0, 
                              (select name from test_bd.products limit 1 offset 3)
                                 as c1, 
                              ref_56.bio as c2, 
                              subq_3.c2 as c3, 
                              ref_60.profile_picture as c4, 
                              ref_56.profile_picture as c5, 
                              (select user_id from test_bd.comments limit 1 offset 1)
                                 as c6
                            from 
                              test_bd.comments as ref_66
                            where EXISTS (
                              select  
                                  ref_56.user_id as c0
                                from 
                                  test_bd.users as ref_67
                                where 26 is not NULL
                                limit 113)
                            limit 120))))))) 
            or ((false) 
              and (((false) 
                  and (((((((subq_8.c2 is not NULL) 
                              and (true)) 
                            or (true)) 
                          or (((EXISTS (
                                select  
                                    ref_56.birthdate as c0, 
                                    ref_68.id as c1, 
                                    (select updated_at from test_bd.posts limit 1 offset 6)
                                       as c2, 
                                    subq_8.c3 as c3, 
                                    subq_3.c1 as c4, 
                                    subq_8.c6 as c5, 
                                    6 as c6, 
                                    subq_8.c1 as c7, 
                                    ref_68.user_id as c8, 
                                    (select virtual_col from test_bd.eids limit 1 offset 4)
                                       as c9, 
                                    subq_3.c2 as c10, 
                                    ref_68.id as c11
                                  from 
                                    test_bd.comments as ref_68
                                  where true
                                  limit 127)) 
                              or (((false) 
                                  and ((false) 
                                    and (false))) 
                                and (false))) 
                            or (false))) 
                        or ((select id from test_bd.posts limit 1 offset 73)
                             is not NULL)) 
                      and (true)) 
                    or ((subq_3.c2 is NULL) 
                      or ((subq_8.c1 is NULL) 
                        or (((ref_56.profile_picture is NULL) 
                            and (true)) 
                          and (EXISTS (
                            select  
                                subq_8.c5 as c0, 
                                ref_56.birthdate as c1, 
                                ref_69.age as c2, 
                                subq_8.c6 as c3, 
                                subq_8.c8 as c4, 
                                56 as c5, 
                                subq_3.c2 as c6, 
                                subq_3.c0 as c7, 
                                ref_56.user_id as c8, 
                                ref_69.email as c9
                              from 
                                test_bd.employee as ref_69
                              where (true) 
                                and (false)
                              limit 109))))))) 
                or (true)))
          limit 107)) then case when subq_8.c6 is not NULL then subq_3.c1 else subq_3.c1 end
       else case when subq_8.c6 is not NULL then subq_3.c1 else subq_3.c1 end
       end
     as c22, 
  32 as c23, 
  subq_3.c1 as c24, 
  case when (false) 
      and (subq_3.c1 is NULL) then subq_3.c2 else subq_3.c2 end
     as c25, 
  subq_8.c1 as c26, 
  subq_8.c6 as c27, 
  subq_8.c3 as c28, 
  (select created_at from test_bd.comments limit 1 offset 56)
     as c29, 
  (select created_at from test_bd.products limit 1 offset 2)
     as c30
from 
  (select  
        subq_2.c9 as c0, 
        case when (EXISTS (
              select  
                  ref_10.created_at as c0, 
                  ref_0.years as c1, 
                  subq_2.c1 as c2
                from 
                  test_bd.posts as ref_10
                where false
                limit 123)) 
            and (ref_0.eid is NULL) then ref_1.title else ref_1.title end
           as c1, 
        subq_2.c6 as c2
      from 
        test_bd.employee as ref_0
          inner join test_bd.user_post_comments as ref_1
          on (EXISTS (
              select  
                  (select username from test_bd.user_post_comments limit 1 offset 2)
                     as c0, 
                  (select tags from test_bd.products limit 1 offset 1)
                     as c1, 
                  ref_2.id as c2, 
                  ref_2.created_at as c3, 
                  ref_2.username as c4, 
                  ref_1.username as c5
                from 
                  test_bd.users as ref_2
                where ref_0.salary is not NULL
                limit 138)),
        lateral (select  
              ref_3.eid as c0, 
              ref_3.eid as c1, 
              ref_3.id as c2, 
              ref_1.title as c3, 
              ref_1.comment as c4, 
              ref_1.comment as c5, 
              ref_1.title as c6, 
              ref_3.virtual_col as c7, 
              7 as c8, 
              ref_4.comment as c9, 
              ref_0.hire_date as c10
            from 
              test_bd.eids as ref_3
                inner join test_bd.user_post_comments as ref_4
                on (false)
            where (((EXISTS (
                    select  
                        ref_1.title as c0, 
                        ref_0.department_id as c1, 
                        (select created_at from test_bd.users limit 1 offset 66)
                           as c2, 
                        ref_5.email as c3, 
                        ref_4.title as c4, 
                        subq_1.c9 as c5, 
                        ref_4.username as c6, 
                        ref_4.comment as c7, 
                        ref_4.title as c8, 
                        ref_0.age as c9
                      from 
                        test_bd.users as ref_5,
                        lateral (select  
                              ref_3.virtual_col as c0, 
                              subq_0.c0 as c1, 
                              ref_5.created_at as c2, 
                              ref_1.title as c3, 
                              ref_1.comment as c4, 
                              ref_3.virtual_col as c5, 
                              subq_0.c0 as c6, 
                              ref_4.title as c7, 
                              ref_5.username as c8, 
                              4 as c9, 
                              ref_5.email as c10, 
                              ref_0.salary as c11, 
                              subq_0.c0 as c12, 
                              ref_6.id as c13
                            from 
                              test_bd.comments as ref_6,
                              lateral (select  
                                    ref_1.comment as c0
                                  from 
                                    test_bd.user_post_comments as ref_7
                                  where true) as subq_0
                            where (ref_0.years is not NULL) 
                              or ((false) 
                                or (false))
                            limit 92) as subq_1
                      where (false) 
                        or (ref_5.created_at is NULL))) 
                  and (EXISTS (
                    select  
                        ref_1.title as c0, 
                        ref_3.eid as c1, 
                        ref_8.title as c2, 
                        ref_0.department_id as c3
                      from 
                        test_bd.user_post_comments as ref_8
                      where true))) 
                and (EXISTS (
                  select  
                      ref_9.birthdate as c0, 
                      ref_1.comment as c1, 
                      ref_1.title as c2, 
                      ref_9.bio as c3, 
                      ref_4.title as c4, 
                      ref_1.comment as c5
                    from 
                      test_bd.user_profiles as ref_9
                    where true
                    limit 157))) 
              and ((((ref_1.comment is NULL) 
                    and (ref_1.title is not NULL)) 
                  and (26 is NULL)) 
                or (true))
            limit 121) as subq_2
      where (subq_2.c5 is NULL) 
        and (((false) 
            or (true)) 
          or (subq_2.c2 is NULL))
      limit 110) as subq_3,
  lateral (select  
        ref_11.eid as c0, 
        subq_3.c1 as c1, 
        ref_11.virtual_col as c2, 
        subq_3.c1 as c3, 
        subq_3.c0 as c4, 
        92 as c5, 
        ref_11.virtual_col as c6, 
        ref_11.eid as c7, 
        ref_11.virtual_col as c8
      from 
        test_bd.eids as ref_11
      where (((((((select email from test_bd.users limit 1 offset 93)
                       is not NULL) 
                  or (((((((((EXISTS (
                                    select  
                                        subq_3.c0 as c0, 
                                        subq_3.c2 as c1, 
                                        subq_3.c2 as c2, 
                                        ref_11.id as c3
                                      from 
                                        test_bd.products as ref_12
                                      where (true) 
                                        and (false)
                                      limit 81)) 
                                  and (false)) 
                                or (true)) 
                              or (subq_3.c0 is NULL)) 
                            or (true)) 
                          or (EXISTS (
                            select  
                                ref_13.id as c0
                              from 
                                test_bd.employee as ref_13
                              where ((true) 
                                  or (false)) 
                                and (false)))) 
                        or ((subq_3.c1 is not NULL) 
                          or ((EXISTS (
                              select  
                                  ref_14.created_at as c0, 
                                  ref_14.id as c1, 
                                  ref_14.user_id as c2, 
                                  subq_3.c0 as c3, 
                                  subq_3.c2 as c4, 
                                  ref_14.comment as c5, 
                                  subq_3.c1 as c6, 
                                  ref_14.created_at as c7, 
                                  subq_3.c1 as c8, 
                                  ref_11.id as c9, 
                                  ref_11.virtual_col as c10, 
                                  38 as c11, 
                                  ref_11.id as c12, 
                                  subq_3.c1 as c13, 
                                  subq_3.c1 as c14, 
                                  ref_14.post_id as c15, 
                                  ref_11.eid as c16
                                from 
                                  test_bd.comments as ref_14
                                where (true) 
                                  or ((false) 
                                    or (false)))) 
                            and (EXISTS (
                              select  
                                  subq_3.c2 as c0
                                from 
                                  test_bd.user_post_comments as ref_15
                                where (subq_3.c0 is not NULL) 
                                  and ((true) 
                                    or (((false) 
                                        or (EXISTS (
                                          select  
                                              ref_11.id as c0, 
                                              ref_15.title as c1, 
                                              subq_3.c2 as c2, 
                                              ref_15.username as c3, 
                                              subq_3.c1 as c4, 
                                              ref_11.id as c5, 
                                              ref_16.id as c6
                                            from 
                                              test_bd.products as ref_16
                                            where (ref_15.title is NULL) 
                                              and (true)
                                            limit 104))) 
                                      or ((ref_15.comment is not NULL) 
                                        or (false))))
                                limit 101))))) 
                      or (true)) 
                    or ((false) 
                      or ((((subq_3.c1 is not NULL) 
                            and (true)) 
                          and (false)) 
                        or ((false) 
                          or (ref_11.virtual_col is NULL)))))) 
                or ((ref_11.eid is NULL) 
                  and (EXISTS (
                    select  
                        (select id from test_bd.products limit 1 offset 1)
                           as c0, 
                        subq_3.c2 as c1, 
                        ref_11.eid as c2, 
                        63 as c3, 
                        ref_11.id as c4, 
                        ref_17.comment as c5, 
                        (select price from test_bd.products limit 1 offset 4)
                           as c6
                      from 
                        test_bd.comments as ref_17
                      where (false) 
                        or (((ref_17.comment is not NULL) 
                            or (ref_17.id is not NULL)) 
                          and (false))
                      limit 132)))) 
              or (ref_11.virtual_col is not NULL)) 
            and (subq_3.c1 is not NULL)) 
          or (((ref_11.id is not NULL) 
              or ((select created_at from test_bd.comments limit 1 offset 3)
                   is not NULL)) 
            and (((true) 
                or (((select id from test_bd.posts limit 1 offset 48)
                       is NULL) 
                  and (EXISTS (
                    select  
                        subq_3.c1 as c0, 
                        ref_18.id as c1, 
                        subq_4.c0 as c2, 
                        ref_18.coordinates as c3, 
                        ref_18.user_id as c4, 
                        ref_11.virtual_col as c5, 
                        subq_4.c0 as c6, 
                        subq_4.c2 as c7, 
                        ref_18.user_id as c8, 
                        ref_11.id as c9, 
                        ref_18.id as c10, 
                        subq_3.c0 as c11, 
                        subq_4.c1 as c12, 
                        27 as c13
                      from 
                        test_bd.locations as ref_18,
                        lateral (select  
                              subq_3.c0 as c0, 
                              26 as c1, 
                              ref_18.id as c2
                            from 
                              test_bd.user_post_comments as ref_19
                            where true
                            limit 174) as subq_4,
                        lateral (select  
                              subq_3.c0 as c0, 
                              26 as c1, 
                              ref_11.eid as c2, 
                              subq_4.c0 as c3, 
                              ref_11.virtual_col as c4, 
                              ref_18.coordinates as c5, 
                              subq_3.c0 as c6, 
                              subq_3.c2 as c7, 
                              ref_11.virtual_col as c8, 
                              ref_11.eid as c9
                            from 
                              test_bd.user_profiles as ref_20
                            where true
                            limit 100) as subq_5
                      where (((((true) 
                                and ((true) 
                                  and (((true) 
                                      and (EXISTS (
                                        select  
                                            ref_11.eid as c0, 
                                            subq_4.c2 as c1, 
                                            subq_3.c2 as c2, 
                                            ref_11.id as c3, 
                                            (select user_id from test_bd.locations limit 1 offset 6)
                                               as c4, 
                                            subq_3.c2 as c5, 
                                            ref_18.coordinates as c6, 
                                            subq_4.c2 as c7, 
                                            ref_11.eid as c8, 
                                            ref_11.eid as c9
                                          from 
                                            test_bd.posts as ref_21
                                          where true
                                          limit 46))) 
                                    and (false)))) 
                              and (subq_3.c2 is not NULL)) 
                            or (ref_11.eid is NULL)) 
                          or (EXISTS (
                            select  
                                (select bio from test_bd.user_profiles limit 1 offset 4)
                                   as c0, 
                                subq_4.c0 as c1, 
                                subq_5.c7 as c2
                              from 
                                test_bd.eids as ref_22
                              where true
                              limit 161))) 
                        and ((subq_5.c7 is not NULL) 
                          and ((((true) 
                                and ((((EXISTS (
                                        select  
                                            subq_5.c6 as c0, 
                                            ref_18.name as c1, 
                                            ref_23.coordinates as c2, 
                                            subq_5.c3 as c3, 
                                            ref_11.eid as c4, 
                                            subq_5.c7 as c5, 
                                            ref_18.user_id as c6, 
                                            subq_4.c0 as c7, 
                                            81 as c8, 
                                            subq_5.c7 as c9, 
                                            ref_18.user_id as c10, 
                                            subq_4.c0 as c11, 
                                            subq_5.c0 as c12, 
                                            (select department_id from test_bd.employee limit 1 offset 6)
                                               as c13, 
                                            subq_3.c1 as c14, 
                                            ref_11.id as c15, 
                                            ref_11.virtual_col as c16, 
                                            ref_11.id as c17, 
                                            subq_3.c2 as c18, 
                                            subq_5.c1 as c19, 
                                            subq_3.c2 as c20, 
                                            ref_23.user_id as c21
                                          from 
                                            test_bd.locations as ref_23
                                          where ((subq_5.c7 is NULL) 
                                              and (true)) 
                                            or (EXISTS (
                                              select  
                                                  ref_23.coordinates as c0, 
                                                  ref_18.id as c1, 
                                                  ref_23.user_id as c2, 
                                                  (select updated_at from test_bd.posts limit 1 offset 5)
                                                     as c3, 
                                                  subq_5.c5 as c4, 
                                                  subq_3.c1 as c5, 
                                                  ref_11.eid as c6, 
                                                  ref_11.virtual_col as c7, 
                                                  ref_11.id as c8, 
                                                  ref_11.virtual_col as c9
                                                from 
                                                  test_bd.locations as ref_24
                                                where true)))) 
                                      and (ref_18.user_id is NULL)) 
                                    and ((false) 
                                      and (((subq_5.c9 is NULL) 
                                          and ((((false) 
                                                or (ref_18.id is NULL)) 
                                              or (false)) 
                                            or (subq_4.c0 is not NULL))) 
                                        and (true)))) 
                                  and (((false) 
                                      or (((((EXISTS (
                                                select  
                                                    subq_4.c0 as c0, 
                                                    ref_11.virtual_col as c1
                                                  from 
                                                    test_bd.products as ref_25
                                                  where EXISTS (
                                                    select  
                                                        subq_3.c1 as c0, 
                                                        ref_11.virtual_col as c1, 
                                                        (select id from test_bd.locations limit 1 offset 3)
                                                           as c2, 
                                                        46 as c3, 
                                                        subq_5.c4 as c4, 
                                                        (select eid from test_bd.employee limit 1 offset 4)
                                                           as c5
                                                      from 
                                                        test_bd.users as ref_26
                                                      where ((false) 
                                                          and ((false) 
                                                            or (true))) 
                                                        or (true)
                                                      limit 107)
                                                  limit 108)) 
                                              and (EXISTS (
                                                select  
                                                    subq_3.c2 as c0, 
                                                    49 as c1, 
                                                    (select name from test_bd.products limit 1 offset 3)
                                                       as c2, 
                                                    subq_3.c1 as c3, 
                                                    ref_27.user_id as c4, 
                                                    subq_4.c0 as c5
                                                  from 
                                                    test_bd.posts as ref_27
                                                  where false))) 
                                            or (subq_5.c0 is NULL)) 
                                          and (((true) 
                                              or ((false) 
                                                and (true))) 
                                            or ((true) 
                                              and (false)))) 
                                        and ((subq_5.c5 is NULL) 
                                          and (EXISTS (
                                            select  
                                                subq_3.c0 as c0, 
                                                subq_6.c0 as c1
                                              from 
                                                test_bd.products as ref_28,
                                                lateral (select  
                                                      ref_29.hire_date as c0
                                                    from 
                                                      test_bd.employee as ref_29
                                                    where false
                                                    limit 116) as subq_6
                                              where false))))) 
                                    and (false)))) 
                              and (false)) 
                            or ((EXISTS (
                                select  
                                    ref_18.name as c0
                                  from 
                                    test_bd.users as ref_30
                                  where (false) 
                                    and (ref_30.username is NULL)
                                  limit 46)) 
                              or (EXISTS (
                                select  
                                    subq_5.c8 as c0
                                  from 
                                    test_bd.user_profiles as ref_31,
                                    lateral (select  
                                          subq_3.c2 as c0, 
                                          ref_18.name as c1, 
                                          ref_11.eid as c2, 
                                          subq_5.c6 as c3, 
                                          subq_3.c2 as c4, 
                                          ref_31.birthdate as c5, 
                                          subq_4.c1 as c6, 
                                          (select post_id from test_bd.comments limit 1 offset 3)
                                             as c7, 
                                          ref_11.id as c8, 
                                          ref_18.coordinates as c9
                                        from 
                                          test_bd.eids as ref_32
                                        where EXISTS (
                                          select  
                                              (select post_id from test_bd.comments limit 1 offset 4)
                                                 as c0, 
                                              subq_3.c0 as c1, 
                                              ref_11.virtual_col as c2, 
                                              subq_4.c0 as c3
                                            from 
                                              test_bd.eids as ref_33
                                            where (((false) 
                                                  or ((true) 
                                                    or (ref_33.eid is NULL))) 
                                                or ((true) 
                                                  and (EXISTS (
                                                    select  
                                                        ref_11.eid as c0, 
                                                        ref_33.id as c1
                                                      from 
                                                        test_bd.comments as ref_34
                                                      where ref_11.eid is NULL
                                                      limit 136)))) 
                                              and (true)
                                            limit 190)) as subq_7
                                  where false)))))
                      limit 91)))) 
              or (subq_3.c0 is not NULL)))) 
        and (true)) as subq_8
where true
limit 121;
SHOW profiles;