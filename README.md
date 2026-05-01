# 📚 Jewelix.Docs

Documentation repository for the **Jewelix** project.

## 📖 Overview

`Jewelix.Docs` is the central documentation hub for the Jewelix project. This repository contains design assets, architectural diagrams, and supporting documentation that helps define, visualize, and communicate the structure and design of the Jewelix application.

## ✨ About Jewelix

Jewelix is a project that combines functional design with elegant visual identity. This documentation repository ensures that all stakeholders have access to consistent branding, architectural guidance, and design resources.

## 📁 Repository Structure

### 🎨 `artifacts/`

The `artifacts` directory contains all visual and structural assets for the Jewelix project.

#### 🏗️ `artifacts/architecture/`

This folder is dedicated to architectural diagrams and system design documentation. It includes:
- 🔷 System architecture diagrams
- 🔗 Component relationship diagrams
- 📊 Data flow diagrams
- 🖥️ Infrastructure documentation
- 📝 Draft versions and iterations of architectural designs
- 📐 Any other architectural visualizations that help understand the system design

**View the architecture diagram:** [Interactive Lucidchart Architecture](https://lucid.app/lucidchart/2a9b4982-61da-4f12-96d9-3d708875fb5a/edit?viewport_loc=-1315%2C80%2C9384%2C4553%2C0_0&invitationId=inv_170a1310-a81e-4b4e-8cf9-3cddcd6c216e)

**Draft Versions:**

| Version | File |
|---------|------|
| Domain Model - Draft 1 | [Jewelix - Domain Model - Draft 1.svg](artifacts/architecture/Jewelix%20-%20Domain%20Model%20-%20Draft%201.svg) |

*Note: Contains finalized architecture documentation as well as draft versions for ongoing design work.*

#### 🖼️ `artifacts/images/`

This folder contains branding and design assets, including:
- 🎯 **Logo files** (`Jewelix.png`, `upscaled-logo.png`, `resized-logo-no-text.png`, etc.)
- 🎨 **Design references** (`Color Palette.png`)
- 🔧 **Icon files** (`.ico` formats for various applications)

These assets should be used consistently across all Jewelix project materials and documentation.

## � Documentation & Wiki

### Quick Access
- 🌐 **[Complete Project Wiki](./WIKI.md)** - Comprehensive guide to all Jewelix repositories, tech stack, and development guides
- 🔗 **[Interactive Architecture Diagram](https://lucid.app/lucidchart/2a9b4982-61da-4f12-96d9-3d708875fb5a/edit)** - Visual system design overview

### Wiki Synchronization
- 🤖 **PowerShell-based CI/CD workflow** - Automatically syncs `WIKI.md` to Wikipedia Jewelix page
- ⚙️ Triggers on every commit to `WIKI.md` on main/master branches
- 📝 No manual steps required - changes are automatically published to Wikipedia

## 🚀 Getting Started

- 🎨 For branding and visual identity, refer to the files in `artifacts/images/`
- 🏗️ For architectural information and system design, check `artifacts/architecture/`
- 🎯 Review the color palette to maintain visual consistency across all Jewelix materials
- 📖 For complete project information, visit the [Project Wiki](./WIKI.md)

## 🤝 Contributing

When adding new documentation or assets:
1. 🏗️ Place architectural diagrams in `artifacts/architecture/`
2. 🖼️ Place images and branding assets in `artifacts/images/`
3. 📝 Update `WIKI.md` for major documentation changes
4. ✅ The wiki will automatically sync to Wikipedia on commit

## 🔧 Automation & CI/CD

This repository includes automated workflows:

### 🌐 Wiki Synchronization (PowerShell-based)
- **Workflow**: Automatically syncs `WIKI.md` to Wikipedia Jewelix page
- **Trigger**: On every push to `WIKI.md` (main/master branch)
- **Technology**: GitHub Actions + PowerShell Core
- **Configuration**: Requires `WIKI_USERNAME` and `WIKI_PASSWORD` GitHub Secrets

---

✅ **Last Updated:** May 2026
