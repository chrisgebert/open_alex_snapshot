{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as work_id,
    doi,
    title,
    display_name,
    publication_year,
    publication_date,
    type,
    cited_by_count,
    is_retracted,
    is_paratext,
    cited_by_api_url,
    language,
    ids,
    primary_location,
    countries_distinct_count,
    institutions_distinct_count,
    biblio,
    concepts,
    mesh,
    locations,
    referenced_works_count,
    sustainable_development_goals,
    keywords,
    counts_by_year,
    updated_date,
    created_date,
    updated
from {{ source('open_alex_snapshot', 'raw_works') }}
