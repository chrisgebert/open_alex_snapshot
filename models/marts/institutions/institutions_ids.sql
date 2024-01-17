{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_institutions_ids as (
    select
        institution_id,
        unnest(ids, recursive := true)
    from {{ ref('stg_institutions') }}
)

select
    institution_id,
    openalex,
    ror,
    grid,
    wikipedia,
    wikidata,
    mag
from unnest_institutions_ids
