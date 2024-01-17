{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_author_ids as (
    select
        author_id,
        unnest(ids)
    from {{ ref('stg_authors') }}
)

select
    author_id,
    openalex,
    orcid,
    scopus
from unnest_author_ids
