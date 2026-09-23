SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c5 as c0, 
  subq_0.c2 as c1
from 
  (select  
        ref_1.birthdate as c0, 
        ref_1.bio as c1, 
        38 as c2, 
        ref_1.bio as c3, 
        (select age from test_bd.employee limit 1 offset 6)
           as c4, 
        ref_0.user_id as c5
      from 
        test_bd.locations as ref_0
          inner join test_bd.user_profiles as ref_1
          on (44 is not NULL)
      where (true) 
        or (true)) as subq_0
where true;
SHOW profiles;