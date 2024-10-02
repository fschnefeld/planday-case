-- import into staging
with staging_events as (
    select 
        organization_id,
        activity_name,
        activity_timestamp,
        user_id,
        user_name,
        user_email,
        user_role,
        user_department,
        user_location,
    from {{ source('planday_case', 'staging_events') }}
)

-- Intermediate CTE for logic and creation of goals

, trial_goals as (
    select 
        organization_id,
        -- goal 1: at least 2 shifts created
        case when sum(case when activity_name = 'shift.created' then 1 else 0 end) >= 2 then 1 else 0 end as shift_created,
        
        -- goal 2: at least 1 employee invited
        case when sum(case when activity_name = 'employee.invited' then 1 else 0 end) >= 1 then 1 else 0 end as employee_invited,
        
        -- goal 3: at least 1 punch-in
        case when sum(case when activity_name = 'punch.in' then 1 else 0 end) >= 1 then 1 else 0 end as punch_in,
        
        -- goal 4: at least 1 punch-in approved
        case when sum(case when activity_name = 'punch.in.approved' then 1 else 0 end) >= 1 then 1 else 0 end as punch_in_approved,
        
        -- goal 5: at least 2 advanced features viewed
        case when sum(case when activity_name = 'page.viewed' and activity_detail in ('revenue-overview', 'integrations-overview', 'absence-overview', 'availability-overview') then 1 else 0 end) >= 2 then 1 else 0 end as advanced_features_viewed
    from staging_events
    group by organization_id
)

-- Final selection
, final as (
select 
    organization_id,
    shift_created,
    employee_invited,
    punch_in,
    punch_in_approved,
    advanced_features_viewed
from trial_goals
)

select * from final
