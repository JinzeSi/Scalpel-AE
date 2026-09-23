SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_3.c0 as c0, 
  subq_3.c0 as c1, 
  subq_4.c2 as c2
from 
  (select  
        ref_2.id as c0, 
        ref_0.user_id as c1
      from 
        test_bd.locations as ref_0
          inner join test_bd.eids as ref_1
            left join test_bd.comments as ref_2
            on (ref_1.id = ref_2.id )
          on (((ref_0.name is not NULL) 
                or ((ref_1.id is not NULL) 
                  and (true))) 
              or ((false) 
                and ((((true) 
                      and (false)) 
                    or (((ref_2.comment is not NULL) 
                        and (((false) 
                            and ((false) 
                              and ((true) 
                                or ((EXISTS (
                                    select  
                                        ref_1.eid as c0, 
                                        ref_0.id as c1, 
                                        99 as c2, 
                                        ref_2.id as c3
                                      from 
                                        test_bd.posts as ref_3,
                                        lateral (select  
                                              ref_2.post_id as c0, 
                                              ref_2.user_id as c1, 
                                              ref_0.coordinates as c2
                                            from 
                                              test_bd.user_profiles as ref_4,
                                              lateral (select  
                                                    ref_5.comment as c0, 
                                                    ref_0.id as c1, 
                                                    ref_5.post_id as c2, 
                                                    (select birthdate from test_bd.user_profiles limit 1 offset 6)
                                                       as c3, 
                                                    ref_0.name as c4, 
                                                    ref_3.title as c5, 
                                                    ref_3.id as c6, 
                                                    ref_5.post_id as c7, 
                                                    57 as c8, 
                                                    ref_3.content as c9
                                                  from 
                                                    test_bd.comments as ref_5
                                                  where (true) 
                                                    and (true)
                                                  limit 19) as subq_0
                                            where (ref_3.id is not NULL) 
                                              or ((true) 
                                                or (true))) as subq_1
                                      where ref_2.created_at is not NULL)) 
                                  or (ref_2.comment is not NULL))))) 
                          or ((ref_0.user_id is not NULL) 
                            or (EXISTS (
                              select  
                                  60 as c0, 
                                  ref_2.id as c1, 
                                  ref_6.id as c2, 
                                  ref_6.salary as c3, 
                                  ref_2.user_id as c4, 
                                  ref_6.id as c5
                                from 
                                  test_bd.employee as ref_6,
                                  lateral (select  
                                        ref_0.user_id as c0
                                      from 
                                        test_bd.user_post_comments as ref_7
                                      where (false) 
                                        or ((false) 
                                          and ((((ref_2.post_id is NULL) 
                                                and (true)) 
                                              and ((false) 
                                                and (false))) 
                                            and ((ref_2.created_at is not NULL) 
                                              and (((false) 
                                                  and (ref_7.comment is NULL)) 
                                                and (false)))))
                                      limit 80) as subq_2
                                where false
                                limit 80))))) 
                      or ((select created_at from test_bd.comments limit 1 offset 6)
                           is NULL))) 
                  and (EXISTS (
                    select  
                        ref_2.created_at as c0, 
                        ref_1.eid as c1, 
                        ref_8.created_at as c2, 
                        ref_2.comment as c3, 
                        ref_1.eid as c4, 
                        ref_1.id as c5, 
                        ref_8.username as c6, 
                        ref_2.user_id as c7, 
                        ref_1.eid as c8, 
                        ref_2.id as c9, 
                        ref_8.email as c10, 
                        ref_0.id as c11
                      from 
                        test_bd.users as ref_8
                      where ref_2.post_id is NULL
                      limit 54)))))
      where ref_1.id is not NULL
      limit 128) as subq_3,
  lateral (select  
        subq_3.c1 as c0, 
        ref_9.comment as c1, 
        ref_9.title as c2
      from 
        test_bd.user_post_comments as ref_9
      where (ref_9.username is not NULL) 
        or ((subq_3.c0 is not NULL) 
          and (((false) 
              or (false)) 
            or (ref_9.comment is not NULL)))) as subq_4
where subq_3.c1 is not NULL
limit 73;
SHOW profiles;