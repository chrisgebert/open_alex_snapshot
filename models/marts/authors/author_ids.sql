{{ 
    config(
        materialized='table'
    )
}}

with unnest_author_ids as (
    select
        id as author_id,
        unnest(ids),
        updated_date
    from {{ source('open_alex_snapshot', 'raw_authors') }}
)

select
    author_id,
    openalex,
    orcid,
    scopus,
    updated_date
from unnest_author_ids
