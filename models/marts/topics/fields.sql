{{
    config(
        materialized= 'table'
    )
}}

select
	id as field_id,
	display_name as field_display_name,
	description as field_description,
	ids.wikipedia as field_wikipedia_id,
	ids.wikidata as field_wikidata_id,
	works_count as field_works_count,
	cited_by_count as field_cited_by_count,
	domain.id as field_domain_id,
	updated_date,
	created_date,
	updated	
from {{ source('open_alex_snapshot', 'raw_fields') }}
