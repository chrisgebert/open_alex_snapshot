{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_primary_location as (
    select
        work_id,
        unnest(primary_location, recursive := true)
    from {{ ref('stg_works') }}
)

select
    work_id,
    id as source_id,
    landing_page_url,
    pdf_url,
    is_oa,
    version,
    license
from unnest_primary_location
