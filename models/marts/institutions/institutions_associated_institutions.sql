{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_associated_institutions as (
    select
        institution_id,
        unnest(associated_institutions, recursive := true)
    from {{ ref('stg_institutions') }}
)

select
    institution_id,
    id as associated_instution_id,
    relationship
from unnest_associated_institutions
