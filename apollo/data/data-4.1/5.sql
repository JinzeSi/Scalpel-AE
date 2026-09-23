SET profiling=1;
EXPLAIN ANALYZE

select  
  subq_1.c0 as c0, 
  (select eid from test_bd.eids limit 1 offset 3)
     as c1, 
  subq_1.c7 as c2, 
  subq_1.c0 as c3, 
  subq_1.c4 as c4, 
  subq_1.c1 as c5, 
  subq_1.c7 as c6, 
  70 as c7, 
  subq_1.c7 as c8, 
  subq_1.c1 as c9, 
  subq_1.c5 as c10, 
  subq_1.c1 as c11, 
  subq_1.c11 as c12, 
  subq_1.c4 as c13, 
  subq_1.c7 as c14, 
  subq_1.c11 as c15
from 
  (select  
        ref_0.virtual_col as c0, 
        ref_1.discount as c1, 
        ref_0.virtual_col as c2, 
        ref_0.id as c3, 
        ref_1.tags as c4, 
        ref_0.virtual_col as c5, 
        ref_0.virtual_col as c6, 
        ref_1.tags as c7, 
        ref_0.virtual_col as c8, 
        ref_1.category as c9, 
        ref_1.discount as c10, 
        case when (EXISTS (
              select  
                  ref_1.category as c0, 
                  ref_2.virtual_col as c1
                from 
                  test_bd.eids as ref_2
                where ((ref_1.category is NULL) 
                    and (((false) 
                        or (ref_2.virtual_col is NULL)) 
                      and ((EXISTS (
                          select  
                              ref_1.discount as c0, 
                              ref_1.created_at as c1, 
                              ref_0.id as c2, 
                              ref_1.category as c3, 
                              ref_2.id as c4, 
                              ref_2.eid as c5, 
                              ref_2.virtual_col as c6, 
                              ref_1.created_at as c7
                            from 
                              test_bd.posts as ref_3
                            where true)) 
                        or (((true) 
                            and (((false) 
                                or (true)) 
                              or (false))) 
                          or (false))))) 
                  or (ref_0.eid is not NULL)
                limit 43)) 
            or ((ref_0.eid is not NULL) 
              and (EXISTS (
                select  
                    ref_4.comment as c0, 
                    (select hire_date from test_bd.employee limit 1 offset 4)
                       as c1, 
                    ref_4.post_id as c2, 
                    56 as c3, 
                    ref_4.user_id as c4
                  from 
                    test_bd.comments as ref_4
                  where (EXISTS (
                      select  
                          ref_4.post_id as c0, 
                          ref_0.id as c1, 
                          ref_4.post_id as c2, 
                          ref_5.comment as c3, 
                          ref_5.username as c4, 
                          ref_4.created_at as c5, 
                          64 as c6
                        from 
                          test_bd.user_post_comments as ref_5
                        where ref_4.post_id is NULL
                        limit 33)) 
                    and ((false) 
                      or (false))))) then ref_0.id else ref_0.id end
           as c11
      from 
        test_bd.eids as ref_0
          left join test_bd.products as ref_1
          on (ref_0.id = ref_1.id )
      where (ref_1.id is NULL) 
        and (EXISTS (
          select  
              ref_6.id as c0, 
              ref_0.virtual_col as c1
            from 
              test_bd.eids as ref_6
                inner join test_bd.posts as ref_7
                on (true)
            where ((((false) 
                    or (true)) 
                  and (ref_6.id is not NULL)) 
                or (ref_1.id is NULL)) 
              or ((true) 
                or (EXISTS (
                  select  
                      subq_0.c2 as c0, 
                      59 as c1, 
                      ref_0.virtual_col as c2, 
                      ref_0.id as c3, 
                      ref_8.user_id as c4, 
                      ref_1.created_at as c5, 
                      ref_8.comment as c6, 
                      ref_0.virtual_col as c7, 
                      ref_6.eid as c8, 
                      (select id from test_bd.eids limit 1 offset 6)
                         as c9, 
                      ref_1.price as c10, 
                      ref_1.category as c11, 
                      ref_8.created_at as c12, 
                      ref_6.virtual_col as c13, 
                      ref_7.user_id as c14
                    from 
                      test_bd.comments as ref_8,
                      lateral (select  
                            ref_9.username as c0, 
                            ref_0.id as c1, 
                            ref_8.user_id as c2, 
                            ref_9.username as c3, 
                            84 as c4, 
                            (select birthdate from test_bd.user_profiles limit 1 offset 25)
                               as c5
                          from 
                            test_bd.user_post_comments as ref_9
                          where true) as subq_0
                    where true
                    limit 80)))))
      limit 110) as subq_1
where (subq_1.c6 is NULL) 
  and ((true) 
    or ((subq_1.c1 is not NULL) 
      and (subq_1.c7 is not NULL)))
limit 131;
SHOW profiles;