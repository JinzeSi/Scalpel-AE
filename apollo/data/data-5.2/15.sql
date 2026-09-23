SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_1.c4 as c0, 
  subq_1.c3 as c1, 
  subq_1.c3 as c2
from 
  (select  
        ref_1.post_id as c0, 
        ref_0.virtual_col as c1, 
        ref_1.user_id as c2, 
        ref_0.eid as c3, 
        ref_0.eid as c4, 
        ref_1.comment as c5
      from 
        test_bd.eids as ref_0
          inner join test_bd.comments as ref_1
          on (((EXISTS (
                  select  
                      ref_1.id as c0, 
                      ref_0.id as c1
                    from 
                      test_bd.products as ref_2
                    where true)) 
                or ((((ref_1.created_at is not NULL) 
                      and (false)) 
                    and (ref_1.comment is not NULL)) 
                  or (ref_0.id is NULL))) 
              or (EXISTS (
                select  
                    subq_0.c3 as c0, 
                    subq_0.c8 as c1, 
                    ref_0.id as c2, 
                    ref_0.eid as c3, 
                    (select id from test_bd.eids limit 1 offset 5)
                       as c4, 
                    ref_0.eid as c5, 
                    subq_0.c4 as c6, 
                    subq_0.c11 as c7, 
                    ref_1.comment as c8, 
                    ref_0.id as c9
                  from 
                    test_bd.employee as ref_3,
                    lateral (select  
                          ref_0.id as c0, 
                          ref_3.id as c1, 
                          ref_3.department_id as c2, 
                          ref_4.id as c3, 
                          ref_4.coordinates as c4, 
                          ref_0.eid as c5, 
                          ref_4.name as c6, 
                          ref_4.coordinates as c7, 
                          ref_4.name as c8, 
                          ref_4.id as c9, 
                          ref_1.id as c10, 
                          ref_1.comment as c11, 
                          ref_0.eid as c12, 
                          ref_4.id as c13
                        from 
                          test_bd.locations as ref_4
                        where ref_0.eid is not NULL
                        limit 65) as subq_0
                  where ((select id from test_bd.eids limit 1 offset 4)
                         is NULL) 
                    and (false)
                  limit 140)))
      where true) as subq_1
where (true) 
  or (true)
limit 114;
SHOW profiles;