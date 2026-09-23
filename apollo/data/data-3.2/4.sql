SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c1 as c0
from 
  (select  
        ref_1.updated_at as c0, 
        ref_0.user_id as c1, 
        ref_1.content as c2
      from 
        test_bd.locations as ref_0
          left join test_bd.posts as ref_1
          on (ref_0.name is NULL)
      where ref_0.user_id is not NULL
      limit 139) as subq_0
where (subq_0.c0 is not NULL) 
  or (subq_0.c2 is not NULL);
SHOW profiles;