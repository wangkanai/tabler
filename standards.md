# Development Standards - Wangkanai Tabler

## 🎯 Overview

This document defines the development standards, coding conventions, and best practices for the Wangkanai Tabler Blazor component library. These standards ensure code quality, maintainability, and consistency across the entire project.

## 📝 Code Standards

### Naming Conventions

#### Component Naming
- **All components**: Use `Tabler` prefix (e.g., `TablerButton`, `TablerCard`, `TablerNavbar`)
- **Files**: PascalCase matching component name (e.g., `TablerButton.razor`)
- **Namespaces**: `Wangkanai.Tabler.Components.{Category}`
- **CSS Classes**: Follow Tabler's existing class naming conventions

#### Parameter Naming
- **Parameters**: PascalCase with descriptive names (`Color`, `Size`, `IsDisabled`)
- **Event Callbacks**: Use `On` prefix (`OnClick`, `OnValueChanged`, `OnToggle`)
- **Render Fragments**: Descriptive names (`ChildContent`, `HeaderContent`, `FooterContent`)

#### Internal Naming
- **Private fields**: camelCase with underscore prefix (`_isVisible`, `_cssClasses`)
- **Private methods**: PascalCase (`CalculateCssClass`, `HandleButtonClick`)
- **Constants**: UPPER_SNAKE_CASE (`DEFAULT_COLOR`, `MAX_ITEMS`)

### File Organization

#### Project Structure
```
src/
├── Core/                           # Service registration and core utilities
├── Components/                     # All Blazor components
│   ├── Base/                      # Base components (Button, Icon, Badge)
│   ├── Layout/                    # Layout components (Page, Container)
│   ├── Navigation/                # Navigation components (Nav, Tabs)
│   ├── Forms/                     # Form components (Input, Select)
│   ├── Data/                      # Data display (Table, Card, List)
│   ├── Feedback/                  # Feedback (Alert, Modal, Toast)
│   └── Models/                    # Shared models and enums
└── Web/                           # CSS/SCSS and static assets
```

#### File Naming
- **Components**: `{Category}/Tabler{ComponentName}.razor`
- **Code-behind**: `{Category}/Tabler{ComponentName}.razor.cs` (only when needed)
- **Models**: `Models/{ModelName}.cs`
- **Enums**: `Models/{EnumName}.cs`
- **Tests**: `tests/{Category}/Tabler{ComponentName}Tests.cs`

## 🏗️ Component Standards

### Component Structure Template

```csharp
@namespace Wangkanai.Tabler.Components.{Category}
@inherits ComponentBase

<div class="@CssClass" @attributes="AdditionalAttributes">
    @ChildContent
</div>

@code {
    /// <summary>
    /// Child content to be rendered inside the component.
    /// </summary>
    [Parameter] public RenderFragment? ChildContent { get; set; }
    
    /// <summary>
    /// Additional attributes to be applied to the component.
    /// </summary>
    [Parameter(CaptureUnmatchedValues = true)] 
    public Dictionary<string, object>? AdditionalAttributes { get; set; }

    /// <summary>
    /// The color theme for the component.
    /// </summary>
    [Parameter] public ComponentColor Color { get; set; } = ComponentColor.Primary;

    /// <summary>
    /// The size of the component.
    /// </summary>
    [Parameter] public ComponentSize Size { get; set; } = ComponentSize.Medium;

    /// <summary>
    /// Gets the computed CSS classes for the component.
    /// </summary>
    protected string CssClass => string.Join(" ", GetCssClasses()).Trim();

    /// <summary>
    /// Generates the CSS classes for the component.
    /// </summary>
    /// <returns>An enumerable of CSS class names.</returns>
    protected virtual IEnumerable<string> GetCssClasses()
    {
        yield return "tabler-component";
        
        if (Color != ComponentColor.None)
            yield return GetColorClass();
            
        if (Size != ComponentSize.Medium)
            yield return GetSizeClass();
    }

    private string GetColorClass() => Color switch
    {
        ComponentColor.Primary => "text-primary",
        ComponentColor.Secondary => "text-secondary",
        ComponentColor.Success => "text-success",
        ComponentColor.Danger => "text-danger",
        ComponentColor.Warning => "text-warning",
        ComponentColor.Info => "text-info",
        _ => string.Empty
    };

    private string GetSizeClass() => Size switch
    {
        ComponentSize.Small => "small",
        ComponentSize.Large => "large",
        ComponentSize.ExtraLarge => "xl",
        _ => string.Empty
    };
}
```

### Required Component Features

#### Standard Parameters
```csharp
// Always include these parameters in components
[Parameter] public RenderFragment? ChildContent { get; set; }
[Parameter(CaptureUnmatchedValues = true)] public Dictionary<string, object>? AdditionalAttributes { get; set; }

// Include when applicable
[Parameter] public ComponentColor Color { get; set; } = ComponentColor.Primary;
[Parameter] public ComponentSize Size { get; set; } = ComponentSize.Medium;
[Parameter] public bool Disabled { get; set; }
[Parameter] public string? CssClass { get; set; }
[Parameter] public string? Id { get; set; }
```

#### Event Handling Pattern
```csharp
// Async event callback pattern
[Parameter] public EventCallback OnClick { get; set; }
[Parameter] public EventCallback<TValue> OnValueChanged { get; set; }

private async Task HandleClick()
{
    if (Disabled) return;
    
    await OnClick.InvokeAsync();
}

private async Task HandleValueChanged(TValue value)
{
    await OnValueChanged.InvokeAsync(value);
}
```

### CSS Class Management

#### Efficient Class Concatenation
```csharp
protected string CssClass => string.Join(" ", GetCssClasses()).Trim();

protected virtual IEnumerable<string> GetCssClasses()
{
    // Base classes from Tabler
    yield return "btn";
    
    // Conditional classes
    if (Color != ButtonColor.None)
        yield return $"btn-{Color.ToString().ToLowerInvariant()}";
        
    if (Size != ButtonSize.Medium)
        yield return $"btn-{Size.ToString().ToLowerInvariant()}";
        
    // State classes
    if (Disabled)
        yield return "disabled";
        
    if (Loading)
        yield return "loading";
        
    // Custom CSS class
    if (!string.IsNullOrWhiteSpace(CssClass))
        yield return CssClass;
}
```

#### CSS-First Approach
- Leverage existing Tabler CSS classes whenever possible
- Only create custom SCSS for Blazor-specific adaptations
- Use CSS custom properties for theming
- Avoid inline styles; use CSS classes

## 🧪 Testing Standards

### Unit Testing Requirements

#### Test Organization
```csharp
namespace Wangkanai.Tabler.UnitTests.Components.Base;

public class TablerButtonTests
{
    [Fact]
    public void TablerButton_WithDefaultParameters_RendersCorrectly()
    {
        // Arrange & Act
        var component = TestContext.RenderComponent<TablerButton>();
        
        // Assert
        component.MarkupMatches("<button class=\"btn btn-primary\"></button>");
    }
    
    [Theory]
    [InlineData(ButtonColor.Primary, "btn-primary")]
    [InlineData(ButtonColor.Secondary, "btn-secondary")]
    [InlineData(ButtonColor.Success, "btn-success")]
    public void TablerButton_WithColor_RendersCorrectClass(ButtonColor color, string expectedClass)
    {
        // Arrange & Act
        var component = TestContext.RenderComponent<TablerButton>(parameters => parameters
            .Add(p => p.Color, color));
        
        // Assert
        Assert.Contains(expectedClass, component.Markup);
    }
}
```

#### Test Categories
- **Unit Tests**: Component logic and rendering (90%+ coverage)
- **Integration Tests**: Component interaction and composition
- **Accessibility Tests**: ARIA compliance and keyboard navigation
- **Performance Tests**: Render time and memory usage benchmarks

#### Test Naming Convention
- **Method**: `{ComponentName}_{Scenario}_{ExpectedResult}`
- **Files**: `{ComponentName}Tests.cs`
- **Namespace**: `Wangkanai.Tabler.UnitTests.Components.{Category}`

### Quality Gates
- **Test Coverage**: Minimum 90% code coverage
- **Performance**: Components must render in < 50ms
- **Accessibility**: WCAG 2.1 AA compliance
- **Browser Support**: Modern browsers (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)

## 📚 Documentation Standards

### XML Documentation Requirements

#### Component Documentation
```csharp
/// <summary>
/// A customizable button component that supports various colors, sizes, and states.
/// Renders as an HTML button element with Tabler CSS styling.
/// </summary>
/// <example>
/// <code>
/// &lt;TablerButton Color="ButtonColor.Primary" OnClick="HandleClick"&gt;
///     Click Me
/// &lt;/TablerButton&gt;
/// </code>
/// </example>
public partial class TablerButton : ComponentBase
{
    /// <summary>
    /// Gets or sets the color theme for the button.
    /// </summary>
    /// <value>The button color theme. Default is <see cref="ButtonColor.Primary"/>.</value>
    [Parameter] public ButtonColor Color { get; set; } = ButtonColor.Primary;
}
```

#### Required Documentation Elements
- **Component Summary**: Clear description of purpose and behavior
- **Parameter Documentation**: Description, type, and default value
- **Usage Examples**: Code examples showing common usage patterns
- **Accessibility Notes**: Any accessibility considerations
- **Browser Support**: Any browser-specific limitations

### Markdown Documentation
- **README Updates**: Keep component lists current
- **API Documentation**: Document breaking changes
- **Migration Guides**: Help users upgrade between versions

## 🔒 Security Standards

### Input Validation
```csharp
// Sanitize user input
protected string SanitizeUserInput(string? input)
{
    if (string.IsNullOrWhiteSpace(input))
        return string.Empty;
        
    // Remove potentially dangerous characters
    return Regex.Replace(input, @"[<>""']", string.Empty);
}
```

### XSS Prevention
- Always encode user-provided content
- Use `@()` syntax for dynamic content
- Validate and sanitize all input parameters
- Never use `@((MarkupString)userInput)` without sanitization

### Content Security Policy
- Ensure components work with strict CSP
- Avoid inline styles and scripts
- Use nonce-based CSP when required

## 🎨 Accessibility Standards

### WCAG 2.1 AA Compliance

#### Required Attributes
```html
<!-- Buttons and interactive elements -->
<button type="button" 
        aria-label="@AriaLabel"
        aria-describedby="@AriaDescribedBy"
        disabled="@Disabled">
    @ChildContent
</button>

<!-- Form inputs -->
<input type="text"
       id="@Id"
       aria-label="@Label"
       aria-required="@Required"
       aria-invalid="@HasValidationErrors" />
```

#### Keyboard Navigation
- All interactive elements must be keyboard accessible
- Support standard keyboard shortcuts (Enter, Space, Arrow keys)
- Proper focus management and visual focus indicators
- Tab order must be logical and intuitive

#### Screen Reader Support
- Provide descriptive ARIA labels
- Use semantic HTML elements when possible
- Include ARIA roles for custom components
- Ensure content changes are announced appropriately

### Color and Contrast
- Minimum contrast ratio of 4.5:1 for normal text
- Minimum contrast ratio of 3:1 for large text
- Don't rely solely on color to convey information
- Support high contrast themes

## 🚀 Performance Standards

### Rendering Optimization
```csharp
// Use ShouldRender to prevent unnecessary re-renders
protected override bool ShouldRender()
{
    // Only re-render when necessary
    return _hasStateChanged;
}

// Use efficient string operations
private readonly StringBuilder _cssBuilder = new();

protected string BuildCssClass()
{
    _cssBuilder.Clear();
    _cssBuilder.Append("btn");
    
    if (Color != ButtonColor.None)
        _cssBuilder.Append($" btn-{Color.ToString().ToLowerInvariant()}");
        
    return _cssBuilder.ToString();
}
```

### Memory Management
- Dispose of resources properly in `IDisposable` components
- Avoid memory leaks with event handlers
- Use object pooling for frequently created objects
- Minimize allocations in render loops

### Bundle Size Optimization
- Use tree shaking to eliminate unused code
- Lazy load non-critical components
- Optimize CSS bundle size
- Use compression for static assets

## 🔧 Development Workflow

### Code Review Standards

#### Required Checks
- [ ] Follows naming conventions
- [ ] Includes comprehensive tests
- [ ] Has proper XML documentation
- [ ] Meets accessibility requirements
- [ ] Passes performance benchmarks
- [ ] Follows component structure template
- [ ] Includes usage examples

#### Code Quality Tools
- **EditorConfig**: Consistent formatting
- **Analyzers**: Microsoft.CodeAnalysis.NetAnalyzers
- **SonarLint**: Code quality and security
- **Nullable Reference Types**: Enabled project-wide

### Commit Standards

#### Commit Message Format
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

#### Types
- **feat**: New feature or component
- **fix**: Bug fix
- **docs**: Documentation updates
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **perf**: Performance improvements
- **build**: Build system changes

#### Examples
```bash
feat(components): add TablerButton component with color variants
fix(button): resolve accessibility issue with aria-label
docs(readme): update component status table
test(button): add comprehensive unit tests for all variants
```

## 🌐 Internationalization Standards

### Localization Support
```csharp
// Use IStringLocalizer for user-facing text
[Inject] private IStringLocalizer<TablerButton> Localizer { get; set; } = default!;

protected string GetLocalizedText(string key) => Localizer[key];
```

### Text Direction Support
- Support both LTR and RTL text direction
- Use logical CSS properties (margin-inline-start vs margin-left)
- Test with RTL languages (Arabic, Hebrew)

### Cultural Considerations
- Date and number formatting based on culture
- Currency display according to locale
- Respect cultural color meanings

## 📋 Version and Release Standards

### Semantic Versioning
- **Major**: Breaking changes to public API
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, backward compatible

### Release Process
1. Update version numbers
2. Update CHANGELOG.md
3. Run full test suite
4. Performance benchmark validation
5. Create GitHub release with notes
6. Publish NuGet packages
7. Update documentation site

### Breaking Change Policy
- Minimize breaking changes
- Provide migration guides
- Deprecate before removing features
- Support previous version for one major release

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-30  
**Applies To**: Wangkanai Tabler v4.4.0+  
**Maintainer**: Wangkanai Development Team