SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c0 as c0
from 
  (select  
        ref_1.profile_picture as c0, 
        case when (((ref_2.title is NULL) 
                and (((EXISTS (
                      select  
                          ref_2.content as c0
                        from 
                          test_bd.users as ref_5
                        where ref_0.eid is NULL)) 
                    or (ref_2.content is not NULL)) 
                  or (((true) 
                      and (EXISTS (
                        select  
                            ref_0.eid as c0, 
                            ref_0.id as c1, 
                            68 as c2, 
                            ref_2.created_at as c3, 
                            ref_1.birthdate as c4, 
                            ref_1.birthdate as c5, 
                            ref_2.id as c6, 
                            ref_6.birthdate as c7, 
                            ref_1.bio as c8, 
                            ref_2.title as c9, 
                            ref_6.birthdate as c10, 
                            ref_6.user_id as c11, 
                            ref_1.profile_picture as c12, 
                            ref_1.user_id as c13, 
                            ref_2.id as c14, 
                            ref_0.id as c15, 
                            73 as c16, 
                            ref_0.virtual_col as c17, 
                            ref_6.birthdate as c18, 
                            ref_2.created_at as c19
                          from 
                            test_bd.user_profiles as ref_6
                          where ref_0.eid is not NULL
                          limit 179))) 
                    or (false)))) 
              and (false)) 
            and (true) then ref_0.virtual_col else ref_0.virtual_col end
           as c1
      from 
        test_bd.eids as ref_0
            right join test_bd.user_profiles as ref_1
            on (ref_0.virtual_col is not NULL)
          inner join test_bd.posts as ref_2
          on (((false) 
                and (false)) 
              or (EXISTS (
                select  
                    ref_2.title as c0
                  from 
                    test_bd.users as ref_3
                  where EXISTS (
                    select  
                        ref_0.virtual_col as c0, 
                        ref_1.birthdate as c1, 
                        ref_2.id as c2, 
                        ref_0.id as c3, 
                        ref_2.created_at as c4, 
                        ref_4.user_id as c5, 
                        ref_0.virtual_col as c6, 
                        ref_4.id as c7, 
                        ref_0.virtual_col as c8, 
                        ref_0.eid as c9, 
                        ref_0.virtual_col as c10, 
                        ref_4.comment as c11, 
                        ref_0.virtual_col as c12, 
                        ref_0.eid as c13, 
                        ref_2.created_at as c14, 
                        ref_0.eid as c15, 
                        ref_0.eid as c16, 
                        ref_4.id as c17, 
                        (select created_at from test_bd.products limit 1 offset 2)
                           as c18, 
                        ref_0.eid as c19, 
                        ref_1.profile_picture as c20
                      from 
                        test_bd.comments as ref_4
                      where true
                      limit 94)
                  limit 118)))
      where ((28 is NULL) 
          or (ref_2.updated_at is NULL)) 
        and ((ref_0.virtual_col is NULL) 
          or (ref_1.user_id is NULL))
      limit 24) as subq_0
where ((subq_0.c0 is not NULL) 
    and (((false) 
        or (true)) 
      and ((subq_0.c1 is not NULL) 
        and (((subq_0.c0 is NULL) 
            or (false)) 
          or ((subq_0.c1 is not NULL) 
            or (subq_0.c1 is not NULL)))))) 
  and (subq_0.c0 is NULL);
SHOW profiles;