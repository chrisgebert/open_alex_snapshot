{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as work_id,
    biblio.volume,
    biblio.issue,
    biblio.first_page,
    biblio.last_page
from {{ source('open_alex_snapshot', 'raw_works') }}
