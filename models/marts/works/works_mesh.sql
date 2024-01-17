{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_works_mesh as (
    select
        work_id,
        unnest(mesh, recursive := true)
    from {{ ref('stg_works') }}
)

select
    work_id,
    descriptor_ui,
    descriptor_name,
    qualifier_ui,
    qualifier_name
from unnest_works_mesh
