{{ 
    config(
        materialized='table'
    ) 
}}

select
    publisher_id as id,
    display_name,
    alternate_titles,
    country_codes,
    hierarchy_level,
    parent_publisher,
    works_count,
    cited_by_count,
    sources_api_url,
    updated_date
from {{ ref('stg_publishers') }}
