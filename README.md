# Next.js Blank Archetype

An [archetect](https://archetect.github.io/) archetype that scaffolds a production-ready Next.js application with Docker and p6m platform CI/CD — no application code included.

## What this generates

- Multi-stage `Dockerfile` for Next.js standalone builds
- GitHub Actions workflows: `build`, `cut-tag`, `promote`
- Kubernetes `PlatformApplication` manifests (base + dev/stg/prd overlays)
- Next.js `.gitignore`

## Usage

```bash
archetect render git@github.com:p6m-archetypes/nextjs-blank-archetype.git
```

You will be prompted for:

| Prompt | Example | Description |
|--------|---------|-------------|
| Project Author | `Jane Doe <jane@acme.com>` | Author name and email |
| Org Name | `acme` | Organization name |
| Solution Name | `platform` | Solution/product name |
| Project Prefix | `dashboard` | Feature/domain name |
| Project Suffix | `ui` | Project type (default: `ui`) |

## After rendering

```bash
cd {{ project-name }}

# Bootstrap the Next.js application
pnpm create next-app .

# Add standalone output to next.config.ts
# output: 'standalone'

# Initialize git and push
git init -b main
gh repo create {{ org-solution-name }}/{{ project-name }} --private --source=. --remote=origin
git add .
git commit -m 'initial commit'
git push -u origin HEAD
```

## CI/CD Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build.yml` | push to `main` (or manual) | Cut patch tag, build & push multi-arch image to Artifactory, deploy to **dev** |
| `cut-tag.yml` | manual (patch/minor/major) | Cut semver tag, build & push, create GitHub Release with image digest, deploy to **prd** |
| `promote.yml` | manual (`environment` + `tag`) | Promote an existing release's exact digest to **stg** or **prd** (no rebuild) |

## Required GitHub Secrets & Variables

| Name | Type | Description |
|------|------|-------------|
| `ARTIFACTORY_USERNAME` | Secret | JFrog Artifactory username |
| `ARTIFACTORY_IDENTITY_TOKEN` | Secret | JFrog Artifactory identity token |
| `ARTIFACTORY_TOKEN` | Secret | JFrog Artifactory token |
| `UPDATE_MANIFEST_TOKEN` | Secret | Token for platform manifest dispatch |
| `ARTIFACTORY_HOSTNAME` | Variable | JFrog Artifactory hostname |
| `ARTIFACTORY_PROJECT` | Variable | JFrog Artifactory project key |
| `PLATFORM_DISPATCH_URL` | Variable | Platform manifest dispatch URL |
