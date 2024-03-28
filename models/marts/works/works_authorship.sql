{{ 
    config(
        materialized='incremental',
        unique_key = ['work_id']
    ) 
}}

with unnest_authorships as (
    select
        id as work_id,
        unnest(authorships) as unnest,
        updated_date
    from {{ source('open_alex_snapshot', 'raw_works') }}
)

select
    work_id,
    unnest.author_position,
    unnest.author.id as author_id,
    unnest.institutions,
    updated_date
from unnest_authorships
where 1 = 1

{% if is_incremental() %}

and updated_date >= (select max(updated_date) from {{ this }} )

{% endif %}
