SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_0.c4 as c0, 
  79 as c1, 
  coalesce(subq_0.c1,
    subq_0.c1) as c2, 
  subq_0.c2 as c3, 
  subq_0.c0 as c4, 
  subq_0.c2 as c5, 
  50 as c6
from 
  (select  
        ref_2.id as c0, 
        ref_1.bio as c1, 
        ref_1.user_id as c2, 
        78 as c3, 
        (select email from test_bd.employee limit 1 offset 4)
           as c4
      from 
        test_bd.users as ref_0
          right join test_bd.user_profiles as ref_1
              inner join test_bd.eids as ref_2
                right join test_bd.employee as ref_3
                on (ref_2.virtual_col is not NULL)
              on (ref_2.id is not NULL)
            left join test_bd.posts as ref_4
              right join test_bd.user_profiles as ref_5
              on (ref_5.birthdate is NULL)
            on (true)
          on (((ref_1.birthdate is not NULL) 
                or (((true) 
                    or (ref_1.birthdate is NULL)) 
                  or ((((EXISTS (
                          select  
                              ref_4.user_id as c0, 
                              ref_1.user_id as c1, 
                              ref_6.comment as c2, 
                              73 as c3
                            from 
                              test_bd.comments as ref_6
                            where (true) 
                              and ((EXISTS (
                                  select  
                                      ref_4.user_id as c0, 
                                      ref_0.email as c1, 
                                      ref_2.eid as c2, 
                                      ref_4.created_at as c3, 
                                      ref_6.user_id as c4
                                    from 
                                      test_bd.users as ref_7
                                    where false)) 
                                or (((false) 
                                    and ((true) 
                                      or (false))) 
                                  and (ref_4.created_at is not NULL)))
                            limit 107)) 
                        and (ref_1.profile_picture is NULL)) 
                      or (true)) 
                    or (ref_4.created_at is not NULL)))) 
              or (((ref_0.created_at is not NULL) 
                  and (ref_4.user_id is NULL)) 
                or (true)))
      where (ref_3.email is not NULL) 
        or ((true) 
          and (ref_3.department_id is NULL))
      limit 85) as subq_0
where case when EXISTS (
      select  
          (select title from test_bd.posts limit 1 offset 4)
             as c0, 
          subq_0.c3 as c1, 
          subq_0.c3 as c2, 
          subq_0.c2 as c3
        from 
          (select  
                subq_0.c0 as c0
              from 
                test_bd.products as ref_8
              where (false) 
                and (true)
              limit 105) as subq_1
        where EXISTS (
          select  
              subq_1.c0 as c0, 
              ref_10.discount as c1, 
              ref_10.category as c2, 
              ref_10.category as c3, 
              (select user_id from test_bd.locations limit 1 offset 43)
                 as c4, 
              subq_1.c0 as c5
            from 
              test_bd.user_post_comments as ref_9
                right join test_bd.products as ref_10
                on (ref_9.title = ref_10.name )
            where ref_10.tags is not NULL
            limit 96)) then coalesce(subq_0.c1,
      subq_0.c1) else coalesce(subq_0.c1,
      subq_0.c1) end
     is NULL;
SHOW profiles;