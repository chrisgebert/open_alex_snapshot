{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_concepts_ancestors as (
    select
        concept_id,
        unnest(ancestors, recursive := true)
    from {{ ref('stg_concepts') }}
)

select 
    concept_id,
    id as ancestor_id
from unnest_concepts_ancestors
