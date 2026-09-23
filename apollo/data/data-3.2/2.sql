SET profiling=1;
EXPLAIN ANALYZE
select  
  ref_0.discount as c0
from 
  test_bd.products as ref_0
    left join test_bd.posts as ref_1
    on ((ref_1.id is not NULL) 
        and ((EXISTS (
            select  
                ref_2.eid as c0, 
                ref_2.eid as c1, 
                ref_0.category as c2, 
                ref_3.created_at as c3, 
                ref_1.user_id as c4, 
                ref_2.eid as c5, 
                ref_1.updated_at as c6, 
                ref_0.name as c7, 
                ref_2.eid as c8, 
                ref_3.username as c9, 
                ref_3.created_at as c10, 
                ref_1.title as c11, 
                ref_3.username as c12, 
                (select coordinates from test_bd.locations limit 1 offset 19)
                   as c13, 
                ref_3.id as c14, 
                ref_1.updated_at as c15, 
                ref_3.id as c16, 
                ref_3.username as c17
              from 
                test_bd.eids as ref_2
                  right join test_bd.users as ref_3
                  on (ref_3.id is not NULL)
              where ref_2.id is not NULL
              limit 141)) 
          and (ref_0.tags is not NULL)))
where true
limit 167;
SHOW profiles;