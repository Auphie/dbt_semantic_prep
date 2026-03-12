# Define the virtual environment directory
VENV := .env_duck
PYTHON := $(VENV)/bin/python3
PIP := $(VENV)/bin/pip

# Default target: sets up the environment and installs packages
install: $(VENV)/bin/activate

$(VENV)/bin/activate: requirements.txt
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	@echo "Setup complete. Run 'source $(VENV)/bin/activate' to start."

# Optional: Clean up the environment
clean:
	rm -rf $(VENV)

# Optional: Run dbt commands through the Makefile
run:
	$(VENV)/bin/dbt run
