import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.auth import APIKeyAuth
from dlt.sources.helpers.rest_client.paginators import OffsetPaginator


@dlt.source
def nyc_open_data_source(
    nyc_open_data_app_token=dlt.secrets["sources.rest_api.nyc_open_data_app_token"],
):
    auth = APIKeyAuth(
        name="X-App-Token", api_key=nyc_open_data_app_token, location="header"
    )
    client = RESTClient(
        base_url="https://data.cityofnewyork.us/resource/",
        paginator=OffsetPaginator(
            limit=1000,  # The maximum number of items to retrieve in each request.
            offset=0,  # The initial offset for the first request. Defaults to 0.
            offset_param="$offset",  # The name of the query parameter used to specify the offset. Defaults to "offset".
            limit_param="$limit",  # The name of the query parameter used to specify the limit. Defaults to "limit".
            total_path=None,  # A JSONPath expression for the total number of items. If not provided, pagination is controlled by maximum_offset and stop_after_empty_page.
            maximum_offset=1000,  # Optional maximum offset value. Limits pagination even without a total count.
            stop_after_empty_page=True,  # Whether pagination should stop when a page contains no result items. Defaults to True.
        ),
        auth=auth,
    )

    @dlt.resource(write_disposition="replace")
    def nyc_311_service_requests():
        for page in client.paginate("erm2-nwe9"):
            yield page

    @dlt.resource(write_disposition="replace")
    def hpd_complaints():
        """
        The Department of Housing Preservation and Development (HPD) records complaints made by the public
        for conditions violating the New York City Housing Maintenance Code (HMC)
        or the New York State Multiple Dwelling Law (MDL).
        """
        for page in client.paginate("ygpa-z7cr"):
            yield page

    return [hpd_complaints]


def load_nyc_open_data_source():
    pipeline = dlt.pipeline(
        pipeline_name="nyc_open_data_pipeline",
        destination="filesystem",
        dataset_name="nyc_open_data",
        progress="log",
    )
    pipeline.run(nyc_open_data_source(), loader_file_format="parquet")


if __name__ == "__main__":
    load_nyc_open_data_source()
