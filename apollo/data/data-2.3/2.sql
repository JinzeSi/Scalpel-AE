SET profiling=1;
EXPLAIN ANALYZE

select  
  coalesce(subq_5.c4,
    subq_5.c8) as c0, 
  73 as c1, 
  subq_5.c0 as c2, 
  case when subq_6.c1 is NULL then ref_0.comment else ref_0.comment end
     as c3, 
  subq_6.c10 as c4, 
  subq_6.c3 as c5, 
  case when ((true) 
        or (subq_6.c3 is not NULL)) 
      or (ref_0.created_at is NULL) then case when true then subq_5.c8 else subq_5.c8 end
       else case when true then subq_5.c8 else subq_5.c8 end
       end
     as c6, 
  ref_0.id as c7, 
  20 as c8
from 
  test_bd.comments as ref_0
    inner join (select  
          ref_2.id as c0, 
          ref_1.bio as c1, 
          ref_1.profile_picture as c2, 
          ref_2.id as c3
        from 
          test_bd.user_profiles as ref_1
            left join test_bd.locations as ref_2
            on ((EXISTS (
                  select  
                      ref_1.birthdate as c0, 
                      ref_3.title as c1, 
                      ref_1.birthdate as c2, 
                      ref_2.user_id as c3
                    from 
                      test_bd.posts as ref_3
                    where ref_1.birthdate is not NULL
                    limit 142)) 
                and (false))
        where true
        limit 129) as subq_0
    on (subq_0.c3 is NULL),
  lateral (select  
        ref_0.comment as c0, 
        ref_0.user_id as c1, 
        ref_4.created_at as c2, 
        ref_4.id as c3, 
        subq_2.c6 as c4, 
        subq_0.c2 as c5, 
        ref_4.post_id as c6, 
        subq_1.c4 as c7, 
        subq_0.c3 as c8, 
        19 as c9, 
        ref_4.comment as c10, 
        subq_1.c4 as c11
      from 
        test_bd.comments as ref_4
          left join (select  
                subq_0.c0 as c0, 
                ref_5.user_id as c1, 
                ref_5.title as c2, 
                ref_0.id as c3, 
                subq_0.c2 as c4, 
                subq_0.c0 as c5
              from 
                test_bd.posts as ref_5
              where ref_5.updated_at is NULL
              limit 55) as subq_1
          on (ref_4.created_at is not NULL),
        lateral (select  
              ref_4.created_at as c0, 
              ref_4.created_at as c1, 
              ref_6.eid as c2, 
              subq_1.c1 as c3, 
              ref_6.virtual_col as c4, 
              ref_6.eid as c5, 
              subq_1.c0 as c6, 
              ref_6.virtual_col as c7, 
              subq_1.c5 as c8, 
              ref_0.created_at as c9, 
              14 as c10, 
              ref_4.comment as c11
            from 
              test_bd.eids as ref_6
            where subq_0.c2 is not NULL
            limit 16) as subq_2
      where ((ref_0.comment is not NULL) 
          and (true)) 
        or (((true) 
            and ((EXISTS (
                select  
                    subq_0.c3 as c0, 
                    ref_0.post_id as c1, 
                    ref_4.comment as c2, 
                    subq_1.c4 as c3
                  from 
                    test_bd.locations as ref_7
                  where ((subq_1.c2 is not NULL) 
                      or (((select id from test_bd.locations limit 1 offset 79)
                             is NULL) 
                        and ((select created_at from test_bd.comments limit 1 offset 6)
                             is not NULL))) 
                    or ((((ref_0.comment is NULL) 
                          or (ref_0.created_at is NULL)) 
                        and (ref_4.post_id is NULL)) 
                      and ((true) 
                        and ((49 is NULL) 
                          or (EXISTS (
                            select  
                                (select id from test_bd.locations limit 1 offset 6)
                                   as c0, 
                                ref_0.comment as c1
                              from 
                                test_bd.user_post_comments as ref_8
                              where EXISTS (
                                select  
                                    subq_0.c2 as c0, 
                                    15 as c1, 
                                    subq_2.c1 as c2
                                  from 
                                    test_bd.employee as ref_9
                                  where true
                                  limit 120)
                              limit 150))))))) 
              or ((true) 
                or (((EXISTS (
                      select  
                          (select user_id from test_bd.locations limit 1 offset 3)
                             as c0
                        from 
                          test_bd.comments as ref_10,
                          lateral (select  
                                ref_4.id as c0, 
                                subq_1.c2 as c1
                              from 
                                test_bd.comments as ref_11,
                                lateral (select  
                                      ref_4.created_at as c0, 
                                      ref_11.user_id as c1, 
                                      ref_4.post_id as c2, 
                                      67 as c3, 
                                      22 as c4, 
                                      ref_12.discount as c5, 
                                      subq_0.c2 as c6, 
                                      ref_4.id as c7, 
                                      ref_12.discount as c8, 
                                      ref_4.post_id as c9, 
                                      subq_1.c4 as c10, 
                                      99 as c11, 
                                      ref_10.comment as c12
                                    from 
                                      test_bd.products as ref_12
                                    where (true) 
                                      or (((((subq_1.c4 is NULL) 
                                              or (true)) 
                                            and (ref_0.post_id is NULL)) 
                                          and (false)) 
                                        and ((true) 
                                          or (false)))
                                    limit 191) as subq_3
                              where EXISTS (
                                select  
                                    (select id from test_bd.eids limit 1 offset 1)
                                       as c0, 
                                    ref_4.comment as c1, 
                                    subq_3.c9 as c2
                                  from 
                                    test_bd.products as ref_13
                                  where (false) 
                                    and (EXISTS (
                                      select  
                                          ref_4.id as c0, 
                                          ref_0.created_at as c1
                                        from 
                                          test_bd.eids as ref_14
                                        where false
                                        limit 118))
                                  limit 106)
                              limit 131) as subq_4
                        where 22 is not NULL
                        limit 159)) 
                    or (true)) 
                  or ((false) 
                    and (((((ref_4.user_id is not NULL) 
                            and (subq_1.c2 is NULL)) 
                          and (true)) 
                        and ((subq_2.c0 is NULL) 
                          and (((true) 
                              or (false)) 
                            and (((((ref_4.id is NULL) 
                                    or (false)) 
                                  or (ref_0.post_id is NULL)) 
                                or (((true) 
                                    or (EXISTS (
                                      select  
                                          57 as c0, 
                                          subq_2.c10 as c1, 
                                          ref_15.comment as c2
                                        from 
                                          test_bd.user_post_comments as ref_15
                                        where ((16 is not NULL) 
                                            and (EXISTS (
                                              select  
                                                  (select discount from test_bd.products limit 1 offset 4)
                                                     as c0, 
                                                  subq_2.c1 as c1
                                                from 
                                                  test_bd.products as ref_16
                                                where (((true) 
                                                      or (false)) 
                                                    and ((false) 
                                                      or (true))) 
                                                  or (false)
                                                limit 122))) 
                                          and (ref_15.comment is not NULL)
                                        limit 85))) 
                                  or ((false) 
                                    and ((false) 
                                      or (EXISTS (
                                        select  
                                            (select eid from test_bd.eids limit 1 offset 32)
                                               as c0, 
                                            subq_2.c11 as c1, 
                                            subq_0.c2 as c2, 
                                            ref_17.salary as c3, 
                                            subq_0.c2 as c4, 
                                            subq_1.c4 as c5, 
                                            86 as c6
                                          from 
                                            test_bd.employee as ref_17
                                          where ((true) 
                                              and ((true) 
                                                and (true))) 
                                            and (true))))))) 
                              or (true))))) 
                      and (false))))))) 
          or (false))) as subq_5,
  lateral (select  
        ref_18.title as c0, 
        80 as c1, 
        coalesce(subq_0.c2,
          subq_5.c7) as c2, 
        coalesce(ref_0.created_at,
          subq_5.c2) as c3, 
        coalesce(subq_0.c0,
          ref_0.id) as c4, 
        subq_5.c3 as c5, 
        ref_0.user_id as c6, 
        ref_0.comment as c7, 
        ref_0.post_id as c8, 
        66 as c9, 
        subq_0.c2 as c10
      from 
        test_bd.user_post_comments as ref_18
      where (subq_0.c2 is not NULL) 
        or (false)
      limit 107) as subq_6
where (((true) 
      and (16 is NULL)) 
    and (subq_0.c3 is not NULL)) 
  or ((93 is NULL) 
    or ((true) 
      or (((select name from test_bd.locations limit 1 offset 6)
             is not NULL) 
        or (((ref_0.comment is NULL) 
            and (((true) 
                or ((false) 
                  and (true))) 
              or ((true) 
                and (((ref_0.comment is not NULL) 
                    and (false)) 
                  and (subq_5.c9 is not NULL))))) 
          or ((ref_0.created_at is NULL) 
            and ((true) 
              and ((EXISTS (
                  select  
                      subq_5.c9 as c0, 
                      ref_0.id as c1, 
                      subq_5.c8 as c2, 
                      subq_0.c2 as c3, 
                      subq_6.c9 as c4
                    from 
                      test_bd.employee as ref_19
                    where (true) 
                      or (true))) 
                and (37 is NULL))))))))
limit 112;
SHOW profiles;