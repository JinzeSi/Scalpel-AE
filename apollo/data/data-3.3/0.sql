SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.id as c0
from 
  test_bd.users as ref_0
    inner join test_bd.locations as ref_1
    on (EXISTS (
        select  
            ref_1.user_id as c0, 
            ref_1.id as c1, 
            ref_1.coordinates as c2, 
            ref_1.user_id as c3, 
            69 as c4, 
            ref_2.created_at as c5, 
            ref_0.id as c6, 
            (select id from test_bd.eids limit 1 offset 1)
               as c7, 
            ref_3.eid as c8, 
            ref_2.created_at as c9, 
            ref_0.email as c10, 
            ref_1.name as c11
          from 
            test_bd.products as ref_2
              right join test_bd.eids as ref_3
              on (ref_2.id = ref_3.eid )
          where EXISTS (
            select  
                ref_4.user_id as c0, 
                ref_3.eid as c1, 
                ref_2.tags as c2
              from 
                test_bd.comments as ref_4
              where (EXISTS (
                  select  
                      ref_1.coordinates as c0, 
                      ref_4.comment as c1, 
                      ref_0.email as c2, 
                      ref_0.created_at as c3, 
                      ref_5.username as c4, 
                      (select updated_at from test_bd.posts limit 1 offset 5)
                         as c5, 
                      ref_1.coordinates as c6, 
                      ref_2.id as c7, 
                      ref_2.created_at as c8, 
                      ref_0.id as c9
                    from 
                      test_bd.user_post_comments as ref_5
                    where false
                    limit 186)) 
                or (true)
              limit 76)
          limit 10))
where (ref_0.email is NULL) 
  or (ref_1.coordinates is not NULL)
limit 93;
SHOW profiles;