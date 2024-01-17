{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_works_authorships as (
    select
        work_id,
        unnest(authorships, recursive := true)
    from {{ ref('stg_works_authorships') }}
),

unnest_authorship_institutions as (
    select
        work_id,
        author_position,
        id as author_id,
        unnest(institutions, recursive := true)
    from unnest_works_authorships
)

select
    work_id,
    author_position,
    author_id,
    id as institution_id
from unnest_authorship_institutions
