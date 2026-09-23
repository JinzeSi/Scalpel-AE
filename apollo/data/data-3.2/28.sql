SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_1.c1 as c0
from 
  (select  
        ref_0.username as c0, 
        ref_0.id as c1, 
        subq_0.c0 as c2
      from 
        test_bd.users as ref_0,
        lateral (select  
              ref_2.id as c0
            from 
              test_bd.locations as ref_1
                left join test_bd.comments as ref_2
                on (ref_1.id = ref_2.id )
            where EXISTS (
              select  
                  ref_1.user_id as c0, 
                  ref_2.user_id as c1, 
                  ref_2.post_id as c2, 
                  68 as c3, 
                  ref_2.id as c4
                from 
                  test_bd.comments as ref_3
                where (false) 
                  or (((ref_0.created_at is not NULL) 
                      or (((true) 
                          or (((ref_0.email is not NULL) 
                              or (((false) 
                                  and (EXISTS (
                                    select  
                                        ref_1.id as c0, 
                                        ref_1.coordinates as c1, 
                                        ref_0.id as c2, 
                                        ref_3.user_id as c3, 
                                        ref_4.profile_picture as c4
                                      from 
                                        test_bd.user_profiles as ref_4
                                      where (ref_3.post_id is NULL) 
                                        or ((true) 
                                          or (EXISTS (
                                            select  
                                                ref_5.eid as c0
                                              from 
                                                test_bd.eids as ref_5
                                              where ref_2.created_at is not NULL
                                              limit 93)))))) 
                                or (ref_0.created_at is not NULL))) 
                            and (true))) 
                        and (EXISTS (
                          select  
                              ref_3.comment as c0, 
                              ref_3.comment as c1, 
                              ref_6.coordinates as c2, 
                              ref_6.coordinates as c3, 
                              ref_0.id as c4
                            from 
                              test_bd.locations as ref_6
                            where false
                            limit 130)))) 
                    or (false))
                limit 29)) as subq_0
      where ((select email from test_bd.employee limit 1 offset 1)
             is not NULL) 
        and ((subq_0.c0 is NULL) 
          or (false))
      limit 12) as subq_1
where subq_1.c0 is not NULL
limit 93;
SHOW profiles;