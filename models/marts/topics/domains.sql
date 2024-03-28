{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as domain_id,
    display_name,
    ids.wikidata as domain_wikidata_id,
    ids.wikipedia as domain_wikipedia_id,
    works_count,
    cited_by_count,
    updated_date,
    created_date,
    updated
from {{ source('open_alex_snapshot', 'raw_domains') }}
