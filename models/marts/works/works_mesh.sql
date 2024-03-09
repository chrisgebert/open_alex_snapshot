{{ 
    config(
        materialized='table'
    ) 
}}

with works_mesh_structure as (
    select
		id as work_id,
		mesh,
		from_json(mesh, '[{"is_major_topic":"BOOLEAN","descriptor_ui":"VARCHAR","descriptor_name":"VARCHAR","qualifier_ui":"VARCHAR","qualifier_name":"VARCHAR"}]') mesh_structure
	from {{ source('open_alex_snapshot', 'raw_works') }}
),

unnest_works_mesh as (
    select
        work_id,
        unnest(mesh_structure) as unnest
    from works_mesh_structure
)

select
    work_id,
    unnest.descriptor_ui,
    unnest.descriptor_name,
    unnest.qualifier_ui,
    unnest.qualifier_name
from unnest_works_mesh
