# Workflow: Seed → Export → Visualize → Migrate

End-to-end validation pipeline for the RHCL program.

## Goal

Verify lab fixtures in 3scale export correctly and GateForge can analyze them — **live** (Admin API discovery) or **offline** (zip import via M2 `POST /api/migration/import-export`).

## One-command E2E (recommended)

With [GateForge](https://github.com/Everything-is-Code/gateforge) and [3scaleextract](https://github.com/Everything-is-Code/3scaleextract) checked out as siblings:

```bash
# Start GateForge (same THREESCALE_* as 3scaleextract .env)
cd gateforge && cp .env.example .env && ./scripts/local-up.sh

# Full lab pipeline
cd gateforge
export THREESCALE_ADMIN_URL=... THREESCALE_ACCESS_TOKEN=...
./scripts/e2e-seed-export-analyze.sh
```

Or from this repo (thin wrapper):

```bash
export GATEFORGE_ROOT=../gateforge
./scripts/e2e-lab.sh
```

**Fixture smoke** (no live 3scale; 2-product offline import only):

```bash
E2E_MODE=fixture ./scripts/e2e-lab.sh
```

## Step-by-step (3scaleextract)

```bash
cd 3scaleextract
source scripts/load-env.sh   # or export THREESCALE_* manually
./scripts/demo/seed-and-export.sh
```

Produces `./export/manifest.json` and full tree (4 `seed_*` products).

## Visualize

```bash
bin/threescale-visualize ./export -o ./report
open report/index.md
```

Review:
- Auth matrix per product
- Mermaid topology diagram
- Backend ↔ product references

## GateForge — live flow

1. Configure the same 3scale URL/token in GateForge (`.env` / Helm).
2. Migration Wizard → select `seed_*` products **or** `E2E_MODE=live ./scripts/e2e-seed-export-analyze.sh`.
3. Strategy `shared` → Analyze → review plan and OIDC warnings.
4. (Optional) Apply on lab cluster with Connectivity Link installed.

## GateForge — offline flow (M2)

```bash
cd export && zip -r ../threescale-export.zip .
curl -X POST http://localhost:8080/api/migration/import-export -F "file=@../threescale-export.zip"
curl -X POST http://localhost:8080/api/migration/analyze \
  -H 'Content-Type: application/json' \
  -d '{"gatewayStrategy":"shared","products":["Seed API Key Product","Seed OIDC Product","Seed App ID Product","Seed Multi-Backend Product"],"targetClusterId":"local"}'
```

The E2E script automates zip → import → analyze when `E2E_MODE=auto|offline`.

## E2E checklist (INT-6 / M3)

- [x] Seed 4 products without error (`product_count: 4`)
- [x] Export `incomplete: false`
- [x] Visualize report generated (`report/index.md`)
- [x] GateForge analyze produces AuthPolicy per auth mode (API key + JWT)
- [x] OIDC consolidation note when lab issuer is fictional (optional)
- [x] `seed_multi_backend` analyzed with HTTPRoute resources

## Troubleshooting

| Problem | Action |
|---------|--------|
| Toolbox pull failed | `docker login registry.redhat.io` |
| Export incomplete | Check Admin token permissions |
| GateForge missing products | Verify `THREESCALE_ADMIN_URL` matches export; or use offline import |
| OIDC warning | Expected when seed uses fictional issuer (`sso.example.com`) |
| GateForge not ready | `cd gateforge && ./scripts/local-up.sh` |

## References

- [SEED.md](https://github.com/Everything-is-Code/3scaleextract/blob/main/docs/SEED.md)
- [GateForge M2 offline docs](https://github.com/Everything-is-Code/gateforge#offline-integration-m2)
- [export-schema-v1.md](../architecture/export-schema-v1.md)
- Skill: `lab-pipeline-seed-export-migrate`
