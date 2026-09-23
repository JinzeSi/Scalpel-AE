SET profiling=1;
EXPLAIN ANALYZE

select  
  case when subq_1.c0 is not NULL then subq_1.c0 else subq_1.c0 end
     as c0, 
  subq_1.c0 as c1, 
  subq_1.c0 as c2, 
  subq_1.c0 as c3, 
  subq_1.c0 as c4, 
  subq_1.c0 as c5, 
  subq_1.c0 as c6, 
  subq_1.c0 as c7
from 
  (select  
        subq_0.c0 as c0
      from 
        (select  
              ref_0.bio as c0
            from 
              test_bd.user_profiles as ref_0
            where (EXISTS (
                select  
                    ref_0.profile_picture as c0, 
                    ref_0.user_id as c1, 
                    ref_1.virtual_col as c2, 
                    ref_0.user_id as c3, 
                    ref_0.profile_picture as c4, 
                    ref_1.virtual_col as c5, 
                    ref_1.virtual_col as c6, 
                    ref_0.user_id as c7, 
                    (select user_id from test_bd.posts limit 1 offset 2)
                       as c8, 
                    ref_1.eid as c9, 
                    ref_0.user_id as c10, 
                    ref_1.eid as c11, 
                    ref_1.id as c12
                  from 
                    test_bd.eids as ref_1
                  where ref_1.virtual_col is NULL
                  limit 115)) 
              or ((select username from test_bd.users limit 1 offset 82)
                   is NULL)
            limit 62) as subq_0
      where (subq_0.c0 is NULL) 
        and (true)) as subq_1
where (true) 
  and (subq_1.c0 is NULL)
limit 104;
SHOW profiles;