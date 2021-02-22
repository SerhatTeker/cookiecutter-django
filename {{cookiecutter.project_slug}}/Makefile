# Makefile for "My Awesome Project"
SHELL := /bin/bash

# Variables
# -------------------------------------------------------------------------------------
VENV		:= ./.venv
ENV			:= ./.env
ENVS		:= ./.envs
BIN			:= $(VENV)/bin
PYTHON3		:= $(BIN)/python3
PYTHON		:= $(PYTHON3)

# Local environment variables for Project
include $(ENV)
# Local environment variables for Django
include $(ENVS)/.local/.django
include $(ENVS)/.local/.postgres

.PHONY: help

.DEFAULT_GOAL := help

help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# -------------------------------------------------------------------------------------
# LOCAL DEV
# -------------------------------------------------------------------------------------

.PHONY= startproject
startproject: install env-vars ## Install requirements, apply migrations and create local admin

.PHONY= setup
setup: startproject migrate create-superuser # Setup the project

.PHONY= start
start: setup runserver # Setup the project and run the dev server

# Install Project
# -------------------------------------------------------------------------------------
venv: ## Make a new virtual environment
	# Current version of Cookiecutter Django works with python 3.8
	virtualenv -p python3.8 $(VENV) && source $(BIN)/activate

install: venv ## Make venv and install local requirements
	$(BIN)/pip install -r requirements/local.txt

migrate: ## Make migrate
	$(PYTHON) manage.py migrate

# Create a super user from env var
# You need to define an env var : DJANGO_DEV_ADMIN_LOCAL
# DJANGO_DEV_ADMIN_LOCAL=name:email:password
# Or get it from .envs/.local/.django
# If none set, the default one:
DJANGO_DEV_ADMIN_LOCAL?=testadmin:testadmin@testapi.com:123asX3?23
create-superuser: ## Create local django admin user
	@echo "Creating Super User"
	@echo "from django.contrib.auth import get_user_model;"\
		"User = get_user_model();" \
		"User.objects.create_superuser(*'$(DJANGO_DEV_ADMIN_LOCAL)'.split(':'))" \
		| $(PYTHON) manage.py shell

define LOCAL_ENV_VARS
\n# PROJECT ENVs
# ------------------------------------------------------------------------------
# local envs
export DATABASE_URL=postgres://postgres:debug@127.0.0.1:5432/{{ cookiecutter.project_slug }}
export CELERY_BROKER_URL=redis://localhost:6379/0
# .env files
export $$(grep -v '^#' ./.envs/.local/.django | xargs)
export $$(grep -v '^#' ./.envs/.local/.postgres | xargs)
endef

.PHONY= env-vars
export LOCAL_ENV_VARS
env-vars:
	@echo -e "$$LOCAL_ENV_VARS" >> $(BIN)/activate

# Utils
# -------------------------------------------------------------------------------------
createsecret: ## Create DJANGO_SECRET
	@echo "Creating SECRET_KEY"
	@echo "SECRET_KEY="\"`python manage.py shell -c 'from django.core.management import utils; print(utils.get_random_secret_key())'`\"

makemigrations: ## Make migrations
	$(PYTHON) manage.py makemigrations

allmigrations: makemigrations migrate ## Make migrations and migrate

# Run Local
# -------------------------------------------------------------------------------------
django-shell: ## Run ipython in django shell
	$(PYTHON) manage.py shell -i ipython

runserver: ## Run the Django server
	$(PYTHON) manage.py runserver $(DJANGO_PORT)

# Test
# -------------------------------------------------------------------------------------
test: coverage ## Run tests and make coverage report

coverage: ## Clear and run tests with coverage report
	coverage erase
	coverage run -m pytest
	coverage report -m
	coverage html

# Clean
# -------------------------------------------------------------------------------------
.PHONY: clean
clean:
	rm db.sqlite3
	gm -rf .venv/
