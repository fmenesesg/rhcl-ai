# Workflow: Seed → Export → Visualize → Migrate

End-to-end validation pipeline for the RHCL program.

## Goal

Verify lab fixtures in 3scale export correctly and GateForge can analyze them — **live** (Admin API discovery) or **offline** (zip import via M2 `POST /api/migration/import-export`).

## One-command E2E (recommended)

With [GateForge](https://github.com/Everything-is-Code/gateforge) and [3scaleextract](https://github.com/Everything-is-Code/3scaleextract) checked out as siblings:

```bash
# Terminal 1 — GateForge stack
cd gateforge && cp .env.example .env && ./scripts/local-up.sh
# Set THREESCALE_*, AI_* (see gateforge .env.example); optional THREESCALEEXTRACT_ROOT

# Terminal 2 — full lab pipeline
cd gateforge
export THREESCALE_ADMIN_URL=... THREESCALE_ACCESS_TOKEN=...
export THREESCALEEXTRACT_ROOT=../3scaleextract   # optional if repos are siblings
./scripts/e2e-seed-export-analyze.sh
```

Or from **this repo** (thin wrapper → GateForge orchestrator):

```bash
export GATEFORGE_ROOT=../gateforge
export THREESCALEEXTRACT_ROOT=../3scaleextract
./scripts/e2e-lab.sh
```

| `E2E_MODE` | Behavior |
|------------|----------|
| `auto` (default) | Seed/export/visualize when 3scale creds set; offline import + analyze |
| `live` | Same seed/export; `POST /api/threescale/refresh` instead of zip import |
| `offline` | Explicit offline import path |
| `fixture` | Skip seed; vendored `export-minimal` tarball (2-product smoke) |

**Fixture smoke** (no live 3scale):

```bash
E2E_MODE=fixture ./scripts/e2e-lab.sh
```

Reuse an existing export directory: `E2E_SKIP_SEED=1 ./scripts/e2e-lab.sh`

## Step-by-step (3scaleextract)

```bash
cd 3scaleextract
source scripts/load-env.sh   # or export THREESCALE_* manually
./scripts/demo/seed-and-export.sh
```

Produces `./export/manifest.json` and seed fixtures (`seed_api_key`, `seed_oidc`, `seed_app_id`, `seed_multi_backend`). Tenants with pre-existing products may show `product_count > 4`; the GateForge E2E script requires `product_count >= 4` and `incomplete: false`.

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
2. Migration Wizard → select `seed_*` products **or** `E2E_MODE=live ./scripts/e2e-lab.sh`.
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

The E2E script automates zip → import → analyze when `E2E_MODE=auto|offline`. Live `threescale-export` output (array-shaped `backend_usages.json`, `kind: List` product YAML) is supported by GateForge import as of [gateforge#40](https://github.com/Everything-is-Code/gateforge/pull/40).

## AI assistant (optional)

For FAQ warm-up and chat during lab runs, configure GateForge `AI_ENDPOINT`, `AI_API_KEY`, `AI_MODEL`, and `AI_TIMEOUT` (default `600s`). RHDP MaaS lab typically uses `https://maas-rhdp.apps.maas.redhatworkshops.io/v1` and model `deepseek-r1-distill-qwen-14b` (no `openai/` prefix). Check `GET /api/chat/faq-status` or `POST /api/chat/warm-faq`.

## E2E checklist (INT-6 / M3)

Validated on OpenShift sandbox lab (2026-06):

- [x] Seed 4+ lab products without error (`product_count >= 4`)
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
| GateForge import 400 | Ensure export is schema 1.0 zip; upgrade GateForge to include #40 parser fixes |
| GateForge missing products | Verify `THREESCALE_ADMIN_URL` matches export; or use offline import |
| OIDC warning | Expected when seed uses fictional issuer (`sso.example.com`) |
| GateForge not ready | `cd gateforge && ./scripts/local-up.sh` |
| FAQ warm-up partial | Raise `AI_TIMEOUT`; run `POST /api/chat/warm-faq` |

## References

- [SEED.md](https://github.com/Everything-is-Code/3scaleextract/blob/main/docs/SEED.md)
- [GateForge M2 offline + M3 E2E](https://github.com/Everything-is-Code/gateforge#offline-integration-m2)
- [export-schema-v1.md](../architecture/export-schema-v1.md)
- Skill: `lab-pipeline-seed-export-migrate`
