{{ 
    config(
        materialized='table'
    )
}}

select
    stg_authors.author_id as id,
    orcid,
    display_name,
    display_name_alternatives,
    works_count,
    cited_by_count,
    last_known_institution,
    institution_display_name,
    institution_country_code,
    works_api_url,
    updated_date
from {{ ref('stg_authors') }}
left join {{ ref('stg_author_institution') }}
    on stg_authors.author_id = stg_author_institution.author_id
