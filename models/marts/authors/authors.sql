{{ 
    config(
        materialized='table'
    )
}}

with author_institution_structure as (
    select
        id as author_id,
        orcid,
        display_name,
        display_name_alternatives,
        works_count,
        cited_by_count,
		from_json(last_known_institution, '{"lineage":["VARCHAR"], "country_code":"VARCHAR", "ror":"VARCHAR", "id":"VARCHAR", "display_name":"VARCHAR", "type":"VARCHAR"}') institution_structure,
        works_api_url,
        updated_date
    from {{ source('open_alex_snapshot', 'raw_authors') }}
)

select
    author_id,
    orcid,
    display_name,
    display_name_alternatives,
    works_count,
    cited_by_count,
    -- institution_structure ->> '$.lineage[*]' as institution_lineage,
    institution_structure.display_name as institution_display_name,
    institution_structure.country_code as institution_country_code,
    works_api_url,
    updated_date
from author_institution_structure
