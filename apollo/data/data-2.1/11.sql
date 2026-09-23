SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_0.c11 as c0, 
  subq_0.c3 as c1, 
  subq_0.c5 as c2, 
  ref_0.comment as c3, 
  subq_0.c7 as c4, 
  subq_0.c10 as c5, 
  ref_0.comment as c6
from 
  test_bd.user_post_comments as ref_0,
  lateral (select  
        ref_1.id as c0, 
        ref_1.created_at as c1, 
        ref_1.discount as c2, 
        49 as c3, 
        ref_1.discount as c4, 
        (select email from test_bd.users limit 1 offset 4)
           as c5, 
        ref_1.name as c6, 
        ref_1.price as c7, 
        32 as c8, 
        ref_1.tags as c9, 
        ref_1.discount as c10, 
        ref_1.tags as c11, 
        ref_1.discount as c12
      from 
        test_bd.products as ref_1
      where (EXISTS (
          select  
              ref_3.comment as c0
            from 
              test_bd.users as ref_2
                inner join test_bd.user_post_comments as ref_3
                on (true)
            where (true) 
              and ((false) 
                or (EXISTS (
                  select  
                      ref_0.title as c0, 
                      ref_2.created_at as c1, 
                      (select title from test_bd.posts limit 1 offset 2)
                         as c2, 
                      (select coordinates from test_bd.locations limit 1 offset 6)
                         as c3, 
                      13 as c4, 
                      ref_3.username as c5, 
                      ref_1.category as c6, 
                      ref_4.name as c7, 
                      ref_3.username as c8, 
                      ref_1.id as c9, 
                      ref_4.name as c10, 
                      ref_1.id as c11, 
                      ref_4.user_id as c12, 
                      ref_4.coordinates as c13, 
                      ref_3.title as c14, 
                      ref_0.comment as c15, 
                      ref_3.comment as c16, 
                      ref_0.title as c17, 
                      ref_0.title as c18, 
                      ref_0.username as c19, 
                      ref_4.user_id as c20
                    from 
                      test_bd.locations as ref_4
                    where (true) 
                      or (((ref_3.username is not NULL) 
                          and ((EXISTS (
                              select  
                                  ref_2.username as c0, 
                                  ref_1.name as c1
                                from 
                                  test_bd.employee as ref_5
                                where (ref_3.username is NULL) 
                                  or (EXISTS (
                                    select  
                                        ref_4.coordinates as c0, 
                                        ref_3.comment as c1, 
                                        (select id from test_bd.comments limit 1 offset 2)
                                           as c2, 
                                        (select id from test_bd.posts limit 1 offset 1)
                                           as c3, 
                                        ref_5.years as c4, 
                                        ref_3.comment as c5
                                      from 
                                        test_bd.products as ref_6
                                      where ref_4.user_id is NULL
                                      limit 117))
                                limit 86)) 
                            and (false))) 
                        or (false))
                    limit 53))))) 
        or (EXISTS (
          select  
              ref_0.comment as c0
            from 
              test_bd.eids as ref_7
            where (EXISTS (
                select  
                    ref_1.tags as c0
                  from 
                    test_bd.comments as ref_8
                  where (true) 
                    or (false)
                  limit 166)) 
              or (true)
            limit 107))
      limit 97) as subq_0
where subq_0.c4 is not NULL
limit 128;
SHOW profiles;