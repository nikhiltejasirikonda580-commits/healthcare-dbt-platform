{% snapshot provider_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='provider_id',
        strategy='check',
        check_cols=[
            'organization_id',
            'provider_name',
            'provider_gender',
            'specialty',
            'city',
            'state',
            'zip_code'
        ],
        invalidate_hard_deletes=True
    )
}}

select
    provider_id,
    organization_id,
    provider_name,
    provider_gender,
    specialty,
    city,
    state,
    zip_code,
    latitude,
    longitude,
    source_encounter_count,
    source_procedure_count
from {{ ref('stg_providers') }}

{% endsnapshot %}