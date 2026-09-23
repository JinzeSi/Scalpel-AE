SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.birthdate as c0, 
  subq_1.c1 as c1, 
  ref_0.profile_picture as c2
from 
  test_bd.user_profiles as ref_0
    left join (select  
          subq_0.c0 as c0, 
          subq_0.c1 as c1, 
          (select comment from test_bd.comments limit 1 offset 9)
             as c2, 
          subq_0.c0 as c3
        from 
          (select  
                ref_1.user_id as c0, 
                ref_1.profile_picture as c1
              from 
                test_bd.user_profiles as ref_1
              where ((ref_1.profile_picture is not NULL) 
                  or (false)) 
                and ((false) 
                  or ((ref_1.user_id is not NULL) 
                    or (ref_1.user_id is NULL)))
              limit 124) as subq_0
        where true
        limit 168) as subq_1
    on (subq_1.c2 is not NULL)
where (ref_0.profile_picture is not NULL) 
  and (((false) 
      or (true)) 
    or (false));
SHOW profiles;