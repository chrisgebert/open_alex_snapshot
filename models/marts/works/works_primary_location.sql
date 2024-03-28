{{ 
    config(
        materialized='incremental',
        unique_key = ['work_id']
    ) 
}}

select
    id as work_id,
    primary_location.source ->> '$.id' as source_id,
    primary_location.landing_page_url,
    primary_location.pdf_url,
    primary_location.is_oa,
    primary_location.version,
    primary_location.license,
    updated_date
from {{ source('open_alex_snapshot', 'raw_works') }}
where 1 = 1

{% if is_incremental() %}

and updated_date >= (select max(updated_date) from {{ this }} )

{% endif %}