dotnet --version

# Build Core library
dotnet clean   ./src/Core/Wangkanai.Tabler.csproj -c Release -tl
dotnet restore ./src/Core/Wangkanai.Tabler.csproj
dotnet build   ./src/Core/Wangkanai.Tabler.csproj -c Release -tl

# Build Components library
dotnet clean   ./src/Components/Wangkanai.Tabler.Components.csproj -c Release -tl
dotnet restore ./src/Components/Wangkanai.Tabler.Components.csproj
dotnet build   ./src/Components/Wangkanai.Tabler.Components.csproj -c Release -tl

# Build Web Components library
dotnet clean   ./src/Web/Wangkanai.Tabler.Components.Web.csproj -c Release -tl
dotnet restore ./src/Web/Wangkanai.Tabler.Components.Web.csproj
dotnet build   ./src/Web/Wangkanai.Tabler.Components.Web.csproj -c Release -tl

# Build Tests
dotnet clean   ./tests/Wangkanai.Tabler.Tests.csproj -c Release -tl
dotnet restore ./tests/Wangkanai.Tabler.Tests.csproj
dotnet build   ./tests/Wangkanai.Tabler.Tests.csproj -c Release -tl
