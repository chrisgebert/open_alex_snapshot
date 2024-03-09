{{ 
    config(
        materialized='table'
    ) 
}}

with works_authorships_structure as (
    select
        id as work_id,
        from_json(authorships, '[{"author_position":"VARCHAR","author":{"id":"VARCHAR","display_name":"VARCHAR","orcid":"NULL"},"institutions":["NULL"],"countries":["NULL"],"is_corresponding":"BOOLEAN","raw_author_name":"VARCHAR","raw_affiliation_strings":["NULL"],"raw_affiliation_string":"VARCHAR"}]') authorships_structure
    from {{ source('open_alex_snapshot', 'raw_works') }}
),

unnest_authorships as (
    select
        work_id,
        unnest(authorships_structure) as unnest,
    from works_authorships_structure
)

select
    work_id,
    unnest.author_position,
    unnest.author.id as author_id,
    unnest.institutions
from unnest_authorships
