SET profiling=1;
EXPLAIN ANALYZE

select  
  ref_0.birthdate as c0, 
  coalesce(case when true then ref_0.birthdate else ref_0.birthdate end
      ,
    ref_0.birthdate) as c1, 
  case when EXISTS (
      select  
          subq_0.c6 as c0, 
          ref_1.department_id as c1, 
          ref_3.id as c2, 
          ref_2.post_id as c3, 
          ref_2.id as c4, 
          54 as c5
        from 
          test_bd.employee as ref_1
            inner join test_bd.comments as ref_2
              inner join test_bd.employee as ref_3
              on (((true) 
                    and ((ref_3.id is not NULL) 
                      or ((false) 
                        or ((((EXISTS (
                                select  
                                    ref_0.birthdate as c0, 
                                    ref_0.profile_picture as c1
                                  from 
                                    test_bd.user_profiles as ref_4
                                  where ref_3.department_id is not NULL)) 
                              or (((ref_0.profile_picture is not NULL) 
                                  and (true)) 
                                or (false))) 
                            or (false)) 
                          and (ref_2.user_id is NULL))))) 
                  or (((true) 
                      or ((ref_0.profile_picture is NULL) 
                        or ((true) 
                          or (EXISTS (
                            select  
                                ref_3.age as c0, 
                                ref_3.years as c1, 
                                ref_5.name as c2, 
                                ref_2.post_id as c3, 
                                ref_3.email as c4, 
                                ref_5.name as c5, 
                                ref_3.email as c6, 
                                ref_0.bio as c7, 
                                ref_2.comment as c8, 
                                ref_5.user_id as c9, 
                                ref_5.name as c10, 
                                ref_3.eid as c11, 
                                ref_5.coordinates as c12, 
                                ref_5.user_id as c13, 
                                ref_2.created_at as c14, 
                                ref_5.name as c15, 
                                ref_5.id as c16, 
                                ref_0.profile_picture as c17, 
                                ref_2.post_id as c18, 
                                ref_3.id as c19
                              from 
                                test_bd.locations as ref_5
                              where (ref_5.name is not NULL) 
                                or ((EXISTS (
                                    select  
                                        ref_2.post_id as c0
                                      from 
                                        test_bd.eids as ref_6
                                      where ref_3.email is not NULL
                                      limit 130)) 
                                  or (ref_2.comment is not NULL))
                              limit 48))))) 
                    or (true)))
            on ((true) 
                and (true)),
          lateral (select  
                ref_0.profile_picture as c0, 
                ref_2.post_id as c1, 
                ref_1.department_id as c2, 
                ref_8.price as c3, 
                ref_0.profile_picture as c4, 
                82 as c5, 
                ref_3.department_id as c6
              from 
                test_bd.employee as ref_7
                  left join test_bd.products as ref_8
                  on (EXISTS (
                      select  
                          ref_9.id as c0, 
                          ref_7.email as c1
                        from 
                          test_bd.eids as ref_9
                        where (((true) 
                              or ((ref_3.salary is not NULL) 
                                or (((((true) 
                                        and (ref_8.id is not NULL)) 
                                      and (true)) 
                                    or (false)) 
                                  and ((ref_7.age is NULL) 
                                    or ((ref_0.bio is not NULL) 
                                      and (false)))))) 
                            or (ref_0.user_id is not NULL)) 
                          or ((false) 
                            and ((false) 
                              or (EXISTS (
                                select  
                                    ref_0.bio as c0, 
                                    ref_8.created_at as c1, 
                                    ref_1.email as c2, 
                                    ref_2.id as c3, 
                                    ref_1.id as c4, 
                                    ref_2.created_at as c5, 
                                    ref_8.id as c6, 
                                    ref_9.eid as c7, 
                                    ref_1.id as c8, 
                                    ref_10.birthdate as c9, 
                                    ref_8.name as c10, 
                                    ref_2.created_at as c11, 
                                    87 as c12, 
                                    ref_1.age as c13, 
                                    ref_1.hire_date as c14, 
                                    ref_2.id as c15, 
                                    ref_9.eid as c16, 
                                    ref_8.name as c17, 
                                    ref_7.years as c18, 
                                    ref_3.salary as c19
                                  from 
                                    test_bd.user_profiles as ref_10
                                  where false))))))
              where false
              limit 63) as subq_0
        where EXISTS (
          select  
              ref_0.user_id as c0
            from 
              test_bd.users as ref_11
            where ref_0.bio is NULL
            limit 144)) then ref_0.profile_picture else ref_0.profile_picture end
     as c2, 
  case when ref_0.bio is NULL then ref_0.profile_picture else ref_0.profile_picture end
     as c3, 
  11 as c4, 
  ref_0.profile_picture as c5, 
  ref_0.profile_picture as c6
from 
  test_bd.user_profiles as ref_0
where (((ref_0.bio is NULL) 
      or (ref_0.bio is NULL)) 
    and ((select id from test_bd.locations limit 1 offset 3)
         is not NULL)) 
  or (((true) 
      or (ref_0.user_id is not NULL)) 
    or (false));
SHOW profiles;