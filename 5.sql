use lesson_4;

-- 1. 

create or replace view short_info as
select u.firstname,
    u.lastname,
    p.hometown,
    p.gender
from users as u
    join profiles as p on u.id = p.user_id
where TIMESTAMPDIFF(year, p.birthday, now()) <= 20;
select *
from short_info;
drop view short_info;

-- 2. 

select *,
    dense_rank() over(
        order by sum_messages desc
    ) as rang
from (
        select distinctrow firstname,
            lastname,
            count(*) over(partition by from_user_id) as sum_messages
        from users as u
            join messages as m on u.id = from_user_id
    ) as d;
    
-- 3. 

select body as 'Message',
    created_at as 'Date',
    TIMESTAMPDIFF(
        MINUTE,
        lag(created_at, 1, created_at) over(
            order by created_at
        ),
        created_at
    ) as 'Difference_minutes'
from messages;