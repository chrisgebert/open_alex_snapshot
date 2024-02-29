{{ 
    config(
        materialized='table'
    ) 
}}

with associated_institutions_structure as (
    select
        id as institution_id,
        from_json(associated_institutions, '[{"id":"VARCHAR","ror":"VARCHAR","display_name":"VARCHAR","country_code":"VARCHAR","type":"VARCHAR","relationship":"VARCHAR","lineage":"NULL"}]') associated_institutions_structure
    from {{ source('open_alex_snapshot', 'raw_institutions') }}
),

unnest_associated_institutions as (
    select
        institution_id,
        unnest(associated_institutions_structure) as unnest
    from associated_institutions_structure
)

select
    institution_id,
    unnest.id as associated_instution_id,
    unnest.relationship
from unnest_associated_institutions
