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

3. Navigate in to the `dlt` folder:
```
cd dlt
```
4. Configure Secrets:
- Create a `secrets.toml` file in the `.dlt` directory.
```
cp .dlt/secrets.example .dlt/secrets.toml
```
- Make sure the file is located in `Renegade/dlt/.dlt/secrets.toml`.
- Add secrets like aws credentials, nyc open data app token, etc.
- You can change the `bucket_url` to your local directory for testing purposes. In which case, you don't need to specify the aws credentials.
- You also don't need to specify the nyn api token for development. You only need it to limit the API call limit.


5. Run the pipeline. If you want to run it for testing purposes, modify the `maximum_offset` to limit the data for pagination. 
```
python nyc_open_data_pipeline.py
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

### Evidence
[Evidence](https://evidence.dev/) is a lightweight BI tool used to make visualizations.

To view the markdown files in this repo, you need to have run sqlmesh and generated the models/data in your `nycdata.db` file. Once this is done, you can:
1. `npm install`  
2. `npm run sources` (in the `evidence/` subdirectory)  
3. `npm run dev`  
This should spin up the server at `localhost:3000` and show Evidence's `index.md` page.  

Refer to the [official documentation](https://docs.evidence.dev/) for more information.

### Cube
[Cube](https://cube.dev/) is a universal semantic layering platform.

[Here](https://cube.dev/docs/product/getting-started/core/create-a-project) is the official documentation to get started with Cube.

Renegade already has a cube project folder containing basic configuraitons and model cubes for the NYC Open Data dataset as a duckdb source. Please note you will need to have Docker installed and running on your machine. 

If you're running the project locally, here's how to get started:
1. Run the nyc_open_data_pipeline.py script with duckdb as the destination to generate some data in the nyc_open_data_pipeline.duckdb file in the RENEGADE root directory.
2. run `cd cube` to navigate to the cube directory.
3. run `docker-compose up` to start the cube server.
4. navigate to `localhost:4000` in your browser to view the cube dashboard.

And that's it! You can edit the models from the cube dashboard and the changes you make will be reflected in the `cube/model` directory, or you can edit the files directly in `cube/model`.

To set the project up to use source data stored in s3, you will need to convigure the `cube/.env` file with the appropriate AWS credentials and bucket url.
1. Create a `.env` file in the cube directory.
2. Add the following to the `.env` file:
```
CUBEJS_DB_DUCKDB_S3_ACCESS_KEY_ID=[your_aws_access_key_id]
CUBEJS_DB_DUCKDB_S3_SECRET_ACCESS_KEY=[your_aws_secret_access_key]
CUBEJS_DB_DUCKDB_S3_ENDPOINT=[s3_endpoint]
CUBEJS_DB_DUCKDB_S3_REGION=[s3_region]
```
3. Update the `CUBEJS_DB_DUCKDB_DATABASE_PATH` environment variable in the docker-compose.yml file to reflect the s3 path to the nyc_open_data_pipeline.duckdb file.