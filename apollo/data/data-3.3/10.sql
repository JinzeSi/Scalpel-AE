SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_1.title as c0, 
  (select id from test_bd.users limit 1 offset 1)
     as c1
from 
  test_bd.posts as ref_0
    left join test_bd.user_post_comments as ref_1
    on (ref_0.user_id is NULL)
where (case when ref_0.title is not NULL then ref_0.title else ref_0.title end
       is NULL) 
  or ((((EXISTS (
          select  
              ref_0.id as c0, 
              ref_2.eid as c1, 
              ref_2.eid as c2, 
              ref_2.id as c3, 
              ref_2.virtual_col as c4, 
              ref_2.virtual_col as c5, 
              ref_1.title as c6, 
              ref_0.title as c7, 
              ref_2.eid as c8, 
              ref_0.id as c9, 
              ref_2.id as c10
            from 
              test_bd.eids as ref_2
            where ((((true) 
                    or (ref_1.username is not NULL)) 
                  or (EXISTS (
                    select  
                        ref_0.content as c0, 
                        ref_2.virtual_col as c1, 
                        ref_0.user_id as c2, 
                        ref_2.id as c3, 
                        ref_3.created_at as c4, 
                        ref_1.comment as c5, 
                        (select id from test_bd.eids limit 1 offset 6)
                           as c6, 
                        ref_1.title as c7, 
                        ref_3.id as c8
                      from 
                        test_bd.posts as ref_3
                      where (true) 
                        and (false)
                      limit 41))) 
                or ((ref_0.user_id is not NULL) 
                  or (true))) 
              or (true)
            limit 140)) 
        and (((false) 
            or (((ref_1.username is not NULL) 
                or (true)) 
              or (EXISTS (
                select  
                    ref_0.updated_at as c0, 
                    ref_1.title as c1
                  from 
                    test_bd.eids as ref_4
                  where (true) 
                    or ((ref_0.updated_at is NULL) 
                      or ((((false) 
                            or ((((ref_0.updated_at is not NULL) 
                                  and (((true) 
                                      or (false)) 
                                    or (false))) 
                                or (false)) 
                              and (EXISTS (
                                select  
                                    ref_0.user_id as c0, 
                                    ref_0.created_at as c1, 
                                    ref_5.department_id as c2, 
                                    ref_5.eid as c3, 
                                    (select user_id from test_bd.locations limit 1 offset 2)
                                       as c4, 
                                    ref_5.age as c5
                                  from 
                                    test_bd.employee as ref_5
                                  where ref_0.user_id is NULL
                                  limit 62)))) 
                          or ((false) 
                            and (EXISTS (
                              select  
                                  ref_0.user_id as c0, 
                                  ref_6.name as c1, 
                                  (select name from test_bd.products limit 1 offset 6)
                                     as c2, 
                                  ref_4.eid as c3, 
                                  ref_0.title as c4, 
                                  ref_6.category as c5, 
                                  ref_0.id as c6, 
                                  ref_1.comment as c7
                                from 
                                  test_bd.products as ref_6
                                where true
                                limit 62)))) 
                        and (false)))
                  limit 81)))) 
          or (false))) 
      and ((((true) 
            and (true)) 
          or (true)) 
        and (ref_1.username is NULL))) 
    and (case when false then case when (true) 
            and (ref_1.title is NULL) then ref_0.content else ref_0.content end
           else case when (true) 
            and (ref_1.title is NULL) then ref_0.content else ref_0.content end
           end
         is not NULL));
SHOW profiles;