{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_works_concepts as (
    select
        id as work_id,
        unnest(concept_structure) as unnested
    from {{ source('open_alex_snapshot', 'raw_works') }}
)

select
    work_id,
    unnested.id as work_concept_id,
    unnested.level as work_concept_level,
    unnested.score as work_concept_score
from unnest_works_concepts
