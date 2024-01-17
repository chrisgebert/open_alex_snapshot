{{ 
    config(
        materialized='table'
    ) 
}}

with unnested_related_works as (
    select
        work_id,
        unnest(related_works) as related_work_id
    from {{ ref('stg_works_referenced_related') }}
)

select
    work_id,
    related_work_id
from unnested_related_works
