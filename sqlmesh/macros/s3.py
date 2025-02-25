from sqlmesh import macro
import os
from sqlmesh.core.macros import macro, MacroEvaluator
from sqlglot import exp
import typing as t
import duckdb
import boto3
from urllib.parse import urlparse
from pathlib import Path

if os.environ.get("APP_ENV") != "prod":
    from dotenv import load_dotenv

    load_dotenv()

def _get_duckdb_connection() -> duckdb.DuckDBPyConnection:
    """
    Establishes a connection to the DuckDB database.

    Returns:
        duckdb.DuckDBConnection: A connection to the DuckDB database.
    """
    db_path = Path("../data/nycdata.db")
    return duckdb.connect(database=str(db_path))


def _setup_duckdb() -> None:
    """
    Sets up the DuckDB database by installing and loading HTTPFS and Iceberg extensions,
    and creating a persistent secret for S3 access.
    """
    conn = _get_duckdb_connection()
    conn.sql("INSTALL httpfs;")
    conn.sql("LOAD httpfs;")
    conn.sql("INSTALL iceberg;")
    conn.sql("LOAD iceberg;")
    sql_query = f"""
    CREATE PERSISTENT SECRET IF NOT EXISTS s3_secret (
        TYPE S3,
        KEY_ID '{os.environ.get("AWS_ACCESS_KEY_ID")}',
        SECRET '{os.environ.get("AWS_SECRET_ACCESS_KEY")}',
        REGION '{os.environ.get("AWS_DEFAULT_REGION")}'
    );
    """
    conn.sql(sql_query)
    conn.close()


def _parse_s3_url(url: str) -> tuple[str, str]:
    """Parse S3 URL into bucket name and prefix.

    Args:
        url: S3 URL (e.g. 's3://bucket/prefix/path')

    Returns:
        tuple: (bucket_name, prefix)
    """
    parsed = urlparse(url.rstrip("/"))
    return parsed.netloc, parsed.path.lstrip("/")


def _build_s3_path(*parts: str) -> str:
    """Build S3 path by joining parts with forward slashes.

    Args:
        *parts: Path parts to join

    Returns:
        str: Joined path with forward slashes
    """
    return "/".join(p.strip("/") for p in parts if p)


def _get_latest_metadata_path(data_source: str, dataset_name: str) -> str:
    """Find the latest metadata JSON file in the specified S3 path.

    Args:
        data_source: Source of the data (e.g. 'nyc_open_data')
        dataset_name: Name of the dataset (e.g. 'hpd_complaints')

    Returns:
        str: Full S3 path to the latest metadata JSON file

    Raises:
        ValueError: If no metadata files are found or if there's an error accessing S3
        EnvironmentError: If S3_BUCKET_URL is not set
    """
    bucket_url = os.environ.get("S3_BUCKET_URL")
    if not bucket_url:
        raise EnvironmentError("S3_BUCKET_URL environment variable is not set")

    bucket_name, base_prefix = _parse_s3_url(bucket_url)
    prefix = _build_s3_path(base_prefix, data_source, dataset_name, "metadata")

    try:
        s3_client = boto3.client("s3")
        response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=prefix)

        metadata_files = [
            obj["Key"]
            for obj in response.get("Contents", [])
            if obj["Key"].endswith(".metadata.json")
        ]

        if not metadata_files:
            raise ValueError(f"No metadata files found in s3://{bucket_name}/{prefix}")

        latest_file = sorted(metadata_files, reverse=True)[0]
        return f"s3://{bucket_name}/{latest_file}"

    except Exception as e:
        raise ValueError(
            f"Error accessing S3 path s3://{bucket_name}/{prefix}: {str(e)}"
        )


@macro()
def get_s3_iceberg_file_path(
    evaluator: t.Any, data_source: str, dataset_name: str
) -> exp.Literal:
    """Generate S3 path for reading data from the landing zone.

    Args:
        evaluator: SQLMesh macro evaluator
        dataset_name: Dataset name (e.g. 'hpd_complaints')

    Returns:
        S3 path as SQLGlot string literal
        Example: 's3://bucket/prefix/path/dataset.parquet'

    Environment:
        S3_BUCKET_URL (str): Full S3 bucket URL (e.g. "s3://bucket/prefix")
    """
    _setup_duckdb()
    path = _get_latest_metadata_path(data_source, dataset_name)
    return exp.Literal.string(path)
