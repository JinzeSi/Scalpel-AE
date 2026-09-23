SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_1.c0 as c0, 
  subq_1.c0 as c1, 
  case when (true) 
      or (EXISTS (
        select  
            subq_1.c0 as c0
          from 
            test_bd.posts as ref_6
          where true
          limit 145)) then subq_1.c0 else subq_1.c0 end
     as c2, 
  subq_1.c0 as c3, 
  subq_1.c0 as c4, 
  case when false then coalesce(subq_1.c0,
      subq_1.c0) else coalesce(subq_1.c0,
      subq_1.c0) end
     as c5, 
  subq_1.c0 as c6, 
  subq_1.c0 as c7, 
  case when (((true) 
          or ((subq_1.c0 is not NULL) 
            or (subq_1.c0 is NULL))) 
        or ((select price from test_bd.products limit 1 offset 1)
             is not NULL)) 
      or (subq_1.c0 is NULL) then (select years from test_bd.employee limit 1 offset 5)
       else (select years from test_bd.employee limit 1 offset 5)
       end
     as c8, 
  subq_1.c0 as c9, 
  subq_1.c0 as c10, 
  subq_1.c0 as c11
from 
  (select  
        ref_2.comment as c0
      from 
        test_bd.comments as ref_0
          inner join test_bd.employee as ref_1
            right join test_bd.comments as ref_2
            on (EXISTS (
                select  
                    ref_2.user_id as c0, 
                    ref_1.id as c1, 
                    ref_1.eid as c2, 
                    ref_2.id as c3, 
                    ref_3.created_at as c4, 
                    (select content from test_bd.posts limit 1 offset 6)
                       as c5, 
                    ref_1.id as c6, 
                    ref_3.comment as c7, 
                    13 as c8, 
                    subq_0.c2 as c9, 
                    ref_2.created_at as c10, 
                    ref_2.id as c11, 
                    subq_0.c2 as c12, 
                    ref_1.salary as c13, 
                    (select username from test_bd.users limit 1 offset 5)
                       as c14, 
                    ref_2.post_id as c15
                  from 
                    test_bd.comments as ref_3,
                    lateral (select  
                          ref_1.salary as c0, 
                          ref_1.salary as c1, 
                          (select user_id from test_bd.posts limit 1 offset 1)
                             as c2
                        from 
                          test_bd.user_profiles as ref_4
                        where true
                        limit 141) as subq_0
                  where true
                  limit 22))
          on (EXISTS (
              select  
                  ref_2.post_id as c0, 
                  72 as c1, 
                  ref_2.user_id as c2, 
                  ref_0.post_id as c3, 
                  ref_1.id as c4, 
                  39 as c5, 
                  ref_2.created_at as c6, 
                  ref_1.department_id as c7
                from 
                  test_bd.user_profiles as ref_5
                where ref_0.id is not NULL))
      where ref_0.user_id is not NULL
      limit 173) as subq_1
where true
limit 107;
SHOW profiles;