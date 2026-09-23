SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_2.c2 as c0, 
  case when EXISTS (
      select  
          ref_4.eid as c0, 
          ref_5.coordinates as c1, 
          subq_3.c2 as c2
        from 
          test_bd.eids as ref_4
            inner join test_bd.locations as ref_5
            on (EXISTS (
                select  
                    ref_4.id as c0, 
                    subq_3.c2 as c1, 
                    subq_2.c0 as c2, 
                    subq_3.c2 as c3, 
                    subq_2.c2 as c4, 
                    subq_3.c1 as c5, 
                    subq_3.c1 as c6, 
                    ref_5.id as c7, 
                    3 as c8, 
                    subq_2.c0 as c9, 
                    ref_5.name as c10
                  from 
                    test_bd.user_profiles as ref_6
                  where (EXISTS (
                      select  
                          subq_3.c1 as c0, 
                          59 as c1
                        from 
                          test_bd.locations as ref_7
                        where true
                        limit 81)) 
                    and ((true) 
                      or ((ref_6.profile_picture is NULL) 
                        and (true)))
                  limit 142))
        where subq_3.c0 is NULL
        limit 101) then subq_2.c1 else subq_2.c1 end
     as c1
from 
  (select  
          subq_1.c0 as c0, 
          subq_1.c0 as c1, 
          subq_1.c0 as c2
        from 
          test_bd.eids as ref_0,
          lateral (select  
                ref_0.virtual_col as c0, 
                ref_1.id as c1, 
                ref_0.eid as c2, 
                ref_0.eid as c3, 
                ref_0.virtual_col as c4
              from 
                test_bd.eids as ref_1
              where true
              limit 5) as subq_0,
          lateral (select  
                ref_2.username as c0
              from 
                test_bd.user_post_comments as ref_2
              where (ref_0.id is NULL) 
                or (true)
              limit 169) as subq_1
        where subq_0.c2 is not NULL
        limit 77) as subq_2
    inner join (select  
          ref_3.name as c0, 
          ref_3.user_id as c1, 
          ref_3.name as c2
        from 
          test_bd.locations as ref_3
        where (false) 
          or (true)
        limit 147) as subq_3
    on (subq_3.c1 is NULL)
where subq_3.c2 is NULL
limit 105;
SHOW profiles;