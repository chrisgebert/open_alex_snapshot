{{ 
    config(
        materialized='table'
    )
}}

select
    id as publisher_id,
    * exclude (id)
from {{ source('open_alex_snapshot', 'raw_publishers') }}
