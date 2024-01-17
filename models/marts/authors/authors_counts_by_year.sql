{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_author_counts_by_year as (
    select
        author_id,
        unnest(counts_by_year, recursive := true)
    from {{ ref('stg_authors') }}
)

select
    author_id,
    year,
    works_count,
    cited_by_count,
    oa_works_count
from unnest_author_counts_by_year
