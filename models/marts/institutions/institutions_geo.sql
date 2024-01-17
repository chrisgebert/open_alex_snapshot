{{ 
    config(
        materialized='table'
    ) 
}}

with unnest_institutions_geo as (
    select
        institution_id,
        unnest(geo, recursive := true)
    from {{ ref('stg_institutions') }}
)

select
    institution_id,
    city,
    geonames_city_id,
    region,
    country_code,
    country,
    latitude,
    longitude
from unnest_institutions_geo
