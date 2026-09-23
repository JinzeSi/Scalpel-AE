SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_0.c0 as c0, 
  subq_0.c0 as c1
from 
  (select  
        (select age from test_bd.employee limit 1 offset 1)
           as c0, 
        case when ((true) 
              or ((select user_id from test_bd.posts limit 1 offset 3)
                   is NULL)) 
            or (EXISTS (
              select  
                  ref_1.id as c0
                from 
                  test_bd.eids as ref_1
                where false)) then ref_0.coordinates else ref_0.coordinates end
           as c1
      from 
        test_bd.locations as ref_0
      where (true) 
        or ((((false) 
              or (ref_0.user_id is NULL)) 
            and (true)) 
          and (3 is not NULL))) as subq_0
where (((subq_0.c1 is not NULL) 
      and ((EXISTS (
          select  
              ref_3.user_id as c0, 
              ref_3.updated_at as c1
            from 
              test_bd.employee as ref_2
                inner join test_bd.posts as ref_3
                on (false)
            where ((((((select hire_date from test_bd.employee limit 1 offset 2)
                           is not NULL) 
                      and (true)) 
                    or (false)) 
                  or (((true) 
                      and (ref_2.years is NULL)) 
                    or (((EXISTS (
                          select  
                              ref_4.content as c0, 
                              ref_2.hire_date as c1, 
                              subq_0.c0 as c2, 
                              ref_3.id as c3, 
                              ref_2.department_id as c4, 
                              subq_0.c0 as c5, 
                              ref_4.created_at as c6, 
                              subq_0.c1 as c7, 
                              ref_3.updated_at as c8, 
                              subq_0.c1 as c9, 
                              (select title from test_bd.posts limit 1 offset 3)
                                 as c10, 
                              ref_3.id as c11
                            from 
                              test_bd.posts as ref_4
                            where (subq_0.c0 is NULL) 
                              or (true))) 
                        and ((EXISTS (
                            select  
                                ref_2.email as c0, 
                                ref_3.content as c1
                              from 
                                test_bd.comments as ref_5
                              where false
                              limit 73)) 
                          or (((subq_0.c0 is NULL) 
                              and (((EXISTS (
                                    select  
                                        ref_2.email as c0, 
                                        subq_0.c0 as c1
                                      from 
                                        test_bd.users as ref_6
                                      where ((true) 
                                          or ((ref_2.hire_date is NULL) 
                                            or (false))) 
                                        and (subq_0.c0 is NULL))) 
                                  and (ref_2.department_id is not NULL)) 
                                and (true))) 
                            or ((ref_3.user_id is not NULL) 
                              or (false))))) 
                      and (true)))) 
                or ((true) 
                  and (((false) 
                      and (false)) 
                    and (true)))) 
              and ((EXISTS (
                  select  
                      ref_2.age as c0, 
                      (select coordinates from test_bd.locations limit 1 offset 78)
                         as c1, 
                      ref_7.eid as c2, 
                      ref_3.user_id as c3, 
                      ref_2.age as c4, 
                      ref_3.title as c5, 
                      subq_0.c1 as c6, 
                      30 as c7
                    from 
                      test_bd.employee as ref_7,
                      lateral (select  
                            ref_7.hire_date as c0
                          from 
                            test_bd.eids as ref_8
                          where (true) 
                            and ((false) 
                              and (true))
                          limit 114) as subq_1
                    where (ref_7.email is not NULL) 
                      and ((subq_0.c1 is NULL) 
                        or ((true) 
                          and (ref_3.updated_at is not NULL)))
                    limit 150)) 
                and (EXISTS (
                  select  
                      ref_2.age as c0
                    from 
                      test_bd.users as ref_9
                    where true))))) 
        or (false))) 
    and ((subq_0.c1 is NULL) 
      and (true))) 
  or (subq_0.c0 is NULL);
SHOW profiles;