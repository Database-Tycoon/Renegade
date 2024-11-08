import dlt
import duckdb
from dlt.sources.rest_api import rest_api_source
from dlt.sources.helpers.rest_client.paginators import OffsetPaginator
from dlt.sources.helpers.rest_client.auth import APIKeyAuth


def load_nyc_311_service_requests():
    auth = APIKeyAuth(
        name="X-API-Key",
        api_key=dlt.secrets["sources.rest_api.nyc_opendata_app_token"],
        location="header",
    )

    source = rest_api_source(
        {
            "client": {
                "base_url": "https://data.cityofnewyork.us/resource/",
                "paginator": OffsetPaginator(
                    limit=1000,
                    offset=0,
                    # if I don't set maximum_offset, then dlt keeps going until blank value returned. 
                    # for testing, you can do something like: 
                    maximum_offset=1000,
                    total_path=None,
                    offset_param="$offset",
                    limit_param="$limit",
                    stop_after_empty_page=True,
                ),
                "auth": auth,
            },
            "resource_defaults": {
                "primary_key": "unique_key",
                "write_disposition": "replace",
            },
            "resources": [
                {
                    "name": "service_requests",
                    "endpoint": {
                        "path": "erm2-nwe9",
                    },
                },
            ],
        }
    )

    pipeline = dlt.pipeline(
        pipeline_name="nyc_open_data",
        destination="duckdb",
        dataset_name="service_requests",
    )

    load_info = pipeline.run(source)
    print(load_info)


if __name__ == "__main__":
    load_nyc_311_service_requests()
