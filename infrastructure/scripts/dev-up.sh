#!/usr/bin/env sh
# Starts only Postgres + Redis (not the API container), for running the backend directly via
# `cd backend && ./mvnw spring-boot:run` while developing against containerized dependencies.
set -eu
cd "$(dirname "$0")/../.."
docker compose up postgres redis
