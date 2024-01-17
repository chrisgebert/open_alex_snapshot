{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as institution_id,
    * exclude (id)
from {{ source('open_alex_snapshot', 'raw_institutions') }}
