{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_sources_ids as (
    select
        source_id,
        unnest(ids, recursive := true)
    from {{ ref('stg_sources') }}
)

select
    source_id,
    openalex,
    issn_l,
    issn,
    mag,
    wikidata,
    fatcat
from unnest_sources_ids
