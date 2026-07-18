# Dashpipe GitHub Pages site

Static landing page for [dashpipe-suite](https://github.com/deepakpalpro/dashpipe), deployed via GitHub Actions to GitHub Pages with a custom domain.

## Local preview

```bash
cd website
python3 -m http.server 8088
# open http://localhost:8088
```

## Enable GitHub Pages

1. In the GitHub repo: **Settings → Pages**
2. **Build and deployment → Source:** GitHub Actions
3. Push to `main` (or merge the PR) — the `pages.yml` workflow publishes `website/` on each push

## Custom domain (DNS)

The [`CNAME`](CNAME) file requests **`dashpipe.io`** as the site hostname. Edit it if you prefer `www.dashpipe.io` or another subdomain.

### Apex domain (`dashpipe.io`)

Add these **A records** at your DNS provider:

| Type | Name | Value |
|------|------|-------|
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |

Optional **AAAA** records for IPv6 (GitHub documents current values in [Pages custom domain docs](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)).

### `www` subdomain

| Type | Name | Value |
|------|------|-------|
| CNAME | `www` | `deepakpalpro.github.io` |

(Use your GitHub username/org if different.)

### After DNS propagates

1. In **Settings → Pages → Custom domain**, enter `dashpipe.io` (or your chosen host)
2. Enable **Enforce HTTPS**
3. Wait for the DNS check to pass (can take up to 24 hours)

## Files

| File | Purpose |
|------|---------|
| `index.html` | Landing page |
| `css/style.css` | Styles |
| `js/main.js` | Mobile nav |
| `CNAME` | Custom domain for GitHub Pages |
