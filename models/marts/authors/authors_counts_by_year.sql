{{ 
    config(
        materialized='table'
    ) 
}}

with author_counts_by_year_structure as (
    select
        id as author_id,
        counts_by_year,
        updated_date
    from {{ source('open_alex_snapshot', 'raw_authors') }}
),

unnest_author_counts_by_year as (
    select
        author_id,
        unnest(counts_by_year) as unnest,
        updated_date
    from author_counts_by_year_structure
)

select
    author_id,
    unnest.year,
    unnest.works_count,
    unnest.cited_by_count,
    unnest.oa_works_count,
    updated_date
from unnest_author_counts_by_year
