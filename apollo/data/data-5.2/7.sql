SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.username as c0, 
  ref_1.user_id as c1, 
  ref_1.coordinates as c2, 
  ref_0.email as c3, 
  ref_1.name as c4, 
  ref_0.id as c5, 
  ref_1.id as c6, 
  ref_0.created_at as c7, 
  ref_0.username as c8, 
  ref_1.name as c9, 
  ref_0.email as c10, 
  case when ((ref_1.name is NULL) 
        and (true)) 
      or (((EXISTS (
            select  
                ref_1.id as c0, 
                ref_2.tags as c1, 
                ref_1.user_id as c2, 
                ref_1.id as c3, 
                ref_1.coordinates as c4, 
                ref_1.user_id as c5, 
                ref_0.username as c6, 
                ref_1.id as c7, 
                ref_0.id as c8, 
                ref_0.created_at as c9, 
                ref_2.name as c10, 
                ref_2.id as c11, 
                ref_0.username as c12, 
                ref_2.tags as c13, 
                ref_0.created_at as c14, 
                ref_2.id as c15, 
                ref_2.price as c16, 
                ref_2.id as c17, 
                ref_0.username as c18, 
                ref_2.category as c19, 
                ref_1.id as c20, 
                ref_0.created_at as c21, 
                ref_0.email as c22, 
                ref_1.coordinates as c23, 
                ref_1.user_id as c24
              from 
                test_bd.products as ref_2
              where true)) 
          and (ref_0.created_at is not NULL)) 
        or (EXISTS (
          select  
              subq_0.c1 as c0, 
              ref_0.id as c1, 
              subq_0.c1 as c2, 
              ref_3.name as c3, 
              ref_0.created_at as c4, 
              subq_0.c1 as c5, 
              ref_3.coordinates as c6
            from 
              test_bd.locations as ref_3,
              lateral (select  
                    ref_0.username as c0, 
                    ref_3.name as c1
                  from 
                    test_bd.user_profiles as ref_4
                  where (true) 
                    or (((false) 
                        or (true)) 
                      or (true))) as subq_0
            where true))) then ref_1.id else ref_1.id end
     as c11, 
  ref_0.created_at as c12, 
  ref_1.user_id as c13, 
  49 as c14, 
  ref_1.user_id as c15, 
  ref_1.id as c16, 
  (select virtual_col from test_bd.eids limit 1 offset 4)
     as c17
from 
  test_bd.users as ref_0
    right join test_bd.locations as ref_1
    on (ref_0.created_at is not NULL)
where (false) 
  or (ref_0.email is not NULL)
limit 99;
SHOW profiles;