select
  author_id, 
  last_known_institution ->> '$.display_name' as institution_display_name,
  last_known_institution ->> '$.country_code' as institution_country_code
from {{ ref('stg_authors') }} as stg_authors
