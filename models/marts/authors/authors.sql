{{ 
    config(
        materialized='incremental',
        unique_key = ['author_id']
    )
}}

select
    id as author_id,
    orcid,
    display_name,
    display_name_alternatives,
    works_count,
    cited_by_count,
    -- last_known_institution ->> '$.lineage[*]' as institution_lineage,
    last_known_institution.display_name as institution_display_name,
    last_known_institution.country_code as institution_country_code,
    works_api_url,
    updated_date
from {{ source('open_alex_snapshot', 'raw_authors') }}
where 1 = 1

{% if is_incremental() %}

and updated_date >= (select max(updated_date) from {{ this }} )

{% endif %}
