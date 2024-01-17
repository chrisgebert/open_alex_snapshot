{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_related_concepts as (
    select
        concept_id,
        unnest(related_concepts, recursive := true)
    from {{ ref('stg_concepts') }}
)

select
    concept_id,
    id as related_concept_id,
    score
from unnest_related_concepts
