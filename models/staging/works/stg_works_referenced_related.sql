{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as work_id,
    referenced_works,
    related_works
from {{ source('open_alex_snapshot', 'raw_works') }}
