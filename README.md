# Renegade

## Instructions

1. Create a new virtual environment: 

    ```
    python -m venv .venv
    source .venv/bin/activate
    ```
2. Install dependencies: 

    ```
    pip install -r requirements.txt
    ```
**Recommend using a version of python >= 3.8.1 and < 3.13 for compatibility with `dlt[filesystem]==1.5.0`.**  

3. Configure Environment Variables:
- Create a `.env` file in the root directory:
    ```
    cp env.example .env
    ```
- Update the following variables in `.env`:
  - AWS credentials (if using S3)
  - NYC Open Data app token (optional for development)
  - Other environment-specific settings

4. (Optional) Configure DLT Secrets (if you configure the .env file, you don't need to do this step):
- If you prefer using DLT's secrets.toml configuration:
    ```
    cd dlt
    cp .dlt/secrets.example .dlt/secrets.toml
    ```
- Make sure the file is located in `Renegade/dlt/.dlt/secrets.toml`
- Add secrets like aws credentials, nyc open data app token, etc.
- You can change the `bucket_url` to your local directory for testing purposes. In which case, you don't need to specify the aws credentials.

5. Run the DLT Pipeline:
- By default, the following command will run the pipeline in incremental mode:
    ```
    python dlt/nyc_open_data_pipeline.py --current-month
    ```
- For historical data backfill:
    ```
    python dlt/nyc_open_data_pipeline.py --backfill
    ```
- For specific date ranges:
    ```
    python dlt/nyc_open_data_pipeline.py --start-date YYYY-MM-DD --end-date YYYY-MM-DD
    ```

6. Check pipeline info:
    ```
    dlt pipeline nyc_open_data_pipeline info
    ``` 
    or 
    ```
    dlt pipeline nyc_open_data_pipeline show
    ``` 
    to use streamlit

## SQLMesh

[SQLMesh](https://sqlmesh.com/) is used for data transformation and modeling. To run the SQLMesh portion:

1. Ensure you have the DLT pipeline data loaded (either locally or in S3)

2. Navigate to the sqlmesh directory:
    ```
    cd sqlmesh
    ```

3. Run SQLMesh in dev mode to plan the changes:
    ```
    sqlmesh plan dev
    ```
   This will create the transformed tables in your configured data warehouse.
4. Run SQLMesh in prod mode to apply the changes:
    ```
    sqlmesh plan prod
    ```

5. To view the model documentation and lineage:
    ```
    sqlmesh ui
    ```
   This will start the SQLMesh UI at `localhost:8000`

## Evidence
[Evidence](https://evidence.dev/) is a lightweight BI tool used to make visualizations.

To view the markdown files in this repo, you need to:
1. Have Docker installed and running on your machine.
2. Have run sqlmesh and generated the models/data in your `nycdata.db` file.
3. Run `docker compose up evidence` to spin up the server.

This should spin up the server at `localhost:3000` and show Evidence's `index.md` page.  

Refer to the [official documentation](https://docs.evidence.dev/) for more information.

## Cube
[Cube](https://cube.dev/) is a universal semantic layering platform.

[Here](https://cube.dev/docs/product/getting-started/core/create-a-project) is the official documentation to get started with Cube.

Renegade already has a cube project folder containing basic configurations and model cubes for the NYC Open Data dataset as a duckdb source. Please note you will need to have Docker installed and running on your machine. 

If you're running the project locally, here's how to get started:
1. Run the nyc_open_data_pipeline.py script with duckdb as the destination to generate some data in the nyc_open_data_pipeline.duckdb file in the RENEGADE root directory.
2. run `docker compose up cube` to start the cube server.
3. navigate to `localhost:4000` in your browser to view the cube dashboard.

And that's it! You can edit the models from the cube dashboard and the changes you make will be reflected in the `cube/model` directory, or you can edit the files directly in `cube/model`.

To set the project up to use source data stored in s3, you will need to configure the `cube/.env` file with the appropriate AWS credentials and bucket url.
1. Create a `.env` file in the cube directory.
2. Add the following to the `.env` file:
```
CUBEJS_DB_DUCKDB_S3_ACCESS_KEY_ID=[your_aws_access_key_id]
CUBEJS_DB_DUCKDB_S3_SECRET_ACCESS_KEY=[your_aws_secret_access_key]
CUBEJS_DB_DUCKDB_S3_ENDPOINT=[s3_endpoint]
CUBEJS_DB_DUCKDB_S3_REGION=[s3_region]
```
3. Update the `CUBEJS_DB_DUCKDB_DATABASE_PATH` environment variable in the docker-compose.yml file to reflect the s3 path to the nyc_open_data_pipeline.duckdb file.