{{ 
    config(
        materialized='table'
    ) 
}}

with related_concept_structure as (
    select
        id as concept_id,
        from_json(related_concepts, '[{"id":"VARCHAR","wikidata":"NULL","display_name":"VARCHAR","level":"UBIGINT","score":"DOUBLE"}]') related_concept_structure
    from {{ source('open_alex_snapshot', 'raw_concepts') }}
),

unnest_related_concepts as (
    select
        concept_id,
        unnest(related_concept_structure) as unnest
    from related_concept_structure
)

select
    concept_id,
    unnest.id as related_concept_id,
    unnest.score as related_concept_score
from unnest_related_concepts
