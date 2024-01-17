{{ 
    config(
        materialized='table'
    ) 
}}

select
    institution_id as id,
    ror,
    display_name,
    country_code,
    type,
    homepage_url,
    image_url,
    image_thumbnail_url,
    display_name_acronyms,
    display_name_alternatives,
    works_count,
    cited_by_count,
    works_api_url,
    updated_date
from {{ ref('stg_institutions') }}
