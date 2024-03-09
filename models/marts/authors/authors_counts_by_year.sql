{{ 
    config(
        materialized='table'
    ) 
}}

with author_counts_by_year_structure as (
    select
        id as author_id,
        from_json(counts_by_year, '[{"cited_by_count":"UBIGINT","year":"UBIGINT","works_count":"UBIGINT","oa_works_count":"UBIGINT"}]') author_counts_by_year_structure
    from {{ source('open_alex_snapshot', 'raw_authors') }}
),

unnest_author_counts_by_year as (
    select
        author_id,
        unnest(author_counts_by_year_structure) as unnest
    from author_counts_by_year_structure
)

select
    author_id,
    unnest.year,
    unnest.works_count,
    unnest.cited_by_count,
    unnest.oa_works_count
from unnest_author_counts_by_year
