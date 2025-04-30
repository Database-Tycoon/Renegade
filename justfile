# Renegade Just Commands
# Install Just: https://github.com/casey/just
set dotenv-load

# List available commands
default:
    @just --list

# Set up local development environment with uv
setup-local:
    #!/usr/bin/env bash
    if command -v uv >/dev/null 2>&1; then
        echo "uv is already installed, using it to install dependencies"
        uv venv
    else
        echo "uv not found, creating virtual environment and installing uv"
        python -m venv .venv
        source .venv/bin/activate
        pip install uv
    fi
    uv pip install -r requirements.txt

# Run the DLT pipeline locally with uv
dlt-local *ARGS:
    cd dlt && uv run python nyc_open_data_pipeline.py {{ARGS}}

# Run DBT locally with uv
dbt-local *ARGS:
    cd dbt && uv run dbt deps && uv run dbt {{ARGS}}

# Build all containers
build:
    docker compose -f docker/docker-compose.yml build

# Start dev environment with only Evidence (recommended for local development)
up-evidence:
    @echo "Starting Evidence container for visualizations..."
    docker compose -f docker/docker-compose.yml up -d evidence
    @echo "✅ Evidence is running at http://localhost:3000"

# Run the DLT pipeline in production container
dlt-container *ARGS:
    @echo "Running DLT pipeline in container..."
    docker compose -f docker/docker-compose.yml up -d dlt
    docker compose -f docker/docker-compose.yml exec -T dlt uv run python /app/dlt/nyc_open_data_pipeline.py {{ARGS}}
    docker compose -f docker/docker-compose.yml stop dlt
    @echo "✅ DLT pipeline completed"

# Run DBT in production container
dbt-container *ARGS:
    @echo "Running dbt in container..."
    docker compose -f docker/docker-compose.yml up -d dbt
    docker compose -f docker/docker-compose.yml exec -T -w /app/dbt dbt sh -c "uv run dbt deps && uv run dbt {{ARGS}}"
    docker compose -f docker/docker-compose.yml stop dbt
    @echo "✅ dbt process completed"

# Deploy to production - customize this for your deployment environment
deploy-prod:
    @echo "Deploying to production..."
    @echo "This command should be customized based on your production environment."
    @echo "Typically, you would:"
    @echo "1. Build and tag your images"
    @echo "2. Push them to a container registry"
    @echo "3. Deploy using your orchestration tool (Kubernetes, ECS, etc.)"
    @echo "Example command might be:"
    @echo "docker compose -f docker/docker-compose.yml build"
    @echo "docker tag renegade_dlt:latest my-registry/renegade_dlt:latest"
    @echo "docker push my-registry/renegade_dlt:latest"
    @echo "kubectl apply -f k8s/"

# Stop and remove containers
down:
    docker compose -f docker/docker-compose.yml down

# Clean up Docker resources
clean:
    docker compose -f docker/docker-compose.yml down -v --remove-orphans
    docker system prune -f 