SET profiling=1;
EXPLAIN ANALYZE
select  
  subq_1.c2 as c0, 
  subq_1.c1 as c1
from 
  (select  
        (select content from test_bd.posts limit 1 offset 15)
           as c0, 
        ref_0.user_id as c1, 
        subq_0.c1 as c2
      from 
        test_bd.user_profiles as ref_0
          right join (select distinct 
                (select comment from test_bd.user_post_comments limit 1 offset 2)
                   as c0, 
                ref_1.username as c1
              from 
                test_bd.users as ref_1
              where (((67 is NULL) 
                    or (((true) 
                        and ((false) 
                          or (false))) 
                      and (false))) 
                  or ((true) 
                    or ((true) 
                      or (true)))) 
                and ((((ref_1.email is not NULL) 
                      or ((true) 
                        and (ref_1.id is not NULL))) 
                    and (true)) 
                  or (ref_1.email is not NULL))) as subq_0
          on (ref_0.bio = subq_0.c0 )
      where subq_0.c0 is not NULL
      limit 84) as subq_1
where ((false) 
    or (false)) 
  or (((((false) 
          and (((EXISTS (
                select  
                    ref_2.name as c0, 
                    subq_1.c1 as c1, 
                    subq_1.c0 as c2, 
                    36 as c3, 
                    subq_1.c1 as c4, 
                    subq_1.c0 as c5, 
                    76 as c6, 
                    subq_1.c1 as c7, 
                    ref_2.category as c8, 
                    ref_2.created_at as c9, 
                    ref_2.created_at as c10, 
                    ref_2.price as c11
                  from 
                    test_bd.products as ref_2
                  where false
                  limit 143)) 
              or (false)) 
            or (false))) 
        or ((EXISTS (
            select  
                subq_1.c2 as c0, 
                subq_1.c1 as c1, 
                30 as c2, 
                ref_3.comment as c3, 
                subq_1.c1 as c4
              from 
                test_bd.user_post_comments as ref_3
              where EXISTS (
                select  
                    subq_1.c1 as c0, 
                    73 as c1, 
                    subq_1.c2 as c2, 
                    ref_4.bio as c3, 
                    (select salary from test_bd.employee limit 1 offset 2)
                       as c4
                  from 
                    test_bd.user_profiles as ref_4
                  where ref_3.username is NULL)
              limit 108)) 
          and (((((EXISTS (
                    select  
                        ref_5.id as c0, 
                        subq_1.c1 as c1, 
                        subq_1.c0 as c2
                      from 
                        test_bd.posts as ref_5
                      where false
                      limit 76)) 
                  or ((EXISTS (
                      select  
                          ref_6.id as c0, 
                          subq_1.c1 as c1, 
                          ref_6.name as c2, 
                          subq_1.c1 as c3, 
                          subq_1.c1 as c4
                        from 
                          test_bd.locations as ref_6
                        where false)) 
                    or ((select id from test_bd.users limit 1 offset 1)
                         is NULL))) 
                and (subq_1.c2 is NULL)) 
              or ((true) 
                or (false))) 
            or (subq_1.c1 is NULL)))) 
      and (EXISTS (
        select  
            ref_7.id as c0, 
            ref_7.id as c1, 
            subq_1.c1 as c2, 
            ref_7.post_id as c3, 
            subq_1.c0 as c4
          from 
            test_bd.comments as ref_7
          where (((true) 
                and (false)) 
              and ((((true) 
                    or (ref_7.user_id is not NULL)) 
                  and (((true) 
                      or (ref_7.user_id is NULL)) 
                    and (ref_7.created_at is NULL))) 
                and (EXISTS (
                  select  
                      subq_1.c0 as c0, 
                      ref_8.email as c1, 
                      ref_7.created_at as c2, 
                      subq_1.c2 as c3, 
                      70 as c4, 
                      ref_7.user_id as c5, 
                      subq_1.c1 as c6, 
                      subq_1.c2 as c7, 
                      ref_8.age as c8, 
                      ref_7.id as c9
                    from 
                      test_bd.employee as ref_8
                    where (false) 
                      and (false)
                    limit 139)))) 
            and (EXISTS (
              select  
                  subq_1.c2 as c0, 
                  subq_1.c0 as c1, 
                  ref_9.post_id as c2, 
                  73 as c3, 
                  ref_7.user_id as c4, 
                  ref_9.user_id as c5, 
                  subq_1.c0 as c6, 
                  ref_7.created_at as c7, 
                  86 as c8, 
                  14 as c9
                from 
                  test_bd.comments as ref_9
                where true
                limit 96))))) 
    or ((((subq_1.c2 is not NULL) 
          or (subq_1.c1 is NULL)) 
        or ((((false) 
              or (subq_1.c1 is not NULL)) 
            and (subq_1.c2 is not NULL)) 
          and (subq_1.c1 is NULL))) 
      and ((subq_1.c2 is not NULL) 
        and ((false) 
          or ((select birthdate from test_bd.user_profiles limit 1 offset 6)
               is NULL)))))
limit 145;
SHOW profiles;