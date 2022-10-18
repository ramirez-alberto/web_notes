
[Angular Security with ASPNET IDENTITY](https://code-maze.com/angular-security-with-asp-net-core-identity/)

https://github.com/CodeMazeBlog/identity-aspnetcore

[Identity Series](https://code-maze.com/asp-net-core-identity-series/)

## Introduction
ASP.NET Core Identity is the membership system for web applications that includes membership, login and user data.

## First steps
Install nuget package: Microsoft.AspNetCore.Identity.EntityFrameworkCore
Inherit the user model from IdentityUser and add custom properties if necessary.

```csharp
public class User : IdentityUser
{
    public string FirstName { get; set; }
    public string LastName { get; set; }
}
```

Modify the context class to inherit from IdentityDbContext\<User> instead of DbContext

At this point, we know how to extend the Identity schema but we should always think about it beforehand. It is quite a common process to add additional data to a user and there are two ways of doing that. By using claims and by adding additional properties in a class.

While using claims, we populate the Claim object by providing the type and the value properties of the string type (new Claim(string type, string value)). But if we have something more complex, we should use a custom property. Additionally, both ways are searchable but the custom properties are a way to go if we search a lot.

## ASP.NET Core Identity Configuration

We can register ASP.NET Core Identity with two extension methods: AddIdentityCore\<TUser> and AddIdentity\<TUser, TRole>.

The AddIdentityCore method adds the services that are necessary for user-management actions, such as creating users, hashing passwords, password validation, etc. If your project doesn’t require any additional features, then you should use this method for the implementation.

If your project requires those features and any additional ones like supporting Roles not only Users, supporting external authentication, and SingInManager, as our application does, you have to use the AddIdentity method. 

Of course, we can achieve the same result with the AddIdentityCore method, but then we would have to manually register Roles, SignInManager, Cookies, etc.

`Program.cs` 
```csharp
builder.Services.AddIdentity<User, IdentityRole>()
    .AddEntityFrameworkStores<ApplicationContext>();
```

So, next to the AddIdentity method call, we add the AddEntityFrameworkStores method to register the required EF Core implementation of Identity stores.

## Create identity tablas via migration

## Add roles to the DB
Create an additional class to configure roles and add to the `OnModelCreating` method

```csharp
public class RoleConfiguration : IEntityTypeConfiguration<IdentityRole>
{
    public void Configure(EntityTypeBuilder<IdentityRole> builder)
    {
        builder.HasData(
        new IdentityRole
        {
            Name = "Visitor",
            NormalizedName = "VISITOR"
        },
        new IdentityRole
        {
            Name = "Administrator",
            NormalizedName = "ADMINISTRATOR"
        });
    }
}

// On Model Creating
modelBuilder.ApplyConfiguration(new RoleConfiguration());
```
 
Next we create and apply migration 

## User Registration
1. Create the model for user registration
2. Add a controller to handle registration GET / POST
3. Create the View
4. Install AutoMapper to map UserRegistrationModel to UserModel, register in Program.cs -> builder.Services.AddAutoMapper(typeof(Program));
and add the MappingProfile
5. In the example we use, add a partial view in the _Layout to display the link to Register form
6. Inject automapper and UserManager in the controller, UserManager\<model>  come from Microsoft.AspNetCore.Identity
7. Apply logic for register a new user
   * Check ModelState.isValid
   * Map to user
   * Store the result from CreateAsync(user, userModel.Password) method in userManager (This method hashes the password)
   * Send the errors or add the role if succeed and redirect

## Authentication

1.  Add the [Authorize] attribute on top of the action or controller and add app.UseAuthentication() auth middleware above the app.UseAuthorization()
2.  For the Login implementation, we need to create a UserLoginModel model, add the actions for GET and POST in the controller. Note: the http Post receive a UserLoginModel and add a link to the Login form
