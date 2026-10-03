# Using Python 3.11 slim image as base
# app needs Python to run. "slim" = smaller size, faster download
# Provides clean Python 3.11 environment
FROM python:3.11-slim

# Set working directory inside container to /app
# All commands after this run inside /app folder
# Creates /app folder and makes it current directory
WORKDIR /app

# Copy requirements.txt file from local machine to container
# Docker reuses this layer = faster builds
COPY requirements.txt .

# Install Python packages from requirements.txt
# Why: Install all dependencies your app needs
RUN pip install --no-cache-dir -r requirements.txt

# Copy all project files from local machine to container
# Copy everything from current directory to /app in container
COPY . .

# Tell Docker this container listens on port 8501
# Streamlit runs on port 8501 by default
# Documents which port to expose
EXPOSE 8501

# Command to run when container starts
# starts your Streamlit app when container launches
# Makes app accessible from outside container
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
