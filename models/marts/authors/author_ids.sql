{{ 
    config(
        materialized='table'
    )
}}

select
    id as author_id,
    ids.openalex,
    ids.orcid,
    ids.scopus,
    updated_date
from {{ source('open_alex_snapshot', 'raw_authors') }}
