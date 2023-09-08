
- About This Project
- Exploratory Analysis
- Develop Our Analysis
- Using `dbt` and `dbt-duckdb`
- Using MotherDuck
- Read More



# About This Project

First, a little background:

## OpenAlex

[OurResearch](https://ourresearch.org) came to the rescue with [OpenAlex](https://openalex.org) after Microsoft announced it would end its support for [Microsoft Academic Graph (MAG)](https://www.microsoft.com/en-us/research/project/microsoft-academic-graph/) at the end of 2021. 

In a short amount of time, OpenAlex started compiling data related to academic publications (e.g. works, authors, publications, institutions, etc.). They stood up an API and some documentation and made this data available to the community. 

In addition, they began releasing data snapshots in [S3](https://registry.opendata.aws/openalex/) for those who have needs outside of what's provided by the API. The snapshots are released monthly, and the most recent author data snapshot [includes the improved author disambiguation feature](https://groups.google.com/g/openalex-users/c/yRgoy2oD2f8/m/iXfGguhQBgAJ).

## DuckDB, and friends (`dbt-duckdb` and MotherDuck)

[DuckDB](https://duckdb.org) is an in-process analytic database that's come on the scene in the past few years that looks like it could change a lot of workflows. It's fast, it's designed to be embedded but you can choose to persist a database if you want to. 

### `dbt-duckdb`

[`dbt-duckdb`](https://github.com/jwills/dbt-duckdb) is a dbt adapter built for use with DuckDB (and also, recently MotherDuck) so we can:
1. configure one or more OpenAlex snapshot file as our data source, and 
2. build a dbt project on top of it, allowing us to make use of all the great things about [`dbt`](https://www.getdbt.com/), like testing and macros and packages created by that community.

### MotherDuck

[MotherDuck](https://motherduck.com) is a serverless instance of DuckDB in the cloud. I believe it remains invite-only at the moment and from what I can tell, they haven't decided on specific pricing yet, so this is all a proof of concept at the moment rather than a full project ready for production. 

I was [granted access to the beta](https://jawns.club/@cgebert/110714745527510396) a little while ago, and the timing has been perfect to play around with this and see what I can do using the improved author snapshot files from OpenAlex.

### Note

Importantly: OpenAlex and MotherDuck both use s3 region `us-east-1` so the data won't be moving between regions. We can explore the OpenAlex snapshots directly from s3 using a local instance of `duckdb` and `dbt-duckdb` too; we'll just need to `set s3_region` in either to access the snapshot data files. 

# Exploratory Analysis

## 1. Get OpenAlex author data snapshot file locations from the most recent manifest

Read all file paths from the latest snapshot manifest file.

```
import requests

manifest = requests.get('https://openalex.s3.amazonaws.com/data/authors/manifest').json()

# get file paths
files = []

for entry in manifest['entries']:
    file = entry['url']
    files.append(file)

print(len(files))
```

## 2. Install `httpfs` and review snapshot data files using `duckdb`

Use `duckdb` to read one or more snapshot files into memory or into a local database table.

```
import duckdb

duckdb.sql("install 'httpfs'; load 'httpfs';")

duckdb.sql("select * from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-08-15/part_001.gz', format='newline_delimited', compression='gzip')")
```

In this example, `duckdb` read the compressed json file of 492 MB into an object in memory in about 12 seconds. 

From here, it's easy to see how we can use a process like this to iterate over the list of file paths from the manifest and use `duckdb`'s [COPY](https://duckdb.org/docs/sql/statements/copy.html) or [CREATE TABLE](https://duckdb.org/docs/sql/statements/create_table) commands to insert these files into a persisted `.duckdb` database that we can store locally.


## 3. Explore a small sample of the records in these snapshot files to see how things are structured

Let's limit the total number of records we're looking at just to understand how these files are structured.

```
import duckdb
import pandas as pd

df = duckdb.sql("select * from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-08-15/part_001.gz', format='newline_delimited', compression='gzip') limit 100").df()

df.columns

Index(['x_concepts', 'display_name_alternatives', 'cited_by_count', 'most_cited_work', 'counts_by_year',          
      'last_known_institution', 'orcid', 'display_name', 'summary_stats', 'works_api_url', 'ids', 'id',
      'updated_date', 'created_date', 'works_count', 'updated'],
      dtype='object')
```

So in these compressed json files, we have:
- an OpenAlex `id`,
- a `display_name` field,
- a `cited_by_count` field,
- a `most_cited_work` field,
- a few arrays (including `x_concepts`, `display_name_alternatives`, '`counts_by_year`) and
- some dict objects (like `last_known_institution`, `summary_stats`, and other `ids`).

This helps us to understand what options we have regarding further exploration in a single snapshot instance, or if we're interested how things change from one snapshot filt to the next over time.

# Develop Our Analysis

## 4. Revise our queries to begin analysis

Let's say we'd like to focus only on those authors who have been cited. (Nothing against those who haven't been cited of course; bibliometric analysis works with the currency of citations that are available.)

We could define a stage table of those `author_ids` like this:

```
duckdb.sql("select id from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-08-15/part_001.gz', format='newline_delimited', compression='gzip') where cited_by_count != 0")
```

Or let's say we want to start unnesting either the `counts_by_year` array to get discrete citation counts for a particular year.

```
duckdb.sql("select id as author_id, unnest(counts_by_year, recursive := true) from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-08-15/part_000.gz', format='newline_delimited', compression='gzip') limit 200")
```

Or even getting the `display_name` of the `last_known_institution` dict.

```
duckdb.sql("select id, display_name, json_extract(last_known_institution, '$.display_name'), works_count, cited_by_count from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-08-15/part_000.gz', format='newline_delimited', compression='gzip') where cited_by_count > 10")
```

# Using `dbt` and `dbt-duck`

## 5. Create a `dbt` project from our analysis

Once we have suitably developed the queries we're interested in tracking from snapshot to snapshot, we can build a `dbt` project that uses OpenAlex database snapshots as a source to build specific tables to perform ongoing analysis and even output files, using `dbt-duckdb`.

#### Create `profiles.yml`

With `dbt-duckdb`, we can work using a persisted `.duckdb` database file, using memory, or using MotherDuck, which we'll get to. In our `profiles.yml`, we'll create a new profile with `type: duckdb` and configure any other `settings` or `extensions` we'll use, like `httpfs`.

```
open_alex_authors:

  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'open_alex.duckdb'
      threads: 24
      extensions:
        - httpfs
```

#### Create `sources.yml`

We'll use the `external_location` meta option with the relevant `read_json_auto` parameters.

```
version: 2

sources:
  - name: open_alex_authors
    schema: main
    description: "Latest OpenAlex author data snapshot"
    meta:
      external_location: "read_json_auto('s3://openalex/data/authors/updated_date=2023-08-15/*.gz', format='newline_delimited', compression='gzip')"
    tables:
      - name: snapshot
```

#### Create models

Like stage models (e.g `stg_authors_cited.sql` or `stg_authors_concepts_cited.sql`), or intermediate models, or aggregation models (like `number_of_authors.sql`).

#### 

# Using MotherDuck



# Read More:

- Authenticating to MotherDuck: https://motherduck.com/docs/getting-started/connect-query-from-python/installation-authentication/

- MotherDuck + dbt: Better Together: https://motherduck.com/blog/motherduck-duckdb-dbt/

- Using MotherDuck with `dbt-duckdb`: https://github.com/jwills/dbt-duckdb#using-motherduck

- OpenAlex Snapshot Data Format: https://docs.openalex.org/download-all-data/snapshot-data-format

- Querying files in S3: https://motherduck.com/docs/key-tasks/querying-s3-files
