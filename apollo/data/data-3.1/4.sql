SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_1.post_id as c0, 
  ref_1.created_at as c1, 
  ref_1.created_at as c2, 
  ref_1.user_id as c3
from 
  test_bd.user_profiles as ref_0
    inner join test_bd.comments as ref_1
    on (((EXISTS (
            select  
                ref_1.user_id as c0
              from 
                test_bd.posts as ref_2
                  left join test_bd.eids as ref_3
                  on (ref_2.id = ref_3.eid )
              where ((EXISTS (
                    select  
                        ref_4.email as c0
                      from 
                        test_bd.users as ref_4
                      where (select email from test_bd.users limit 1 offset 28)
                           is NULL
                      limit 73)) 
                  and ((ref_1.post_id is not NULL) 
                    or (((EXISTS (
                          select  
                              ref_3.id as c0, 
                              ref_0.bio as c1, 
                              ref_1.post_id as c2, 
                              ref_2.title as c3, 
                              (select created_at from test_bd.comments limit 1 offset 6)
                                 as c4, 
                              ref_0.profile_picture as c5, 
                              ref_0.birthdate as c6, 
                              ref_1.post_id as c7, 
                              ref_2.id as c8, 
                              ref_1.id as c9, 
                              ref_3.virtual_col as c10, 
                              ref_2.user_id as c11, 
                              ref_1.created_at as c12
                            from 
                              test_bd.eids as ref_5
                            where false
                            limit 97)) 
                        and (false)) 
                      or (false)))) 
                or (ref_1.post_id is not NULL))) 
          or (ref_0.bio is not NULL)) 
        and ((ref_0.bio is not NULL) 
          and (EXISTS (
            select  
                ref_0.profile_picture as c0
              from 
                test_bd.products as ref_6
                  inner join test_bd.comments as ref_7
                  on ((((EXISTS (
                            select  
                                ref_8.username as c0, 
                                ref_1.post_id as c1, 
                                ref_1.comment as c2, 
                                (select tags from test_bd.products limit 1 offset 4)
                                   as c3, 
                                ref_0.birthdate as c4, 
                                (select user_id from test_bd.posts limit 1 offset 5)
                                   as c5, 
                                ref_7.created_at as c6, 
                                ref_1.id as c7, 
                                ref_0.birthdate as c8, 
                                ref_1.user_id as c9
                              from 
                                test_bd.user_post_comments as ref_8
                              where EXISTS (
                                select  
                                    ref_6.discount as c0, 
                                    ref_7.post_id as c1, 
                                    ref_0.bio as c2, 
                                    ref_6.price as c3
                                  from 
                                    test_bd.user_profiles as ref_9
                                  where 11 is NULL
                                  limit 89))) 
                          or ((false) 
                            and (((ref_1.comment is NULL) 
                                or ((true) 
                                  and (ref_6.name is NULL))) 
                              and (false)))) 
                        and (((true) 
                            or (false)) 
                          or ((select updated_at from test_bd.posts limit 1 offset 5)
                               is NULL))) 
                      or (((ref_6.id is NULL) 
                          or ((29 is not NULL) 
                            and ((true) 
                              and (ref_7.id is not NULL)))) 
                        or ((ref_0.bio is not NULL) 
                          or (ref_1.comment is NULL))))
              where ref_7.user_id is NULL))))
where true
limit 114;
SHOW profiles;