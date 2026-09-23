SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_0.c1 as c0, 
  coalesce(subq_0.c0,
    subq_0.c0) as c1, 
  subq_0.c2 as c2
from 
  (select  
        ref_0.comment as c0, 
        ref_1.user_id as c1, 
        ref_0.title as c2
      from 
        test_bd.user_post_comments as ref_0
          inner join test_bd.user_profiles as ref_1
          on (ref_1.user_id is not NULL)
      where (((true) 
            and ((false) 
              or (false))) 
          and (true)) 
        or (true)) as subq_0
where true;
SHOW profiles;