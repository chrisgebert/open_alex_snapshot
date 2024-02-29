{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as publisher_id,
    display_name,
    alternate_titles,
    country_codes,
    hierarchy_level,
    parent_publisher,
    works_count,
    cited_by_count,
    sources_api_url,
    updated_date
from {{ source('open_alex_snapshot', 'raw_publishers') }}
