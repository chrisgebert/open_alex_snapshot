
{{ config(materialized='table') }}

select
    id as author_id,
    unnest(counts_by_year, recursive := true)
from {{ source('open_alex_authors', 'snapshot') }}