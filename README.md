# Magma

This repository contains workflows and automation scripts for [Project Name]. The workflows are managed using GitHub Actions, and certain resources must be deployed beforehand to ensure the smooth execution of these workflows.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Resources Deployment](#resources-deployment)
  - [Helm Chart for GitHub Runners](#helm-chart-for-github-runners)
  - [MLflow Deployment](#mlflow-deployment)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

Before running any of the GitHub Actions workflows in this repository, the following resources need to be deployed and configured:

1. **Self-hosted GitHub Runners:** Deployed using a Helm chart for scalability and management.
2. **MLflow Server:** Set up for real-time tracking and monitoring of machine learning experiments.

Ensure that you have access to a Kubernetes cluster and Helm installed in your local environment. The cluster should have sufficient resources for deploying the GitHub runners and the MLflow server.

## Resources Deployment
