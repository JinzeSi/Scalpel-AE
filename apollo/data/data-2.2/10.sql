SET profiling=1;
EXPLAIN ANALYZE
select  
  ref_0.bio as c0, 
  subq_0.c0 as c1, 
  subq_0.c1 as c2, 
  ref_0.bio as c3, 
  ref_0.profile_picture as c4, 
  subq_0.c0 as c5, 
  ref_0.birthdate as c6, 
  ref_0.birthdate as c7
from 
  test_bd.user_profiles as ref_0
    left join (select  
          ref_2.price as c0, 
          ref_1.coordinates as c1
        from 
          test_bd.locations as ref_1
            left join test_bd.products as ref_2
            on (false)
        where ((ref_2.price is NULL) 
            or (false)) 
          or (ref_1.user_id is NULL)) as subq_0
    on (true)
where true;
SHOW profiles;