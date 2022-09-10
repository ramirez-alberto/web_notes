dotnet tool uninstall --global dotnet-aspnet-codegenerator
dotnet tool install --global dotnet-aspnet-codegenerator
dotnet tool uninstall --global dotnet-ef
dotnet tool install --global dotnet-ef
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.EntityFrameworkCore.SQLite
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.VisualStudio.Web.CodeGeneration.Design
dotnet add package Microsoft.EntityFrameworkCore.SqlServer

#Microsoft.EntityFrameworkCore.Tools for visual studio
# Scaffold running the next line    
dotnet-aspnet-codegenerator controller -name MoviesController -m Movie -dc MvcMovieContext --relativeFolderPath Controllers --useDefaultLayout --referenceScriptLibraries -sqlite
dotnet-aspnet-codegenerator controller -name CommentsController -m Comment -dc MvcArticleContext  --relativeFolderPath Controllers --useDefaultLayout --referenceScriptLibraries -sqlite

# The command-line interface (CLI) tools for EF Core
# The aspnet-codegenerator scaffolding tool.
# Design time tools for EF Core
# The EF Core SQLite provider, which installs the EF Core package as a dependency.
# Packages needed for scaffolding: Microsoft.VisualStudio.Web.CodeGeneration.Design
#  and Microsoft.EntityFrameworkCore.SqlServer
# https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-mvc-app/adding-model?view=aspnetcore-6.0&tabs=visual-studio-code

# Install ef cli and run migrations
dotnet tool install --global dotnet-ef

dotnet ef migrations add InitialCreate
dotnet ef database update