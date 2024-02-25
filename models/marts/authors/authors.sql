{{ 
    config(
        materialized='table'
    )
}}

with extracted_author_date as (
    select
        id as author_id,
        orcid,
        display_name,
        display_name_alternatives,
        works_count,
        cited_by_count,
        json_extract_string(last_known_institution, ['institution_lineage', 'display_name', 'country_code']) extracted_institution,
        works_api_url,
        updated_date
    from {{ source('open_alex_snapshot', 'raw_authors')}}
)

select
    author_id,
    orcid,
    display_name,
    display_name_alternatives,
    works_count,
    cited_by_count,
    extracted_institution[1] as institution_lineage,
    extracted_institution[2] as institution_display_name,
    extracted_institution[3] as institution_country_code,
    works_api_url,
    updated_date
from extracted_author_date
