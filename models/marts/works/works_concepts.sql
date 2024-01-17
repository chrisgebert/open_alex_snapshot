{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_works_concepts as (
    select
        work_id,
        unnest(concepts, recursive := true)
    from {{ ref('stg_works') }}
)

select
    work_id,
    id as concept_id,
    score
from unnest_works_concepts
