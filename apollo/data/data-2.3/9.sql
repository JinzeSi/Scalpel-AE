SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.discount as c0, 
  ref_0.tags as c1, 
  ref_0.id as c2, 
  (select salary from test_bd.employee limit 1 offset 6)
     as c3, 
  ref_0.price as c4, 
  ref_0.price as c5, 
  ref_0.id as c6, 
  ref_0.price as c7, 
  ref_0.id as c8
from 
  test_bd.products as ref_0
where (select comment from test_bd.user_post_comments limit 1 offset 6)
     is not NULL;
SHOW profiles;