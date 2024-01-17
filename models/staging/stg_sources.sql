{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as source_id,
    * exclude (id)
from {{ source('open_alex_snapshot', 'raw_sources') }}
