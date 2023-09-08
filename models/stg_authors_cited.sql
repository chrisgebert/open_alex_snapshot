
select id
from {{ source('open_alex_authors', 'snapshot') }}
where cited_by_count != 0