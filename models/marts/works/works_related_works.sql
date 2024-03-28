{{ 
    config(
        materialized='incremental',
        unique_key = ['work_id']
    ) 
}}

with unnested_related_works as (
    select
        id as work_id,
        unnest(related_works) as related_work_id,
        updated_date
    from {{ source('open_alex_snapshot', 'raw_works') }}
)

select
    work_id,
    related_work_id,
    updated_date
from unnested_related_works
where 1 = 1

{% if is_incremental() %}

and updated_date >= (select max(updated_date) from {{ this }} )

{% endif %}