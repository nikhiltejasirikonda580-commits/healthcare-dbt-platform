with patient_dim as (
    select count(*) as cnt
    from {{ ref('dim_patient') }}
),
patient_mart as (
    select count(*) as cnt
    from {{ ref('mart_patient_360') }}
)

select *
from patient_dim d
cross join patient_mart m
where d.cnt <> m.cnt