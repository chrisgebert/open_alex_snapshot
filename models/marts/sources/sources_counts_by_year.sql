{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_sources_counts_by_year as (
    select
        source_id,
        unnest(counts_by_year, recursive := true)
    from {{ ref('stg_sources') }}
)

select
    source_id,
    year,
    works_count,
    cited_by_count,
    oa_works_count
from unnest_sources_counts_by_year
