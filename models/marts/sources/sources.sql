{{ 
    config(
        materialized='table'
    ) 
}}

select
    source_id as id,
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
from {{ ref('stg_sources') }}
