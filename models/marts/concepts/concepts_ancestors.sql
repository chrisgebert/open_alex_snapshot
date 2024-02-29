{{ 
    config(
        materialized='table'
    ) 
}}

with concepts_ancestors_structure as (
    select
        id as concept_id,
        from_json(ancestors, '[{"id":"VARCHAR","wikidata":"VARCHAR","display_name":"VARCHAR","level":"UBIGINT"}]') concept_ancestors_structure
    from {{ source('open_alex_snapshot', 'raw_concepts') }}
),

unnest_concepts_ancestors as (
    select
        concept_id,
        unnest(concept_ancestors_structure) as unnest
    from concepts_ancestors_structure
)

select 
    concept_id,
    unnest.id as ancestor_id
from unnest_concepts_ancestors
