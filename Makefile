APP=src/vernon_store_analytics
VENV=venv
PYTHON=$(VENV)/bin/python
PIP=$(VENV)/bin/pip

.PHONY: install run dev test lint format migrate

## Setup
install:
	python3.12 -m venv $(VENV)
	$(PIP) install -r requirements-dev.txt

## Run
run:
	$(PYTHON) -m uvicorn src.vernon_store_analytics.main:app \
		--host 0.0.0.0 --port 8000

dev:
	$(PYTHON) -m uvicorn src.vernon_store_analytics.main:app \
		--host 0.0.0.0 --port 8000 --reload

## Testing
test:
	$(PYTHON) -m pytest tests/ -v

test-cov:
	$(PYTHON) -m pytest tests/ --cov=$(APP) \
		--cov-report=html --cov-report=term-missing

test-unit:
	$(PYTHON) -m pytest tests/unit/ -v

test-integration:
	$(PYTHON) -m pytest tests/integration/ -v

## Code Quality
lint:
	$(PYTHON) -m ruff check src/ tests/

format:
	$(PYTHON) -m black src/ tests/
	$(PYTHON) -m ruff check --fix src/ tests/

typecheck:
	$(PYTHON) -m mypy src/

check: lint typecheck test

## Database
migrate:
	$(PYTHON) -m alembic upgrade head

migrate-down:
	$(PYTHON) -m alembic downgrade -1

migrate-create:
	$(PYTHON) -m alembic revision --autogenerate -m "$(name)"

## Seed Data
seed:
	$(PYTHON) -m scripts.seed

seed-reset:
	$(PYTHON) -m scripts.seed --reset

seed-large:
	$(PYTHON) -m scripts.seed --reset --visitors 500 --days 7

## Utilities
clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -name "*.pyc" -delete
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov
