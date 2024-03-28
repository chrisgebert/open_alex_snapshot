{{ 
    config(
        materialized='table'
    ) 
}}

with sources_counts_by_year_structure as (
    select
        id as source_id,
        from_json(counts_by_year, '[
            {
                "year":"UBIGINT",
                "works_count":"UBIGINT",
                "oa_works_count":"UBIGINT",
                "cited_by_count":"UBIGINT"
            }
        ]') sources_counts_by_year_structure
    from {{ source('open_alex_snapshot', 'raw_sources') }}
),

unnest_sources_counts_by_year as (
    select
        source_id,
        unnest(sources_counts_by_year_structure) as unnest
    from sources_counts_by_year_structure
)

select
    source_id,
    unnest.year,
    unnest.works_count,
    unnest.cited_by_count,
    unnest.oa_works_count
from unnest_sources_counts_by_year
