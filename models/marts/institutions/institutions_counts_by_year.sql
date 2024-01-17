{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_institution_counts_by_year as (
    select
        institution_id,
        unnest(counts_by_year, recursive := true)
    from {{ ref('stg_institutions') }}
)

select
    institution_id,
    year,
    works_count,
    cited_by_count
from unnest_institution_counts_by_year
