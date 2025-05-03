# Renegade

## Overview
Project Renegade is a "portable" data stack, and it can be run anywhere you can run a python script. The goal of the project is to implement open source tools for common data processing, analysis, and visualization tasks, without any reliance on running servers.

In our POC/version 1 phase, we're processing several NYC Open Data sources and serving visualizations in Evidence.

## Architecture Overview
[images/renegade-diagram-v1.png]

## Instructions

1. Create a new virtual environment using UV (recommended): 

    ```bash
    just setup-local
    ```

   This will:
   - Create a virtual environment
   - Install UV if not already installed
   - Install dependencies using UV

   *Alternatively, you can set up manually:*
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

**Recommend using a version of python >= 3.8.1 and < 3.13 for compatibility with `dlt[filesystem]==1.5.0`.**  

2. Configure Environment Variables:
   - Create a `.env` file in the root directory:
     ```bash
     cp env.example .env
     ```
   - Update the following variables in `.env`:
     - AWS credentials for S3 access:
       ```
       AWS_ACCESS_KEY_ID=your_access_key_id
       AWS_SECRET_ACCESS_KEY=your_secret_access_key
       AWS_DEFAULT_REGION=us-east-2
       S3_BUCKET_URL=s3://your-bucket-name/dlt/landing/
       ```
     - DLT filesystem destination (automatically configured from the above variables):
       ```
       DESTINATION__FILESYSTEM__BUCKET_URL=${S3_BUCKET_URL}
       DESTINATION__FILESYSTEM__CREDENTIALS__AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
       DESTINATION__FILESYSTEM__CREDENTIALS__AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
       DESTINATION__FILESYSTEM__CREDENTIALS__REGION_NAME=${AWS_DEFAULT_REGION}
       ```
     - [NYC Open Data app token](https://support.socrata.com/hc/en-us/articles/210138558-Generating-App-Tokens-and-API-Keys) (optional for development)
     - Other environment-specific settings

3. (Optional) Alternative Configuration with DLT Secrets:
   - If you prefer using DLT's secrets.toml configuration instead of environment variables:
     ```bash
     cd dlt
     cp .dlt/secrets.example .dlt/secrets.toml
     ```
   - Make sure the file is located in `Renegade/dlt/.dlt/secrets.toml`
   - Update the S3 configuration in the secrets file:
     ```toml
     [destination.filesystem]
     bucket_url = "s3://your-bucket-name/dlt/landing"
     
     [destination.filesystem.credentials]
     aws_access_key_id = "YOUR_AWS_ACCESS_KEY_ID"
     aws_secret_access_key = "YOUR_AWS_SECRET_ACCESS_KEY"
     region_name = "us-east-2"
     ```
   - For local development without S3, you can change the `bucket_url` to a local directory path:
     ```toml
     [destination.filesystem]
     bucket_url = "/path/to/local/directory"
     ```
     In this case, you don't need to specify the AWS credentials.

## Development Workflow Using Just Commands

This project uses [Just](https://github.com/casey/just) as a command runner to simplify common operations.

### Just Installation

```bash
# macOS
brew install just

# Linux
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash

# Windows (with Chocolatey)
choco install just
```

### Available Just Commands

To see all available commands:
```bash
just
```

Common commands:

1. **Local Development (Recommended Workflow):**

   ```bash
   # Set up local environment with UV
   just setup-local
   
   # Start Evidence visualization server
   just up-evidence
   
   # Run DLT pipeline locally
   just dlt-local --current-month
   
   # Run DBT models locally
   just dbt-local run
   ```

2. **Container-based Development:**

   ```bash
   # Build all containers
   just build
   
   # Run DLT pipeline in container
   just dlt-container --current-month
   
   # Run DBT in container
   just dbt-container run
   
   # Start only Evidence container
   just up-evidence
   
   # Stop all containers
   just down
   
   # Clean up Docker resources
   just clean
   ```

### Running DLT Pipeline

Local development:
```bash
# Run for current month
just dlt-local --current-month

# Run with backfill
just dlt-local --backfill

# Run for specific date range
just dlt-local --start-date YYYY-MM-DD --end-date YYYY-MM-DD
```

Container execution:
```bash
# Same parameters as above
just dlt-container --current-month
```

To check pipeline info:
```bash
cd dlt
dlt pipeline nyc_open_data_pipeline info
```
or use the streamlit interface:
```bash
cd dlt
dlt pipeline nyc_open_data_pipeline show
```

## Docker Setup

The project includes Docker configurations for all components. Docker-related files are organized in the `docker/` directory.

### Docker File Structure

```
Renegade/
├── docker/
│   ├── Dockerfile.dlt       # Dockerfile for DLT service
│   ├── Dockerfile.dbt       # Dockerfile for dbt service
│   └── docker-compose.yml   # Docker composition for all services
├── dlt/                     # DLT source code
├── dbt/                     # dbt source code
├── evidence/                # Evidence source code
└── justfile                 # Just commands
```

### Prerequisites

- Docker installed on your machine
- Configured `.env` file in the project root

### Environment Configuration

When running in Docker:
- Environment variables are loaded from the `.env` file
- Host environment variables take precedence if provided
- For production environments, ensure your S3 bucket and AWS credentials are correctly configured

## Evidence

[Evidence](https://evidence.dev/) is a lightweight BI tool used to create visualizations.

To view the Evidence visualizations:

1. Start the Evidence container:
   ```bash
   just up-evidence
   ```

2. Access the Evidence dashboard at `http://localhost:3000`

Refer to the [official Evidence documentation](https://docs.evidence.dev/) for more information.
