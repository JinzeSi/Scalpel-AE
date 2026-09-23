SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_2.c0 as c0, 
  subq_2.c0 as c1, 
  subq_2.c2 as c2, 
  subq_2.c1 as c3, 
  subq_2.c2 as c4, 
  subq_2.c0 as c5, 
  subq_2.c2 as c6, 
  subq_2.c1 as c7, 
  subq_2.c1 as c8, 
  subq_2.c2 as c9, 
  subq_2.c1 as c10, 
  subq_2.c1 as c11, 
  subq_2.c2 as c12, 
  subq_2.c0 as c13, 
  coalesce(subq_2.c2,
    subq_2.c1) as c14, 
  (select user_id from test_bd.user_profiles limit 1 offset 2)
     as c15, 
  subq_2.c2 as c16, 
  subq_2.c2 as c17, 
  subq_2.c1 as c18, 
  subq_2.c1 as c19
from 
  (select  
        subq_0.c2 as c0, 
        subq_0.c4 as c1, 
        subq_0.c2 as c2
      from 
        (select  
              ref_0.user_id as c0, 
              ref_0.created_at as c1, 
              ref_0.created_at as c2, 
              ref_0.id as c3, 
              ref_0.created_at as c4, 
              ref_0.created_at as c5
            from 
              test_bd.comments as ref_0
            where true
            limit 63) as subq_0
      where ((false) 
          and ((true) 
            or ((subq_0.c4 is not NULL) 
              and (EXISTS (
                select  
                    ref_1.id as c0, 
                    subq_0.c1 as c1, 
                    subq_0.c5 as c2, 
                    subq_0.c2 as c3, 
                    ref_1.id as c4
                  from 
                    test_bd.eids as ref_1
                  where (subq_0.c3 is NULL) 
                    and ((true) 
                      or (false))))))) 
        or (((EXISTS (
              select  
                  subq_0.c4 as c0, 
                  subq_1.c0 as c1, 
                  subq_1.c0 as c2, 
                  ref_2.name as c3, 
                  ref_2.user_id as c4, 
                  subq_0.c1 as c5, 
                  ref_2.user_id as c6, 
                  subq_1.c0 as c7, 
                  subq_0.c2 as c8, 
                  subq_1.c0 as c9, 
                  subq_0.c5 as c10, 
                  subq_1.c0 as c11, 
                  subq_1.c0 as c12, 
                  ref_2.id as c13
                from 
                  test_bd.locations as ref_2,
                  lateral (select  
                        ref_3.birthdate as c0
                      from 
                        test_bd.user_profiles as ref_3
                      where EXISTS (
                        select  
                            ref_2.name as c0, 
                            ref_3.profile_picture as c1, 
                            ref_2.id as c2, 
                            ref_2.user_id as c3, 
                            77 as c4, 
                            ref_3.user_id as c5, 
                            ref_4.username as c6
                          from 
                            test_bd.users as ref_4
                          where ((false) 
                              or (false)) 
                            or (ref_2.id is NULL)
                          limit 18)
                      limit 140) as subq_1
                where (EXISTS (
                    select  
                        subq_1.c0 as c0, 
                        subq_0.c4 as c1, 
                        ref_5.user_id as c2, 
                        subq_0.c3 as c3
                      from 
                        test_bd.user_profiles as ref_5
                      where (subq_1.c0 is not NULL) 
                        or (false)
                      limit 106)) 
                  or ((true) 
                    or (true)))) 
            and (subq_0.c4 is NULL)) 
          or ((EXISTS (
              select  
                  subq_0.c2 as c0, 
                  subq_0.c4 as c1, 
                  ref_6.comment as c2, 
                  subq_0.c1 as c3, 
                  (select username from test_bd.user_post_comments limit 1 offset 5)
                     as c4, 
                  (select department_id from test_bd.employee limit 1 offset 3)
                     as c5, 
                  subq_0.c2 as c6, 
                  ref_6.title as c7, 
                  ref_6.title as c8
                from 
                  test_bd.user_post_comments as ref_6
                where EXISTS (
                  select  
                      ref_7.created_at as c0, 
                      (select profile_picture from test_bd.user_profiles limit 1 offset 1)
                         as c1, 
                      subq_0.c0 as c2, 
                      ref_6.username as c3
                    from 
                      test_bd.products as ref_7
                    where ((select id from test_bd.eids limit 1 offset 1)
                           is not NULL) 
                      and (false)
                    limit 134)
                limit 71)) 
            and ((false) 
              and ((EXISTS (
                  select  
                      ref_8.username as c0, 
                      ref_8.title as c1, 
                      subq_0.c3 as c2, 
                      ref_8.comment as c3, 
                      subq_0.c4 as c4, 
                      subq_0.c0 as c5, 
                      ref_8.comment as c6, 
                      (select name from test_bd.locations limit 1 offset 51)
                         as c7, 
                      ref_8.comment as c8, 
                      ref_8.comment as c9, 
                      ref_8.comment as c10, 
                      ref_8.comment as c11
                    from 
                      test_bd.user_post_comments as ref_8
                    where false)) 
                and (true)))))
      limit 141) as subq_2
where ((((subq_2.c0 is not NULL) 
        or ((subq_2.c2 is not NULL) 
          and (subq_2.c2 is NULL))) 
      and (((true) 
          or (((((subq_2.c1 is NULL) 
                  or (true)) 
                or ((subq_2.c1 is not NULL) 
                  or (subq_2.c0 is not NULL))) 
              or (true)) 
            or (EXISTS (
              select  
                  subq_2.c1 as c0, 
                  subq_2.c2 as c1, 
                  (select age from test_bd.employee limit 1 offset 6)
                     as c2, 
                  ref_9.id as c3, 
                  ref_9.eid as c4, 
                  ref_9.eid as c5, 
                  ref_9.virtual_col as c6, 
                  subq_2.c1 as c7, 
                  ref_9.id as c8, 
                  (select created_at from test_bd.posts limit 1 offset 41)
                     as c9, 
                  46 as c10, 
                  ref_9.id as c11, 
                  ref_9.id as c12, 
                  subq_2.c2 as c13, 
                  subq_2.c2 as c14, 
                  ref_9.id as c15
                from 
                  test_bd.eids as ref_9
                where subq_2.c1 is NULL
                limit 62)))) 
        and (EXISTS (
          select  
              ref_10.discount as c0, 
              ref_10.category as c1, 
              ref_10.created_at as c2, 
              subq_2.c2 as c3, 
              subq_2.c0 as c4, 
              subq_2.c2 as c5, 
              subq_2.c0 as c6, 
              ref_10.category as c7, 
              ref_10.category as c8, 
              ref_10.price as c9, 
              subq_2.c1 as c10, 
              subq_2.c0 as c11, 
              32 as c12
            from 
              test_bd.products as ref_10
            where subq_2.c2 is not NULL
            limit 88)))) 
    and (((subq_2.c1 is not NULL) 
        and ((true) 
          and (EXISTS (
            select  
                ref_11.discount as c0, 
                68 as c1, 
                subq_2.c0 as c2, 
                subq_2.c0 as c3, 
                subq_2.c2 as c4, 
                ref_11.category as c5, 
                (select id from test_bd.eids limit 1 offset 6)
                   as c6
              from 
                test_bd.products as ref_11
                  inner join test_bd.user_profiles as ref_12
                  on (ref_12.birthdate is not NULL)
              where true)))) 
      and (((EXISTS (
            select  
                subq_2.c2 as c0, 
                ref_13.user_id as c1, 
                subq_2.c2 as c2, 
                ref_13.user_id as c3, 
                subq_2.c1 as c4, 
                subq_2.c0 as c5, 
                subq_2.c2 as c6, 
                ref_13.user_id as c7
              from 
                test_bd.posts as ref_13
              where EXISTS (
                select  
                    ref_13.user_id as c0, 
                    ref_14.user_id as c1, 
                    ref_14.user_id as c2, 
                    subq_2.c0 as c3
                  from 
                    test_bd.locations as ref_14
                  where false
                  limit 80)
              limit 159)) 
          or (true)) 
        and (EXISTS (
          select  
              ref_16.eid as c0, 
              ref_16.id as c1, 
              subq_2.c2 as c2, 
              subq_2.c1 as c3, 
              ref_15.id as c4
            from 
              test_bd.products as ref_15
                inner join test_bd.eids as ref_16
                on (ref_15.id = ref_16.eid )
            where ref_16.id is not NULL
            limit 89))))) 
  and (((subq_2.c0 is not NULL) 
      or ((((true) 
            or (subq_2.c0 is NULL)) 
          or (false)) 
        and (subq_2.c2 is NULL))) 
    or (subq_2.c1 is not NULL))
limit 106;
SHOW profiles;