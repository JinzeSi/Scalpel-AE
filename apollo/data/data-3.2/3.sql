SET profiling=1;
EXPLAIN ANALYZE
select  
  ref_0.tags as c0, 
  ref_0.category as c1, 
  ref_0.id as c2, 
  ref_0.discount as c3, 
  ref_0.created_at as c4, 
  ref_0.tags as c5, 
  ref_0.created_at as c6, 
  coalesce(ref_0.category,
    ref_0.category) as c7
from 
  test_bd.products as ref_0
where (ref_0.category is not NULL) 
  and (ref_0.price is not NULL);
SHOW profiles;