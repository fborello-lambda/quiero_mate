# Variables
PROJECT_NAME=quiero-mate
PORT?=4000
MIX_ENV?=dev

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
.PHONY: help

## -------------------------------
## Phoenix (Local) Targets
## -------------------------------

setup: ## Install dependencies and set up the database
	mix setup
	mix deps.get
# 	mix ecto.setup
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

#clean-db: ## Reset the database
#	mix ecto.reset
#.PHONY: clean-db

## -------------------------------
## Docker Targets
## -------------------------------

# https://unix.stackexchange.com/questions/546726/setup-docker-container-to-communicate-with-host-over-d-bus
# Running with `sudo` to "pass" the notifications from the docker container to the host.
# Tested on Ubuntu with GNOME as notification manager.
run-docker: ## Starts the Phoenix app in Docker
	sudo docker run -p 4000:$(PORT) \
	-e SECRET_KEY_BASE=$$(docker run --rm elixir:1.18.2-otp-27-alpine elixir -e "IO.puts(:crypto.strong_rand_bytes(48) |> Base.encode64())") \
	-e PHX_HOST=localhost \
	-v /run/user/1000/bus:/run/user/1000/bus \
	-e DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS} \
	$(PROJECT_NAME)
.PHONY: run-docker

build-docker: ## Builds the Docker image
	sudo docker build -t $(PROJECT_NAME) .
.PHONY: build-docker

all-docker: ## Builds and Runs the Docker Image
	make build-docker
	make run-docker
.PHONY: build-run-docker

clean-docker: ## Removes Docker image
	sudo docker rmi -f $(PROJECT_NAME) || true
.PHONY: clean-docker

stop-docker: ## Stops the running container
	sudo docker ps -q --filter ancestor=$(PROJECT_NAME) | xargs -I {} sudo docker stop {}
.PHONY: stop-docker

ps:
	sudo docker ps
.PHONY: ps-docker
