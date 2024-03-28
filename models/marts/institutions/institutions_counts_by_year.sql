{{ 
    config(
        materialized='table'
    ) 
}}

with insitution_counts_by_year as (

    select
        id as institution_id,
        counts_by_year
    from {{ source('open_alex_snapshot', 'raw_institutions') }}

),

unnest_counts_by_year as (
    
    select
        institution_id,
        unnest(counts_by_year) as unnested
    from insitution_counts_by_year

)

select
    institution_id,
    unnested.year,
    unnested.works_count,
    unnested.cited_by_count
from unnest_counts_by_year
