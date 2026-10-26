# Infrastructure

## Local development

Local development does not need AWS credentials. `docker-compose.yml` at the repo root starts
PostgreSQL, Redis, and the API together — see the root `README.md`.

`scripts/` holds local-dev helper scripts (seed data, bootstrap). See its own files for what
exists today.

## AWS deployment — not started (Phase 6)

The master spec asks for ECS, RDS for PostgreSQL, S3 (private homework uploads/assets), CloudFront
(public static assets), Cognito (optional future auth integration), and CloudWatch (logs/metrics/
alarms). None of this has been built yet — no `aws/` directory exists here because an empty
placeholder of Terraform/CDK/CloudFormation files with nothing real in them would be worse than
not having the directory at all. Per the master spec's own instruction, Phase 6 work (including
this) should not begin until the core MVP works, unless explicitly requested.

When this phase starts, a reasonable shape for this directory:

```
infrastructure/
  aws/
    README.md           # deployment runbook
    *.tf or cdk/         # IaC, whichever the project owner prefers
  scripts/
    deploy.sh
```
