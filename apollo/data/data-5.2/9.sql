SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_0.c0 as c0, 
  subq_0.c0 as c1, 
  subq_0.c0 as c2, 
  subq_0.c0 as c3, 
  case when EXISTS (
      select  
          ref_1.id as c0, 
          ref_1.created_at as c1, 
          ref_1.post_id as c2, 
          ref_1.user_id as c3, 
          subq_0.c0 as c4, 
          subq_0.c0 as c5, 
          ref_1.post_id as c6, 
          (select eid from test_bd.eids limit 1 offset 4)
             as c7, 
          subq_0.c0 as c8, 
          ref_1.id as c9
        from 
          test_bd.comments as ref_1
        where (ref_1.user_id is NULL) 
          and ((select user_id from test_bd.posts limit 1 offset 1)
               is not NULL)
        limit 100) then subq_0.c0 else subq_0.c0 end
     as c4, 
  subq_0.c0 as c5, 
  subq_0.c0 as c6, 
  coalesce(subq_0.c0,
    subq_0.c0) as c7, 
  subq_0.c0 as c8
from 
  (select  
        ref_0.id as c0
      from 
        test_bd.users as ref_0
      where ref_0.id is not NULL) as subq_0
where true
limit 83;
SHOW profiles;