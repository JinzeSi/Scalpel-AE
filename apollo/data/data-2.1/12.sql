SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_3.age as c0, 
  ref_3.eid as c1, 
  ref_2.email as c2, 
  ref_3.id as c3, 
  ref_2.eid as c4, 
  ref_2.department_id as c5, 
  ref_2.eid as c6, 
  case when ((true) 
        and (subq_0.c0 is not NULL)) 
      and ((false) 
        or ((EXISTS (
            select  
                ref_2.department_id as c0, 
                ref_4.id as c1, 
                ref_4.eid as c2, 
                ref_3.id as c3
              from 
                test_bd.eids as ref_4
                  right join test_bd.eids as ref_5
                  on (ref_4.id = ref_5.eid )
              where ref_2.department_id is not NULL
              limit 91)) 
          and (false))) then ref_3.age else ref_3.age end
     as c7, 
  subq_0.c0 as c8
from 
  (select  
          ref_1.title as c0, 
          ref_0.comment as c1, 
          ref_0.title as c2
        from 
          test_bd.user_post_comments as ref_0
            inner join test_bd.posts as ref_1
            on (false)
        where (false) 
          and ((ref_0.comment is not NULL) 
            or (ref_0.username is NULL))
        limit 60) as subq_0
    right join test_bd.employee as ref_2
      right join test_bd.employee as ref_3
      on (true)
    on (subq_0.c0 = ref_2.email )
where ((subq_0.c0 is NULL) 
    and (ref_3.years is NULL)) 
  or (coalesce(ref_2.eid,
      ref_2.years) is NULL)
limit 125;
SHOW profiles;