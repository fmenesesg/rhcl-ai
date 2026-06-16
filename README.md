# RHCL AI — Context, skills, and guidelines

Central repository for the **Red Hat Connectivity Link (RHCL)** program: **3scale API Management** to **Connectivity Link (Kuadrant)** migration.

**Language:** All agent context, rules, skills, and docs in this repo are **English only**.

## Ecosystem

| Repo | Role |
|------|-----|
| [3scaleextract](https://github.com/Everything-is-Code/3scaleextract) | Hybrid export, lab seed, visualize |
| [gateforge](https://github.com/Everything-is-Code/gateforge) | Migration platform (Quarkus + Angular) |
| **rhcl-ai** (this repo) | Cross-cutting docs, Cursor rules/skills, GitHub templates |

## Recommended workspace layout

```
rhcl/
├── 3scaleextract/
├── gateforge/
└── rhcl-ai/          ← this repo
```

## Cursor setup

**Full guide:** [docs/ai/cursor-setup.md](docs/ai/cursor-setup.md)

Summary:

1. Clone all three repos under a `rhcl/` directory.
2. Link or copy `.cursor` from this repo to the workspace root:
   ```bash
   cd rhcl && ln -s rhcl-ai/.cursor .cursor
   # Windows / no symlink: ./rhcl-ai/scripts/sync-cursor-config.sh
   ```
3. Open the **`rhcl/`** folder in Cursor (not a single subrepo).
4. Verify rules in **Settings → Rules** (`rhcl-global`, `gateforge-java`, `3scaleextract-go`).

See [AGENTS.md](AGENTS.md) (primary agent guide) and [CLAUDE.md](CLAUDE.md) (Claude Code).

Full workspace bootstrap:

```bash
git clone https://github.com/Everything-is-Code/rhcl-ai.git
./rhcl-ai/scripts/setup-rhcl-workspace.sh
```

## Documentation

| Area | Path |
|------|------|
| Pipeline overview | [docs/architecture/pipeline-overview.md](docs/architecture/pipeline-overview.md) |
| Export contract v1 | [docs/architecture/export-schema-v1.md](docs/architecture/export-schema-v1.md) |
| 3scale → CL mapping | [docs/architecture/3scale-to-cl-mapping.md](docs/architecture/3scale-to-cl-mapping.md) |
| **Cursor setup** | [docs/ai/cursor-setup.md](docs/ai/cursor-setup.md) |
| **Agent governance** | [docs/ai/agent-governance.md](docs/ai/agent-governance.md) |
| LangChain4j / AI | [docs/ai/gateforge-langchain4j.md](docs/ai/gateforge-langchain4j.md) |
| MCP tools | [docs/ai/mcp-tools-gateforge.md](docs/ai/mcp-tools-gateforge.md) |
| Local lab | [docs/workflows/local-lab-setup.md](docs/workflows/local-lab-setup.md) |
| Seed → migrate pipeline | [docs/workflows/seed-export-visualize-migrate.md](docs/workflows/seed-export-visualize-migrate.md) |

## GitHub templates

Copy from [`templates/github/`](templates/github/) into each repo:

```bash
cp -r templates/github/.github ../3scaleextract/
cp -r templates/github/.github ../gateforge/
```

## Program milestones

| Milestone | Goal |
|-----------|------|
| **M1 — Test foundation** | CI runs tests; minimum coverage on critical paths |
| **M2 — Integration offline** | GateForge imports export v1 |
| **M3 — E2E lab** | Documented and automatable seed→export→migrate pipeline (`./scripts/e2e-lab.sh`) |

## License

Apache 2.0 — see [LICENSE](LICENSE).
