SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c0 as c0, 
  case when EXISTS (
      select  
          ref_1.name as c0, 
          subq_0.c2 as c1
        from 
          test_bd.locations as ref_1
        where false) then subq_0.c2 else subq_0.c2 end
     as c1, 
  subq_0.c0 as c2, 
  case when subq_0.c0 is not NULL then (select username from test_bd.users limit 1 offset 34)
       else (select username from test_bd.users limit 1 offset 34)
       end
     as c3, 
  13 as c4, 
  subq_0.c2 as c5, 
  subq_0.c2 as c6, 
  subq_0.c2 as c7, 
  subq_0.c0 as c8, 
  subq_0.c0 as c9, 
  subq_0.c1 as c10, 
  case when (subq_0.c2 is not NULL) 
      and (subq_0.c2 is NULL) then subq_0.c2 else subq_0.c2 end
     as c11, 
  subq_0.c1 as c12, 
  subq_0.c1 as c13
from 
  (select  
        ref_0.email as c0, 
        ref_0.id as c1, 
        ref_0.department_id as c2
      from 
        test_bd.employee as ref_0
      where (false) 
        or ((ref_0.department_id is NULL) 
          or (true))) as subq_0
where ((((subq_0.c2 is NULL) 
        and ((((((((true) 
                      and (subq_0.c2 is NULL)) 
                    and ((false) 
                      or (EXISTS (
                        select  
                            subq_0.c2 as c0, 
                            subq_0.c2 as c1, 
                            ref_2.created_at as c2
                          from 
                            test_bd.posts as ref_2
                          where false
                          limit 157)))) 
                  and (true)) 
                or (true)) 
              or ((subq_0.c0 is NULL) 
                and (((false) 
                    or (EXISTS (
                      select  
                          ref_3.comment as c0, 
                          ref_3.user_id as c1
                        from 
                          test_bd.comments as ref_3,
                          lateral (select  
                                ref_3.post_id as c0, 
                                ref_4.created_at as c1, 
                                ref_4.post_id as c2, 
                                subq_0.c2 as c3, 
                                ref_4.created_at as c4, 
                                ref_4.comment as c5, 
                                ref_4.post_id as c6, 
                                ref_4.id as c7, 
                                ref_4.post_id as c8, 
                                subq_0.c1 as c9, 
                                ref_4.post_id as c10, 
                                ref_3.created_at as c11, 
                                ref_4.comment as c12, 
                                ref_3.post_id as c13, 
                                ref_4.comment as c14, 
                                ref_4.comment as c15, 
                                46 as c16, 
                                ref_4.post_id as c17
                              from 
                                test_bd.comments as ref_4
                              where (87 is NULL) 
                                or (false)
                              limit 62) as subq_1
                        where true))) 
                  or (subq_0.c0 is NULL)))) 
            or (EXISTS (
              select  
                  subq_0.c2 as c0, 
                  subq_2.c0 as c1, 
                  subq_2.c1 as c2
                from 
                  test_bd.users as ref_5,
                  lateral (select  
                        ref_5.username as c0, 
                        ref_5.username as c1, 
                        ref_6.eid as c2
                      from 
                        test_bd.eids as ref_6
                      where (false) 
                        or (true)
                      limit 100) as subq_2
                where ref_5.created_at is not NULL))) 
          or ((EXISTS (
              select  
                  ref_7.created_at as c0, 
                  ref_7.title as c1, 
                  ref_7.created_at as c2, 
                  75 as c3, 
                  ref_7.created_at as c4, 
                  ref_7.title as c5, 
                  subq_0.c2 as c6, 
                  ref_7.content as c7, 
                  ref_7.id as c8, 
                  ref_7.created_at as c9, 
                  subq_0.c0 as c10, 
                  ref_7.id as c11, 
                  ref_7.updated_at as c12, 
                  subq_0.c0 as c13, 
                  subq_0.c2 as c14, 
                  ref_7.updated_at as c15, 
                  subq_0.c1 as c16, 
                  ref_7.user_id as c17, 
                  ref_7.id as c18, 
                  subq_0.c0 as c19, 
                  ref_7.user_id as c20, 
                  subq_0.c0 as c21, 
                  (select id from test_bd.products limit 1 offset 83)
                     as c22, 
                  (select name from test_bd.locations limit 1 offset 18)
                     as c23, 
                  ref_7.id as c24, 
                  subq_0.c2 as c25, 
                  subq_0.c1 as c26, 
                  subq_0.c1 as c27, 
                  ref_7.title as c28, 
                  ref_7.id as c29
                from 
                  test_bd.posts as ref_7
                where EXISTS (
                  select  
                      ref_8.updated_at as c0, 
                      ref_8.id as c1, 
                      subq_0.c1 as c2, 
                      ref_7.user_id as c3, 
                      ref_7.id as c4, 
                      ref_7.updated_at as c5, 
                      ref_7.content as c6, 
                      ref_8.created_at as c7, 
                      35 as c8, 
                      ref_7.content as c9, 
                      ref_7.content as c10
                    from 
                      test_bd.posts as ref_8
                    where false
                    limit 148)
                limit 119)) 
            or (false)))) 
      or ((subq_0.c2 is not NULL) 
        and (subq_0.c1 is not NULL))) 
    and (EXISTS (
      select  
          subq_0.c2 as c0, 
          subq_3.c3 as c1, 
          subq_3.c4 as c2, 
          subq_0.c1 as c3, 
          subq_0.c2 as c4, 
          subq_0.c1 as c5, 
          (select coordinates from test_bd.locations limit 1 offset 5)
             as c6, 
          subq_3.c3 as c7, 
          subq_0.c1 as c8, 
          subq_0.c2 as c9, 
          subq_0.c1 as c10
        from 
          (select  
                subq_0.c1 as c0, 
                ref_9.tags as c1, 
                ref_9.created_at as c2, 
                subq_0.c2 as c3, 
                subq_0.c2 as c4, 
                ref_9.created_at as c5
              from 
                test_bd.products as ref_9
              where (false) 
                and (true)
              limit 126) as subq_3
        where false))) 
  or (subq_0.c0 is NULL)
limit 121;
SHOW profiles;