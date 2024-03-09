{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as work_id,
    doi,
    title,
    display_name,
    publication_year,
    publication_date,
    type,
    cited_by_count,
    is_retracted,
    is_paratext,
    cited_by_api_url,
    language,
    updated_date
from {{ source('open_alex_snapshot', 'raw_works') }}
