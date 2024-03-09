{{ 
    config(
        materialized='table'
    ) 
}}

with unnested_related_works as (
    select
        id as work_id,
        unnest(related_works) as related_work_id
    from {{ source('open_alex_snapshot', 'raw_works') }}
)

select
    work_id,
    related_work_id
from unnested_related_works
