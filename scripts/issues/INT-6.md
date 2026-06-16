## Alcance

Script/documentación E2E completa:

1. `threescale-seed --skip-existing`
2. `threescale-export --include-applications --redact-secrets`
3. `threescale-visualize`
4. GateForge analyze (live + offline via M2 import)

Documentar en [rhcl-ai seed-export-visualize-migrate.md](https://github.com/Everything-is-Code/rhcl-ai/blob/main/docs/workflows/seed-export-visualize-migrate.md) y script `rhcl-ai/scripts/e2e-lab.sh` (wrapper → `gateforge/scripts/e2e-seed-export-analyze.sh`).

## Checklist E2E

- [x] 4+ productos seed (`product_count >= 4`)
- [x] export `incomplete: false`
- [x] analyze AuthPolicy por auth mode
- [x] warning OIDC placeholder (opcional)

## Cross-links

- [Everything-is-Code/3scaleextract](https://github.com/Everything-is-Code/3scaleextract)
- [Everything-is-Code/gateforge](https://github.com/Everything-is-Code/gateforge) — PR #39 (script), #40 (live export parser), #41 (docs)

**Plan PO:** INT-6 | **Milestone:** M3 - E2E lab
