{{
    config(
        materialized= 'table'
    )
}}

select
	id as subfield_id,
	display_name as subfield_display_name,
	description as subfield_description,
	ids.wikipedia as subfield_wikipedia_id,
	ids.wikidata as subfield_wikidata_id,
	works_count as subfield_works_count,
	cited_by_count as subfield_cited_by_count,
	field.id as field_id,
	domain.id as domain_id,
	updated_date,
	created_date,
	updated
from {{ source('open_alex_snapshot', 'raw_subfields') }}
