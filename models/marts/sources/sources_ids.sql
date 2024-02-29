{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as source_id,
    ids.openalex,
    ids.issn_l,
    ids.issn,
    ids.mag,
    ids.wikidata,
    ids.fatcat
from {{ source('open_alex_snapshot', 'raw_sources') }}
