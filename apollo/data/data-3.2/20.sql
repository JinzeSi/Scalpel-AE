SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.profile_picture as c0, 
  ref_0.birthdate as c1, 
  53 as c2
from 
  test_bd.user_profiles as ref_0
where EXISTS (
  select  
      ref_0.birthdate as c0, 
      ref_1.title as c1
    from 
      test_bd.user_post_comments as ref_1
    where EXISTS (
      select  
          ref_0.bio as c0, 
          (select age from test_bd.employee limit 1 offset 93)
             as c1, 
          ref_2.created_at as c2, 
          ref_2.created_at as c3
        from 
          test_bd.comments as ref_2
        where ref_2.id is not NULL)
    limit 137);
SHOW profiles;