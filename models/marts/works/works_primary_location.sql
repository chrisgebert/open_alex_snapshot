{{ 
    config(
        materialized='table'
    ) 
}}

with primary_location_structure as (
    select
        id as work_id,
        from_json(primary_location, '{
                                "source":{
                                            "id":"VARCHAR",
                                            "issn_l":"VARCHAR",
                                            "issn":["VARCHAR"],
                                            "display_name":"VARCHAR",
                                            "publisher":"VARCHAR",
                                            "host_organization":"VARCHAR",
                                            "host_organization_name":"VARCHAR",
                                            "host_organization_lineage":["VARCHAR"],
                                            "host_organization_lineage_names":["VARCHAR"],
                                            "is_oa":"BOOLEAN",
                                            "is_in_doaj":"BOOLEAN",
                                            "host_institution_lineage":["NULL"],
                                            "host_institution_lineage_names":["NULL"],
                                            "publisher_lineage":["VARCHAR"],
                                            "publisher_lineage_names":["VARCHAR"],
                                            "publisher_id":"VARCHAR",
                                            "type":"VARCHAR"
                                    },
                                "pdf_url":"NULL",
                                "landing_page_url":"VARCHAR",
                                "is_oa":"BOOLEAN",
                                "version":"NULL",
                                "license":"NULL",
                                "doi":"VARCHAR",
                                "is_accepted":"BOOLEAN",
                                "is_published":"BOOLEAN"
                    }') location_structure
    from {{ source('open_alex_snapshot', 'raw_works') }}
)

select
    work_id,
    location_structure.source ->> '$.id' as source_id,
    location_structure.landing_page_url,
    location_structure.pdf_url,
    location_structure.is_oa,
    location_structure.version,
    location_structure.license
from primary_location_structure
