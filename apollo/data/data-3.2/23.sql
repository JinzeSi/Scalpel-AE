SET profiling=1;
EXPLAIN ANALYZE

select  
  case when EXISTS (
      select  
          subq_2.c1 as c0
        from 
          test_bd.comments as ref_3
            left join test_bd.comments as ref_4
            on ((select eid from test_bd.employee limit 1 offset 4)
                   is not NULL),
          lateral (select  
                94 as c0, 
                28 as c1
              from 
                test_bd.users as ref_5
              where (ref_4.post_id is not NULL) 
                or (subq_1.c2 is not NULL)
              limit 106) as subq_2
        where true
        limit 161) then subq_1.c3 else subq_1.c3 end
     as c0
from 
  (select  
        subq_0.c24 as c0, 
        subq_0.c18 as c1, 
        subq_0.c0 as c2, 
        subq_0.c29 as c3, 
        subq_0.c33 as c4, 
        subq_0.c14 as c5
      from 
        (select  
              ref_0.content as c0, 
              ref_0.user_id as c1, 
              ref_0.title as c2, 
              ref_0.created_at as c3, 
              ref_0.title as c4, 
              ref_0.content as c5, 
              ref_0.content as c6, 
              75 as c7, 
              ref_0.user_id as c8, 
              ref_0.user_id as c9, 
              ref_0.created_at as c10, 
              (select post_id from test_bd.comments limit 1 offset 3)
                 as c11, 
              ref_0.created_at as c12, 
              ref_0.title as c13, 
              ref_0.id as c14, 
              ref_0.content as c15, 
              ref_0.created_at as c16, 
              ref_0.id as c17, 
              ref_0.created_at as c18, 
              ref_0.updated_at as c19, 
              (select id from test_bd.locations limit 1 offset 78)
                 as c20, 
              ref_0.title as c21, 
              ref_0.id as c22, 
              ref_0.updated_at as c23, 
              ref_0.title as c24, 
              ref_0.user_id as c25, 
              ref_0.updated_at as c26, 
              ref_0.title as c27, 
              ref_0.title as c28, 
              ref_0.updated_at as c29, 
              ref_0.user_id as c30, 
              ref_0.updated_at as c31, 
              (select user_id from test_bd.comments limit 1 offset 2)
                 as c32, 
              ref_0.content as c33
            from 
              test_bd.posts as ref_0
            where true
            limit 96) as subq_0
      where EXISTS (
        select  
            ref_1.user_id as c0, 
            subq_0.c31 as c1, 
            (select user_id from test_bd.user_profiles limit 1 offset 4)
               as c2, 
            subq_0.c27 as c3, 
            ref_1.user_id as c4
          from 
            test_bd.user_profiles as ref_1
          where ((true) 
              or ((71 is NULL) 
                and (false))) 
            and (EXISTS (
              select  
                  subq_0.c17 as c0, 
                  subq_0.c16 as c1, 
                  ref_2.user_id as c2, 
                  subq_0.c4 as c3, 
                  subq_0.c3 as c4, 
                  ref_1.bio as c5, 
                  subq_0.c22 as c6, 
                  ref_1.profile_picture as c7, 
                  (select user_id from test_bd.posts limit 1 offset 1)
                     as c8
                from 
                  test_bd.comments as ref_2
                where (select category from test_bd.products limit 1 offset 6)
                     is not NULL))
          limit 75)
      limit 97) as subq_1
where true;
SHOW profiles;