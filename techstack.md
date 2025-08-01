# Technology Stack - Wangkanai Tabler

## 🎯 Overview

This document provides a comprehensive overview of the technology stack used in the Wangkanai Tabler Blazor component library, including core technologies, development tools, build pipeline, testing frameworks, and deployment infrastructure.

## 🏗️ Core Technology Stack

### .NET Ecosystem

#### Target Framework
- **.NET 9.0** (Primary Target)
  - **Justification**: Latest LTS version with performance improvements and new features
  - **Compatibility**: Backward compatible with .NET 8.0 applications
  - **Features**: Native AOT support, improved Blazor performance, enhanced nullable reference types

#### Language Features
- **C# 12** 
  - Primary expressions
  - Collection expressions
  - Ref readonly parameters
  - Default lambda parameters
  - Alias any type
  - Inline arrays

#### Runtime Targets
- **Blazor Server**: Server-side rendering with SignalR connection
- **Blazor WebAssembly**: Client-side execution in browser
- **Blazor Hybrid**: Desktop and mobile applications (MAUI support)

### Blazor Component Framework

#### Core Components
```xml
<PackageReference Include="Microsoft.AspNetCore.Components" Version="9.0.0" />
<PackageReference Include="Microsoft.AspNetCore.Components.Web" Version="9.0.0" />
<PackageReference Include="Microsoft.AspNetCore.Components.Forms" Version="9.0.0" />
<PackageReference Include="Microsoft.AspNetCore.Components.Authorization" Version="9.0.0" />
```

#### Component Features
- **Parameter Binding**: Two-way data binding with `@bind`
- **Event Handling**: Async event callbacks and custom events
- **Lifecycle Methods**: Component initialization and disposal
- **Cascading Parameters**: Parent-to-child data flow
- **Templates**: `RenderFragment` for flexible content projection
- **State Management**: Component-level and application-level state

### CSS Framework & Styling

#### Base Framework
- **Tabler CSS 1.4.0+**
  - Source: `@tabler/core` npm package
  - License: MIT
  - Features: Complete admin dashboard CSS framework
  - Components: 100+ pre-designed components
  - Responsive: Mobile-first design approach

#### CSS Processing Pipeline
- **SCSS/Sass 1.89.2+**
  - Source-to-CSS compilation
  - Variable customization
  - Mixin libraries
  - Modular architecture

#### CSS Optimization
- **CleanCSS 5.6.3+**
  - CSS minification and optimization
  - Dead code elimination
  - Source map generation
  - Compression and gzipping

## 🛠️ Development Tools

### Integrated Development Environments

#### Primary IDEs
- **Visual Studio 2022 (17.13+)**
  - Blazor debugging support
  - IntelliSense for Razor components
  - Built-in SCSS support
  - Integrated testing tools
  - NuGet package management

- **JetBrains Rider 2025.1+**
  - Advanced Blazor support
  - Superior refactoring tools
  - Built-in version control
  - Database tools integration
  - Performance profiling

#### Alternative Editors
- **Visual Studio Code**
  - C# extension pack
  - Blazor WASM debugging
  - SCSS/Sass extensions
  - GitLens integration

### Development SDKs

#### .NET SDK
```bash
# Required SDK version
.NET SDK 9.0.0+

# Verification command
dotnet --version
```

#### Node.js Ecosystem
```bash
# Required for CSS build pipeline
Node.js 22.x LTS+
npm 10.x+

# Global tools
npm install -g sass
npm install -g clean-css-cli
```

### Code Quality Tools

#### Static Analysis
- **Microsoft.CodeAnalysis.NetAnalyzers**
  - Code quality rules
  - Performance analyzers
  - Security vulnerability detection
  - Maintainability metrics

- **SonarCloud Integration**
  - Continuous code quality monitoring
  - Technical debt tracking
  - Security hotspot detection
  - Code coverage analysis

#### Formatting & Linting
- **EditorConfig**
  - Consistent code formatting
  - Cross-IDE compatibility
  - Team-wide standards enforcement

- **Nullable Reference Types**
  - Compile-time null safety
  - Enhanced IntelliSense
  - Runtime exception prevention

### Version Control

#### Git Configuration
```bash
# Repository structure
Repository: github.com/wangkanai/tabler
Primary Branch: main
Development Branch: develop
Feature Branches: feature/*
Release Branches: release/*
Hotfix Branches: hotfix/*
```

#### Git Hooks
- **Pre-commit**: Code formatting, linting
- **Pre-push**: Test execution, build verification
- **Commit Message**: Conventional commit format validation

## 🏗️ Build & Development Pipeline

### Build System

#### MSBuild Configuration
```xml
<!-- Directory.Build.props -->
<Project>
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <WarningsNotAsErrors>NU1603</WarningsNotAsErrors>
  </PropertyGroup>
</Project>
```

#### Build Scripts
```powershell
# Primary build script: build.ps1
param(
    [string]$Configuration = "Release",
    [switch]$Test,
    [switch]$Pack
)

# Restore dependencies
dotnet restore

# Build solution
dotnet build --configuration $Configuration --no-restore

# Run tests
if ($Test) {
    dotnet test --configuration $Configuration --no-build --verbosity normal
}

# Create NuGet packages
if ($Pack) {
    dotnet pack --configuration $Configuration --no-build --output ./packages
}
```

### CSS Build Pipeline

#### Package Configuration
```json
{
  "name": "wangkanai-tabler-web",
  "version": "4.4.0",
  "scripts": {
    "build": "npm-run-all clean sass minify copy",
    "clean": "rimraf wwwroot/dist/*",
    "sass": "sass wwwroot/scss/tabler.scss:wwwroot/dist/tabler.css --source-map",
    "minify": "cleancss -o wwwroot/dist/tabler.min.css wwwroot/dist/tabler.css",
    "copy": "cpy wwwroot/dist/* ../Components/wwwroot/",
    "watch": "nodemon --watch wwwroot/scss --ext scss --exec 'npm run build'",
    "dev": "npm run watch"
  },
  "devDependencies": {
    "sass": "^1.89.2",
    "clean-css-cli": "^5.6.3",
    "nodemon": "^3.1.10",
    "npm-run-all": "^4.1.5",
    "cpy-cli": "^5.0.0",
    "rimraf": "^6.0.1"
  },
  "dependencies": {
    "@tabler/core": "^1.4.0",
    "rfs": "^10.0.0"
  }
}
```

#### SCSS Architecture
```scss
// wwwroot/scss/tabler.scss - Main entry point
@import "variables";      // Custom CSS variables
@import "mixins";         // Utility mixins
@import "base";           // Base component styles
@import "components";     // Component-specific styles
@import "utilities";      // Utility classes
@import "themes";         // Theme variations

// Import Tabler core (base framework)
@import "~@tabler/core/src/scss/tabler";
```

### Continuous Integration

#### GitHub Actions Workflow
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '9.0.x'
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '22'
        cache: 'npm'
        cache-dependency-path: src/Web/package-lock.json
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build CSS
      run: |
        cd src/Web
        npm ci
        npm run build
    
    - name: Build solution
      run: dotnet build --configuration Release --no-restore
    
    - name: Run tests
      run: dotnet test --configuration Release --no-build --verbosity normal --collect:"XPlat Code Coverage"
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v4
```

## 🧪 Testing Framework

### Unit Testing Stack

#### Core Testing Framework
```xml
<PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.12.0" />
<PackageReference Include="xunit" Version="2.9.2" />
<PackageReference Include="xunit.runner.visualstudio" Version="2.8.2" />
<PackageReference Include="coverlet.collector" Version="6.0.2" />
```

#### Blazor Testing
```xml
<PackageReference Include="bunit" Version="1.31.3" />
<PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="9.0.0" />
<PackageReference Include="AngleSharp" Version="1.1.2" />
```

#### Assertion Libraries
```xml
<PackageReference Include="FluentAssertions" Version="6.12.1" />
<PackageReference Include="Shouldly" Version="4.2.1" />
```

#### Mocking Framework
```xml
<PackageReference Include="NSubstitute" Version="5.3.0" />
<PackageReference Include="Moq" Version="4.20.72" />
```

### Testing Categories

#### Unit Tests
- **Component Logic Testing**: Parameter handling, CSS class generation
- **Service Testing**: Business logic validation
- **Utility Testing**: Helper methods and extensions
- **Model Testing**: Data validation and transformation

#### Integration Tests
- **Component Interaction**: Parent-child component communication
- **Form Validation**: End-to-end form scenarios
- **Event Handling**: User interaction workflows

#### Performance Tests
```xml
<PackageReference Include="BenchmarkDotNet" Version="0.14.0" />
<PackageReference Include="NBomber" Version="5.10.5" />
```

### Test Organization
```
tests/
├── Unit/                           # Unit tests
│   ├── Components/
│   │   ├── Base/
│   │   ├── Forms/
│   │   └── Layout/
│   ├── Services/
│   └── Utilities/
├── Integration/                    # Integration tests
│   ├── Components/
│   ├── Forms/
│   └── Scenarios/
├── Functional/                     # End-to-end tests
│   ├── UserWorkflows/
│   └── AccessibilityTests/
└── Performance/                    # Performance benchmarks
    ├── ComponentBenchmarks/
    └── RenderingBenchmarks/
```

## 📦 Package Management

### NuGet Packages

#### Core Packages
```xml
<!-- Main component library -->
<PackageReference Include="Wangkanai.Tabler" Version="4.4.0" />

<!-- Optional extensions -->
<PackageReference Include="Wangkanai.Tabler.Extensions" Version="4.4.0" />
<PackageReference Include="Wangkanai.Tabler.Validation" Version="4.4.0" />
```

#### Package Configuration
```xml
<PropertyGroup>
  <PackageId>Wangkanai.Tabler</PackageId>
  <Version>4.4.0</Version>
  <Authors>Sarin Na Wangkanai</Authors>
  <Company>Wangkanai</Company>
  <Product>Wangkanai Tabler</Product>
  <Description>A robust integration of the Tabler CSS framework into Blazor</Description>
  <PackageTags>aspnetcore;blazor;tabler;ui;components;admin;dashboard</PackageTags>
  <PackageLicenseExpression>Apache-2.0</PackageLicenseExpression>
  <PackageProjectUrl>https://github.com/wangkanai/tabler</PackageProjectUrl>
  <RepositoryUrl>https://github.com/wangkanai/tabler</RepositoryUrl>
  <RepositoryType>git</RepositoryType>
  <PackageIcon>icon.png</PackageIcon>
  <PackageReadmeFile>README.md</PackageReadmeFile>
</PropertyGroup>
```

### NPM Packages

#### Frontend Dependencies
```json
{
  "dependencies": {
    "@tabler/core": "^1.4.0",
    "@tabler/icons": "^3.21.0",
    "rfs": "^10.0.0"
  },
  "devDependencies": {
    "sass": "^1.89.2",
    "clean-css-cli": "^5.6.3",
    "nodemon": "^3.1.10",
    "npm-run-all": "^4.1.5",
    "cpy-cli": "^5.0.0",
    "rimraf": "^6.0.1",
    "postcss": "^8.4.49",
    "autoprefixer": "^10.4.20"
  }
}
```

## 🌐 Browser Support Matrix

### Modern Browser Support

#### Desktop Browsers
| Browser | Minimum Version | Current Support | Features |
|---------|----------------|-----------------|----------|
| Chrome | 90+ | ✅ Full | All features supported |
| Firefox | 88+ | ✅ Full | All features supported |
| Safari | 14+ | ✅ Full | All features supported |
| Edge | 90+ | ✅ Full | All features supported |
| Opera | 76+ | ✅ Full | All features supported |

#### Mobile Browsers
| Browser | Minimum Version | Current Support | Features |
|---------|----------------|-----------------|----------|
| iOS Safari | 14+ | ✅ Full | Touch optimized |
| Chrome Mobile | 90+ | ✅ Full | Touch optimized |
| Firefox Mobile | 88+ | ✅ Full | Touch optimized |
| Samsung Internet | 14+ | ✅ Full | Touch optimized |

### Feature Support

#### CSS Features
- **CSS Grid**: Full support across all target browsers
- **Flexbox**: Full support across all target browsers
- **CSS Custom Properties**: Full support across all target browsers
- **CSS Container Queries**: Supported in Chrome 105+, Firefox 110+, Safari 16+

#### JavaScript Features
- **ES2020 Modules**: Required for Blazor WebAssembly
- **WebAssembly**: Required for Blazor WebAssembly
- **Web Components**: Optional for advanced scenarios

## ⚡ Performance Tools

### Build Performance

#### Compilation Optimization
- **ReadyToRun Images**: Faster application startup
- **Trimming**: Reduced application size
- **AOT Compilation**: Ahead-of-time compilation for WebAssembly

#### Bundle Analysis
```bash
# Analyze bundle size
dotnet publish -c Release --verbosity normal

# CSS bundle analysis
npm run build -- --analyze
```

### Runtime Performance

#### Monitoring Tools
- **Application Insights**: Azure-based monitoring
- **Blazor DevTools**: Browser extension for debugging
- **Performance Timeline**: Browser performance profiling

#### Metrics Collection
```csharp
// Performance metrics
public class ComponentPerformanceMetrics
{
    public TimeSpan RenderTime { get; set; }
    public long MemoryUsage { get; set; }
    public int ComponentCount { get; set; }
    public double BundleSize { get; set; }
}
```

## 🔒 Security Tools

### Code Security

#### Static Analysis Security Testing (SAST)
- **SonarCloud Security Rules**: Vulnerability detection
- **CodeQL**: GitHub's semantic code analysis
- **Security Code Scan**: .NET security analyzer

#### Dependency Scanning
```bash
# Check for security vulnerabilities
dotnet list package --vulnerable
npm audit
```

### Runtime Security

#### Content Security Policy
```http
Content-Security-Policy: 
  default-src 'self';
  style-src 'self' 'unsafe-inline';
  script-src 'self';
  img-src 'self' data: blob:;
  font-src 'self';
  connect-src 'self';
```

#### Authentication & Authorization
- **ASP.NET Core Identity**: User management
- **JWT Bearer**: API authentication
- **OAuth 2.0/OpenID Connect**: Third-party authentication

## 📊 Monitoring & Analytics

### Application Performance Monitoring

#### Azure Application Insights
```xml
<PackageReference Include="Microsoft.ApplicationInsights.AspNetCore" Version="2.22.0" />
```

#### Custom Telemetry
```csharp
// Component usage telemetry
public class TablerTelemetryService
{
    private readonly TelemetryClient _telemetryClient;
    
    public void TrackComponentUsage(string componentName, Dictionary<string, string> properties)
    {
        _telemetryClient.TrackEvent($"Component.{componentName}.Used", properties);
    }
}
```

### Build Analytics

#### GitHub Actions Insights
- Build duration tracking
- Test execution metrics
- Deployment success rates
- Code coverage trends

## 🚀 Deployment Infrastructure

### Hosting Platforms

#### Blazor Server
- **Azure App Service**: Managed hosting platform
- **Azure Container Instances**: Container-based deployment
- **On-premises IIS**: Windows Server hosting

#### Blazor WebAssembly
- **Azure Static Web Apps**: Static hosting with APIs
- **GitHub Pages**: Static site hosting
- **Netlify**: JAMstack deployment platform
- **Vercel**: Frontend deployment platform

### Container Support

#### Docker Configuration
```dockerfile
# Dockerfile for Blazor Server
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["src/Components/Wangkanai.Tabler.Components.csproj", "src/Components/"]
RUN dotnet restore "src/Components/Wangkanai.Tabler.Components.csproj"
COPY . .
WORKDIR "/src/src/Components"
RUN dotnet build "Wangkanai.Tabler.Components.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Wangkanai.Tabler.Components.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Wangkanai.Tabler.Components.dll"]
```

## 📋 Tool Requirements Summary

### Development Machine Requirements

#### Essential Software
```bash
# .NET Development
.NET 9.0 SDK
Visual Studio 2022 17.13+ OR JetBrains Rider 2025.1+

# Frontend Development
Node.js 22.x LTS+
npm 10.x+

# Version Control
Git 2.40+
```

#### Optional but Recommended
```bash
# Additional Tools
PowerShell 7+
Docker Desktop
Azure CLI (for cloud deployment)
GitHub CLI (for repository management)
```

### CI/CD Pipeline Requirements

#### Build Agents
- **GitHub Actions**: ubuntu-latest, windows-latest, macos-latest
- **Azure DevOps**: VS2022 build agents
- **Self-hosted**: Windows Server 2022, Ubuntu 22.04 LTS

#### Required Capabilities
- .NET 9.0 SDK
- Node.js 22.x LTS
- Git 2.40+
- Docker (for containerized builds)

## 🔄 Version Management

### Semantic Versioning
```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]

Examples:
4.4.0          (Stable release)
4.4.1-alpha.1  (Pre-release)
4.4.1+build.1  (Build metadata)
```

### Release Channels
- **Stable**: Production-ready releases
- **Preview**: Beta features for testing
- **Nightly**: Daily builds from develop branch

### Compatibility Matrix
| Tabler Version | .NET Version | Blazor Version | Support Status |
|----------------|-------------|----------------|----------------|
| 4.4.x | .NET 9.0 | 9.0.x | Current |
| 4.3.x | .NET 8.0 | 8.0.x | Maintenance |
| 4.2.x | .NET 8.0 | 8.0.x | End of Life |

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-30  
**Technology Stack**: Current as of Wangkanai Tabler v4.4.0  
**Maintainer**: Wangkanai Development Team  
**Next Review**: 2025-04-30