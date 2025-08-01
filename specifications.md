# Technical Specifications - Wangkanai Tabler

## 🎯 Overview

This document provides detailed technical specifications for the Wangkanai Tabler Blazor component library, including API specifications, component specifications, system requirements, and technical constraints.

## 🏗️ System Architecture Specifications

### Target Framework
- **.NET 9.0**: Primary target framework
- **C# 12**: Language version with nullable reference types
- **Blazor Components**: Server and WebAssembly hosting models

### Assembly Structure
```
Wangkanai.Tabler.dll                    # Core services and extensions
├── Extensions/
├── Options/
└── Services/

Wangkanai.Tabler.Components.dll         # Component library
├── Base/
├── Layout/
├── Navigation/
├── Forms/
├── Data/
├── Feedback/
└── Models/

Wangkanai.Tabler.Components.Web.dll     # CSS and static assets
├── wwwroot/dist/
└── wwwroot/scss/
```

### Dependency Specifications

#### Core Dependencies
```xml
<PackageReference Include="Microsoft.AspNetCore.Components" Version="9.0.0" />
<PackageReference Include="Microsoft.AspNetCore.Components.Web" Version="9.0.0" />
```

#### Optional Dependencies
```xml
<PackageReference Include="Wangkanai.Validation" Version="4.4.0" Condition="$(UseValidation)" />
<PackageReference Include="Wangkanai.Detection" Version="4.4.0" Condition="$(UseDetection)" />
```

#### Build Dependencies
```json
{
  "devDependencies": {
    "sass": "^1.89.2",
    "clean-css-cli": "^5.6.3", 
    "nodemon": "^3.1.10",
    "@tabler/core": "^1.4.0"
  }
}
```

## 📐 Component API Specifications

### Base Component Interface

#### ITablerComponent
```csharp
public interface ITablerComponent
{
    /// <summary>
    /// Additional attributes to be applied to the component's root element.
    /// </summary>
    Dictionary<string, object>? AdditionalAttributes { get; set; }
    
    /// <summary>
    /// Custom CSS class to be applied to the component.
    /// </summary>
    string? CssClass { get; set; }
    
    /// <summary>
    /// Unique identifier for the component.
    /// </summary>
    string? Id { get; set; }
}
```

#### TablerComponentBase
```csharp
public abstract class TablerComponentBase : ComponentBase, ITablerComponent
{
    [Parameter(CaptureUnmatchedValues = true)]
    public Dictionary<string, object>? AdditionalAttributes { get; set; }
    
    [Parameter] public string? CssClass { get; set; }
    [Parameter] public string? Id { get; set; }
    
    /// <summary>
    /// Gets the computed CSS classes for the component.
    /// </summary>
    protected abstract string ComputedCssClass { get; }
    
    /// <summary>
    /// Generates the final CSS class string combining base classes and custom classes.
    /// </summary>
    protected virtual string BuildCssClass(params string[] baseClasses)
    {
        var classes = new List<string>(baseClasses);
        
        if (!string.IsNullOrWhiteSpace(CssClass))
            classes.Add(CssClass);
            
        return string.Join(" ", classes).Trim();
    }
}
```

### Component Parameter Specifications

#### Color System
```csharp
public enum ComponentColor
{
    None = 0,
    Primary = 1,
    Secondary = 2,
    Success = 3,
    Danger = 4,
    Warning = 5,
    Info = 6,
    Light = 7,
    Dark = 8,
    Muted = 9
}
```

#### Size System
```csharp
public enum ComponentSize
{
    ExtraSmall = 1,
    Small = 2,
    Medium = 3,    // Default
    Large = 4,
    ExtraLarge = 5
}
```

#### Variant System
```csharp
public enum ComponentVariant
{
    Default = 0,
    Solid = 1,
    Outline = 2,
    Ghost = 3,
    Minimal = 4
}
```

## 🧩 Component-Specific Specifications

### TablerButton Specification

#### API Surface
```csharp
public partial class TablerButton : TablerComponentBase
{
    // Visual Properties
    [Parameter] public ButtonColor Color { get; set; } = ButtonColor.Primary;
    [Parameter] public ButtonSize Size { get; set; } = ButtonSize.Medium;
    [Parameter] public ButtonVariant Variant { get; set; } = ButtonVariant.Solid;
    
    // State Properties
    [Parameter] public bool Disabled { get; set; }
    [Parameter] public bool Loading { get; set; }
    [Parameter] public bool Block { get; set; }
    
    // Content Properties
    [Parameter] public RenderFragment? ChildContent { get; set; }
    [Parameter] public RenderFragment? IconContent { get; set; }
    [Parameter] public string? Text { get; set; }
    
    // Behavior Properties
    [Parameter] public string? Type { get; set; } = "button";
    [Parameter] public string? Href { get; set; }
    [Parameter] public string? Target { get; set; }
    
    // Events
    [Parameter] public EventCallback OnClick { get; set; }
    [Parameter] public EventCallback<MouseEventArgs> OnMouseOver { get; set; }
    [Parameter] public EventCallback<MouseEventArgs> OnMouseOut { get; set; }
}
```

#### CSS Class Mapping
```csharp
private string GetButtonClasses()
{
    var classes = new List<string> { "btn" };
    
    // Color classes
    classes.Add(Color switch
    {
        ButtonColor.Primary => "btn-primary",
        ButtonColor.Secondary => "btn-secondary",
        ButtonColor.Success => "btn-success",
        ButtonColor.Danger => "btn-danger",
        ButtonColor.Warning => "btn-warning",
        ButtonColor.Info => "btn-info",
        ButtonColor.Light => "btn-light",
        ButtonColor.Dark => "btn-dark",
        _ => "btn-primary"
    });
    
    // Size classes
    if (Size != ButtonSize.Medium)
    {
        classes.Add(Size switch
        {
            ButtonSize.Small => "btn-sm",
            ButtonSize.Large => "btn-lg",
            _ => string.Empty
        });
    }
    
    // Variant classes
    if (Variant == ButtonVariant.Outline)
        classes[1] = classes[1].Replace("btn-", "btn-outline-");
    
    // State classes
    if (Disabled) classes.Add("disabled");
    if (Loading) classes.Add("loading");
    if (Block) classes.Add("btn-block");
    
    return string.Join(" ", classes.Where(c => !string.IsNullOrEmpty(c)));
}
```

### TablerForm Specification

#### API Surface
```csharp
public partial class TablerForm : TablerComponentBase
{
    // Form Properties
    [Parameter] public string? Method { get; set; } = "post";
    [Parameter] public string? Action { get; set; }
    [Parameter] public string? Enctype { get; set; }
    [Parameter] public bool NoValidate { get; set; }
    
    // Validation Properties
    [Parameter] public object? Model { get; set; }
    [Parameter] public EditContext? EditContext { get; set; }
    [Parameter] public bool EnableValidation { get; set; } = true;
    
    // Layout Properties
    [Parameter] public FormLayout Layout { get; set; } = FormLayout.Vertical;
    [Parameter] public FormSize Size { get; set; } = FormSize.Medium;
    
    // Content Properties
    [Parameter] public RenderFragment? ChildContent { get; set; }
    
    // Events
    [Parameter] public EventCallback<EditContext> OnValidSubmit { get; set; }
    [Parameter] public EventCallback<EditContext> OnInvalidSubmit { get; set; }
    [Parameter] public EventCallback<EditContext> OnSubmit { get; set; }
}
```

### TablerTable Specification

#### API Surface
```csharp
public partial class TablerTable<TItem> : TablerComponentBase where TItem : class
{
    // Data Properties
    [Parameter, EditorRequired] public IEnumerable<TItem> Items { get; set; } = Array.Empty<TItem>();
    [Parameter] public Func<TItem, object?>? KeySelector { get; set; }
    
    // Display Properties
    [Parameter] public bool Striped { get; set; }
    [Parameter] public bool Bordered { get; set; }
    [Parameter] public bool Hoverable { get; set; }
    [Parameter] public bool Responsive { get; set; } = true;
    [Parameter] public TableSize Size { get; set; } = TableSize.Medium;
    
    // Functionality Properties
    [Parameter] public bool Sortable { get; set; }
    [Parameter] public bool Filterable { get; set; }
    [Parameter] public bool Paginated { get; set; }
    [Parameter] public int PageSize { get; set; } = 10;
    
    // Content Properties
    [Parameter] public RenderFragment<TItem>? RowTemplate { get; set; }
    [Parameter] public RenderFragment? HeaderTemplate { get; set; }
    [Parameter] public RenderFragment? EmptyTemplate { get; set; }
    [Parameter] public RenderFragment? LoadingTemplate { get; set; }
    
    // Events
    [Parameter] public EventCallback<TItem> OnRowClick { get; set; }
    [Parameter] public EventCallback<TableSortEventArgs> OnSort { get; set; }
    [Parameter] public EventCallback<TableFilterEventArgs> OnFilter { get; set; }
}
```

## 🎨 CSS Specifications

### CSS Architecture
```scss
// Base Tabler CSS (from @tabler/core)
@import "node_modules/@tabler/core/dist/css/tabler.min.css";

// Custom Tabler extensions
@import "scss/variables";     // Custom CSS variables
@import "scss/mixins";        // Utility mixins
@import "scss/components";    // Component-specific styles
@import "scss/utilities";     // Utility classes
@import "scss/themes";        // Theme variations
```

### CSS Custom Properties
```css
:root {
  /* Tabler Component Colors */
  --tblr-component-primary: #0369a1;
  --tblr-component-secondary: #6b7280;
  --tblr-component-success: #16a34a;
  --tblr-component-danger: #dc2626;
  --tblr-component-warning: #d97706;
  --tblr-component-info: #0891b2;
  
  /* Component Sizes */
  --tblr-component-size-sm: 0.875rem;
  --tblr-component-size-md: 1rem;
  --tblr-component-size-lg: 1.125rem;
  --tblr-component-size-xl: 1.25rem;
  
  /* Spacing */
  --tblr-component-padding-sm: 0.375rem 0.75rem;
  --tblr-component-padding-md: 0.5rem 1rem;
  --tblr-component-padding-lg: 0.75rem 1.5rem;
  
  /* Border Radius */
  --tblr-component-border-radius: 0.375rem;
  --tblr-component-border-radius-sm: 0.25rem;
  --tblr-component-border-radius-lg: 0.5rem;
}
```

### Component CSS Structure
```scss
// Component-specific SCSS structure
.tabler-component {
  // Base styles
  display: inline-block;
  position: relative;
  
  // Size variants
  &.small { font-size: var(--tblr-component-size-sm); }
  &.large { font-size: var(--tblr-component-size-lg); }
  
  // Color variants
  &.primary { color: var(--tblr-component-primary); }
  &.secondary { color: var(--tblr-component-secondary); }
  
  // State classes
  &.disabled {
    opacity: 0.6;
    pointer-events: none;
  }
  
  &.loading {
    position: relative;
    pointer-events: none;
    
    &::after {
      content: "";
      position: absolute;
      // Loading spinner styles
    }
  }
}
```

## 🔧 Build Specifications

### SCSS Build Pipeline
```json
{
  "scripts": {
    "build": "npm-run-all clean sass minify",
    "clean": "rimraf wwwroot/dist/*",
    "sass": "sass wwwroot/scss/tabler.scss:wwwroot/dist/tabler.css --source-map",
    "minify": "cleancss -o wwwroot/dist/tabler.min.css wwwroot/dist/tabler.css",
    "watch": "nodemon --watch wwwroot/scss --ext scss --exec 'npm run build'"
  }
}
```

### MSBuild Integration
```xml
<Target Name="BuildCSS" BeforeTargets="Build">
  <Exec Command="npm run build" 
        WorkingDirectory="$(ProjectDir)" 
        Condition="Exists('$(ProjectDir)package.json')" />
</Target>
```

## 📏 Performance Specifications

### Rendering Performance
| Metric | Target | Measurement |
|--------|--------|-------------|
| Component Render Time | < 50ms | BenchmarkDotNet |
| Initial Load Time | < 500ms | Browser DevTools |
| Bundle Size (CSS) | < 2MB | Build output |
| Bundle Size (JS) | < 1MB | Build output |
| Memory Usage | < 100MB | Process monitoring |

### Benchmark Specifications
```csharp
[MemoryDiagnoser]
[SimpleJob(RuntimeMoniker.Net90)]
public class ComponentRenderBenchmarks
{
    private TestContext _testContext = null!;
    
    [GlobalSetup]
    public void Setup()
    {
        _testContext = new TestContext();
    }
    
    [Benchmark]
    public void RenderTablerButton()
    {
        var component = _testContext.RenderComponent<TablerButton>(parameters => parameters
            .Add(p => p.Color, ButtonColor.Primary)
            .Add(p => p.Text, "Click Me"));
            
        // Force render
        _ = component.Markup;
    }
    
    [GlobalCleanup]
    public void Cleanup()
    {
        _testContext?.Dispose();
    }
}
```

## 🌐 Browser Support Specifications

### Supported Browsers
| Browser | Minimum Version | Features |
|---------|----------------|----------|
| Chrome | 90+ | Full support |
| Firefox | 88+ | Full support |
| Safari | 14+ | Full support |
| Edge | 90+ | Full support |
| iOS Safari | 14+ | Touch optimized |
| Chrome Mobile | 90+ | Touch optimized |

### Feature Support Matrix
| Feature | Chrome | Firefox | Safari | Edge | Notes |
|---------|--------|---------|--------|------|-------|
| CSS Grid | ✅ | ✅ | ✅ | ✅ | Layout components |
| CSS Custom Properties | ✅ | ✅ | ✅ | ✅ | Theming system |
| CSS Container Queries | ✅ | ✅ | ⚠️ | ✅ | Safari 16+ |
| JavaScript Modules | ✅ | ✅ | ✅ | ✅ | Blazor framework |

### Polyfill Requirements
- None required for target browser versions
- CSS fallbacks provided for older properties
- Progressive enhancement approach

## ♿ Accessibility Specifications

### WCAG 2.1 AA Compliance

#### Required ARIA Attributes
```html
<!-- Interactive components -->
<button type="button"
        aria-label="Button description"
        aria-describedby="help-text"
        aria-expanded="false"
        aria-pressed="false">
  Button Content
</button>

<!-- Form components -->
<input type="text"
       id="input-id"
       aria-label="Input description"
       aria-required="true"
       aria-invalid="false"
       aria-describedby="error-message">

<!-- Modal components -->
<div role="dialog"
     aria-modal="true"
     aria-labelledby="modal-title"
     aria-describedby="modal-description">
  Modal Content
</div>
```

#### Color Contrast Requirements
| Element Type | Minimum Ratio | Target Ratio |
|--------------|---------------|--------------|
| Normal Text | 4.5:1 | 7:1 |
| Large Text (18pt+) | 3:1 | 4.5:1 |
| UI Components | 3:1 | 4.5:1 |
| Graphics | 3:1 | 4.5:1 |

#### Keyboard Navigation
- **Tab Order**: Logical and intuitive
- **Focus Management**: Visible focus indicators
- **Keyboard Shortcuts**: Standard shortcuts supported
- **Escape Handling**: Closes modals and dropdowns

### Screen Reader Support
| Screen Reader | Version | Support Level |
|---------------|---------|---------------|
| NVDA | 2023+ | Full support |
| JAWS | 2023+ | Full support |
| VoiceOver | macOS 12+ | Full support |
| TalkBack | Android 12+ | Full support |

## 🔒 Security Specifications

### Input Sanitization
```csharp
public static class InputSanitizer
{
    private static readonly Regex HtmlTagRegex = new(@"<[^>]*>", RegexOptions.Compiled);
    private static readonly Regex ScriptRegex = new(@"<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>", 
        RegexOptions.IgnoreCase | RegexOptions.Compiled);
    
    public static string SanitizeHtml(string? input)
    {
        if (string.IsNullOrWhiteSpace(input))
            return string.Empty;
            
        // Remove script tags
        input = ScriptRegex.Replace(input, string.Empty);
        
        // Remove HTML tags (optional, based on requirements)
        input = HtmlTagRegex.Replace(input, string.Empty);
        
        return input.Trim();
    }
    
    public static string SanitizeCssClass(string? input)
    {
        if (string.IsNullOrWhiteSpace(input))
            return string.Empty;
            
        // Allow only alphanumeric, hyphens, underscores, and spaces
        return Regex.Replace(input, @"[^a-zA-Z0-9\-_\s]", string.Empty);
    }
}
```

### Content Security Policy
```
Content-Security-Policy: 
  default-src 'self';
  style-src 'self' 'unsafe-inline';
  script-src 'self';
  img-src 'self' data: blob:;
  font-src 'self';
  connect-src 'self';
```

## 📦 Package Specifications

### NuGet Package Metadata
```xml
<PropertyGroup>
  <PackageId>Wangkanai.Tabler</PackageId>
  <Version>4.4.0</Version>
  <Authors>Sarin Na Wangkanai</Authors>
  <Company>Wangkanai</Company>
  <Product>Wangkanai Tabler</Product>
  <Description>A robust integration of the Tabler CSS framework into Blazor</Description>
  <PackageTags>aspnetcore;blazor;tabler;ui;components</PackageTags>
  <PackageLicenseExpression>Apache-2.0</PackageLicenseExpression>
  <PackageProjectUrl>https://github.com/wangkanai/tabler</PackageProjectUrl>
  <RepositoryUrl>https://github.com/wangkanai/tabler</RepositoryUrl>
  <RepositoryType>git</RepositoryType>
</PropertyGroup>
```

### Package Dependencies
```xml
<ItemGroup>
  <PackageReference Include="Microsoft.AspNetCore.Components" Version="9.0.0" />
  <PackageReference Include="Microsoft.AspNetCore.Components.Web" Version="9.0.0" />
</ItemGroup>
```

### Multi-Targeting Support
```xml
<PropertyGroup>
  <TargetFrameworks>net8.0;net9.0</TargetFrameworks>
</PropertyGroup>
```

## 🧪 Testing Specifications

### Unit Test Requirements
- **Test Framework**: xUnit v3
- **Test Runner**: dotnet test
- **Coverage Tool**: Built-in .NET coverage
- **Assertion Library**: FluentAssertions
- **Mocking**: NSubstitute (when needed)

### Test Categories
```csharp
[Trait("Category", "Unit")]
[Trait("Component", "TablerButton")]
public class TablerButtonTests { }

[Trait("Category", "Integration")]
[Trait("Component", "TablerForm")]
public class TablerFormIntegrationTests { }

[Trait("Category", "Performance")]
[Trait("Component", "TablerTable")]
public class TablerTablePerformanceTests { }
```

### Coverage Requirements
| Test Type | Minimum Coverage | Target Coverage |
|-----------|------------------|-----------------|
| Unit Tests | 90% | 95% |
| Integration Tests | 80% | 90% |
| End-to-End Tests | 70% | 80% |

## 📊 Monitoring and Metrics

### Performance Metrics
```csharp
public class ComponentMetrics
{
    public TimeSpan RenderTime { get; set; }
    public long MemoryUsage { get; set; }
    public int ElementCount { get; set; }
    public double CssFileSize { get; set; }
}
```

### Quality Metrics
- **Cyclomatic Complexity**: < 10 per method
- **Lines of Code**: < 100 per component
- **Maintainability Index**: > 70
- **Technical Debt**: < 5% of total development time

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-30  
**Applies To**: Wangkanai Tabler v4.4.0+  
**Specification Level**: Technical Implementation  
**Maintainer**: Wangkanai Development Team