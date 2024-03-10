{{ 
    config(
        materialized='table'
    ) 
}}

with works_topics_structure as (
    select
        id as work_id,
        from_json(topics, '[{"id":"VARCHAR","display_name":"VARCHAR","subfield":{"id":"UBIGINT","display_name":"VARCHAR"},"field":{"id":"UBIGINT","display_name":"VARCHAR"},"domain":{"id":"UBIGINT","display_name":"VARCHAR"},"score":"DOUBLE"}]') topics_structure
    from {{ source('open_alex_snapshot', 'raw_works') }}
),

unnest_works_topics as (
    select
        work_id,
        unnest(topics_structure) as unnested
    from works_topics_structure
)

select
    work_id,
    unnested.id as work_topic_id,
    unnested.display_name as work_topic_display_name,
    unnested.score as work_topic_score
from unnest_works_topics
