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
   - Add the following configuration to the `secrets.toml` file:
     ```toml
     # put your secret values and credentials here. do not share this file and do not push it to github

     [destination.filesystem]
     bucket_url = "s3://proj-renegade" 

     [destination.filesystem.credentials]
     aws_access_key_id = "YOUR_AWS_KEY_ID"
     aws_secret_access_key = "YOUR_AWS_SECRET_ACCESS_KEY"


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