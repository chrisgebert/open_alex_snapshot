{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as source_id,
    issn_l,
    issn,
    display_name,
    publisher,
    works_count,
    cited_by_count,
    is_oa,
    is_in_doaj,
    homepage_url,
    works_api_url,
    updated_date
from {{ source('open_alex_snapshot', 'raw_sources') }}
