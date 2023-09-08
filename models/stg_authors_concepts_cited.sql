
{{ config(materialized='table') }}

with extract as (
    select 
        id as author_id, 
        unnest(x_concepts, recursive := true) 
    from {{ source('open_alex_authors', 'snapshot') }}
)

select * 
from extract
inner join {{ ref('stg_authors_cited') }} as stg_authors_cited
    on extract.author_id = stg_authors_cited.id
where level = 0
