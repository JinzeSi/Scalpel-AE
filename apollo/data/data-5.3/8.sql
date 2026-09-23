SET profiling=1;
EXPLAIN ANALYZE
select  
  coalesce(subq_0.c5,
    case when subq_0.c2 is NULL then subq_0.c4 else subq_0.c4 end
      ) as c0
from 
  (select  
          ref_0.birthdate as c0, 
          ref_0.profile_picture as c1, 
          case when false then ref_0.user_id else ref_0.user_id end
             as c2, 
          (select profile_picture from test_bd.user_profiles limit 1 offset 6)
             as c3, 
          ref_0.bio as c4, 
          ref_0.bio as c5, 
          (select eid from test_bd.eids limit 1 offset 4)
             as c6, 
          ref_0.bio as c7
        from 
          test_bd.user_profiles as ref_0
        where ref_0.bio is not NULL) as subq_0
    right join (select  
          ref_1.created_at as c0, 
          ref_1.post_id as c1, 
          ref_2.content as c2, 
          ref_2.updated_at as c3, 
          ref_1.post_id as c4
        from 
          test_bd.comments as ref_1
            left join test_bd.posts as ref_2
            on ((EXISTS (
                  select  
                      ref_2.content as c0
                    from 
                      test_bd.user_post_comments as ref_3
                    where true
                    limit 143)) 
                and (false))
        where (false) 
          or (true)
        limit 138) as subq_1
    on (true)
where case when subq_1.c4 is not NULL then coalesce(subq_0.c6,
      subq_0.c2) else coalesce(subq_0.c6,
      subq_0.c2) end
     is NULL
limit 29;
SHOW profiles;