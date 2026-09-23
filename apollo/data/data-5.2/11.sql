SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_1.c0 as c0, 
  subq_1.c0 as c1, 
  subq_1.c1 as c2, 
  subq_1.c0 as c3, 
  subq_1.c2 as c4, 
  62 as c5, 
  (select comment from test_bd.user_post_comments limit 1 offset 2)
     as c6, 
  subq_1.c0 as c7, 
  case when 2 is NULL then case when (subq_1.c0 is NULL) 
        or (((false) 
            or (false)) 
          and (EXISTS (
            select  
                ref_4.username as c0, 
                (select birthdate from test_bd.user_profiles limit 1 offset 5)
                   as c1, 
                ref_4.comment as c2
              from 
                test_bd.user_post_comments as ref_4
              where (EXISTS (
                  select  
                      ref_5.content as c0, 
                      ref_4.comment as c1
                    from 
                      test_bd.posts as ref_5
                    where (false) 
                      and (true))) 
                and ((false) 
                  or (false))
              limit 77))) then coalesce(subq_1.c1,
        subq_1.c1) else coalesce(subq_1.c1,
        subq_1.c1) end
       else case when (subq_1.c0 is NULL) 
        or (((false) 
            or (false)) 
          and (EXISTS (
            select  
                ref_4.username as c0, 
                (select birthdate from test_bd.user_profiles limit 1 offset 5)
                   as c1, 
                ref_4.comment as c2
              from 
                test_bd.user_post_comments as ref_4
              where (EXISTS (
                  select  
                      ref_5.content as c0, 
                      ref_4.comment as c1
                    from 
                      test_bd.posts as ref_5
                    where (false) 
                      and (true))) 
                and ((false) 
                  or (false))
              limit 77))) then coalesce(subq_1.c1,
        subq_1.c1) else coalesce(subq_1.c1,
        subq_1.c1) end
       end
     as c8, 
  coalesce(subq_1.c0,
    subq_1.c0) as c9, 
  subq_1.c0 as c10, 
  subq_1.c0 as c11, 
  (select id from test_bd.users limit 1 offset 3)
     as c12, 
  subq_1.c2 as c13, 
  case when (subq_1.c0 is not NULL) 
      or (subq_1.c2 is not NULL) then subq_1.c2 else subq_1.c2 end
     as c14, 
  subq_1.c1 as c15
from 
  (select  
        ref_1.username as c0, 
        subq_0.c7 as c1, 
        subq_0.c5 as c2
      from 
        (select  
                ref_0.created_at as c0, 
                ref_0.created_at as c1, 
                (select id from test_bd.eids limit 1 offset 1)
                   as c2, 
                ref_0.created_at as c3, 
                (select virtual_col from test_bd.eids limit 1 offset 6)
                   as c4, 
                81 as c5, 
                ref_0.id as c6, 
                ref_0.created_at as c7, 
                (select birthdate from test_bd.user_profiles limit 1 offset 68)
                   as c8, 
                ref_0.comment as c9
              from 
                test_bd.comments as ref_0
              where ((ref_0.user_id is NULL) 
                  and (true)) 
                or ((select email from test_bd.users limit 1 offset 6)
                     is not NULL)) as subq_0
          left join test_bd.user_post_comments as ref_1
          on (((false) 
                or (((EXISTS (
                      select  
                          ref_1.username as c0, 
                          ref_1.username as c1, 
                          ref_2.created_at as c2, 
                          subq_0.c4 as c3, 
                          ref_1.comment as c4, 
                          ref_2.user_id as c5, 
                          ref_2.id as c6, 
                          subq_0.c6 as c7, 
                          ref_1.title as c8, 
                          ref_2.comment as c9, 
                          subq_0.c2 as c10, 
                          ref_2.user_id as c11, 
                          (select salary from test_bd.employee limit 1 offset 2)
                             as c12, 
                          25 as c13, 
                          (select username from test_bd.users limit 1 offset 2)
                             as c14
                        from 
                          test_bd.comments as ref_2
                        where ref_1.username is not NULL
                        limit 62)) 
                    and ((false) 
                      and (false))) 
                  or (true))) 
              and (EXISTS (
                select  
                    ref_3.title as c0, 
                    11 as c1
                  from 
                    test_bd.user_post_comments as ref_3
                  where false
                  limit 135)))
      where true
      limit 37) as subq_1
where (EXISTS (
    select  
        (select bio from test_bd.user_profiles limit 1 offset 1)
           as c0, 
        subq_1.c2 as c1, 
        subq_1.c1 as c2
      from 
        (select  
              87 as c0, 
              subq_2.c4 as c1, 
              subq_1.c2 as c2
            from 
              test_bd.users as ref_6,
              lateral (select  
                    subq_1.c1 as c0, 
                    subq_1.c1 as c1, 
                    ref_6.created_at as c2, 
                    ref_6.id as c3, 
                    ref_6.email as c4
                  from 
                    test_bd.posts as ref_7
                  where true
                  limit 149) as subq_2
            where subq_1.c0 is not NULL
            limit 67) as subq_3
      where subq_1.c0 is NULL
      limit 68)) 
  and (subq_1.c2 is not NULL)
limit 102;
SHOW profiles;