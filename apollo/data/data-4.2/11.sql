SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_1.c0 as c0, 
  subq_1.c0 as c1, 
  subq_1.c1 as c2
from 
  (select  
        ref_1.user_id as c0, 
        ref_5.id as c1
      from 
        test_bd.employee as ref_0
          inner join test_bd.locations as ref_1
            inner join test_bd.user_post_comments as ref_2
                right join test_bd.user_post_comments as ref_3
                  right join test_bd.user_profiles as ref_4
                  on (ref_3.title is not NULL)
                on (ref_3.comment is not NULL)
              inner join test_bd.comments as ref_5
              on (ref_2.comment = ref_5.comment )
            on (ref_1.id = ref_4.user_id )
          on (EXISTS (
              select  
                  ref_3.title as c0, 
                  ref_4.birthdate as c1, 
                  ref_6.comment as c2, 
                  ref_1.user_id as c3
                from 
                  test_bd.comments as ref_6,
                  lateral (select  
                        ref_2.comment as c0
                      from 
                        test_bd.products as ref_7
                      where (select id from test_bd.comments limit 1 offset 6)
                           is not NULL
                      limit 41) as subq_0
                where EXISTS (
                  select  
                      ref_8.id as c0, 
                      ref_6.post_id as c1, 
                      subq_0.c0 as c2, 
                      ref_1.name as c3, 
                      ref_1.name as c4, 
                      ref_4.profile_picture as c5, 
                      subq_0.c0 as c6, 
                      ref_1.name as c7
                    from 
                      test_bd.eids as ref_8
                    where (true) 
                      or (EXISTS (
                        select  
                            ref_4.birthdate as c0, 
                            ref_9.email as c1, 
                            ref_4.user_id as c2, 
                            ref_8.id as c3, 
                            ref_2.comment as c4, 
                            ref_9.username as c5
                          from 
                            test_bd.users as ref_9
                          where ref_4.birthdate is not NULL
                          limit 81)))
                limit 46))
      where EXISTS (
        select  
            ref_2.title as c0, 
            ref_4.user_id as c1, 
            ref_1.user_id as c2, 
            (select comment from test_bd.user_post_comments limit 1 offset 3)
               as c3, 
            ref_0.eid as c4, 
            ref_5.post_id as c5, 
            ref_10.id as c6, 
            ref_2.title as c7, 
            ref_5.user_id as c8, 
            ref_3.username as c9, 
            ref_10.email as c10, 
            ref_2.comment as c11, 
            ref_1.id as c12, 
            ref_5.post_id as c13, 
            ref_1.id as c14, 
            ref_3.title as c15
          from 
            test_bd.users as ref_10
          where ref_0.email is not NULL)
      limit 121) as subq_1
where (subq_1.c1 is NULL) 
  and ((EXISTS (
      select  
          ref_11.comment as c0
        from 
          test_bd.comments as ref_11
        where ((ref_11.comment is not NULL) 
            or ((true) 
              or ((EXISTS (
                  select  
                      ref_12.discount as c0, 
                      ref_11.id as c1, 
                      29 as c2, 
                      ref_11.post_id as c3, 
                      ref_11.user_id as c4, 
                      ref_11.comment as c5, 
                      subq_1.c1 as c6, 
                      ref_12.price as c7
                    from 
                      test_bd.products as ref_12
                    where false)) 
                and ((EXISTS (
                    select  
                        ref_11.id as c0
                      from 
                        test_bd.users as ref_13
                      where (ref_13.email is not NULL) 
                        and (((false) 
                            and (false)) 
                          or (true))
                      limit 63)) 
                  or (subq_1.c0 is not NULL))))) 
          and ((EXISTS (
              select  
                  ref_14.id as c0, 
                  subq_1.c0 as c1
                from 
                  test_bd.eids as ref_14
                where ((ref_11.id is not NULL) 
                    and ((ref_14.id is not NULL) 
                      or (false))) 
                  and (EXISTS (
                    select  
                        ref_14.virtual_col as c0, 
                        ref_14.eid as c1
                      from 
                        test_bd.locations as ref_15
                      where (true) 
                        and (((ref_15.coordinates is not NULL) 
                            or (ref_11.user_id is not NULL)) 
                          and ((false) 
                            and (true)))
                      limit 51)))) 
            or (true))
        limit 35)) 
    or (subq_1.c1 is NULL))
limit 122;
SHOW profiles;