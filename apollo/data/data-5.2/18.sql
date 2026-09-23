SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_2.c14 as c0, 
  subq_2.c9 as c1, 
  subq_3.c3 as c2, 
  case when (subq_2.c13 is NULL) 
      or ((EXISTS (
          select  
              ref_8.comment as c0, 
              ref_6.created_at as c1, 
              subq_2.c9 as c2, 
              ref_6.comment as c3, 
              ref_6.user_id as c4
            from 
              test_bd.comments as ref_6
                left join test_bd.user_post_comments as ref_7
                  inner join test_bd.comments as ref_8
                  on (false)
                on ((EXISTS (
                      select  
                          ref_6.user_id as c0, 
                          ref_6.user_id as c1, 
                          ref_6.created_at as c2, 
                          subq_2.c9 as c3
                        from 
                          test_bd.users as ref_9,
                          lateral (select  
                                ref_7.username as c0, 
                                ref_7.comment as c1, 
                                ref_10.email as c2, 
                                subq_3.c1 as c3, 
                                ref_9.id as c4, 
                                ref_6.post_id as c5, 
                                subq_2.c4 as c6, 
                                subq_2.c0 as c7, 
                                subq_2.c14 as c8, 
                                ref_8.created_at as c9
                              from 
                                test_bd.employee as ref_10
                              where EXISTS (
                                select  
                                    ref_8.post_id as c0, 
                                    ref_6.comment as c1, 
                                    ref_11.email as c2, 
                                    ref_6.created_at as c3
                                  from 
                                    test_bd.users as ref_11
                                  where false
                                  limit 138)) as subq_4
                        where false
                        limit 91)) 
                    and ((EXISTS (
                        select  
                            subq_3.c12 as c0, 
                            subq_3.c10 as c1, 
                            (select hire_date from test_bd.employee limit 1 offset 6)
                               as c2, 
                            subq_3.c14 as c3, 
                            subq_2.c6 as c4
                          from 
                            test_bd.products as ref_12
                          where (false) 
                            and (subq_3.c13 is not NULL)
                          limit 73)) 
                      or (true)))
            where EXISTS (
              select  
                  ref_7.username as c0, 
                  ref_13.salary as c1, 
                  subq_3.c5 as c2, 
                  40 as c3, 
                  ref_8.comment as c4, 
                  (select comment from test_bd.comments limit 1 offset 3)
                     as c5, 
                  ref_7.title as c6, 
                  ref_7.title as c7, 
                  subq_3.c9 as c8, 
                  (select discount from test_bd.products limit 1 offset 4)
                     as c9, 
                  ref_13.department_id as c10, 
                  subq_3.c10 as c11
                from 
                  test_bd.employee as ref_13
                where EXISTS (
                  select  
                      ref_7.comment as c0, 
                      subq_2.c2 as c1, 
                      subq_2.c1 as c2
                    from 
                      test_bd.eids as ref_14
                    where (EXISTS (
                        select  
                            subq_2.c1 as c0
                          from 
                            test_bd.comments as ref_15,
                            lateral (select  
                                  subq_2.c1 as c0
                                from 
                                  test_bd.products as ref_16
                                where false) as subq_5
                          where false
                          limit 139)) 
                      and (ref_14.virtual_col is not NULL))))) 
        or (subq_2.c10 is not NULL)) then subq_3.c13 else subq_3.c13 end
     as c3
from 
  (select  
        subq_1.c0 as c0, 
        ref_0.coordinates as c1, 
        subq_1.c0 as c2, 
        subq_1.c0 as c3, 
        ref_0.user_id as c4, 
        ref_0.coordinates as c5, 
        subq_1.c0 as c6, 
        subq_1.c0 as c7, 
        subq_1.c0 as c8, 
        subq_1.c0 as c9, 
        ref_0.name as c10, 
        ref_0.user_id as c11, 
        ref_0.user_id as c12, 
        subq_1.c0 as c13, 
        subq_1.c0 as c14, 
        subq_1.c0 as c15
      from 
        test_bd.locations as ref_0,
        lateral (select  
              (select comment from test_bd.user_post_comments limit 1 offset 2)
                 as c0
            from 
              test_bd.eids as ref_1
                inner join test_bd.users as ref_2
                on ((true) 
                    and (true))
            where (ref_2.created_at is not NULL) 
              or (EXISTS (
                select  
                    ref_3.bio as c0
                  from 
                    test_bd.user_profiles as ref_3,
                    lateral (select  
                          ref_0.name as c0, 
                          ref_2.username as c1, 
                          ref_1.id as c2, 
                          ref_2.username as c3, 
                          ref_0.name as c4, 
                          ref_0.coordinates as c5
                        from 
                          test_bd.locations as ref_4
                        where false
                        limit 63) as subq_0
                  where (ref_2.email is NULL) 
                    or (false)
                  limit 90))) as subq_1
      where true
      limit 57) as subq_2,
  lateral (select  
        ref_5.title as c0, 
        ref_5.created_at as c1, 
        subq_2.c10 as c2, 
        ref_5.content as c3, 
        ref_5.updated_at as c4, 
        subq_2.c5 as c5, 
        ref_5.title as c6, 
        subq_2.c4 as c7, 
        subq_2.c5 as c8, 
        ref_5.id as c9, 
        ref_5.title as c10, 
        subq_2.c0 as c11, 
        subq_2.c8 as c12, 
        ref_5.user_id as c13, 
        ref_5.user_id as c14, 
        ref_5.user_id as c15
      from 
        test_bd.posts as ref_5
      where subq_2.c6 is NULL
      limit 88) as subq_3
where (subq_2.c11 is NULL) 
  and (subq_3.c13 is NULL)
limit 99;
SHOW profiles;