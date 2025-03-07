# Variables
PROJECT_NAME=quiero-mate
PORT=4000
MIX_ENV=dev

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
.PHONY: help

## -------------------------------
## Phoenix (Local) Targets
## -------------------------------

setup: ## Install dependencies and set up the database
	mix deps.get
	mix ecto.setup
.PHONY: setup

server: setup ## Run the Phoenix server locally
	mix phx.server
.PHONY: server

test: ## Run tests
	mix test
.PHONY: test

format: ## Format the code
	mix format
.PHONY: format

clean-db: ## Reset the database
	mix ecto.reset
.PHONY: clean-db

## -------------------------------
## Docker Targets
## -------------------------------

docker: build ## Starts the Phoenix app in Docker
	docker run -p 4000:$(PORT) \
	-e SECRET_KEY_BASE=$$(docker run --rm elixir:1.18.2-otp-27-alpine elixir -e "IO.puts(:crypto.strong_rand_bytes(48) |> Base.encode64())") \
	-e PHX_HOST=localhost \
	$(PROJECT_NAME)
.PHONY: docker

build: ## Builds the Docker image
	docker build -t $(PROJECT_NAME) .
.PHONY: build

clean: ## Removes Docker container and image
	docker rm -f $(PROJECT_NAME) || true
	docker rmi -f $(PROJECT_NAME) || true
.PHONY: clean

logs: ## Shows logs from the running container
	docker logs -f $(PROJECT_NAME)
.PHONY: logs

stop: ## Stops the running container
	docker stop $(PROJECT_NAME) || true
.PHONY: stop
