
select id
from {{ source('open_alex_authors', 'authors') }}
where cited_by_count != 0