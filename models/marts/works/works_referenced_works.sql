{{ 
    config(
        materialized='table'
    ) 
}}

with unnested_referenced_works as (
    select
        work_id,
        unnest(referenced_works) as referenced_work_id
from {{ ref('stg_works_referenced_related') }}
)

select
    work_id,
    referenced_work_id
from unnested_referenced_works
