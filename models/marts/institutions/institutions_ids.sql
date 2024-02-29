{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as institution_id,
    ids.openalex,
    ids.ror,
    ids.grid,
    ids.wikipedia,
    ids.wikidata,
    ids.mag
from {{ source('open_alex_snapshot', 'raw_institutions') }}
