# {{ project-title }}

> **Repository:** This project is hosted under the [`{{ org-name }}`](https://github.com/{{ org-name }}) GitHub organization.

**// TODO:** Add description of your project's business function.

## Getting Started

### 1. Bootstrap the Next.js application

```bash
{{ framework-bootstrap }}
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

### How the multi-stage Dockerfile works

The `Dockerfile` uses a multi-stage build on `node:22-alpine` so the final image
ships only what's needed to run the app — no source, dev dependencies, or build
toolchain. Each stage builds on a shared `base`:

1. **`base`** — `node:22-alpine`, the common foundation for the stages below.
2. **`deps`** — adds `libc6-compat`, copies only `package.json` + `pnpm-lock.yaml`,
   and runs `pnpm install --frozen-lockfile`. Isolating dependency install in its
   own layer keeps it cached across builds unless the lockfile changes.
3. **`builder`** — copies the installed `node_modules` from `deps` and the rest of
   the source, then runs `pnpm build`. With `output: 'standalone'` set in
   `next.config.ts`, Next.js emits a self-contained `.next/standalone` server.
4. **`runner`** — the final production image. Sets `NODE_ENV=production`, creates a
   non-root `nextjs` user, and copies only the build outputs (`public`,
   `.next/standalone`, `.next/static`). It runs `node server.js` on port 3000.

Because only the third stage's artifacts land in `runner`, the published image
stays small and free of build-time tooling.

## CI/CD

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `build.yml` | push to `main` (or manual) | Cut patch tag, build & push multi-arch image to Artifactory, deploy to **dev** |
| `cut-tag.yml` | manual (patch/minor/major) | Cut semver tag, build & push, create GitHub Release with image digest, deploy to **prd** |
| `promote.yml` | manual (`environment` + `tag`) | Promote an existing release's exact digest to **stg** or **prd** (no rebuild) |

## Deployment (GitOps)

Deployment is GitOps-driven — the workflows never run `kubectl`. Instead, they dispatch an
image-digest update via the `p6m-actions/platform-application-manifest-dispatch` action, which writes
the new digest into the platform's GitOps repo for ArgoCD to sync.

This repo's `.platform/kubernetes/` tree holds the Kustomize manifests:

- `base/` — the `PlatformApplication` resource (`apiVersion: meta.p6m.dev/v1alpha1`) and shared config.
- `dev/`, `stg/`, `prd/` — per-environment overlays that patch the base for each target environment.

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
