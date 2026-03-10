{% snapshot organization_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='organization_id',
        strategy='check',
        check_cols=[
            'organization_name',
            'address',
            'city',
            'state',
            'zip_code',
            'phone',
            'revenue',
            'utilization'
        ],
        invalidate_hard_deletes=True
    )
}}

select
    organization_id,
    organization_name,
    address,
    city,
    state,
    zip_code,
    latitude,
    longitude,
    phone,
    revenue,
    utilization
from {{ ref('stg_organizations') }}

{% endsnapshot %}