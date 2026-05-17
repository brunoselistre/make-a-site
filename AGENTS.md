# Agent Instructions — Make-a-Site

> **Purpose:** This file tells any AI agent how to work with the `make-a-site` static site generator and deploy pipeline.
> **Scope:** HTML/CSS/JS static sites, multi-provider deploy, 5 visual templates.
> **Language:** This project uses Portuguese (pt-BR) for client-facing output, but agents may work in English or Portuguese.

---

## 1. Project Overview

`make-a-site` is a static site generator with an automated deployment pipeline. It generates HTML/CSS/JS sites from templates and deploys them to 7 different hosting providers via shell scripts.

**Key principle:** Edit only `src/`. No build step. Files in `src/` are deployed as-is.

---

## 2. Directory Structure

```
make-a-site/
├── src/                      # EDIT THIS — source files deployed as-is
│   ├── index.html            # Homepage
│   ├── about.html            # About page
│   ├── services.html         # Services page
│   ├── contact.html          # Contact page
│   ├── css/
│   │   ├── main.css          # Global styles + CSS variables
│   │   └── components/       # Component CSS files
│   ├── js/
│   │   ├── main.js           # Social icons, WhatsApp, footer year
│   │   └── modules/          # JS modules
│   ├── images/               # Image assets
│   └── fonts/                # Custom web fonts
├── templates/                # 5 visual templates (HTML + CSS)
│   ├── minimalist/
│   ├── modern/
│   ├── bold/
│   ├── classic/
│   └── retro/
├── scripts/                  # Deployment scripts
│   ├── setup.sh              # Initial configuration wizard
│   ├── preflight.sh          # Pre-deploy validation
│   ├── deploy.sh             # Main deploy script
│   ├── rollback.sh           # Rollback to previous version
│   └── providers/            # Provider-specific deploy logic
│       ├── ftp.sh
│       ├── sftp.sh
│       ├── s3.sh
│       ├── vercel.sh
│       ├── netlify.sh
│       ├── local.sh
│       └── rsync.sh
├── config/
│   ├── .env.example          # Template env vars (safe to commit)
│   └── .env.production       # REAL credentials — NEVER commit
├── backups/                  # Auto-generated deploy backups
└── .github/workflows/
    └── deploy.yml            # GitHub Actions auto-deploy
```

---

## 3. Agent Workflow Rules

### 3.1 When Creating a New Website

Use the **5-phase workflow** defined in `.claude/commands/new-website.md`:

| Phase | Action |
|-------|--------|
| **Phase 1** | Collect client info: company name, segment, URL, WhatsApp, pages, GitHub repo, deploy provider, credentials |
| **Phase 2** | Present 5 templates, let client choose, then collect color/font preferences |
| **Phase 3** | Interpret preferences into concrete tokens (hex colors, font pairs, border radius, image keywords). Confirm before proceeding. |
| **Phase 4** | Build the project: copy template, create env file, update package.json, replace placeholders, handle page additions/removals |
| **Phase 5** | Present local preview options, verify checklist, await approval |

**Important:** Never skip a phase. Always wait for user confirmation before proceeding to the next phase.

### 3.2 When Editing an Existing Site

1. **Identify the scope:** Which pages, styles, or functionality need changes?
2. **Edit `src/` only:** Never modify files outside `src/` unless explicitly asked to change deployment config.
3. **Preview locally:** Use `cd src && python3 -m http.server 8080` or VS Code Live Server.
4. **Deploy when ready:** `bash scripts/deploy.sh production`

### 3.3 Placeholder Replacements (Phase 4)

When generating a new site, replace these placeholders globally in `src/`:

| Placeholder | Replace With |
|-------------|--------------|
| `Nome do Cliente` | Real company name |
| `nomecliente` | Slug for contact email |
| `business` (loremflickr keyword) | Segment keyword (e.g., `dental`, `restaurant,food`) |
| Google Fonts URL | Generated URL for chosen font pair |
| CSS `:root` colors | Confirmed hex values |
| `--radius: 6px` | Confirmed border radius |
| `<meta name="whatsapp-number" content="">` | `content="<number>"` (all pages) |

### 3.4 Template-Specific Constraints

| Template | Constraint |
|----------|------------|
| **Bold** | `h1` has `white-space: nowrap` for brutalist overflow effect. **Do not remove.** Use `<br>` for long headlines. |
| **Modern** | Hero uses CSS gradients (`::before`/`::after`). **Do not add** `<img class="hero-bg">`. |
| **Minimalist** | Hero uses `.hero-text-pane` + `.hero-image-pane` (split-screen). Image uses `seed/hero/1200/1600` (portrait). |
| **Classic** | Traditional hero with photo + overlay. |
| **Retro** | Same structure as Classic; paper texture is 100% CSS. |

---

## 4. Deployment Pipeline

### 4.1 Supported Providers

| Provider | `DEPLOY_PROVIDER` | Key Vars |
|----------|-------------------|----------|
| FTP | `ftp` | `FTP_HOST`, `FTP_USER`, `FTP_PASSWORD`, `FTP_PORT`, `REMOTE_PATH` |
| SFTP | `sftp` | `SFTP_HOST`, `SFTP_USER`, `SFTP_PASSWORD`, `SFTP_PORT`, `REMOTE_PATH` |
| S3 | `s3` | `S3_BUCKET`, `S3_REGION`, `S3_ACCESS_KEY`, `S3_SECRET_KEY`, `S3_ENDPOINT` |
| Vercel | `vercel` | `VERCEL_TOKEN`, `VERCEL_PROJECT_ID`, `VERCEL_ORG_ID` |
| Netlify | `netlify` | `NETLIFY_AUTH_TOKEN`, `NETLIFY_SITE_ID` |
| Local | `local` | `LOCAL_DEST` |
| Rsync | `rsync` | `RSYNC_HOST`, `RSYNC_USER`, `RSYNC_PORT`, `REMOTE_PATH` |

### 4.2 Deploy Commands

```bash
# Setup (first time)
bash scripts/setup.sh

# Validate connection and config
bash scripts/preflight.sh

# Deploy to production
bash scripts/deploy.sh production

# Rollback to previous version
bash scripts/rollback.sh production

# Rollback to specific date
bash scripts/rollback.sh production YYYYMMDD
```

### 4.3 Deploy Process (what `deploy.sh` does)

1. **Preflight** — validates credentials and connectivity
2. **Backup** — copies `src/` to `backups/src-TIMESTAMP/`
3. **Upload** — sends `src/` to configured provider
4. **Smoke test** — checks `SITE_URL` returns HTTP 200
5. **Summary** — shows timestamp, backup location, site URL

### 4.4 Critical Rules

- **`config/.env.production` contains secrets.** It is in `.gitignore`. Never commit it.
- **Backups are local only.** They live in `backups/` on your machine. If you lose the machine, you lose the backups.
- **No automatic server rollback for FTP.** If smoke test fails, the script shows the rollback command. You must run it manually.

---

## 5. Visual Templates

### 5.1 Available Templates

| # | Name | ID | Default Fonts | Best For |
|---|------|-----|---------------|----------|
| 1 | Minimalist | `minimalist` | Inter | Luxury brands, portfolios, aesthetics |
| 2 | Modern / SaaS | `modern` | Syne + DM Sans | Software, apps, tech startups |
| 3 | Bold / Brutalist | `bold` | Bebas Neue + Space Grotesk | Creative agencies, streetwear, music |
| 4 | Classic / Corporate | `classic` | IBM Plex Serif + IBM Plex Sans | Law, finance, healthcare, B2B |
| 5 | Retro / Nostalgic | `retro` | Playfair Display + Lora | Cafes, artisanal brands, indie |

### 5.2 Font Pairing Reference

| Style | Headings | Body |
|-------|----------|------|
| Minimalist/modern | Inter 700 | Inter 400 |
| Elegant serif | Playfair Display | Source Serif 4 |
| Geometric/bold | Syne | DM Sans |
| Friendly/rounded | Nunito | Nunito |
| Corporate | IBM Plex Sans | IBM Plex Sans |
| Luxury | Cormorant Garamond | Jost |
| Technical | Space Grotesk | IBM Plex Mono |

### 5.3 Border Radius Guide

| Context | Radius |
|---------|--------|
| Corporate / technical | 4px |
| Modern | 8px |
| Friendly / casual | 14px |

---

## 6. Icons & Assets

### 6.1 UI Icons
- Use inline SVGs
- Attributes: `fill="none"`, `stroke="currentColor"`, `stroke-width="1.5"`, `viewBox="0 0 24 24"`
- Follow patterns in `about.html` and `contact.html`

### 6.2 Social Icons
- Generated automatically via `simple-icons` in `src/js/main.js`
- Edit the `socialLinks` array to add/remove networks

### 6.3 Images
- Placeholder images from `loremflickr.com`
- Keyword mapping by segment:
  - Dental clinic → `dental`
  - Restaurant → `restaurant,food`
  - Law office → `law,office`
  - Gym → `fitness,gym`
  - Agency → `office,business`
  - Fashion → `fashion,clothing`
  - Spa → `beauty,spa`
  - Construction → `construction,architecture`

---

## 7. Common Agent Tasks

### 7.1 Create New Project

Follow the 5-phase workflow in `.claude/commands/new-website.md` exactly.

### 7.2 Add a New Page

1. Copy structure from `about.html` (page-hero + section with container)
2. Adapt title and content
3. Add link in `<nav>` and `footer` of **all** pages
4. Use lorem ipsum for body content unless client provides text

### 7.3 Remove a Page

1. Delete the `.html` file
2. Remove its links from `<nav>` and `footer` in **all remaining** pages

### 7.4 Update Colors/Fonts

1. Edit CSS variables in `src/css/main.css` `:root`
2. Update Google Fonts link in all HTML files
3. Preview locally before deploying

### 7.5 Fix Deploy Issues

| Symptom | Solution |
|---------|----------|
| `Login incorrect / 530` | Check password in hosting panel; verify `DEPLOY_PROVIDER` matches |
| Timeout | Retry (3 auto-retries built-in); check firewall for port 21/22 |
| Smoke test ≠ 200 | Check redirects with `curl -IL`; update `SITE_URL` to exact 200 URL |
| GitHub Actions fails | Verify all secrets exist and names match exactly (case-sensitive) |

---

## 8. Git & Version Control

- Commit `src/` changes regularly
- `.env.production`, `backups/`, and `.git/` are in `.gitignore`
- For GitHub Actions auto-deploy: push to `main` branch triggers deploy

---

## 9. Safety Checklist for Agents

Before any deploy, verify:
- [ ] `src/` contains all intended files
- [ ] No placeholder text left in visible areas (hero h1, hero p, service names, page titles)
- [ ] WhatsApp number meta tag set (if provided)
- [ ] All page links work in nav and footer
- [ ] `config/.env.production` exists and has correct provider/credentials
- [ ] `bash scripts/preflight.sh` passes

After deploy, verify:
- [ ] Site returns HTTP 200
- [ ] Layout is responsive
- [ ] WhatsApp button appears (if configured)
- [ ] Social icons render in footer
