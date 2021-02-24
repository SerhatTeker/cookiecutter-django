# Makefile for {{ cookiecutter.project_name }}
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

# Export all variable to sub-make
export

.PHONY: help startproject setup start venv install migrate create-superuser env-vars servers test coverage clean

.DEFAULT_GOAL := help

help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# -------------------------------------------------------------------------------------
# LOCAL DEV
# -------------------------------------------------------------------------------------
startproject: install env-vars ## Install requirements, apply migrations and create local admin

setup: startproject migrate create-superuser # Setup the project

start: setup runserver # Setup the project and run the dev server

# Install Project
# -------------------------------------------------------------------------------------
venv: ## Make a new virtual environment
	# Current version of Cookiecutter Django works with python 3.8
	virtualenv -p python3.8 $(VENV) && source $(BIN)/activate

install: npm-install venv ## Make venv and install local requirements
	$(BIN)/pip install -r requirements/local.txt

npm-install:
	npm install

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
# .env files
export $$(grep -v '^#' ./.envs/.local/.django | xargs)
export $$(grep -v '^#' ./.envs/.local/.postgres | xargs)
endef

export LOCAL_ENV_VARS
env-vars: ## Load local env vars to os from virtualenv
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
{%- if cookiecutter.use_async == 'y' %}
servers:
	make -j 2 npm-server django-server
{%- else %}
servers:
	make -j 2 npm-server django-server-async
{% endif %}

django-server-async: ## Run the Django async server
	uvicorn config.asgi:application --host 0.0.0.0 --reload

django-server: ## Run the Django server
	$(PYTHON) manage.py runserver $(DJANGO_PORT)

npm-server:
	npm run dev

django-shell: ## Run ipython in django shell
	$(PYTHON) manage.py shell -i ipython

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
clean:
	rm db.sqlite3
	gm -rf .venv/
