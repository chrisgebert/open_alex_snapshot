
{{ config(materialized='table') }}

select 
    year, 
    count(distinct author_id) as author_count
from {{ ref('stg_counts_by_year') }}
group by year
