-- Import with ref to previously established logic for goals
with trial_goals as (
    select * from {{ ref('plandaycase__trial_goals') }}
)
-- Providing Marts source for trial_activation
select
    organization_id,
    case when shift_created = 1 then 'shift_created'
    when employee_invited = 1 then 'employee_invited'
    when punch_in = 1 then 'punch_in'
    when punch_in_approved = 1 then 'punch_in_approved'
    when advanced_features_viewed = 1 then 'advanced_features_viewed'
    end as trial_activation
from trial_goals

