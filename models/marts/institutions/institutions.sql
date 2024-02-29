{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as institution_id,
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
from {{ source('open_alex_snapshot', 'raw_institutions') }}
