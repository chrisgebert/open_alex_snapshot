{{ 
    config(
        materialized='table'
    ) 
}}

with works_concept_structure as (
    select
        id as work_id,
        from_json(concepts, '[{"id":"VARCHAR","wikidata":"VARCHAR","display_name":"VARCHAR","level":"BIGINT","score":"DOUBLE"}]') concept_structure
    from {{ source('open_alex_snapshot', 'raw_works') }}
),

unnest_works_concepts as (
    select
        work_id,
        unnest(concept_structure) as unnested
    from concept_structure
)

select
    work_id,
    unnested.id as work_concept_id,
    unnested.level as work_concept_level,
    unnested.score as work_concept_score
from unnest_works_concepts
