SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.user_id as c0, 
  ref_0.post_id as c1, 
  ref_0.id as c2, 
  ref_0.created_at as c3, 
  ref_1.years as c4, 
  ref_0.user_id as c5
from 
  test_bd.comments as ref_0
    left join test_bd.employee as ref_1
    on ((((ref_0.created_at is not NULL) 
            or ((((((ref_1.email is NULL) 
                      or (((true) 
                          or (ref_1.eid is NULL)) 
                        or (EXISTS (
                          select  
                              ref_1.hire_date as c0, 
                              ref_0.post_id as c1, 
                              ref_0.id as c2, 
                              ref_1.id as c3, 
                              ref_0.created_at as c4
                            from 
                              test_bd.comments as ref_2
                            where (ref_1.hire_date is not NULL) 
                              and (false)
                            limit 79)))) 
                    or ((ref_1.department_id is not NULL) 
                      or ((((true) 
                            and ((true) 
                              and (ref_0.post_id is not NULL))) 
                          and ((ref_0.post_id is NULL) 
                            and (false))) 
                        or (false)))) 
                  and (false)) 
                or ((ref_0.post_id is NULL) 
                  and (EXISTS (
                    select  
                        ref_3.id as c0, 
                        ref_0.user_id as c1, 
                        ref_0.id as c2, 
                        ref_1.years as c3, 
                        ref_3.updated_at as c4, 
                        ref_0.created_at as c5, 
                        ref_1.department_id as c6, 
                        ref_1.hire_date as c7, 
                        ref_3.content as c8
                      from 
                        test_bd.posts as ref_3
                      where ref_0.created_at is not NULL
                      limit 88)))) 
              or ((EXISTS (
                  select  
                      ref_1.years as c0, 
                      ref_4.name as c1, 
                      ref_4.discount as c2, 
                      ref_0.id as c3, 
                      ref_4.tags as c4, 
                      ref_4.id as c5, 
                      ref_4.discount as c6
                    from 
                      test_bd.products as ref_4,
                      lateral (select  
                            ref_0.post_id as c0, 
                            ref_5.created_at as c1, 
                            ref_1.salary as c2, 
                            (select profile_picture from test_bd.user_profiles limit 1 offset 4)
                               as c3, 
                            ref_1.age as c4, 
                            ref_4.discount as c5
                          from 
                            test_bd.posts as ref_5
                          where false) as subq_0
                    where subq_0.c0 is not NULL
                    limit 90)) 
                and (false)))) 
          and ((select user_id from test_bd.locations limit 1 offset 41)
               is not NULL)) 
        and (ref_1.salary is not NULL))
where ref_0.created_at is NULL;
SHOW profiles;