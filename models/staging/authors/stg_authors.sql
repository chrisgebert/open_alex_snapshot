select
    id as author_id,
    display_name,
    display_name_alternatives,
    orcid,
    last_known_institution,
    -- last_known_institutions,
    counts_by_year,
    works_count,
    cited_by_count,
    most_cited_work,
    summary_stats,
    ids,
    works_api_url,
    x_concepts,
    updated_date
from {{ source('open_alex_snapshot', 'raw_authors') }}
-- where cited_by_count != 0
