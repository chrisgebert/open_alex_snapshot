{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as work_id,
    doi,
    ids.mag,
    ids.pmid
from {{ source('open_alex_snapshot', 'raw_works') }}
