{{
    config(
        materialized= 'table'
    )
}}

select
	id as topic_id,
	display_name as display_name_id,
	subfield.id as topic_subfield_id,
	field.id as topic_field_id,
	domain.id as topic_domain_id,
	description as topic_description,
	keywords,
	ids.wikipedia as topic_wikipedia_id,
	updated_date,
	created_date,
	updated
from {{ source('open_alex_snapshot', 'raw_topics') }}
