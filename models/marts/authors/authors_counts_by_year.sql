{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_author_counts_by_year as (
    select
        id as author_id,
        unnest(counts_by_year, recursive := true)
    from {{ source('open_alex_snapshot', 'raw_authors') }}
)

select
    author_id,
    year,
    works_count,
    cited_by_count,
    oa_works_count
from unnest_author_counts_by_year
