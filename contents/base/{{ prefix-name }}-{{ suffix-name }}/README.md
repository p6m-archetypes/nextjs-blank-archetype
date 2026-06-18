# {{ project-title }}

**// TODO:** Add description of your project's business function.

## Getting Started

### 1. Bootstrap the Next.js application

```bash
pnpm create next-app .
```

### 2. Enable standalone output

In `next.config.ts` (or `next.config.js`), add:

```ts
const nextConfig = {
  output: 'standalone',
};
```

This is required for the multi-stage Dockerfile to produce a minimal production image.

### 3. Run locally

```bash
pnpm install
pnpm dev
```

### 4. Build the Docker image

```bash
docker build -t {{ prefix-name }}-{{ suffix-name }} .
docker run -p 3000:3000 {{ prefix-name }}-{{ suffix-name }}
```

## CI/CD

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build.yml` | push to main | Build Docker image, deploy to dev |
| `cut-tag.yml` | manual | Semantic version tag + GitHub Release + deploy to prd |
| `promote-stg.yml` | manual (tag input) | Promote a release to staging |
| `promote-prd.yml` | manual (tag input) | Promote a release to production |

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
