SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_7.created_at as c0, 
  ref_7.id as c1, 
  ref_7.id as c2, 
  subq_1.c6 as c3, 
  subq_1.c5 as c4
from 
  (select  
          ref_1.id as c0, 
          ref_3.username as c1, 
          ref_0.created_at as c2, 
          ref_0.user_id as c3, 
          ref_3.created_at as c4, 
          ref_3.email as c5, 
          ref_1.id as c6, 
          ref_2.id as c7, 
          ref_2.comment as c8
        from 
          test_bd.posts as ref_0
            inner join test_bd.eids as ref_1
              left join test_bd.comments as ref_2
                right join test_bd.users as ref_3
                on (((false) 
                      or ((true) 
                        or (true))) 
                    or ((EXISTS (
                        select  
                            ref_3.email as c0, 
                            ref_3.email as c1, 
                            ref_4.salary as c2, 
                            (select birthdate from test_bd.user_profiles limit 1 offset 4)
                               as c3, 
                            37 as c4, 
                            ref_4.age as c5, 
                            subq_0.c5 as c6
                          from 
                            test_bd.employee as ref_4,
                            lateral (select  
                                  ref_4.department_id as c0, 
                                  (select post_id from test_bd.comments limit 1 offset 6)
                                     as c1, 
                                  ref_3.id as c2, 
                                  ref_4.salary as c3, 
                                  ref_5.user_id as c4, 
                                  ref_4.years as c5, 
                                  ref_2.id as c6, 
                                  ref_2.user_id as c7, 
                                  ref_4.email as c8, 
                                  ref_4.eid as c9, 
                                  ref_3.id as c10
                                from 
                                  test_bd.locations as ref_5
                                where true) as subq_0
                          where (true) 
                            or (subq_0.c4 is NULL)
                          limit 135)) 
                      or ((EXISTS (
                          select  
                              ref_6.id as c0
                            from 
                              test_bd.comments as ref_6
                            where (true) 
                              or ((select virtual_col from test_bd.eids limit 1 offset 2)
                                   is NULL)
                            limit 172)) 
                        and (true))))
              on (ref_1.eid = ref_3.id )
            on (ref_0.content = ref_2.comment )
        where ref_2.id is not NULL
        limit 153) as subq_1
    inner join test_bd.users as ref_7
    on (subq_1.c0 = ref_7.id )
where true
limit 66;
SHOW profiles;