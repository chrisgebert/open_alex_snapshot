# Contents

- [About This Project](#about-this-project)
- [Exploratory Analysis](#exploratory-analysis)
- [Loading Snapshot Files into a Local DuckDB Database](#loading-snapshot-files-into-a-local-duckdb-database)
- [Develop Our Analysis](#develop-our-analysis)
- [Using `dbt` and `dbt-duckdb`](#using-dbt-and-dbt-duck)
- [Using MotherDuck](#using-motherduck)
- [Next Steps](#next-steps)
- [Read More](#read-more)

# About This Project

First, a little background:

## OpenAlex

[OurResearch](https://ourresearch.org) came to the rescue with [OpenAlex](https://openalex.org) after Microsoft announced it would end its support for [Microsoft Academic Graph (MAG)](https://www.microsoft.com/en-us/research/project/microsoft-academic-graph/) at the end of 2021. 

In a short amount of time, OpenAlex started compiling data related to academic publications (e.g. works, authors, publications, institutions, etc.). They stood up an API and documentation and made this data available to the community at no charge.

In addition, they began releasing regular data snapshots in [s3](https://registry.opendata.aws/openalex/) for those who have needs outside of what's provided by the API. The snapshots are released monthly, and the August author data snapshot from this year [included an improved author disambiguation feature](https://groups.google.com/g/openalex-users/c/yRgoy2oD2f8/m/iXfGguhQBgAJ), which can be a [thorny problem to solve](https://docs.openalex.org/api-entities/authors/author-disambiguation).

## DuckDB, and friends (`dbt-duckdb` and MotherDuck)

### DuckDB

[DuckDB](https://duckdb.org) is an in-process analytic database that's come on the scene in the past few years that looks like it could change a lot of workflows. It's fast, it's designed to be embedded, but you can choose to persist a database if you want to.

### `dbt-duckdb`

[`dbt-duckdb`](https://github.com/duckdb/dbt-duckdb) is a dbt adapter built for use with DuckDB (and also, recently MotherDuck) so we can:
1. create a single data source from all the most recent OpenAlex snapshot files, and 
2. build a dbt project on top of it, allowing us to make use of all the great things about [`dbt`](https://www.getdbt.com/), like testing and macros and packages created by that community.

### MotherDuck

[MotherDuck](https://motherduck.com) is a serverless instance of DuckDB in the cloud.

I was [granted access to the beta](https://jawns.club/@cgebert/110714745527510396) a little while ago (though they've recently announced they're welcoming sign-ups from anyone), and the timing has been perfect to play around with this and see what I can do using the recent improved author snapshot files from OpenAlex.

### Note

Importantly: OpenAlex and MotherDuck both use s3 region `us-east-1` so the data won't be moving between regions. We can explore the OpenAlex snapshots directly from s3 using a local instance of `duckdb` and `dbt-duckdb` too; we'll just need to `set s3_region` in either to access the snapshot data files. 

# Exploratory Analysis

For our exploratory analysis, we can follow the [OpenAlex documentation to download all the snapshot files](https://docs.openalex.org/download-all-data/download-to-your-machine) to our machine, or alternatively, we can use DuckDB to query one or more of those file directly without downloading them first.

For now, we'll query [just one of the files using the file path](https://docs.openalex.org/download-all-data/snapshot-data-format#the-manifest-file) from the [most recent manifest](https://openalex.s3.amazonaws.com/data/authors/manifest), and once we're more familiar with the data model, we'll grab all the files that make up the snapshot. 

## Review a snapshot data file using DuckDB

We'll need to first install and load the `httpfs` extension to use DuckDB to read one or more snapshot files into memory. Which looks like this in python:

```python
import duckdb

duckdb.sql("install 'httpfs'; load 'httpfs';")

duckdb.sql("select * from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-07-21/part_000.gz', format='newline_delimited', compression='gzip')")
```

<details>
<summary>
Query Results

</summary>

```
┌──────────────────────┬──────────────────────┬────────────────┬───┬──────────────┬─────────────┬────────────┐
│      x_concepts      │ display_name_alter…  │ cited_by_count │ … │ created_date │ works_count │  updated   │
│ struct(score doubl…  │      varchar[]       │     int64      │   │     date     │    int64    │    date    │
├──────────────────────┼──────────────────────┼────────────────┼───┼──────────────┼─────────────┼────────────┤
│ [{'score': 100.0, …  │ [J W Chappell, JB …  │           1840 │ … │ 2023-07-21   │           3 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Runa Patel]         │           1293 │ … │ 2023-07-21   │           1 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Basket-Late Inves…  │           1273 │ … │ 2023-07-21   │           1 │ 2023-07-21 │
│ [{'score': 41.7, '…  │ [Syaiful Bahri Dja…  │           1269 │ … │ 2023-07-21   │          12 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [L McVay-Boudreau]   │           1233 │ … │ 2023-07-21   │           7 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [E. Y. Chen]         │           1207 │ … │ 2023-07-21   │           2 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Sven-Erik Torhell]  │           1176 │ … │ 2023-07-21   │           1 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [D. B. Payne]        │           1079 │ … │ 2023-07-21   │           1 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Gard Pd]            │           1061 │ … │ 2023-07-21   │           4 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Frank Ostrander]    │           1057 │ … │ 2023-07-21   │           1 │ 2023-07-21 │
│          ·           │        ·             │             ·  │ · │     ·        │           · │     ·      │
│          ·           │        ·             │             ·  │ · │     ·        │           · │     ·      │
│          ·           │        ·             │             ·  │ · │     ·        │           · │     ·      │
│ [{'score': 100.0, …  │ [David Menapace]     │            173 │ … │ 2023-07-21   │           1 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Jenny Matilde Gui…  │            173 │ … │ 2023-07-21   │           1 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Ah-Keng Kau]        │            173 │ … │ 2023-07-21   │           2 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Y. Ye]              │            173 │ … │ 2023-07-21   │           1 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Jih Fei Cheng]      │            172 │ … │ 2023-07-21   │           1 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [M.-C. Hameau, M.C…  │            172 │ … │ 2023-07-21   │           4 │ 2023-07-21 │
│ [{'score': 50.0, '…  │ [John Jukes]         │            172 │ … │ 2023-07-21   │           2 │ 2023-07-21 │
│ [{'score': 87.5, '…  │ [M. Eccleston, M E…  │            172 │ … │ 2023-07-21   │           8 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Lawn Sd]            │            172 │ … │ 2023-07-21   │           4 │ 2023-07-21 │
│ [{'score': 100.0, …  │ [Jyunichi Kajiwara]  │            172 │ … │ 2023-07-21   │           4 │ 2023-07-21 │
├──────────────────────┴──────────────────────┴────────────────┴───┴──────────────┴─────────────┴────────────┤
│ ? rows (>9999 rows, 20 shown)                                                         16 columns (6 shown) │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

</details>

In this example, DuckDB read the compressed json file of 492 MB from s3 into an object in memory in about 10 seconds. 

## Get a small sample of the records in these snapshot files to explore the data model

Let's limit the total number of records we're looking at just to understand what each of these fields contain and write the results to a `pandas` dataframe.

```python
import duckdb
import pandas as pd

df = duckdb.sql("select * from read_json_auto('https://openalex.s3.amazonaws.com/data/authors/updated_date%3D2023-07-21/part_000.gz', format='newline_delimited', compression='gzip') limit 100").df()

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

This helps us understand what's available in further exploration in a single snapshot instance, or if we're interested how things change from one snapshot file to the next over time.

From here, it's simplest to follow the [OpenAlex documentation](https://docs.openalex.org/download-all-data/download-to-your-machine) and use the `aws cli` commands to sync all the author snapshot files to a local directory, which were about 28GB and 105 files total in the latest snapshot. 

```sh
aws s3 ls --summarize --human-readable --no-sign-request --recursive "s3://openalex/data/authors/"

aws s3 sync --delete "s3://openalex/data/authors/" "data/authors/" --no-sign-request
```

# Loading Snapshot Files into a Local DuckDB Database

We can make use of DuckDB's [COPY](https://duckdb.org/docs/sql/statements/copy.html) or [CREATE TABLE](https://duckdb.org/docs/sql/statements/create_table) commands to insert these downloaded files into a persisted `.duckdb` database that we store locally. Which looks like this when using the DuckDB CLI:

```sql
duckdb open_alex_authors.duckdb

select count(*)
from read_json_auto(
  '~/open_alex_authors/data/authors/*/*.gz',
  format='newline_delimited',
  compression='gzip'
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
create table september_2023_snapshot
from read_json_auto(
  '~/open_alex_authors/data/authors/*/*.gz',
  format='newline_delimited',
  compression='gzip'
);
```

The benefit of loading the data into the database using DuckDB at this step is that we can bypass the need to run python scripts to flatten the compressed json source files into CSVs. We can unnest the nested JSON fields later if we decide those are valuable to our analysis, but this method will better mirror the data as it existed at the time of its extraction in its original form and may even allow us to start diving into the specifics of the snapshot sooner.

# Develop Our Analysis

## Revise our queries to begin analysis and modeling

Let's say we'd like to focus only on those authors who have been cited. (Nothing against those who haven't been cited of course; bibliometric analysis uses with the currency of citations that are available.)

We could define a stage table of those `author_ids` like this:

```sql
select
  id as author_id
from september_2023_snapshot
where cited_by_count != 0;
```

Or let's say we want to start unnesting the `counts_by_year` array to get discrete citation counts for a particular year.

```sql
select
  id as author_id,
  unnest(counts_by_year, recursive := true)
from september_2023_snapshot;
```

Or extracting the `display_name` of the `last_known_institution` dict.

```sql
select
  id as author_id,
  display_name, 
  json_extract(last_known_institution, '$.display_name'),
  works_count, 
  cited_by_count
from september_2023_snapshot
where cited_by_count > 10;
```

# Using `dbt` and `dbt-duck`

## Create a `dbt` project from our analysis

Once we have identified and developed the queries we're interested in tracking from snapshot to snapshot, we can build a `dbt` project that uses OpenAlex database snapshots as a source to materialize actual tables to perform ongoing analysis and even output files, using `dbt-duckdb`.

### Create `profiles.yml`

With `dbt-duckdb`, we can work using a persisted `.duckdb` database file, using memory, or using MotherDuck, which we'll get to. In our `profiles.yml`, we can create a new profile with `type: duckdb` and [configure any other `settings` or `extensions`](https://github.com/duckdb/dbt-duckdb#duckdb-extensions-settings-and-filesystems) we'll use, like `httpfs` if necessary.

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
```

### Create `sources.yml`

We'll use the local copy of our DuckDB database as the source, but we could also use the `external_location` meta option with the relevant `read_json_auto` parameters if we're reading files directly from s3 without loading them into a local database.

```yaml
version: 2

sources:
  - name: open_alex_authors
    schema: main
    description: "Latest OpenAlex author data snapshot"
    # meta:
    #   external_location: "read_json_auto('s3://openalex/data/authors/updated_date=2023-08-15/*.gz', format='newline_delimited', compression='gzip')"
    tables:
      - name: september_2023_snapshot
```

### Create models

We can define stage models (e.g `stg_authors_cited.sql`, `stg_authors_concepts_cited.sql`, or `stg_counts_by_year.sql`), or intermediate models, or aggregation models (like `number_of_authors.sql`) using `dbt`.

```sh
dbt run --select stg_authors_cited stg_authors_concepts_cited stg_counts_by_year number_of_authors
```

<details>
<summary>

`dbt run`

</summary>

```
(open_alex_authors) M20 :: projects/open_alex_authors » dbt run --select stg_authors_cited stg_authors_concepts_cited stg_counts_by_year number_of_authors
01:20:20  Running with dbt=1.5.2
01:20:21  Registered adapter: duckdb=1.5.2
01:20:21  Unable to do partial parsing because a project config has changed
01:20:21  Found 4 models, 0 tests, 0 snapshots, 0 analyses, 316 macros, 0 operations, 0 seed files, 1 source, 0 exposures, 0 metrics, 0 groups
01:20:21  
01:20:22  Concurrency: 24 threads (target='dev')
01:20:22  
01:20:22  1 of 4 START sql table model main.stg_authors_cited ............................ [RUN]
01:20:22  2 of 4 START sql table model main.stg_counts_by_year ........................... [RUN]
01:20:37  1 of 4 OK created sql table model main.stg_authors_cited ....................... [OK in 15.59s]
01:20:37  3 of 4 START sql table model main.stg_authors_concepts_cited ................... [RUN]
01:27:18  2 of 4 OK created sql table model main.stg_counts_by_year ...................... [OK in 415.90s]
01:27:18  4 of 4 START sql table model main.number_of_authors ............................ [RUN]
01:39:48  4 of 4 OK created sql table model main.number_of_authors ....................... [OK in 750.45s]
01:48:42  3 of 4 OK created sql table model main.stg_authors_concepts_cited .............. [OK in 1684.83s]
01:48:42  
01:48:42  Finished running 4 table models in 0 hours 28 minutes and 20.97 seconds (1700.97s).
01:48:43  
01:48:43  Completed successfully
01:48:43  
01:48:43  Done. PASS=4 WARN=0 ERROR=0 SKIP=0 TOTAL=4
```
</details>


### Create outputs

From these models, we can begin to output files (using `dbt-duckdb`'s functionality to [write to external files](https://github.com/duckdb/dbt-duckdb#writing-to-external-files)), or [export the data to parquet]() or another compressed format, or begin to use a BI tool like [Evidence.dev](https://evidence.dev/) to generate reports that will produce analysis about specific parts of the most recent OpenAlex snapshot. 

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

From here, since different disciplines are cited at different rates, it'd make sense to start parsing the `x_concepts` fields to explore which authors and which institutions are most highly cited within a given [concept](https://docs.openalex.org/api-entities/concepts/concept-object) so we can begin to track how those within top percentages change over time from snapshot to snapshot.

# Read More:

- Authenticating to MotherDuck: https://motherduck.com/docs/getting-started/connect-query-from-python/installation-authentication/

- MotherDuck + dbt: Better Together: https://motherduck.com/blog/motherduck-duckdb-dbt/

- OpenAlex Snapshot Data Format: https://docs.openalex.org/download-all-data/snapshot-data-format

- Querying files in S3: https://motherduck.com/docs/key-tasks/querying-s3-files

- Using MotherDuck with `dbt-duckdb`: https://github.com/duckdb/dbt-duckdb#using-motherduck
