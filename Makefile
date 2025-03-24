# Variables
PROJECT_NAME=quiero-mate
PORT?=4000
MIX_ENV?=dev

STAMP_FILE = .docker_stamp
DOCKER_IMAGE = $(PROJECT_NAME)
DOCKERFILE = Dockerfile

LAST_MODIFIED_FILES = $(DOCKERFILE) $(shell find . -name '*.ex' -or -name '*.exs')
STAMP_HASH = $(shell stat -c %Y $(LAST_MODIFIED_FILES) | md5sum | awk '{print $$1}')


help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
.PHONY: help

## -------------------------------
## Phoenix (Local) Targets
## -------------------------------

setup: ## Install dependencies and set up the database
	mix setup
	mix deps.get
	mix ecto.setup
.PHONY: setup

run: setup ## Run the Phoenix server locally
	@if [ "$(MIX_ENV)" = "prod" ]; then \
		SECRET_KEY_BASE=$$(mix phx.gen.secret) && \
		export SECRET_KEY_BASE && \
		mix phx.digest && \
		mix phx.server; \
	else \
		mix phx.server; \
	fi
.PHONY: run

test: ## Run tests
	mix test
.PHONY: test

fmt: ## Format the code
	mix format
.PHONY: fmt

reset-db: ## Reset the database
	mix ecto.reset
.PHONY: reset-db

## -------------------------------
## Docker Targets
## -------------------------------

run-docker: build-docker ## Starts the Phoenix app in Docker
	docker run -p 4000:$(PORT) \
	-e SECRET_KEY_BASE=$$(docker run --rm elixir:1.18.2-otp-27-alpine elixir -e "IO.puts(:crypto.strong_rand_bytes(48) |> Base.encode64())") \
	-e DATABASE_PATH=/app/$(DOCKER_IMAGE).db \
	-e PHX_HOST=localhost \
	$(DOCKER_IMAGE)
.PHONY: run-docker

build-docker: ## Builds the Docker image if files have changed
	@if [ ! -f $(STAMP_FILE) ] || [ "$(STAMP_HASH)" != "$(shell cat $(STAMP_FILE))" ]; then \
		echo "Changes detected, rebuilding the Docker image..."; \
		docker build -t $(DOCKER_IMAGE) .; \
		echo $(STAMP_HASH) > $(STAMP_FILE); \
	else \
		echo "No changes detected, skipping Docker build."; \
	fi
.PHONY: build-docker

all-docker: ## Builds and Runs the Docker Image
	make build-docker
	make run-docker
.PHONY: build-run-docker

clean-docker: ## Removes Docker image
	docker rmi -f $(DOCKER_IMAGE) || true
.PHONY: clean-docker

stop-docker: ## Stops the running container
	docker ps -q --filter ancestor=$(DOCKER_IMAGE) | xargs -I {} docker stop {}
.PHONY: stop-docker

ps:
	sudo docker ps
.PHONY: ps-docker
