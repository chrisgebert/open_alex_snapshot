{{ 
    config(
        materialized='table'
    ) 
}}

select
    work_id,
    doi,
    ids.mag,
    ids.pmid
from {{ ref('stg_works') }}
