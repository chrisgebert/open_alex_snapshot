{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_works_biblio as (
    select
        work_id,
        unnest(biblio, recursive := true)
    from {{ ref('stg_works') }}
)

select
    work_id,
    volume,
    issue,
    first_page,
    last_page
from unnest_works_biblio
