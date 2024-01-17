{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_concept_ids as (
    select
        concept_id,
        unnest(ids)
    from {{ ref('stg_concepts') }}
)

select
    concept_id,
    openalex,
    wikidata,
    wikipedia,
    umls_aui,
    umls_cui,
    mag
from unnest_concept_ids
