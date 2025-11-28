#!/bin/bash
# Convenience script to run Python programs with the configured Python 3.10 environment
# Usage: ./run_python.sh script_name.py [arguments...]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PYTHON_ENV="$PROJECT_ROOT/venv310/bin/python"

if [ ! -f "$PYTHON_ENV" ]; then
    echo "Error: Python environment not found at $PYTHON_ENV"
    echo "Please run configure_python_environment first"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 script_name.py [arguments...]"
    echo "Available scripts:"
    ls -1 *.py 2>/dev/null || echo "No Python scripts found"
    exit 1
fi

echo "Using Python environment: $PYTHON_ENV"
echo "Running: $@"
echo "---"

exec "$PYTHON_ENV" "$@"