# GitHub Pages setup

The public site lives in this **`docs/`** folder:

| File | URL |
|------|-----|
| [`index.html`](index.html) | Site home (`/` or `https://dashpipe.io/`) |
| [`README.md`](README.md) | Documentation hub (`/README`) |
| [`CNAME`](CNAME) | Custom domain (`dashpipe.io`) |

## Why the landing page is here

GitHub Pages was serving **`docs/README.md`** at the site root because the repo uses the **`/docs` folder** as the publish source. Adding **`docs/index.html`** takes precedence over `README.md` at `/`.

## Enable GitHub Pages

**Option A — Deploy from branch (simplest)**

1. **Settings → Pages → Build and deployment**
2. **Source:** Deploy from a branch
3. **Branch:** `main` · **Folder:** `/docs`
4. Save. Root URL serves `index.html`; markdown docs render via Jekyll.

**Option B — GitHub Actions (CI deploy)**

1. **Settings → Pages → Source:** GitHub Actions
2. Push to `main` runs [`.github/workflows/pages.yml`](../.github/workflows/pages.yml) (Jekyll build + deploy)

## Custom domain DNS

See [`CNAME`](CNAME) (`dashpipe.io`). Apex **A records** point to GitHub Pages:

| Type | Name | Value |
|------|------|-------|
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |

For **`www`**, CNAME to `deepakpalpro.github.io`.

Then **Settings → Pages → Custom domain** → `dashpipe.io` → **Enforce HTTPS**.

## Local preview

```bash
cd docs
python3 -m http.server 8088
# http://localhost:8088/index.html
```

For full Jekyll preview: `bundle exec jekyll serve` (requires Ruby).
