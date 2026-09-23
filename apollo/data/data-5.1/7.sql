SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_0.c4 as c0
from 
  (select  
            ref_0.user_id as c0, 
            ref_1.user_id as c1, 
            ref_1.user_id as c2, 
            ref_0.id as c3, 
            ref_1.created_at as c4
          from 
            test_bd.locations as ref_0
              inner join test_bd.posts as ref_1
              on (ref_0.name is NULL)
          where (ref_1.user_id is NULL) 
            or (EXISTS (
              select  
                  (select user_id from test_bd.locations limit 1 offset 5)
                     as c0, 
                  ref_2.id as c1, 
                  22 as c2
                from 
                  test_bd.eids as ref_2
                where true))
          limit 95) as subq_0
      left join test_bd.employee as ref_3
        right join test_bd.user_profiles as ref_4
          left join test_bd.products as ref_5
          on (false)
        on ((ref_4.bio is NULL) 
            or (EXISTS (
              select  
                  ref_5.id as c0
                from 
                  test_bd.employee as ref_6
                where (false) 
                  and ((true) 
                    and (true)))))
      on (subq_0.c0 = ref_4.user_id )
    left join (select  
          ref_7.id as c0, 
          ref_7.eid as c1, 
          ref_7.id as c2, 
          ref_7.virtual_col as c3, 
          ref_7.eid as c4, 
          ref_7.eid as c5
        from 
          test_bd.eids as ref_7
        where (true) 
          or ((true) 
            or (false))) as subq_1
    on (ref_5.name is not NULL)
where ref_4.bio is NULL;
SHOW profiles;