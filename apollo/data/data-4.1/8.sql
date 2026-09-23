SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c9 as c0, 
  50 as c1, 
  subq_0.c12 as c2, 
  subq_0.c7 as c3, 
  subq_0.c13 as c4, 
  subq_0.c3 as c5, 
  subq_0.c13 as c6, 
  subq_0.c2 as c7, 
  subq_0.c11 as c8, 
  19 as c9
from 
  (select  
        ref_1.coordinates as c0, 
        ref_4.title as c1, 
        ref_1.coordinates as c2, 
        ref_7.id as c3, 
        ref_0.comment as c4, 
        ref_2.post_id as c5, 
        ref_0.title as c6, 
        ref_2.post_id as c7, 
        ref_6.created_at as c8, 
        ref_4.username as c9, 
        ref_1.name as c10, 
        ref_7.title as c11, 
        ref_1.user_id as c12, 
        ref_3.comment as c13, 
        case when false then ref_1.name else ref_1.name end
           as c14, 
        ref_7.content as c15
      from 
        test_bd.user_post_comments as ref_0
          left join test_bd.locations as ref_1
                inner join test_bd.comments as ref_2
                on (17 is not NULL)
              inner join test_bd.user_post_comments as ref_3
                inner join test_bd.user_post_comments as ref_4
                on (true)
              on (EXISTS (
                  select  
                      (select id from test_bd.eids limit 1 offset 5)
                         as c0, 
                      ref_1.id as c1, 
                      ref_3.title as c2, 
                      ref_3.username as c3, 
                      ref_4.title as c4, 
                      ref_3.title as c5, 
                      (select user_id from test_bd.locations limit 1 offset 5)
                         as c6
                    from 
                      test_bd.locations as ref_5
                    where (false) 
                      or ((true) 
                        and ((true) 
                          and (ref_2.id is not NULL)))
                    limit 125))
            inner join test_bd.users as ref_6
              inner join test_bd.posts as ref_7
              on (ref_6.id is NULL)
            on ((((ref_4.username is not NULL) 
                    or ((ref_4.comment is NULL) 
                      and (EXISTS (
                        select  
                            (select user_id from test_bd.locations limit 1 offset 6)
                               as c0, 
                            41 as c1
                          from 
                            test_bd.user_profiles as ref_8
                          where false
                          limit 137)))) 
                  and (EXISTS (
                    select  
                        ref_3.comment as c0, 
                        ref_9.id as c1, 
                        ref_9.hire_date as c2, 
                        ref_7.user_id as c3, 
                        ref_9.eid as c4, 
                        7 as c5, 
                        ref_2.user_id as c6
                      from 
                        test_bd.employee as ref_9
                      where (((ref_2.user_id is NULL) 
                            and (true)) 
                          and ((true) 
                            or (EXISTS (
                              select  
                                  ref_3.comment as c0, 
                                  50 as c1, 
                                  ref_7.title as c2, 
                                  ref_10.id as c3
                                from 
                                  test_bd.eids as ref_10
                                where (ref_10.virtual_col is not NULL) 
                                  or (57 is not NULL)
                                limit 108)))) 
                        and (EXISTS (
                          select  
                              ref_9.hire_date as c0
                            from 
                              test_bd.posts as ref_11
                            where false))
                      limit 92))) 
                and (EXISTS (
                  select  
                      ref_2.created_at as c0
                    from 
                      test_bd.user_profiles as ref_12
                    where ref_4.username is not NULL
                    limit 152)))
          on (((ref_1.name is NULL) 
                and (false)) 
              or (ref_6.id is NULL))
      where ((true) 
          or (true)) 
        or (ref_0.comment is NULL)
      limit 53) as subq_0
where coalesce((select user_id from test_bd.comments limit 1 offset 2)
      ,
    subq_0.c5) is not NULL
limit 145;
SHOW profiles;