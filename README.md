# Contents

- [About This Project](#about-this-project)
- [Exploratory Analysis](#exploratory-analysis)
- [Loading Snapshot Files into a Local DuckDB Database](#loading-snapshot-files-into-a-local-duckdb-database)
- [Using `dbt` and `dbt-duckdb`](#using-dbt-and-dbt-duck)
- [Using MotherDuck](#using-motherduck)
- [Next Steps](#next-steps)
- [Read More](#read-more)

# About This Project

First, a little background:

## OpenAlex

[OurResearch](https://ourresearch.org) came to the rescue with [OpenAlex](https://openalex.org) after Microsoft announced it would end its support for [Microsoft Academic Graph (MAG)](https://www.microsoft.com/en-us/research/project/microsoft-academic-graph/) at the end of 2021. 

In a short amount of time, OpenAlex started compiling data related to academic publications (e.g. works, authors, publications, institutions, etc.). They stood up an API and documentation and made this data available to the community at no charge.

In addition, they began releasing regular data snapshots in [s3](https://registry.opendata.aws/openalex/) for those who have needs outside of what's provided by the API. The snapshots are released monthly, and the August author data snapshot from 2023 [included an improved author disambiguation feature](https://groups.google.com/g/openalex-users/c/yRgoy2oD2f8/m/iXfGguhQBgAJ), which can be a [thorny problem to solve](https://docs.openalex.org/api-entities/authors/author-disambiguation).

More recently, they've started to use [a method for classifying research topics of a particular work](https://help.openalex.org/how-it-works/topics) developed in partnership with CWTS at Leiden University. This is a move away from `concepts` that existed in the former data model which were inherited from MAG. 

## DuckDB, and friends (`dbt-duckdb` and MotherDuck)

### DuckDB

[DuckDB](https://duckdb.org) is an in-process analytic database that's come on the scene in the past few years that looks like it could change a lot of workflows. It's fast, it's designed to be embedded, but you can choose to persist a database if you want to.

### `dbt-duckdb`

[`dbt-duckdb`](https://github.com/duckdb/dbt-duckdb) is a dbt adapter built for use with DuckDB (and also, recently MotherDuck) so we can:
1. create data sources from all the most recent OpenAlex snapshot files, and 
2. build a dbt project on top of it, allowing us to make use of all the great things about [`dbt`](https://www.getdbt.com/), like testing and macros and packages created by that community.

### MotherDuck

[MotherDuck](https://motherduck.com) is a serverless instance of DuckDB in the cloud.

I was [granted access to the beta](https://jawns.club/@cgebert/110714745527510396) a little while ago (though they've since announced they're welcoming sign-ups from anyone), and the timing has been perfect to play around with this and see what I can do.

### Note

Importantly: OpenAlex and MotherDuck both use s3 region `us-east-1` so the data won't be moving between regions. We can explore the OpenAlex snapshots directly from s3 using a local instance of `duckdb` and `dbt-duckdb` too; we'll just need to `set s3_region` in either to access the snapshot data files. 

# Exploratory Analysis

For our exploratory analysis, we can follow the [OpenAlex documentation to download all the snapshot files](https://docs.openalex.org/download-all-data/download-to-your-machine) to our machine. Or alternatively, we can use DuckDB to query one or more of those file directly without downloading them first.

For now, we'll query [just one of the files using the file path](https://docs.openalex.org/download-all-data/snapshot-data-format#the-manifest-file) from the [most recent manifest](https://openalex.s3.amazonaws.com/data/authors/manifest), and once we're more familiar with the data model, we'll grab all the files that make up the snapshot. 

## Review a snapshot data file using DuckDB

We'll start by using [DESCRIBE](https://duckdb.org/docs/guides/meta/describe) to take a look at the schema of one of the author snapshot files. 

```sql
describe (select * from read_ndjson_auto('s3://openalex/data/authors/updated_date=2023-02-24/part_000.gz'))
```

<details>
<summary>
Results

</summary>

```
┌──────────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─────────┬─────────┬─────────┬─────────┐
│     column_name      │                                                                 column_type                                                                 │  null   │   key   │ default │  extra  │
│       varchar        │                                                                   varchar                                                                   │ varchar │ varchar │ varchar │ varchar │
├──────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┤
│ id                   │ VARCHAR                                                                                                                                     │ YES     │         │         │         │
│ orcid                │ VARCHAR                                                                                                                                     │ YES     │         │         │         │
│ display_name         │ VARCHAR                                                                                                                                     │ YES     │         │         │         │
│ display_name_alter…  │ VARCHAR[]                                                                                                                                   │ YES     │         │         │         │
│ works_count          │ BIGINT                                                                                                                                      │ YES     │         │         │         │
│ cited_by_count       │ BIGINT                                                                                                                                      │ YES     │         │         │         │
│ most_cited_work      │ VARCHAR                                                                                                                                     │ YES     │         │         │         │
│ summary_stats        │ STRUCT("2yr_mean_citedness" DOUBLE, h_index BIGINT, i10_index BIGINT, oa_percent DOUBLE, works_count BIGINT, cited_by_count BIGINT, "2yr_…  │ YES     │         │         │         │
│ affiliations         │ STRUCT(institution STRUCT(id VARCHAR, ror VARCHAR, display_name VARCHAR, country_code VARCHAR, "type" VARCHAR, lineage VARCHAR[]), "years…  │ YES     │         │         │         │
│ ids                  │ STRUCT(openalex VARCHAR, orcid VARCHAR, scopus VARCHAR)                                                                                     │ YES     │         │         │         │
│ last_known_institu…  │ STRUCT(id VARCHAR, ror VARCHAR, display_name VARCHAR, country_code VARCHAR, "type" VARCHAR, lineage VARCHAR[])                              │ YES     │         │         │         │
│ last_known_institu…  │ STRUCT(id VARCHAR, ror VARCHAR, display_name VARCHAR, country_code VARCHAR, "type" VARCHAR, lineage VARCHAR[])[]                            │ YES     │         │         │         │
│ counts_by_year       │ STRUCT("year" BIGINT, works_count BIGINT, oa_works_count BIGINT, cited_by_count BIGINT)[]                                                   │ YES     │         │         │         │
│ x_concepts           │ STRUCT(id VARCHAR, wikidata VARCHAR, display_name VARCHAR, "level" BIGINT, score DOUBLE)[]                                                  │ YES     │         │         │         │
│ works_api_url        │ VARCHAR                                                                                                                                     │ YES     │         │         │         │
│ updated_date         │ DATE                                                                                                                                        │ YES     │         │         │         │
│ created_date         │ DATE                                                                                                                                        │ YES     │         │         │         │
│ updated              │ VARCHAR                                                                                                                                     │ YES     │         │         │         │
├──────────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────────┴─────────┴─────────┴─────────┤
│ 18 rows                                                                                                                                                                                          6 columns |
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

</details>

We can see the parsed data fields and how DuckDB will infer the data types while using the `read_ndjson_auto` function. While inferring the data types is an option, I've found it more useful to be as explicit as possible when parsing JSON source files for this project, especially for some of the nested fields.

### Nested data fields

This [OpenAlex snapshot documentation page](https://docs.openalex.org/download-all-data/upload-to-your-database) makes the distinction between loading data into a cloud data warehouse or into a relational database. When working with nested data structures in DuckDB, we can can choose to load the data as-is into the database and parse the JSON later. Or we can unnest the JSON as we're reading it to speed up later queries and improve efficiency.

To be as explicit as possible (as well as to avoid loading large amounts of `inverted_abstract_index` data specifically from the `works` snapshot files), I've chosen to define [`columns` as a parameter](/models/sources.yml#L14-L30) to include with the `read_ndjson` function along with the data types of those columns. The data types can be found by using the `DESCRIBE` function as used above, or through a method similar to the [one documented here](https://github.com/duckdb/duckdb/discussions/5272).

Whether the data types are defined as the file is being read initially, or later from a raw table loaded into the database as is, it's most efficient to parse the JSON once and only once.

## Download all snapshot files

At this point, we can download all the snapshot files and store them locally so we don't need to pull them from the s3 bucket. There are a few different ways to do this, but the [OpenAlex documentation](https://docs.openalex.org/download-all-data/download-to-your-machine) using the `aws cli` is probably simplest for now.

```sh
aws s3 ls --summarize --human-readable --no-sign-request --recursive "s3://openalex/data/authors/"

aws s3 sync --delete "s3://openalex/data/authors/" "data/authors/" --no-sign-request
```

# Loading snapshot files into a local DuckDB database

We can make use of DuckDB's [COPY](https://duckdb.org/docs/sql/statements/copy.html) or [CREATE TABLE](https://duckdb.org/docs/sql/statements/create_table) commands to insert these downloaded files into a persisted `.duckdb` database that we store locally. Which looks like this when using the DuckDB CLI:

```sql
duckdb open_alex_authors.duckdb

select count(*)
from read_ndjson(
  '~/open_alex_authors/february_2024/data/authors/*/*.gz'
);
```

<details>
<summary>

Query Result

</summary>

```
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│     92840725 │
└──────────────┘
```
</details>

```sql
create table authors
from read_ndjson(
  '~/open_alex_snapshot/february_2024_snapshot/data/authors/*/*.gz',
  columns = {
    id: 'VARCHAR',
    orcid: 'VARCHAR',
    display_name: 'VARCHAR',
    display_name_alternatives: 'VARCHAR[]',
    works_count: 'BIGINT',
    cited_by_count: 'BIGINT',
    most_cited_work: 'VARCHAR',
    ids: 'STRUCT(openalex VARCHAR, orcid VARCHAR, scopus VARCHAR)',
    last_known_institution: 'STRUCT(id VARCHAR, ror VARCHAR, display_name VARCHAR, country_code VARCHAR, type VARCHAR, lineage VARCHAR[])',
    counts_by_year: 'STRUCT(year VARCHAR, works_count BIGINT, oa_works_count BIGINT, cited_by_count BIGINT)[]',
    works_api_url: 'VARCHAR',
    updated_date: 'DATE',
    created_date: 'DATE',
    updated: 'VARCHAR'
  }
  compression='gzip'
);
```

# Using `dbt` and `dbt-duckdb`

## Set up the `dbt` project

### Create `profiles.yml`

With `dbt-duckdb`, we can work using a persisted `.duckdb` database file, using memory, or using MotherDuck, which we'll get to. In our `profiles.yml`, we can create a new profile with `type: duckdb` and [configure any other `settings` or `extensions`](https://github.com/duckdb/dbt-duckdb#duckdb-extensions-settings-and-filesystems) we'll use.

```yaml
open_alex_snapshot:

  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'open_alex_snapshot.duckdb'
      threads: 1
      extensions:
        - httpfs
```

### Create `sources.yml`

We'll define the local copy of our OpenAlex snapshot files as various raw sources, but we could also use the `external_location` meta option with the relevant `read_ndjson` parameters if we're reading files directly from s3 without loading them into a local database. Here's what the `raw_authors` source would look like in `sources.yml`:

```yaml
version: 2

sources:
  - name: open_alex_snapshot
    schema: main
    description: "Latest OpenAlex data snapshot"
    # meta:
    #   external_location: "read_json_auto('s3://openalex/data/authors/updated_date=2023-08-15/*.gz', format='newline_delimited', compression='gzip')"
    tables:
      - name: raw_authors
        meta:
          external_location: >
            read_ndjson('~/open_alex_snapshot/february_2024_snapshot/data/authors/*/*.gz',
            columns = {
              id: 'VARCHAR',
              orcid: 'VARCHAR',
              display_name: 'VARCHAR',
              display_name_alternatives: 'VARCHAR[]',
              works_count: 'BIGINT',
              cited_by_count: 'BIGINT',
              most_cited_work: 'VARCHAR',
              ids: 'STRUCT(openalex VARCHAR, orcid VARCHAR, scopus VARCHAR)',
              last_known_institution: 'STRUCT(id VARCHAR, ror VARCHAR, display_name VARCHAR, country_code VARCHAR, type VARCHAR, lineage VARCHAR[])',
              counts_by_year: 'STRUCT(year VARCHAR, works_count BIGINT, oa_works_count BIGINT, cited_by_count BIGINT)[]',
              works_api_url: 'VARCHAR',
              updated_date: 'DATE',
              created_date: 'DATE',
              updated: 'VARCHAR'
            })
```

### Create models

Once the sources are defined, we can use the [OpenAlex Postgres schema diagram](https://docs.openalex.org/download-all-data/upload-to-your-database/load-to-a-relational-database/postgres-schema-diagram) (with a few modifications) to detail the models that will be created in our `dbt` project. I've set up a few of these as incremental models relying on the `updated_date`, but I haven't seen a great improvement in overall processing as a result from snapshot to snapshot.

### Create outputs

From these models, we can begin to output files (using `dbt-duckdb`'s functionality to [write to external files](https://github.com/duckdb/dbt-duckdb#writing-to-external-files)), or [export the data to parquet](https://duckdb.org/docs/guides/import/parquet_export) or another compressed format, or begin to use a BI tool like [evidence.dev](https://evidence.dev/) to generate reports that will produce analysis about specific parts of the most recent OpenAlex snapshot. 

# Using MotherDuck

At this point, we'll connect to a MotherDuck account and create the database there that already exists locally:

## Creating the local database in MotherDuck

```sql
.open md:
CREATE OR REPLACE DATABASE open_alex_authors FROM 'open_alex_authors.duckdb';
```

### Add MotherDuck profile to dbt

Or if only the snapshot table exists in MotherDuck, we can run our `dbt-duckdb` models against that source, by addng a MotherDuck target (i.e. the `prod` target) in the `profiles.yml` file.

```yaml
open_alex_authors:

  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'open_alex_authors.duckdb'
      threads: 24
      extensions:
        - httpfs
    prod:
      type: duckdb
      path: md:open_alex_authors
```

### Other options

Depending on whether you're looking to sync files locally at all, you could decide to [query and store the OpenAlex files directly from s3](https://motherduck.com/docs/key-tasks/querying-s3-files). Because both OpenAlex and MotherDuck exist in s3 region `us-east-1`, you could choose to use the OpenAlex s3 snapshot location as a source to run your `dbt-duckdb` models and create a MotherDuck database share or generate output files without relying on local storage at all. 

I haven't tested that much and the [cold storage fees](https://motherduck.com/pricing/) may mean storing multiple full snapshots would grow to be prohibitively expensive over time for a hobby project. But that could be mitigated with local storage since MotherDuck will [run hybrid queries](https://motherduck.com/docs/key-tasks/running-hybrid-queries) from the CLI, combining local storage with what exists in the cloud, or only persisting certain aggregations from each snapshot.

## Creating a Share

Once the database is created in MotherDuck, we can also choose to [share the database](https://motherduck.com/docs/key-tasks/managing-shared-motherduck-database/), including the base snapshot table and other models we created from it. 

```sql
CREATE SHARE open_alex_authors_share FROM open_alex_authors
```

So, others can attach and [query the database share](https://motherduck.com/docs/key-tasks/querying-a-shared-motherduck-database).

```sql
ATTACH 'md:_share/open_alex_authors/5d0ef4a6-8f80-4c74-b821-08fda756ca2d'
```

# Next Steps

From here, since different disciplines are cited at different rates, it'd make sense to start parsing the `topics` fields to explore which authors and which institutions are most highly cited within a given [topic](https://docs.openalex.org/api-entities/topics) so we can begin to track how those within top percentages change over time from snapshot to snapshot.

# Read More:

[1]: https://www.leidenmadtrics.nl/articles/an-open-approach-for-classifying-research-publications "An open approach for classifying research publications"

[2]: https://motherduck.com/docs/getting-started/connect-query-from-python/installation-authentication/ "Authenticating to MotherDuck"

[3]: https://motherduck.com/blog/motherduck-duckdb-dbt/ "MotherDuck + dbt: Better Together"

[4]: https://docs.openalex.org/download-all-data/snapshot-data-format "OpenAlex Snapshot Data Format"

[5]: https://www.leidenmadtrics.nl/articles/opening-up-the-cwts-leiden-ranking-toward-a-decentralized-and-open-model-for-data-curation "Opening up the CWTS Leiden Ranking: Toward a decentralized and open model for data curation"

[5]: https://motherduck.com/docs/key-tasks/querying-s3-files "Querying files in S3"

[6]: https://duckdb.org/2023/03/03/json "Shredding Deeply Nested JSON, One Vector at a Time"

[7]: https://github.com/duckdb/dbt-duckdb#using-motherduck "Using MotherDuck with `dbt-duckdb`"

[8]: https://bnm3k.github.io/blog/wrangling-json-with-duckdb "Wrangling JSON with DuckDB"
