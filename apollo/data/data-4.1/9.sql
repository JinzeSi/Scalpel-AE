SET profiling=1;
EXPLAIN ANALYZE

select distinct 
  subq_1.c0 as c0, 
  subq_1.c0 as c1
from 
  (select  
        subq_0.c2 as c0, 
        subq_0.c5 as c1, 
        subq_0.c5 as c2
      from 
        (select  
              ref_2.coordinates as c0, 
              ref_0.title as c1, 
              ref_0.title as c2, 
              ref_2.id as c3, 
              ref_2.name as c4, 
              ref_0.comment as c5
            from 
              test_bd.user_post_comments as ref_0
                inner join test_bd.eids as ref_1
                  left join test_bd.locations as ref_2
                  on ((true) 
                      and (ref_1.virtual_col is not NULL))
                on (73 is not NULL)
            where (true) 
              or ((true) 
                and ((ref_0.username is not NULL) 
                  and (EXISTS (
                    select  
                        ref_2.coordinates as c0, 
                        ref_3.created_at as c1, 
                        ref_3.created_at as c2
                      from 
                        test_bd.users as ref_3
                      where (ref_2.name is NULL) 
                        and ((true) 
                          and (false))
                      limit 14))))) as subq_0
      where subq_0.c0 is not NULL) as subq_1
where subq_1.c0 is not NULL
limit 120;
SHOW profiles;