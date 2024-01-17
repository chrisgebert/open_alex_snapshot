{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_work_ids as (
    select
        work_id,
        unnest(ids, recursive := true)
    from {{ ref('stg_works') }}
)

select
    work_id,
    openalex,
    doi,
    mag,
    pmid
from unnest_work_ids
