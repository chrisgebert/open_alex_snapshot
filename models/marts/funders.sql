{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as funder_id,
    display_name as funder_display_name,
    country_code as funder_country_code,
    description as funder_description,
    roles,
    works_count,
    cited_by_count,
    updated_date,
    created_date,
    updated
from {{ source('open_alex_snapshot', 'raw_funders') }}