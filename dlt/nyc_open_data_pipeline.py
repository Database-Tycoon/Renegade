import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.auth import APIKeyAuth
from dlt.sources.helpers.rest_client.paginators import OffsetPaginator
from dlt.destinations import filesystem
from datetime import datetime
from zoneinfo import ZoneInfo
import argparse


@dlt.source
def nyc_open_data_source(
    # nyc_open_data_app_token=dlt.secrets["sources.rest_api.nyc_open_data_app_token"],
    backfill=False,
):
    # auth = APIKeyAuth(
    #     name="X-App-Token", api_key=nyc_open_data_app_token, location="header"
    # )
    client = RESTClient(
        base_url="https://data.cityofnewyork.us/resource/",
        paginator=OffsetPaginator(
            limit=100_000,  # The maximum number of items to retrieve in each request.
            offset=0,  # The initial offset for the first request. Defaults to 0.
            offset_param="$offset",  # The name of the query parameter used to specify the offset. Defaults to "offset".
            limit_param="$limit",  # The name of the query parameter used to specify the limit. Defaults to "limit".
            total_path=None,  # A JSONPath expression for the total number of items. If not provided, pagination is controlled by maximum_offset and stop_after_empty_page.
            # maximum_offset=1000,  # Optional maximum offset value. Limits pagination even without a total count.
            stop_after_empty_page=True,  # Whether pagination should stop when a page contains no result items. Defaults to True.
        ),
        # auth=auth,
    )

    @dlt.resource(write_disposition="replace")
    def nyc_311_service_requests():
        """
        This resource is NOT being used currently. 
        """
        for page in client.paginate("erm2-nwe9"):
            yield page

    @dlt.resource(write_disposition="append")
    def hpd_complaints():
        """
        The Department of Housing Preservation and Development (HPD) records complaints made by the public
        for conditions violating the New York City Housing Maintenance Code (HMC)
        or the New York State Multiple Dwelling Law (MDL).

        This resource supports two loading modes:
        - Incremental: When backfill=False (default), only loads complaints from the current month
          based on received_date, problem_status_date, or complaint_status_date
        - Historical: When backfill=True, loads the complete historical dataset
        """

        params = {}
        if not backfill:
            current_time = datetime.now(ZoneInfo("America/New_York"))
            current_month = current_time.strftime(
                "%Y-%m"
            )  # This will output like "2024-02"

            params["$where"] = (
                f"date_trunc_ym(received_date) = '{current_month}' or "
                f"date_trunc_ym(problem_status_date) = '{current_month}' or "
                f"date_trunc_ym(complaint_status_date) = '{current_month}'"
            )

        for page in client.paginate("ygpa-z7cr", params=params):
            yield page

    return [hpd_complaints]


def load_nyc_open_data_source(backfill=False):
    pipeline = dlt.pipeline(
        pipeline_name="nyc_open_data_pipeline",
        destination=filesystem(
            layout="{table_name}/historical/loaded_on_{YYYY}_{MM}_{DD}/{load_id}.{file_id}.{ext}"
            if backfill
            else "{table_name}/incremental/{YYYY}/{MM}/{load_id}.{file_id}.{ext}",
        ),
        dataset_name="nyc_open_data",
        progress="log",
    )
    pipeline.run(nyc_open_data_source(backfill=backfill), loader_file_format="parquet")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--backfill",
        action="store_true",
        help="Run in backfill mode to load all historical data",
    )
    args = parser.parse_args()

    load_nyc_open_data_source(backfill=args.backfill)
