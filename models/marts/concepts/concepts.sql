{{ 
    config(
        materialized='table'
    ) 
}}

select
    concept_id as id,
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
from {{ ref('stg_concepts')}}
