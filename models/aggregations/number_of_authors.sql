
{{ config(materialized='table') }}

select 
    year, 
    count(distinct author_id) as author_count
from {{ source('open_alex_authors', 'snapshot') }}
group by year
