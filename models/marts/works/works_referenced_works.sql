{{ 
    config(
        materialized='table'
    ) 
}}

with unnested_referenced_works as (
    select
        id as work_id,
        unnest(referenced_works) as referenced_work_id
from {{ source('open_alex_snapshot', 'raw_works') }}
)

select
    work_id,
    referenced_work_id
from unnested_referenced_works
