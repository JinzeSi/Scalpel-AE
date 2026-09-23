SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_0.c0 as c0, 
  subq_0.c0 as c1, 
  subq_0.c0 as c2, 
  coalesce(subq_0.c0,
    subq_0.c0) as c3, 
  subq_0.c0 as c4, 
  subq_0.c0 as c5, 
  subq_0.c0 as c6
from 
  (select  
        ref_0.id as c0
      from 
        test_bd.employee as ref_0
            right join test_bd.employee as ref_1
            on ((ref_1.age is NULL) 
                or (ref_1.salary is not NULL))
          inner join test_bd.user_post_comments as ref_2
          on (ref_0.age is NULL)
      where ref_1.years is not NULL) as subq_0
where (subq_0.c0 is NULL) 
  and (subq_0.c0 is NULL)
limit 87;
SHOW profiles;