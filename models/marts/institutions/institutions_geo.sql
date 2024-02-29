{{ 
    config(
        materialized='table'
    ) 
}}

select
    id as institution_id,
    geo.city,
    geo.geonames_city_id,
    geo.region,
    geo.country_code,
    geo.country,
    geo.latitude,
    geo.longitude
from {{ source('open_alex_snapshot', 'raw_institutions') }}
