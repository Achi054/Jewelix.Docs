# 💎 Jewelix Project Wiki

A comprehensive guide to the **Jewelix** ecosystem - a modern, full-stack application combining functional design with elegant visual identity.

---

## 📋 Table of Contents

- [🏢 Project Overview](#-project-overview)
- [🏗️ Architecture](#️-architecture)
- [📦 Repositories](#-repositories)
- [🛠️ Technology Stack](#️-technology-stack)
- [🚀 Getting Started](#-getting-started)
- [💻 Development Guide](#-development-guide)
- [📚 Project Structure](#-project-structure)
- [🤝 Contributing](#-contributing)

---

## 🏢 Project Overview

**Jewelix** is a sophisticated, modern application designed with attention to both functionality and visual elegance. The project is organized as a multi-repository ecosystem, with each component serving a specific role in the overall system.

### 🎯 Core Mission

- **Visual Excellence**: Maintain consistent branding and design language across all platforms
- **Functional Design**: Build robust, scalable services and APIs
- **User Experience**: Deliver a seamless, intuitive web experience
- **Infrastructure**: Provide reusable core libraries and infrastructure

---

## 🏗️ Architecture

### System Overview

Jewelix follows a **microservices-inspired architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────┐
│          Jewelix Web Application (Angular)          │
│                  (Frontend Layer)                    │
└───────────┬─────────────────────────────┬───────────┘
            │                             │
    ┌───────▼─────────┐         ┌────────▼────────┐
    │ Jewelix.Identity│         │  Other Services │
    │  (API Backend)  │         │  (Future)       │
    └────────┬────────┘         └─────────────────┘
             │
             ▼
    ┌──────────────────────────┐
    │ Library.Jewelix.Core     │
    │ (Shared Infrastructure)  │
    └──────────────────────────┘
```

### Key Characteristics

- 🔐 **Authentication & Authorization**: Centralized identity provider
- 🎨 **Design System**: Unified branding and visual assets
- 📚 **Documentation**: Comprehensive architecture and design documentation
- 🔄 **Scalability**: Microservices-ready infrastructure
- 📐 **Clean Architecture**: Domain-driven design principles

---

## 📦 Repositories

### 1️⃣ **Jewelix.Docs** - Documentation Hub
**Purpose**: Central repository for all documentation, architectural diagrams, and branding assets

📍 **Location**: `/Jewelix.Docs`

**Contents**:
- 📊 **Architectural Diagrams**: System design and component relationships
- 🎨 **Branding Assets**: Logo files, color palettes, icons
- 📖 **Design References**: Visual guidelines and specifications
- 📝 **Domain Models**: Draft versions and finalized designs

**Key Features**:
- Interactive Lucidchart architecture diagrams
- Comprehensive color palette
- Multiple logo formats for different use cases
- Version-controlled design documentation

---

### 2️⃣ **Jewelix.Web** - Angular Frontend Application
**Purpose**: Modern, responsive web application built with Angular

📍 **Location**: `/Jewelix.Web`

**Tech Stack**:
- ⚡ Angular v20.0.0
- 🎨 SASS CSS preprocessor
- 📦 Node.js v22.17.0
- 🏗️ Standalone component architecture
- 🌐 i18n localization support

**Key Features**:
- Standalone component template (no NgModules)
- Internationalization (i18n) support
- SASS-based styling system
- Comprehensive testing infrastructure
- ESLint code quality checks
- Development and production build configurations
- Hot reload during development
- HTTP server for serving production builds

**Common Commands**:
```bash
npm start              # Start development server
npm run build          # Build for development
npm run build-prod     # Production build
npm run build-locale   # Build with localization
npm run test           # Run unit tests
npm run lint           # Check code quality
npm run localize       # Extract i18n strings
```

---

### 3️⃣ **Jewelix.Identity** - Authentication & Identity Provider
**Purpose**: RESTful API for user management, authentication, and authorization

📍 **Location**: `/Jewelix.Identity`

**Tech Stack**:
- 🎯 C# / .NET (ASP.NET Core)
- 🏛️ Clean Architecture pattern
- 🗄️ Domain-driven design
- ✅ Comprehensive test suite
- 🔄 CI/CD pipelines

**Project Structure**:
```
src/
├── Application/         # Use cases and application logic
├── Domain/             # Business entities and rules
├── Infrastructure/     # External services, database, APIs
├── Persistence/        # Data access layer
├── Presentation/       # API controllers and DTOs
└── Web/               # API configuration and hosting
test/                  # Unit and integration tests
```

**Core Responsibilities**:
- ✅ User registration and management
- 🔐 Authentication (login/logout)
- 🛡️ Authorization and role-based access control
- 🔑 Token generation and validation
- 👥 User profile management

---

### 4️⃣ **Library.Jewelix.Core** - Shared Infrastructure Library
**Purpose**: Reusable core infrastructure templates for libraries and APIs

📍 **Location**: `/Library.Jewelix.Core`

**Tech Stack**:
- 🎯 C# / .NET
- 📚 Reusable utility libraries
- 🔧 Common infrastructure patterns

**Key Components**:
- 💾 **Caching**: Distributed cache implementations
- 📝 **Logging**: Structured logging framework
- 🗄️ **Database**: ORM and database access patterns

**Purpose**:
Provides shared infrastructure used by both Jewelix.Identity and future API services to maintain consistency and reduce code duplication.

---

## 🛠️ Technology Stack

### Frontend
| Technology | Version | Purpose |
|------------|---------|---------|
| **Angular** | v20.0.0 | SPA framework |
| **TypeScript** | Latest | Type-safe JavaScript |
| **SASS/SCSS** | Latest | CSS preprocessing |
| **ESLint** | Latest | Code quality |
| **Prettier** | Latest | Code formatting |

### Backend
| Technology | Purpose |
|------------|---------|
| **.NET / C#** | Core runtime |
| **ASP.NET Core** | Web API framework |
| **Entity Framework** | Data access |
| **xUnit / NUnit** | Testing framework |

### Development
| Tool | Purpose |
|------|---------|
| **Git** | Version control |
| **GitHub Actions** | CI/CD automation |
| **Visual Studio / VS Code** | IDEs |
| **npm / dotnet** | Package managers |

---

## 🚀 Getting Started

### Prerequisites

**For Frontend Development**:
- Node.js v22.17.0 or higher
- npm or yarn
- Angular CLI

**For Backend Development**:
- .NET SDK (for Jewelix.Identity and Library.Jewelix.Core)
- Visual Studio 2022 or VS Code with C# extensions
- Git

### Quick Start

#### 1️⃣ Clone the Repository
```bash
git clone https://github.com/yourusername/Jewelix.git
cd Jewelix
```

#### 2️⃣ Set Up Frontend
```bash
cd Jewelix.Web
npm install
npm start
```
The application will open at `http://localhost:4200`

#### 3️⃣ Set Up Backend (Identity API)
```bash
cd Jewelix.Identity
dotnet restore
dotnet build
dotnet run --project src/Web/Jewelix.Identity.Web.csproj
```
The API will be available at `http://localhost:5000`

#### 4️⃣ Access the Application
- 🌐 **Web App**: [http://localhost:4200](http://localhost:4200)
- 📡 **API**: [http://localhost:5000](http://localhost:5000)
- 📚 **Swagger UI**: [http://localhost:5000/swagger](http://localhost:5000/swagger)

---

## 💻 Development Guide

### Frontend Development (Jewelix.Web)

#### Development Server
```bash
cd Jewelix.Web
npm start
```
- Hot reload enabled
- Opens in default browser at `http://localhost:4200`
- Watch file changes and rebuild automatically

#### Build for Production
```bash
npm run build-prod
```

#### Running Tests
```bash
npm run test
```

#### Code Quality
```bash
npm run lint
```

#### Localization
```bash
npm run localize          # Extract i18n strings
npm run build-locale      # Build with translations
```

### Backend Development (Jewelix.Identity)

#### Build Solution
```bash
cd Jewelix.Identity
dotnet build
```

#### Run API
```bash
dotnet run --project src/Web/Jewelix.Identity.Web.csproj
```

#### Run Tests
```bash
dotnet test
```

#### Create Migrations
```bash
dotnet ef migrations add MigrationName --project src/Persistence/
```

### Shared Library (Library.Jewelix.Core)

Used as a NuGet reference in other projects:
```bash
cd Library.Jewelix.Core
dotnet build
dotnet pack  # Create NuGet package
```

---

## 📚 Project Structure

### Root Directory Layout
```
Jewelix/
├── Jewelix.Docs/                # Documentation and assets
│   ├── artifacts/
│   │   ├── architecture/        # Architecture diagrams
│   │   └── images/              # Branding and design assets
│   └── README.md
│
├── Jewelix.Web/                 # Angular frontend
│   ├── src/
│   │   ├── app/                 # Angular components
│   │   ├── locale/              # i18n translations
│   │   └── styles.scss
│   ├── public/
│   ├── dist/                    # Build output
│   └── package.json
│
├── Jewelix.Identity/            # Authentication API
│   ├── src/
│   │   ├── Application/         # Use cases
│   │   ├── Domain/              # Business logic
│   │   ├── Infrastructure/      # External services
│   │   ├── Persistence/         # Data access
│   │   ├── Presentation/        # API endpoints
│   │   └── Web/                 # ASP.NET Core hosting
│   ├── test/
│   └── Jewelix.Identity.sln
│
└── Library.Jewelix.Core/        # Shared infrastructure
    ├── src/
    └── Library.Jewelix.Core.sln
```

---

## 🎨 Branding & Design Assets

### Color Palette
All branding colors are documented in:
📁 `Jewelix.Docs/artifacts/images/Color Palette.png`

### Logo Files
- 🎯 **Jewelix.png** - Full logo
- 🎯 **upscaled-logo.png** - High-resolution version
- 🎯 **resized-logo-no-text.png** - Icon-only version

### Icon Files
Multiple `.ico` formats available for various applications and platforms.

---

## 🤝 Contributing

### Development Workflow

#### 1️⃣ Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

#### 2️⃣ Make Your Changes
- Follow existing code styles and patterns
- Write unit tests for new features
- Update documentation as needed

#### 3️⃣ Code Quality Checks

**Frontend**:
```bash
npm run lint
npm run test
```

**Backend**:
```bash
dotnet build
dotnet test
```

#### 4️⃣ Commit and Push
```bash
git add .
git commit -m "feat: describe your changes"
git push origin feature/your-feature-name
```

#### 5️⃣ Create Pull Request
- Reference related issues
- Add description of changes
- Ensure CI/CD checks pass

### Guidelines

- 📝 **Code Style**: Follow existing patterns in each project
- ✅ **Tests**: Maintain or improve test coverage
- 📚 **Documentation**: Update docs for API changes
- 🔄 **Clean Commits**: Use atomic, well-described commits
- 🎯 **Scope**: Keep PRs focused on single features

### Adding New Documentation

1. Place architectural diagrams in `Jewelix.Docs/artifacts/architecture/`
2. Place images and assets in `Jewelix.Docs/artifacts/images/`
3. Update relevant README files
4. Sync this wiki if structure changes

---

## 📞 Support & Resources

### Key Locations
- 📖 **Main Docs**: [Jewelix.Docs/README.md](../README.md)
- 🎨 **Architecture Diagrams**: [Lucidchart](https://lucid.app/lucidchart/2a9b4982-61da-4f12-96d9-3d708875fb5a/edit)
- 🏗️ **Identity Domain Model**: [Jewelix - Domain Model - Draft 1.svg](../artifacts/architecture/Jewelix%20-%20Domain%20Model%20-%20Draft%201.svg)

### Useful Commands Reference

**Frontend Quick Commands**:
```bash
npm start              # Development
npm run build-prod     # Production build
npm run test           # Run tests
npm run lint           # Check code
```

**Backend Quick Commands**:
```bash
dotnet build           # Build
dotnet run            # Run
dotnet test           # Test
dotnet watch run      # Watch mode
```

---

## 📊 Project Status

| Repository | Status | Description |
|------------|--------|-------------|
| Jewelix.Docs | ✅ Active | Documentation hub |
| Jewelix.Web | ✅ Active | Angular v20 frontend |
| Jewelix.Identity | ✅ Active | Identity provider API |
| Library.Jewelix.Core | ✅ Active | Shared infrastructure |

---

## 🔮 Future Roadmap

- 🔐 OAuth 2.0 integration
- 📱 Mobile app development
- 🔔 Real-time notifications
- 📊 Analytics dashboard
- 🌐 Multi-language support expansion
- 🚀 Microservices expansion

---

**Last Updated**: May 2026  
**Project Maintainers**: Jewelix Team  
**License**: See individual repository LICENSE files

---

## Quick Navigation

🏠 [Back to Main Documentation](./README.md) | 📚 [Explore All Docs](./artifacts/architecture/) | 🎨 [Design Assets](./artifacts/images/) | 💻 [Code Repositories](#-repositories)
