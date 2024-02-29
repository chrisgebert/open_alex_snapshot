{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as concept_id,
    wikidata,
    display_name,
    level,
    description,
    works_count,
    cited_by_count,
    image_url,
    image_thumbnail_url,
    works_api_url,
    updated_date
from {{ source('open_alex_snapshot', 'raw_concepts') }}
