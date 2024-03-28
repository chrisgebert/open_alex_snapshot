{{ 
    config(
        materialized='incremental',
        unique_key = ['work_id']
    ) 
}}

with unnest_works_topics as (
    select
        work_id,
        unnest(topics) as unnested,
        updated_date
    from {{ source('open_alex_snapshot', 'raw_works') }}
)

select
    work_id,
    unnested.id as work_topic_id,
    unnested.display_name as work_topic_display_name,
    unnested.score as work_topic_score,
    updated_date
from unnest_works_topics
where 1 = 1

{% if is_incremental() %}

and updated_date >= (select max(updated_date) from {{ this }} )

{% endif %}