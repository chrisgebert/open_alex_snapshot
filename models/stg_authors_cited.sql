
select id
from {{ source('open_alex_authors', 'september_2023_snapshot') }}
where cited_by_count != 0
