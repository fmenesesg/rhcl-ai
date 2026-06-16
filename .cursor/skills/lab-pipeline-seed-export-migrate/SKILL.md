---
name: lab-pipeline-seed-export-migrate
description: Run lab pipeline seed, export, visualize, and GateForge migrate. Use for demos, E2E, and validating seed_api_key, seed_oidc, seed_app_id, seed_multi_backend fixtures.
---

# Lab Pipeline: Seed → Export → Visualize → Migrate

## Prerequisites

- Lab 3scale tenant with Admin API token.
- Docker or Podman + Red Hat toolbox image (for seed).
- Variables: `THREESCALE_ADMIN_URL`, `THREESCALE_ACCESS_TOKEN`.
- Sibling checkouts: `3scaleextract`, `gateforge`, `rhcl-ai` (see [setup-rhcl-workspace.sh](../../scripts/setup-rhcl-workspace.sh)).

## One-command E2E (preferred)

From **gateforge** (orchestrator):

```bash
cd gateforge && ./scripts/local-up.sh   # terminal 1
export THREESCALE_ADMIN_URL=... THREESCALE_ACCESS_TOKEN=...
export THREESCALEEXTRACT_ROOT=../3scaleextract
./scripts/e2e-seed-export-analyze.sh
```

From **rhcl-ai** (wrapper):

```bash
export GATEFORGE_ROOT=../gateforge
export THREESCALEEXTRACT_ROOT=../3scaleextract
./scripts/e2e-lab.sh                    # E2E_MODE=auto (default)
E2E_MODE=fixture ./scripts/e2e-lab.sh   # smoke without live 3scale
```

## Step 1 — Seed (3scaleextract)

```bash
cd 3scaleextract
go build -o bin/threescale-seed ./cmd/threescale-seed
bin/threescale-seed --skip-existing --list-fixtures
bin/threescale-seed --skip-existing
```

Fixtures: `seed_api_key`, `seed_oidc`, `seed_app_id`, `seed_multi_backend`.

## Step 2 — Export

```bash
go build -o bin/threescale-export ./cmd/threescale-export
bin/threescale-export --output ./export --include-applications --redact-secrets
```

All-in-one script: `scripts/demo/seed-and-export.sh`

## Step 3 — Visualize

```bash
go build -o bin/threescale-visualize ./cmd/threescale-visualize
bin/threescale-visualize ./export -o ./report
```

## Step 4 — GateForge analyze

**Live:** configure Admin API in GateForge `.env`; wizard or `E2E_MODE=live`.

**Offline (M2):** zip export → `POST /api/migration/import-export` → `POST /api/migration/analyze`. Automated by `E2E_MODE=auto|offline` in the orchestrator script.

**Local GateForge:**

```bash
cd gateforge
cp .env.example .env   # THREESCALE_*, optional AI_*, THREESCALEEXTRACT_ROOT
./scripts/local-up.sh
# UI http://localhost:4200 → Migration Wizard
```

## E2E criteria (INT-6 / M3)

- Export manifest: `incomplete: false`, `product_count >= 4`
- Analyze plan includes AuthPolicy per auth mode (API key + OIDC JWT for lab fixtures)
- Optional OIDC consolidation warning for fictional issuer

## References

- rhcl-ai/docs/workflows/seed-export-visualize-migrate.md
- rhcl-ai/scripts/e2e-lab.sh
- rhcl-ai/docs/workflows/local-lab-setup.md
- 3scaleextract/docs/SEED.md
- gateforge/scripts/e2e-seed-export-analyze.sh
