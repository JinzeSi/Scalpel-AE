SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c4 as c0, 
  subq_0.c0 as c1, 
  subq_0.c4 as c2, 
  subq_0.c1 as c3, 
  subq_0.c7 as c4, 
  subq_0.c7 as c5
from 
  (select  
        ref_1.id as c0, 
        ref_0.virtual_col as c1, 
        ref_2.title as c2, 
        ref_2.comment as c3, 
        ref_0.eid as c4, 
        ref_2.title as c5, 
        ref_2.comment as c6, 
        ref_0.virtual_col as c7, 
        ref_0.id as c8
      from 
        test_bd.eids as ref_0
            left join test_bd.posts as ref_1
            on (ref_0.id is NULL)
          right join test_bd.user_post_comments as ref_2
          on ((ref_1.user_id is not NULL) 
              or (ref_0.eid is not NULL))
      where ref_2.comment is not NULL
      limit 125) as subq_0
where (((subq_0.c1 is NULL) 
      and (subq_0.c0 is not NULL)) 
    and (((((subq_0.c4 is NULL) 
            and ((EXISTS (
                select  
                    ref_3.id as c0, 
                    ref_3.coordinates as c1, 
                    (select id from test_bd.eids limit 1 offset 100)
                       as c2, 
                    subq_0.c0 as c3
                  from 
                    test_bd.locations as ref_3
                  where ((true) 
                      or ((subq_0.c4 is NULL) 
                        or (false))) 
                    or (true)
                  limit 152)) 
              or ((subq_0.c1 is NULL) 
                and (((select comment from test_bd.comments limit 1 offset 22)
                       is not NULL) 
                  or ((((select profile_picture from test_bd.user_profiles limit 1 offset 6)
                           is NULL) 
                      and ((false) 
                        and (subq_0.c0 is NULL))) 
                    or (true)))))) 
          or ((true) 
            and ((true) 
              and (false)))) 
        or (true)) 
      or (false))) 
  or (EXISTS (
    select  
        (select id from test_bd.posts limit 1 offset 5)
           as c0, 
        subq_1.c0 as c1, 
        subq_1.c0 as c2
      from 
        (select  
              subq_0.c8 as c0
            from 
              test_bd.user_profiles as ref_4
            where subq_0.c2 is NULL
            limit 168) as subq_1
      where (subq_0.c3 is not NULL) 
        and (subq_0.c6 is not NULL)
      limit 137))
limit 155;
SHOW profiles;