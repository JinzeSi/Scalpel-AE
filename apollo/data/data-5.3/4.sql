SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c0 as c0
from 
  (select  
        ref_2.profile_picture as c0, 
        ref_0.age as c1
      from 
        test_bd.employee as ref_0
            left join test_bd.employee as ref_1
            on (ref_0.email = ref_1.email )
          inner join test_bd.user_profiles as ref_2
          on (ref_1.eid is NULL)
      where EXISTS (
        select  
            ref_0.department_id as c0, 
            ref_2.birthdate as c1, 
            ref_3.name as c2, 
            ref_1.age as c3, 
            ref_0.email as c4, 
            ref_3.name as c5, 
            ref_3.name as c6, 
            ref_0.eid as c7, 
            ref_3.name as c8, 
            ref_2.profile_picture as c9, 
            ref_3.name as c10
          from 
            test_bd.locations as ref_3
          where (false) 
            or ((ref_2.profile_picture is not NULL) 
              or (true))
          limit 160)
      limit 89) as subq_0
where (((EXISTS (
        select  
            ref_4.title as c0, 
            ref_4.created_at as c1, 
            subq_0.c1 as c2, 
            subq_0.c1 as c3, 
            ref_4.id as c4, 
            ref_4.created_at as c5, 
            ref_5.title as c6, 
            subq_0.c1 as c7
          from 
            test_bd.posts as ref_4
              right join test_bd.user_post_comments as ref_5
              on ((false) 
                  and ((EXISTS (
                      select distinct 
                          ref_6.title as c0, 
                          subq_0.c0 as c1
                        from 
                          test_bd.user_post_comments as ref_6
                        where (EXISTS (
                            select  
                                ref_6.username as c0
                              from 
                                test_bd.employee as ref_7
                              where ((false) 
                                  and (((ref_5.username is not NULL) 
                                      and ((EXISTS (
                                          select  
                                              subq_0.c0 as c0, 
                                              ref_6.title as c1, 
                                              ref_6.title as c2, 
                                              ref_6.comment as c3, 
                                              ref_4.content as c4, 
                                              ref_6.comment as c5, 
                                              ref_6.comment as c6, 
                                              ref_4.content as c7, 
                                              (select comment from test_bd.user_post_comments limit 1 offset 5)
                                                 as c8, 
                                              ref_7.age as c9
                                            from 
                                              test_bd.comments as ref_8
                                            where false)) 
                                        or (EXISTS (
                                          select  
                                              subq_0.c0 as c0
                                            from 
                                              test_bd.products as ref_9
                                            where (true) 
                                              and (false)
                                            limit 133)))) 
                                    or ((select comment from test_bd.user_post_comments limit 1 offset 6)
                                         is not NULL))) 
                                and ((false) 
                                  and (ref_4.user_id is NULL))
                              limit 94)) 
                          or (subq_0.c1 is NULL)
                        limit 125)) 
                    or (ref_4.updated_at is NULL)))
          where (select tags from test_bd.products limit 1 offset 1)
               is NULL
          limit 107)) 
      or ((subq_0.c1 is not NULL) 
        and (subq_0.c1 is NULL))) 
    or (case when (EXISTS (
            select  
                subq_0.c1 as c0, 
                subq_0.c1 as c1, 
                subq_0.c1 as c2, 
                subq_0.c1 as c3, 
                subq_0.c0 as c4, 
                subq_0.c0 as c5, 
                ref_10.username as c6, 
                ref_10.id as c7, 
                subq_0.c0 as c8, 
                subq_0.c1 as c9
              from 
                test_bd.users as ref_10
              where EXISTS (
                select  
                    ref_11.created_at as c0
                  from 
                    test_bd.comments as ref_11,
                    lateral (select  
                          ref_12.user_id as c0, 
                          subq_0.c1 as c1
                        from 
                          test_bd.user_profiles as ref_12
                        where true) as subq_1,
                    lateral (select  
                          subq_1.c1 as c0, 
                          subq_1.c1 as c1
                        from 
                          test_bd.user_post_comments as ref_13
                        where ref_11.comment is NULL
                        limit 15) as subq_2
                  where ((select eid from test_bd.eids limit 1 offset 39)
                         is NULL) 
                    and (ref_11.created_at is not NULL)
                  limit 150)
              limit 54)) 
          or (true) then subq_0.c1 else subq_0.c1 end
         is not NULL)) 
  or (((EXISTS (
        select  
            ref_15.virtual_col as c0, 
            80 as c1, 
            subq_0.c0 as c2, 
            ref_15.id as c3, 
            ref_15.virtual_col as c4, 
            ref_14.name as c5, 
            97 as c6, 
            (select department_id from test_bd.employee limit 1 offset 6)
               as c7, 
            ref_15.eid as c8, 
            66 as c9, 
            subq_0.c1 as c10
          from 
            test_bd.products as ref_14
              left join test_bd.eids as ref_15
              on ((((((false) 
                          or ((((EXISTS (
                                  select  
                                      ref_15.id as c0, 
                                      ref_14.category as c1
                                    from 
                                      test_bd.user_profiles as ref_16
                                    where ((false) 
                                        and ((false) 
                                          and (EXISTS (
                                            select  
                                                ref_14.id as c0, 
                                                ref_17.updated_at as c1, 
                                                (select discount from test_bd.products limit 1 offset 1)
                                                   as c2, 
                                                subq_0.c0 as c3, 
                                                ref_17.updated_at as c4, 
                                                ref_14.price as c5, 
                                                ref_14.created_at as c6, 
                                                ref_17.created_at as c7
                                              from 
                                                test_bd.posts as ref_17
                                              where true
                                              limit 124)))) 
                                      or (true)
                                    limit 95)) 
                                and (true)) 
                              and ((false) 
                                and ((true) 
                                  and (false)))) 
                            and (((select id from test_bd.posts limit 1 offset 38)
                                   is NULL) 
                              or ((subq_0.c0 is not NULL) 
                                or ((((ref_14.price is not NULL) 
                                      and (((true) 
                                          and (false)) 
                                        and (((ref_14.price is not NULL) 
                                            and (ref_15.virtual_col is NULL)) 
                                          and ((true) 
                                            and ((true) 
                                              or ((((((true) 
                                                        or (true)) 
                                                      and (false)) 
                                                    and ((((false) 
                                                          and (true)) 
                                                        and (false)) 
                                                      or (true))) 
                                                  or (ref_14.id is not NULL)) 
                                                or (true))))))) 
                                    and (subq_0.c1 is NULL)) 
                                  and (((true) 
                                      and (((subq_0.c0 is not NULL) 
                                          and ((false) 
                                            and (ref_15.eid is not NULL))) 
                                        and ((false) 
                                          or (ref_15.virtual_col is not NULL)))) 
                                    or (true))))))) 
                        or ((false) 
                          or (((true) 
                              and (EXISTS (
                                select  
                                    ref_18.id as c0, 
                                    ref_14.category as c1, 
                                    subq_0.c1 as c2, 
                                    ref_18.email as c3, 
                                    (select title from test_bd.posts limit 1 offset 46)
                                       as c4, 
                                    ref_15.id as c5, 
                                    ref_18.eid as c6, 
                                    ref_15.eid as c7, 
                                    (select email from test_bd.users limit 1 offset 6)
                                       as c8, 
                                    ref_14.price as c9
                                  from 
                                    test_bd.employee as ref_18
                                  where ref_18.years is not NULL
                                  limit 186))) 
                            and (false)))) 
                      and (false)) 
                    or (EXISTS (
                      select  
                          ref_14.tags as c0, 
                          ref_19.years as c1, 
                          (select years from test_bd.employee limit 1 offset 3)
                             as c2, 
                          ref_19.eid as c3, 
                          ref_15.id as c4
                        from 
                          test_bd.employee as ref_19
                        where true
                        limit 106))) 
                  and ((false) 
                    and (true)))
          where ref_14.created_at is not NULL
          limit 61)) 
      or (false)) 
    or ((((((EXISTS (
                select  
                    ref_20.salary as c0, 
                    subq_0.c0 as c1, 
                    ref_20.age as c2, 
                    ref_20.department_id as c3, 
                    ref_20.department_id as c4, 
                    subq_0.c0 as c5, 
                    ref_20.email as c6, 
                    (select id from test_bd.eids limit 1 offset 6)
                       as c7, 
                    subq_0.c1 as c8, 
                    subq_0.c1 as c9, 
                    ref_20.department_id as c10, 
                    (select bio from test_bd.user_profiles limit 1 offset 6)
                       as c11, 
                    (select name from test_bd.products limit 1 offset 2)
                       as c12, 
                    33 as c13, 
                    subq_0.c1 as c14, 
                    subq_0.c0 as c15
                  from 
                    test_bd.employee as ref_20
                  where (EXISTS (
                      select  
                          (select updated_at from test_bd.posts limit 1 offset 1)
                             as c0, 
                          subq_0.c1 as c1, 
                          ref_21.salary as c2, 
                          subq_0.c1 as c3, 
                          ref_21.eid as c4, 
                          subq_0.c0 as c5, 
                          ref_21.department_id as c6, 
                          subq_0.c0 as c7, 
                          33 as c8
                        from 
                          test_bd.employee as ref_21
                        where false)) 
                    and (ref_20.eid is NULL))) 
              or (((false) 
                  or ((subq_0.c0 is not NULL) 
                    and (((true) 
                        or ((subq_0.c1 is NULL) 
                          or (false))) 
                      and (false)))) 
                or (subq_0.c1 is not NULL))) 
            and (subq_0.c0 is NULL)) 
          or (((false) 
              and (subq_0.c1 is not NULL)) 
            or (true))) 
        or (false)) 
      or ((select comment from test_bd.comments limit 1 offset 60)
           is NULL)))
limit 64;
SHOW profiles;