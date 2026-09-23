SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_3.bio as c0, 
  ref_2.discount as c1, 
  ref_3.bio as c2, 
  ref_0.coordinates as c3, 
  ref_4.discount as c4, 
  100 as c5, 
  ref_4.category as c6, 
  ref_2.created_at as c7, 
  39 as c8, 
  ref_0.name as c9, 
  ref_3.birthdate as c10, 
  coalesce(ref_3.user_id,
    ref_2.id) as c11, 
  coalesce(ref_3.user_id,
    coalesce(ref_4.id,
      ref_4.id)) as c12, 
  ref_0.name as c13, 
  ref_3.birthdate as c14, 
  ref_3.user_id as c15
from 
  test_bd.locations as ref_0
    right join (select  
              ref_1.birthdate as c0
            from 
              test_bd.user_profiles as ref_1
            where ref_1.birthdate is not NULL
            limit 148) as subq_0
        left join test_bd.products as ref_2
        on (true)
      right join test_bd.user_profiles as ref_3
        right join test_bd.products as ref_4
        on ((true) 
            or ((ref_4.discount is not NULL) 
              or (((ref_3.user_id is NULL) 
                  or (((true) 
                      and ((((true) 
                            and (ref_3.user_id is NULL)) 
                          or (((EXISTS (
                                select  
                                    ref_5.title as c0, 
                                    ref_3.bio as c1, 
                                    ref_5.comment as c2, 
                                    (select username from test_bd.user_post_comments limit 1 offset 2)
                                       as c3, 
                                    (select email from test_bd.users limit 1 offset 5)
                                       as c4, 
                                    81 as c5, 
                                    25 as c6, 
                                    subq_1.c0 as c7, 
                                    subq_1.c1 as c8, 
                                    ref_5.title as c9, 
                                    ref_4.tags as c10
                                  from 
                                    test_bd.user_post_comments as ref_5,
                                    lateral (select  
                                          ref_3.user_id as c0, 
                                          ref_5.title as c1
                                        from 
                                          test_bd.users as ref_6
                                        where false
                                        limit 72) as subq_1
                                  where EXISTS (
                                    select  
                                        ref_3.user_id as c0, 
                                        (select title from test_bd.user_post_comments limit 1 offset 6)
                                           as c1, 
                                        12 as c2, 
                                        ref_4.created_at as c3, 
                                        ref_3.bio as c4, 
                                        subq_1.c0 as c5, 
                                        ref_4.price as c6, 
                                        ref_7.id as c7, 
                                        subq_1.c0 as c8, 
                                        ref_7.created_at as c9, 
                                        ref_4.price as c10, 
                                        ref_5.username as c11, 
                                        ref_7.username as c12
                                      from 
                                        test_bd.users as ref_7
                                      where (true) 
                                        and (((true) 
                                            and (false)) 
                                          or (((((false) 
                                                  and (ref_4.created_at is NULL)) 
                                                and ((false) 
                                                  or (false))) 
                                              or ((ref_4.discount is not NULL) 
                                                or (true))) 
                                            or (false))))
                                  limit 77)) 
                              and (true)) 
                            or ((select id from test_bd.eids limit 1 offset 96)
                                 is not NULL))) 
                        and (false))) 
                    and ((true) 
                      and (ref_4.price is NULL)))) 
                or (false))))
      on ((false) 
          and (ref_2.category is not NULL))
    on (ref_0.id = ref_4.id )
where ref_3.profile_picture is NULL
limit 120;
SHOW profiles;