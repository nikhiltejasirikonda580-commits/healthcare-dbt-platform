with fact_counts as (
    select count(*) as encounter_count
    from {{ ref('fct_encounter') }}
    where provider_id is not null
),
mart_counts as (
    select sum(encounter_count) as encounter_count
    from {{ ref('mart_provider_performance') }}
)

select *
from fact_counts f
cross join mart_counts m
where f.encounter_count <> m.encounter_count