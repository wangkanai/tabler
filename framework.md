# Framework Architecture - Wangkanai Tabler

## 🎯 Overview

This document describes the architectural framework, design patterns, and structural guidelines for the Wangkanai Tabler Blazor component library. It serves as the blueprint for understanding how components are organized, how they interact, and how the framework enables extensibility and maintainability.

## 🏗️ Architectural Principles

### 1. Layered Architecture

The Wangkanai Tabler framework follows a layered architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │ ← Blazor Components (TablerButton, etc.)
├─────────────────────────────────────────┤
│            Service Layer                │ ← Core Services & Extensions
├─────────────────────────────────────────┤
│            Domain Layer                 │ ← Models, Enums, Interfaces
├─────────────────────────────────────────┤
│         Infrastructure Layer            │ ← CSS Pipeline, Static Assets
└─────────────────────────────────────────┘
```

### 2. Component-Oriented Design

Every UI element is a self-contained, reusable component with:
- **Encapsulation**: Internal state and logic hidden from consumers
- **Composition**: Components can contain other components
- **Inheritance**: Shared functionality through base classes
- **Polymorphism**: Different implementations of common interfaces

### 3. CSS-First Approach

The framework leverages Tabler's existing CSS system:
- **No Custom JavaScript**: All interactions handled by Blazor
- **Minimal Custom CSS**: Only Blazor-specific adaptations
- **Theme Consistency**: Maintains visual fidelity with Tabler design system
- **Performance**: Leverages optimized CSS frameworks

## 🧩 Component Framework

### Component Hierarchy

```
TablerComponentBase (Abstract)
├── ITablerComponent (Interface)
├── IDisposable (Optional)
└── ComponentBase (Blazor Base)

Specialized Base Classes:
├── TablerFormComponentBase<T>     # Form input components
├── TablerDataComponentBase<T>     # Data display components
├── TablerLayoutComponentBase      # Layout containers
└── TablerInteractiveComponentBase # Interactive elements
```

### Base Component Architecture

#### ITablerComponent Interface
```csharp
public interface ITablerComponent
{
    /// <summary>
    /// Additional HTML attributes for the root element.
    /// </summary>
    Dictionary<string, object>? AdditionalAttributes { get; set; }
    
    /// <summary>
    /// Custom CSS classes to apply to the component.
    /// </summary>
    string? CssClass { get; set; }
    
    /// <summary>
    /// Unique identifier for the component.
    /// </summary>
    string? Id { get; set; }
}
```

#### TablerComponentBase Abstract Class
```csharp
public abstract class TablerComponentBase : ComponentBase, ITablerComponent
{
    // Interface Implementation
    [Parameter(CaptureUnmatchedValues = true)]
    public Dictionary<string, object>? AdditionalAttributes { get; set; }
    
    [Parameter] public string? CssClass { get; set; }
    [Parameter] public string? Id { get; set; }
    
    // Component Infrastructure
    protected abstract string BaseCssClass { get; }
    protected virtual string ComputedCssClass => BuildCssClass();
    
    // CSS Class Management
    protected virtual string BuildCssClass()
    {
        var classes = new List<string> { BaseCssClass };
        
        AddConditionalClasses(classes);
        
        if (!string.IsNullOrWhiteSpace(CssClass))
            classes.Add(CssClass);
            
        return string.Join(" ", classes.Where(c => !string.IsNullOrEmpty(c)));
    }
    
    protected virtual void AddConditionalClasses(List<string> classes) { }
    
    // Lifecycle Management
    protected virtual void OnParametersSetBegin() { }
    protected virtual void OnParametersSetEnd() { }
    
    public sealed override Task SetParametersAsync(ParameterView parameters)
    {
        OnParametersSetBegin();
        var result = base.SetParametersAsync(parameters);
        OnParametersSetEnd();
        return result;
    }
}
```

### Specialized Base Classes

#### Form Component Base
```csharp
public abstract class TablerFormComponentBase<T> : TablerComponentBase, IDisposable
{
    // Form Context
    [CascadingParameter] public EditContext? EditContext { get; set; }
    [CascadingParameter] public TablerForm? Form { get; set; }
    
    // Validation
    [Parameter] public Expression<Func<T>>? ValueExpression { get; set; }
    [Parameter] public EventCallback<T> ValueChanged { get; set; }
    [Parameter] public T? Value { get; set; }
    
    // Validation State
    protected bool HasValidationErrors => ValidationErrors.Any();
    protected IEnumerable<string> ValidationErrors { get; private set; } = Array.Empty<string>();
    
    // Field Identifier
    protected FieldIdentifier FieldIdentifier { get; private set; }
    
    protected override void OnInitialized()
    {
        if (ValueExpression != null)
        {
            FieldIdentifier = FieldIdentifier.Create(ValueExpression);
            EditContext?.OnValidationStateChanged += OnValidationStateChanged;
        }
    }
    
    private void OnValidationStateChanged(object? sender, ValidationStateChangedEventArgs e)
    {
        ValidationErrors = EditContext?.GetValidationMessages(FieldIdentifier) ?? Array.Empty<string>();
        InvokeAsync(StateHasChanged);
    }
    
    public virtual void Dispose()
    {
        if (EditContext != null)
            EditContext.OnValidationStateChanged -= OnValidationStateChanged;
    }
}
```

#### Interactive Component Base
```csharp
public abstract class TablerInteractiveComponentBase : TablerComponentBase
{
    // State Properties
    [Parameter] public bool Disabled { get; set; }
    [Parameter] public bool Loading { get; set; }
    
    // Event Handling
    [Parameter] public EventCallback OnClick { get; set; }
    [Parameter] public EventCallback<MouseEventArgs> OnMouseOver { get; set; }
    [Parameter] public EventCallback<MouseEventArgs> OnMouseOut { get; set; }
    [Parameter] public EventCallback<FocusEventArgs> OnFocus { get; set; }
    [Parameter] public EventCallback<FocusEventArgs> OnBlur { get; set; }
    
    // Interaction Logic
    protected virtual async Task HandleClick(MouseEventArgs args)
    {
        if (Disabled || Loading) return;
        
        await OnClick.InvokeAsync();
    }
    
    protected override void AddConditionalClasses(List<string> classes)
    {
        base.AddConditionalClasses(classes);
        
        if (Disabled) classes.Add("disabled");
        if (Loading) classes.Add("loading");
    }
}
```

## 🎨 Design Patterns

### 1. Template Method Pattern

Components use the template method pattern for consistent behavior:

```csharp
public abstract class TablerDisplayComponentBase : TablerComponentBase
{
    // Template method
    protected override string BuildCssClass()
    {
        var classes = new List<string>();
        
        // Step 1: Add base classes (implemented by derived class)
        AddBaseClasses(classes);
        
        // Step 2: Add size classes (common implementation)
        AddSizeClasses(classes);
        
        // Step 3: Add color classes (common implementation)
        AddColorClasses(classes);
        
        // Step 4: Add state classes (implemented by derived class)
        AddStateClasses(classes);
        
        // Step 5: Add custom classes
        if (!string.IsNullOrWhiteSpace(CssClass))
            classes.Add(CssClass);
            
        return string.Join(" ", classes.Where(c => !string.IsNullOrEmpty(c)));
    }
    
    // Abstract methods to be implemented by derived classes
    protected abstract void AddBaseClasses(List<string> classes);
    protected virtual void AddStateClasses(List<string> classes) { }
    
    // Common implementations
    protected virtual void AddSizeClasses(List<string> classes) { /* ... */ }
    protected virtual void AddColorClasses(List<string> classes) { /* ... */ }
}
```

### 2. Strategy Pattern

Different rendering strategies for different contexts:

```csharp
public interface ITablerIconStrategy
{
    string GetIconMarkup(string iconName, ComponentSize size);
}

public class SvgIconStrategy : ITablerIconStrategy
{
    public string GetIconMarkup(string iconName, ComponentSize size)
    {
        // SVG implementation
        return $"<svg class=\"icon icon-{iconName}\">...</svg>";
    }
}

public class FontIconStrategy : ITablerIconStrategy
{
    public string GetIconMarkup(string iconName, ComponentSize size)
    {
        // Font icon implementation
        return $"<i class=\"ti ti-{iconName}\"></i>";
    }
}
```

### 3. Factory Pattern

Component and service creation:

```csharp
public interface ITablerComponentFactory
{
    T CreateComponent<T>() where T : TablerComponentBase, new();
    T CreateComponent<T>(Action<T> configure) where T : TablerComponentBase, new();
}

public class TablerComponentFactory : ITablerComponentFactory
{
    private readonly IServiceProvider _serviceProvider;
    
    public TablerComponentFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }
    
    public T CreateComponent<T>() where T : TablerComponentBase, new()
    {
        var component = new T();
        // Inject dependencies if needed
        return component;
    }
    
    public T CreateComponent<T>(Action<T> configure) where T : TablerComponentBase, new()
    {
        var component = CreateComponent<T>();
        configure(component);
        return component;
    }
}
```

### 4. Observer Pattern

State change notifications:

```csharp
public interface ITablerStateNotification
{
    event EventHandler<TablerStateChangedEventArgs> StateChanged;
    void NotifyStateChanged(string property, object? oldValue, object? newValue);
}

public class TablerStateChangedEventArgs : EventArgs
{
    public string PropertyName { get; }
    public object? OldValue { get; }
    public object? NewValue { get; }
    
    public TablerStateChangedEventArgs(string propertyName, object? oldValue, object? newValue)
    {
        PropertyName = propertyName;
        OldValue = oldValue;
        NewValue = newValue;
    }
}
```

## 🔧 Service Framework

### Service Registration

#### Core Services
```csharp
public static class TablerServiceCollectionExtensions
{
    public static IServiceCollection AddTabler(this IServiceCollection services)
    {
        return services.AddTabler(options => { });
    }
    
    public static IServiceCollection AddTabler(this IServiceCollection services, 
        Action<TablerOptions> configureOptions)
    {
        // Register core services
        services.Configure(configureOptions);
        services.AddSingleton<ITablerComponentFactory, TablerComponentFactory>();
        services.AddSingleton<ITablerIconService, TablerIconService>();
        services.AddSingleton<ITablerThemeService, TablerThemeService>();
        
        // Register validation services (optional)
        services.TryAddSingleton<ITablerValidationService, TablerValidationService>();
        
        return services;
    }
}
```

#### Service Options
```csharp
public class TablerOptions
{
    /// <summary>
    /// Default color theme for components.
    /// </summary>
    public ComponentColor DefaultColor { get; set; } = ComponentColor.Primary;
    
    /// <summary>
    /// Default size for components.
    /// </summary>
    public ComponentSize DefaultSize { get; set; } = ComponentSize.Medium;
    
    /// <summary>
    /// Enable accessibility features by default.
    /// </summary>
    public bool EnableAccessibility { get; set; } = true;
    
    /// <summary>
    /// Icon strategy to use (SVG or Font).
    /// </summary>
    public IconStrategy IconStrategy { get; set; } = IconStrategy.Svg;
    
    /// <summary>
    /// Theme variant (Light, Dark, Auto).
    /// </summary>
    public ThemeVariant Theme { get; set; } = ThemeVariant.Auto;
}
```

### Theme Service

```csharp
public interface ITablerThemeService
{
    ThemeVariant CurrentTheme { get; }
    event EventHandler<ThemeChangedEventArgs> ThemeChanged;
    
    Task SetThemeAsync(ThemeVariant theme);
    Task ToggleThemeAsync();
    string GetThemeCssClass();
}

public class TablerThemeService : ITablerThemeService
{
    private ThemeVariant _currentTheme = ThemeVariant.Auto;
    
    public ThemeVariant CurrentTheme => _currentTheme;
    public event EventHandler<ThemeChangedEventArgs>? ThemeChanged;
    
    public Task SetThemeAsync(ThemeVariant theme)
    {
        var oldTheme = _currentTheme;
        _currentTheme = theme;
        
        ThemeChanged?.Invoke(this, new ThemeChangedEventArgs(oldTheme, theme));
        
        return Task.CompletedTask;
    }
    
    public Task ToggleThemeAsync()
    {
        var newTheme = _currentTheme switch
        {
            ThemeVariant.Light => ThemeVariant.Dark,
            ThemeVariant.Dark => ThemeVariant.Light,
            _ => ThemeVariant.Light
        };
        
        return SetThemeAsync(newTheme);
    }
    
    public string GetThemeCssClass()
    {
        return _currentTheme switch
        {
            ThemeVariant.Dark => "theme-dark",
            ThemeVariant.Light => "theme-light",
            _ => string.Empty
        };
    }
}
```

## 📐 Layout Framework

### Container System

```csharp
public abstract class TablerLayoutComponentBase : TablerComponentBase
{
    [Parameter] public RenderFragment? ChildContent { get; set; }
    [Parameter] public LayoutBreakpoint Breakpoint { get; set; } = LayoutBreakpoint.None;
    [Parameter] public bool Fluid { get; set; }
    
    protected override void AddConditionalClasses(List<string> classes)
    {
        base.AddConditionalClasses(classes);
        
        if (Fluid)
            classes.Add("container-fluid");
        else if (Breakpoint != LayoutBreakpoint.None)
            classes.Add($"container-{Breakpoint.ToString().ToLowerInvariant()}");
        else
            classes.Add("container");
    }
}
```

### Grid System Integration

```csharp
public class TablerRow : TablerLayoutComponentBase
{
    [Parameter] public RowAlignment HorizontalAlignment { get; set; } = RowAlignment.Start;
    [Parameter] public RowAlignment VerticalAlignment { get; set; } = RowAlignment.Start;
    [Parameter] public bool NoGutters { get; set; }
    
    protected override string BaseCssClass => "row";
    
    protected override void AddConditionalClasses(List<string> classes)
    {
        base.AddConditionalClasses(classes);
        
        if (NoGutters) classes.Add("g-0");
        
        if (HorizontalAlignment != RowAlignment.Start)
            classes.Add($"justify-content-{HorizontalAlignment.ToString().ToLowerInvariant()}");
            
        if (VerticalAlignment != RowAlignment.Start)
            classes.Add($"align-items-{VerticalAlignment.ToString().ToLowerInvariant()}");
    }
}

public class TablerColumn : TablerLayoutComponentBase
{
    [Parameter] public ColumnSize? XS { get; set; }
    [Parameter] public ColumnSize? SM { get; set; }
    [Parameter] public ColumnSize? MD { get; set; }
    [Parameter] public ColumnSize? LG { get; set; }
    [Parameter] public ColumnSize? XL { get; set; }
    [Parameter] public ColumnSize? XXL { get; set; }
    
    protected override string BaseCssClass => "col";
    
    protected override void AddConditionalClasses(List<string> classes)
    {
        base.AddConditionalClasses(classes);
        
        AddBreakpointClass(classes, "xs", XS);
        AddBreakpointClass(classes, "sm", SM);
        AddBreakpointClass(classes, "md", MD);
        AddBreakpointClass(classes, "lg", LG);
        AddBreakpointClass(classes, "xl", XL);
        AddBreakpointClass(classes, "xxl", XXL);
    }
    
    private void AddBreakpointClass(List<string> classes, string breakpoint, ColumnSize? size)
    {
        if (size.HasValue)
        {
            if (size.Value == ColumnSize.Auto)
                classes.Add($"col-{breakpoint}-auto");
            else
                classes.Add($"col-{breakpoint}-{(int)size.Value}");
        }
    }
}
```

## 🎛️ State Management Framework

### Component State

```csharp
public abstract class TablerStatefulComponentBase<TState> : TablerComponentBase 
    where TState : class, new()
{
    protected TState State { get; private set; } = new();
    
    protected virtual void UpdateState(Action<TState> updateAction)
    {
        var oldState = State;
        updateAction(State);
        
        OnStateUpdated(oldState, State);
        StateHasChanged();
    }
    
    protected virtual void OnStateUpdated(TState oldState, TState newState) { }
    
    protected virtual void ResetState()
    {
        State = new TState();
        StateHasChanged();
    }
}
```

### Global State Management

```csharp
public interface ITablerStateManager
{
    T GetState<T>() where T : class, new();
    void SetState<T>(T state) where T : class;
    void UpdateState<T>(Action<T> updateAction) where T : class, new();
    event EventHandler<StateChangedEventArgs> StateChanged;
}

public class TablerStateManager : ITablerStateManager
{
    private readonly Dictionary<Type, object> _states = new();
    
    public event EventHandler<StateChangedEventArgs>? StateChanged;
    
    public T GetState<T>() where T : class, new()
    {
        var type = typeof(T);
        if (!_states.TryGetValue(type, out var state))
        {
            state = new T();
            _states[type] = state;
        }
        return (T)state;
    }
    
    public void SetState<T>(T state) where T : class
    {
        var type = typeof(T);
        var oldState = _states.TryGetValue(type, out var existing) ? existing : null;
        
        _states[type] = state;
        
        StateChanged?.Invoke(this, new StateChangedEventArgs(type, oldState, state));
    }
    
    public void UpdateState<T>(Action<T> updateAction) where T : class, new()
    {
        var state = GetState<T>();
        updateAction(state);
        SetState(state);
    }
}
```

## 🔌 Extension Framework

### Component Extensions

```csharp
public interface ITablerComponentExtension
{
    string Name { get; }
    void Initialize(TablerComponentBase component);
    void OnParametersSet(TablerComponentBase component);
    void OnAfterRender(TablerComponentBase component, bool firstRender);
}

public class TablerTooltipExtension : ITablerComponentExtension
{
    public string Name => "Tooltip";
    
    public void Initialize(TablerComponentBase component)
    {
        // Initialize tooltip functionality
    }
    
    public void OnParametersSet(TablerComponentBase component)
    {
        // Update tooltip parameters
    }
    
    public void OnAfterRender(TablerComponentBase component, bool firstRender)
    {
        // Setup tooltip after render
    }
}
```

### Plugin Architecture

```csharp
public interface ITablerPlugin
{
    string Name { get; }
    Version Version { get; }
    void Configure(IServiceCollection services, TablerOptions options);
    void Initialize(IServiceProvider services);
}

public class TablerValidationPlugin : ITablerPlugin
{
    public string Name => "Validation";
    public Version Version => new(1, 0, 0);
    
    public void Configure(IServiceCollection services, TablerOptions options)
    {
        services.AddSingleton<ITablerValidationService, TablerValidationService>();
    }
    
    public void Initialize(IServiceProvider services)
    {
        // Plugin initialization logic
    }
}
```

## 📊 Performance Framework

### Render Optimization

```csharp
public abstract class TablerOptimizedComponentBase : TablerComponentBase
{
    private string? _lastCssClass;
    private bool _hasParametersChanged;
    
    protected override bool ShouldRender()
    {
        // Only render if parameters have actually changed
        return _hasParametersChanged;
    }
    
    public override Task SetParametersAsync(ParameterView parameters)
    {
        _hasParametersChanged = false;
        
        foreach (var parameter in parameters)
        {
            if (HasParameterChanged(parameter))
            {
                _hasParametersChanged = true;
                break;
            }
        }
        
        return base.SetParametersAsync(parameters);
    }
    
    protected virtual bool HasParameterChanged(ParameterValue parameter)
    {
        // Implement parameter change detection logic
        return true; // Simplified for example
    }
    
    protected override string BuildCssClass()
    {
        // Cache CSS class if parameters haven't changed
        if (_lastCssClass != null && !_hasParametersChanged)
            return _lastCssClass;
            
        _lastCssClass = base.BuildCssClass();
        return _lastCssClass;
    }
}
```

### Memory Management

```csharp
public abstract class TablerDisposableComponentBase : TablerComponentBase, IAsyncDisposable
{
    private readonly List<IDisposable> _disposables = new();
    private readonly List<Func<ValueTask>> _asyncDisposables = new();
    
    protected void RegisterDisposable(IDisposable disposable)
    {
        _disposables.Add(disposable);
    }
    
    protected void RegisterAsyncDisposable(Func<ValueTask> disposable)
    {
        _asyncDisposables.Add(disposable);
    }
    
    public async ValueTask DisposeAsync()
    {
        // Dispose async disposables
        foreach (var asyncDisposable in _asyncDisposables)
        {
            await asyncDisposable();
        }
        
        // Dispose regular disposables
        foreach (var disposable in _disposables)
        {
            disposable.Dispose();
        }
        
        _disposables.Clear();
        _asyncDisposables.Clear();
        
        GC.SuppressFinalize(this);
    }
}
```

## 🧪 Testing Framework

### Component Testing Base

```csharp
public abstract class TablerComponentTestBase : IDisposable
{
    protected TestContext TestContext { get; private set; }
    
    protected TablerComponentTestBase()
    {
        TestContext = new TestContext();
        SetupServices();
    }
    
    protected virtual void SetupServices()
    {
        TestContext.Services.AddTabler();
    }
    
    protected IRenderedComponent<T> RenderComponent<T>(Action<ComponentParameterCollectionBuilder<T>>? parameters = null) 
        where T : IComponent
    {
        return TestContext.RenderComponent<T>(parameters ?? (_ => { }));
    }
    
    protected void AssertCssClass(IRenderedComponent<TablerComponentBase> component, string expectedClass)
    {
        Assert.Contains(expectedClass, component.Instance.ComputedCssClass);
    }
    
    public void Dispose()
    {
        TestContext?.Dispose();
    }
}
```

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-30  
**Framework Version**: Wangkanai Tabler v4.4.0+  
**Architecture Level**: Framework Design  
**Maintainer**: Wangkanai Development Team