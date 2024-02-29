{{ 
    config(
        materialized='table'
    ) 
}}

with institution_counts_by_year_structure as (
    select
        id as institution_id,
        from_json(counts_by_year, '[{"year":"UBIGINT","works_count":"UBIGINT","oa_works_count":"UBIGINT","cited_by_count":"UBIGINT"}]') institution_counts_by_year_structure
    from {{ source('open_alex_snapshot', 'raw_institutions') }}
),

unnest_institution_counts_by_year as (
    select
        institution_id,
        unnest(institution_counts_by_year_structure) as unnest
    from institution_counts_by_year_structure
)

select
    institution_id,
    unnest.year,
    unnest.works_count,
    unnest.cited_by_count
from unnest_institution_counts_by_year
