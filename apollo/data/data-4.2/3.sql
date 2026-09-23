SET profiling=1;
EXPLAIN ANALYZE

WITH 
jennifer_0 AS (select  
    subq_1.c0 as c0
  from 
    (select  
            ref_0.created_at as c0, 
            (select profile_picture from test_bd.user_profiles limit 1 offset 54)
               as c1, 
            ref_0.created_at as c2, 
            ref_1.created_at as c3, 
            ref_0.email as c4
          from 
            test_bd.users as ref_0
              inner join test_bd.users as ref_1
              on (ref_1.id is not NULL)
          where true
          limit 97) as subq_0
      left join (select  
            ref_2.created_at as c0, 
            ref_2.comment as c1, 
            ref_2.user_id as c2, 
            ref_2.user_id as c3, 
            54 as c4
          from 
            test_bd.comments as ref_2
          where false) as subq_1
      on (subq_0.c3 = subq_1.c0 )
  where (true) 
    or (case when (subq_1.c2 is NULL) 
          and (true) then subq_0.c1 else subq_0.c1 end
         is NULL)
  limit 138)
select  
    66 as c0, 
    (select comment from test_bd.comments limit 1 offset 2)
       as c1, 
    ref_3.title as c2, 
    ref_3.user_id as c3, 
    ref_3.updated_at as c4, 
    ref_3.created_at as c5, 
    (select title from test_bd.user_post_comments limit 1 offset 5)
       as c6
  from 
    test_bd.posts as ref_3
  where ref_3.user_id is not NULL
;
SHOW profiles;