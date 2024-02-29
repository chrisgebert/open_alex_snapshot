{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as concept_id,
    ids.openalex,
    ids.wikidata,
    ids.wikipedia,
    ids.umls_aui,
    ids.umls_cui,
    ids.mag
from {{ source('open_alex_snapshot', 'raw_concepts') }}
