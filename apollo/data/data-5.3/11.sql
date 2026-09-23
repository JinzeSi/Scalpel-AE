SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.email as c0, 
  ref_0.username as c1, 
  ref_0.username as c2, 
  case when (EXISTS (
        select  
            ref_5.created_at as c0, 
            ref_4.title as c1, 
            ref_2.comment as c2, 
            ref_6.id as c3, 
            ref_4.title as c4, 
            ref_2.username as c5, 
            ref_6.comment as c6, 
            ref_6.created_at as c7
          from 
            test_bd.comments as ref_1
                  inner join test_bd.user_post_comments as ref_2
                  on (EXISTS (
                      select  
                          ref_0.created_at as c0, 
                          ref_3.id as c1, 
                          68 as c2, 
                          ref_1.comment as c3, 
                          ref_0.created_at as c4
                        from 
                          test_bd.posts as ref_3
                        where true
                        limit 116))
                right join test_bd.user_post_comments as ref_4
                on (ref_1.post_id is NULL)
              inner join test_bd.products as ref_5
                inner join test_bd.comments as ref_6
                on ((((EXISTS (
                          select distinct 
                              60 as c0, 
                              subq_0.c0 as c1
                            from 
                              test_bd.user_profiles as ref_7,
                              lateral (select  
                                    ref_0.username as c0, 
                                    (select user_id from test_bd.comments limit 1 offset 1)
                                       as c1, 
                                    ref_5.category as c2
                                  from 
                                    test_bd.products as ref_8
                                  where false) as subq_0
                            where (ref_7.user_id is not NULL) 
                              or ((ref_0.username is NULL) 
                                or (((ref_0.email is NULL) 
                                    or (false)) 
                                  or (ref_7.profile_picture is NULL)))
                            limit 21)) 
                        and (false)) 
                      or ((true) 
                        and ((false) 
                          and ((EXISTS (
                              select  
                                  ref_9.created_at as c0, 
                                  ref_0.created_at as c1, 
                                  ref_6.post_id as c2, 
                                  ref_5.price as c3, 
                                  ref_6.created_at as c4, 
                                  ref_5.name as c5
                                from 
                                  test_bd.comments as ref_9
                                where false
                                limit 161)) 
                            and (((false) 
                                and (ref_6.id is not NULL)) 
                              and (true)))))) 
                    or (ref_0.created_at is NULL))
              on (ref_4.comment = ref_6.comment )
          where true
          limit 90)) 
      and ((ref_0.created_at is NULL) 
        or (EXISTS (
          select  
              (select salary from test_bd.employee limit 1 offset 4)
                 as c0, 
              ref_0.username as c1
            from 
              test_bd.eids as ref_10
            where true
            limit 95))) then ref_0.email else ref_0.email end
     as c3, 
  ref_0.email as c4, 
  ref_0.email as c5, 
  ref_0.email as c6, 
  ref_0.username as c7, 
  coalesce(case when ref_0.created_at is not NULL then ref_0.created_at else ref_0.created_at end
      ,
    ref_0.created_at) as c8, 
  ref_0.email as c9
from 
  test_bd.users as ref_0
where ref_0.email is not NULL
limit 61;
SHOW profiles;