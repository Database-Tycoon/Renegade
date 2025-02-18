import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.auth import APIKeyAuth
from dlt.sources.helpers.rest_client.paginators import OffsetPaginator
from datetime import datetime
from zoneinfo import ZoneInfo
import argparse


@dlt.source
def nyc_open_data_source(
    # nyc_open_data_app_token=dlt.secrets["sources.rest_api.nyc_open_data_app_token"],
    backfill=False,
    start_date=None,
    end_date=None,
    current_month=False,
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

    @dlt.resource(write_disposition="append", table_format="iceberg")
    def hpd_complaints():
        """
        The Department of Housing Preservation and Development (HPD) records complaints made by the public
        for conditions violating the New York City Housing Maintenance Code (HMC)
        or the New York State Multiple Dwelling Law (MDL).

        This resource supports these loading modes:
        - Current Month: When --current-month flag is used, loads complaints that have been updated or newly added during the current month
        - Date Range: When --start-date and --end-date are provided, loads data that have been updated or newly added within the specified date range
        - Historical: When --backfill flag is used, loads the complete historical dataset
        """

        params = {}
        if backfill:
            pass  # No filtering needed for backfill
        elif current_month:
            current_time = datetime.now(ZoneInfo("America/New_York"))
            current_month_str = current_time.strftime("%Y-%m")
            params["$where"] = (
                f"date_trunc_ym(received_date) = '{current_month_str}' OR "
                f"date_trunc_ym(problem_status_date) = '{current_month_str}' OR "
                f"date_trunc_ym(complaint_status_date) = '{current_month_str}'"
            )
        elif start_date and end_date:
            params["$where"] = (
                f"(date_trunc_ymd(received_date) >= '{start_date}' AND date_trunc_ymd(received_date) <= '{end_date}') OR "
                f"(date_trunc_ymd(problem_status_date) >= '{start_date}' AND date_trunc_ymd(problem_status_date) <= '{end_date}') OR "
                f"(date_trunc_ymd(complaint_status_date) >= '{start_date}' AND date_trunc_ymd(complaint_status_date) <= '{end_date}')"
            )
        else:
            raise ValueError(
                "Must specify either --backfill, --current-month, or both --start-date and --end-date"
            )

        for page in client.paginate("ygpa-z7cr", params=params):
            yield page

    return [hpd_complaints]


def load_nyc_open_data_source(
    backfill=False, start_date=None, end_date=None, current_month=False
):
    pipeline = dlt.pipeline(
        pipeline_name="nyc_open_data_pipeline",
        destination="filesystem",
        dataset_name="nyc_open_data",
        progress="log",
    )
    pipeline.run(
        nyc_open_data_source(
            backfill=backfill,
            start_date=start_date,
            end_date=end_date,
            current_month=current_month,
        ),
        loader_file_format="parquet",
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--backfill",
        action="store_true",
        help="Run in backfill mode to load all historical data",
    )
    parser.add_argument(
        "--current-month",
        action="store_true",
        help="Load data for the current month",
    )
    parser.add_argument(
        "--start-date",
        help="Start date for date range ingestion (format: YYYY-MM-DD)",
    )
    parser.add_argument(
        "--end-date",
        help="End date for date range ingestion (format: YYYY-MM-DD)",
    )
    args = parser.parse_args()

    if (
        sum(
            [args.backfill, args.current_month, bool(args.start_date and args.end_date)]
        )
        != 1
    ):
        raise ValueError(
            "Must specify exactly one mode: --backfill, --current-month, or both --start-date and --end-date"
        )

    load_nyc_open_data_source(
        backfill=args.backfill,
        start_date=args.start_date,
        end_date=args.end_date,
        current_month=args.current_month,
    )
