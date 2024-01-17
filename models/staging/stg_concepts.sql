{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as concept_id,
    * exclude (id)
from {{ source('open_alex_snapshot', 'raw_concepts') }}
