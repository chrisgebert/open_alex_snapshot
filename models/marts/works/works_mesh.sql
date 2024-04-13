{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_works_mesh as (
    select
        id as work_id,
        unnest(mesh) as unnest
	from {{ source('open_alex_snapshot', 'raw_works') }}
)

select
    work_id,
    unnest.descriptor_ui,
    unnest.descriptor_name,
    unnest.qualifier_ui,
    unnest.qualifier_name
from unnest_works_mesh
