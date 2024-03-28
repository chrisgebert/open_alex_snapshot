{{ 
    config(
        materialized='incremental',
        unique_key = ['work_id']
    ) 
}}

with unnested_referenced_works as (
    select
        id as work_id,
        unnest(referenced_works) as referenced_work_id,
        updated_date
from {{ source('open_alex_snapshot', 'raw_works') }}
)

select
    work_id,
    referenced_work_id,
    updated_date
from unnested_referenced_works
where 1 = 1

{% if is_incremental() %}

and updated_date >= (select max(updated_date) from {{ this }} )

{% endif %}