{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as work_id,
    authorships
from {{ source('open_alex_snapshot', 'raw_works') }}
