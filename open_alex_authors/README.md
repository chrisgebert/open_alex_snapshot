
# Background

There are a handful of things that I've been thinking about / playing with and they all kinda came together recently in a way that made sense to write up and share. 

First, some background:

## OpenAlex

[OurResearch](https://ourresearch.org) came to the rescue with [OpenAlex](https://openalex.org) after Microsoft announced it would end its support for [Microsoft Academic Graph (MAG)](https://www.microsoft.com/en-us/research/project/microsoft-academic-graph/) at the end of 2021. In a short amount of time, OpenAlex started compiling data related to academic publications (e.g. works, authors, publications, institutions, etc.). They stood up an API and some documentation and made this data available to the community. In addition, they've released data snapshots in [s3](https://registry.opendata.aws/openalex/) for those who have needs outside of what's provided by the API. The snapshots are released monthly, and the most recent author data snapshot [includes the improved author disambiguation feature](https://groups.google.com/g/openalex-users/c/yRgoy2oD2f8/m/iXfGguhQBgAJ).

## DuckDB, and friends (MotherDuck and `dbt-duckdb`)

[DuckDB](https://duckdb.org) is an in-process analytic database that's come on the scene in the past few years that looks like it could change a lot of workflows. It's fast, it's designed to be embedded but you can choose to persist a database if you want to. 

### MotherDuck

[MotherDuck](https://motherduck.com) is a serverless instance of DuckDB in the cloud. I believe it remains invite-only at the moment and from what I can tell, they haven't decided on specific pricing yet, so this is all a proof of concept at the moment rather than a full project ready for production. 

### `dbt-duckdb`

[`dbt-duckdb`](https://github.com/jwills/dbt-duckdb) is a dbt adapter built for use with DuckDB (and also, recently MotherDuck) so we can configure OpenAlex as our source, and build a dbt project on top of it, allowing us to make use of all the great things about dbt like testing and macros and packages created by that community.


### Note

Importantly: OpenAlex and MotherDuck both use s3 region `us-east-1` so the data won't be moving between regions. We can explore the OpenAlex snapshots directly from s3 using a local instance of `duckdb` and `dbt-duckdb` too; we'll just need to `set s3_region` in either to access the snapshot data files. 



# 1. Get the OpenAlex author data snapshot file locations from the most recent manifest

```
import requests

manifest = requests.get('https://openalex.s3.amazonaws.com/data/authors/manifest').json()

# get file paths and dates
files = []

for entry in manifest['entries']:
    file = entry['url']
    files.append(file)

print(len(files))
```

# 2. Install `httpfs` and review snapshot data files using `duckdb`

```
import duckdb

duckdb.sql("install 'httpfs'; load 'httpfs';")

duckdb.sql("select * from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-08-15/part_001.gz', format='newline_delimited', compression='gzip'))
```

In this example, `duckdb` read the compressed json file of 492 MB into an object in memory in about 10 seconds. 

It's easy to see how we can iterate over the list of file paths from the manifest and use `duckdb`'s COPY or CREATE TABLE commands to insert these files into a persisted `.duckdb` database that we can store locally.


# 3. Explore a small sample of the records in these snapshot files to see how things are structured

Let's limit the total number of records we're looking at just to understand how these files are 

```
import duckdb
import pandas as pd

df = duckdb.sql("select * from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-08-15/part_001.gz', format='newline_delimited', compression='gzip') limit 100).df()

df.columns

Index(['x_concepts', 'display_name_alternatives', 'cited_by_count',
       'most_cited_work', 'counts_by_year', 'last_known_institution', 'orcid',
       'display_name', 'summary_stats', 'works_api_url', 'ids', 'id',
       'updated_date', 'created_date', 'works_count', 'updated'],
      dtype='object')

```

So in these compressed json files, we have an OpenAlex `id`, a `display_name` field, a `cited_by_count` field, a `most_cited_work` field, a few arrays (including `x_concepts`, `display_name_alternatives`, '`counts_by_year`) and some dict objects (like `last_known_institution`, `summary_stats`, and other `ids`). This helps us to understand how we might want to further explore.



# 4. Revise our queries to begin analysis

Using this information, we can revise our `duckdb` queries to focus on fields that are most valuable to us in our analysis, and even start to unnest some of these arrays or dict objects, and start a process of transformation from the source snapshot files.

1. Unnesting `counts_by_year` to get `author_id`, `cited_by_count`, `year`, `works_count`, and `oa_works_count`
```
duckdb.sql("select id as author_id, unnest(counts_by_year, recursive := true) from read_json_auto('https://openalex.s3amazonaws.com/data/authors/updated_date%3D2023-08-15/part_000.gz', format='newline_delimited', compression='gzip') limit 200")
```

2. Unnesting `last_known_institution` to get `author_id`, `display_name`, `last_known_institution['display_name']`, `works_count`, `cited_by_count`
```
duckdb.sql("select id, display_name, json_extract(last_known_institution, '$.display_name'), works_count, cited_by_count from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-08-15/part_000.gz', format='newline_delimited', compression='gzip') where cited_by_count > 10")
```

3. 
```

```



# 5. Create a `dbt` project from our analysis

Using the above, we can build a `dbt` project that uses OpenAlex database snapshots as its source and to build specific tables to perform ongoing analysis and even output files, using `dbt-duckdb`. With `dbt-duckdb`, we can work with a persisted `.duckdb` database file, within memory, or with MotherDuck, which we'll get to. In our `profiles.yml`, we'll create a new profile with `type: duckdb` and configure any other `settings` we'll use. Then we can run `dbt init` to initialize the project 

## Create `sources.yml`
```
version: 2

sources:
  - name: open_alex_authors
    schema: main
    description: "Latest OpenAlex author data snapshot"
    meta:
      external_location: "read_json_auto('s3://openalex/data/authors/updated_date=2023-08-15/*.gz', format='newline_delimited', compression='gzip')"
```

## Create models

Like `stg_authors_cited`, `stg_authors_concepts_cited`


```
select
    id as author_id,
    unnest(counts_by_year, recursive := true) as counts_by_year
from read_json_auto('s3://openalex/data/authors/updated_date=2023-03-13/part_000.gz', format='newline_delimited', compression='gzip')
```



# Using MotherDuck




### Source

Open Alex Snapshot files

- JSON formatted, gzip compressed, s3 region 'us-east-1'





Read files into `duckdb` to convert the json files to `csv` to be used as model sources for `dbt`.


# Read More:

- Authenticating to MotherDuck: https://motherduck.com/docs/getting-started/connect-query-from-python/installation-authentication/

- Using MotherDuck with `dbt-duckdb`: https://github.com/jwills/dbt-duckdb#using-motherduck

- OpenAlex Snapshot Data Format: https://docs.openalex.org/download-all-data/snapshot-data-format

- Querying files in S3: https://motherduck.com/docs/key-tasks/querying-s3-files

