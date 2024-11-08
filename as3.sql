-- 1 task

# Department Top Three Salaries
with ranked_salaries as (
select
    e.name as Employee,
    d.name as Department,
    e.salary as Salary,
    dense_rank() over (partition by e.departmentId order by e.salary desc) as salary_rank
from Employee as e
left join Department as d on e.departmentId = d.id
)

select
Employee,
Department,
Salary
from ranked_salaries
where salary_rank <= 3;


-- 2 task

# Trips and Users
with union_table as (
    select a.request_at, a.status
    from Trips as a
    left join Users as b on a.client_id = b.users_id and b.banned = 'No'
    left join Users as c on a.driver_id = c.users_id and c.banned = 'No'
    where a.request_at >= '2013-10-01' and a.request_at <= '2013-10-03'
    and b.users_id IS NOT NULL
    and c.users_id IS NOT NULL
),

merged_table as (
    select
    a.request_at as "Day",
    round(
    sum(case when a.status in ('cancelled_by_client', 'cancelled_by_driver') then 1 else 0 end) /
    count(*),
    2
    ) as "Cancellation Rate"
    from union_table as a
    group by a.request_at
)

select * from merged_table

-- 3 task

# Human Traffic of Stadium
with consecutive_visits as (
    select *,
    row_number() over (order by id) as grp
    from Stadium
    where people >= 100
),

group_table as (
    select id, visit_date, people,
    (id - grp) as g
    from consecutive_visits
),

finish_table as (
    select g,
    count(*) as size
    from group_table
    group by g
)

select a.id, a.visit_date, a.people from group_table as a
join finish_table as b on a.g = b.g
where b.size >= 3


-- 4 task

# Last Person to Fit in the Bus
with ordered_table as(
    select * from Queue
    order by turn
),

finished_table as (
    select person_name,
    sum(weight) over (order by turn) as total_weight
    from ordered_table
)

select person_name from finished_table
where total_weight <= 1000
order by total_weight desc
limit 1

-- 5 task

# Managers with at Least 5 Direct Reports
with manager_table as(
    select managerId,
    count(managerId) as num_reports
    from Employee
    group by managerId
),

maximal_man as (
    select managerId,
    num_reports
    from manager_table
    where num_reports >= 5
)

select name from Employee
where id in (select managerId from maximal_man)

