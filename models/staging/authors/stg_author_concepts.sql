with unnest_concepts as (
    select
        author_id,
        unnest(x_concepts, recursive := true)
    from {{ ref('stg_authors') }}
)

select
    author_id,
    score as concept_score,
    level as concept_level,
    id as concept_id,
    display_name as concept_display_name,
    wikidata as concept_wikidata_url
from unnest_concepts
