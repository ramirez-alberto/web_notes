
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
1. Create the model for user registrations
2. Add a controller to handle registration GET / POST.
3. Create the View
4. Install AutoMapper (`AutoMapper.Extensions.Microsoft.DependencyInjection`) to map UserRegistrationModel to UserModel, register in Program.cs -> `builder.Services.AddAutoMapper(typeof(Program));`
and add the MappingProfile

   ***Note*** If we want to map to another property, in the profile we can use `ForMember(modelProperty,options)` method
   ```csharp
      public class MappingProfile : Profile
      {
         public MappingProfile()
         {
               CreateMap<DTO,Model>();
               CreateMap<UserRegistrationModel, User>()
               .ForMember(u => u.UserName, opt => opt.MapFrom(x => x.Email));
         }
      }
   ```

5. In the example we use a partial view in the _Layout to display the link to Register form
6. Inject Automapper ( using `IMapper`) and UserManager in the controller, `UserManager<model>`  come from `Microsoft.AspNetCore.Identity`
7. Apply logic for register a new user
   * Check `ModelState.isValid`
   * Map to user `Map<ToModel>(FromModel)`
   * Store the result from `CreateAsync(user, userModel.Password)` method in userManager (This method [hashes the password]("https://code-maze.com/data-protection-aspnet-core/"))
   * Send the errors or add the role `AddToRoleAsync(user,RoleName)` if `result.Succeeded` and redirect
     ```csharp
         var result = await _userManager.CreateAsync(user, userModel.Password);
         if(!result.Succeeded)
         {
            foreach (var error in result.Errors)
            {
                  ModelState.TryAddModelError(error.Code, error.Description);
            }
            return View(userModel);
         }
         await _userManager.AddToRoleAsync(user, "Visitor");
         return RedirectToAction(nameof(HomeController.Index), "Home");
     ``` 

## Authentication

1.  Add the [Authorize] attribute on top of the action or controller and add app.UseAuthentication() auth middleware above the app.UseAuthorization()
2.  For the Login implementation, we need to create a UserLoginModel model, add the actions for GET and POST in the controller. 

      ***Note:***
      the http Post receive a UserLoginModel
3. Create a link to Accountn/Login (Default route) and create the Login View
4. Implement the Login Controller
   * Modify Login action to receive the return url `string returnUrl = null` and save it in the ViewData for the GET response `ViewData["ReturnUrl"] = returnUrl;`
   * For the POST action implement a method to check if the url is local
      ```csharp
         return RedirectToLocal(returnUrl);
         private IActionResult RedirectToLocal(string returnUrl)
            {
            if (Url.IsLocalUrl(returnUrl))
               return Redirect(returnUrl);
            else
               return RedirectToAction(nameof(HomeController.Index), "Home");
            
            }
      ```
   * Modify Login Form `asp-route-returnUrl="@ViewData["ReturnUrl"]"`
   * Check `!ModelState.isValid`
   * Find the user with `userManager.FindByEmailAsync(userLoginModel.Email)` <- We use FindEmail because the email is our username
   * Check if the response is not null and `CheckPasswordAsync(responseFromFindByEmail, userLoginModel.Password)`
   * If True: Instance a new `ClaimIdentity` and add the Claims for NameIdentifier and Name
      ```csharp
              var identity = new ClaimsIdentity(IdentityConstants.ApplicationScheme);
               identity.AddClaim(new Claim(ClaimTypes.NameIdentifier, user.Id));
               identity.AddClaim(new Claim(ClaimTypes.Name, user.UserName));
      ```
   * SignIn by providing the scheme parameter and the claims principal. 
      ```csharp
         await HttpContext.SignInAsync(IdentityConstants.ApplicationScheme,
            new ClaimsPrincipal(identity));`
      ```
   * Redirect to Index `return RedirectToAction(nameof(HomeController.Index), "Home");`
   * If False: Add a ModelError and return the View without parameters 
   `ModelState.AddModelError("", "Invalid UserName or Password");`

      ***Note :***
      We can check the claims details with:
      ```csharp
            <h2>Claim details</h2>
            <ul>
            @foreach (var claim in User.Claims)
            {
               <li><strong>@claim.Type</strong>: @claim.Value</li>
            }
            </ul>
      ```

## Identity Options

### Rules
   We can find and adjust this rules, such as password validation or check if an email is already registered, in `IdentityOptions`. This options are configured in `AddIdentity`
   ```csharp
         builder.Services.AddIdentity<User, IdentityRole>(opt =>
         {
         opt.Password.RequiredLength = 7;
         opt.Password.RequireDigit = false;
         opt.Password.RequireUppercase = false;
         })
         .AddEntityFrameworkStores<ApplicationContext>();
   ```

### Default Routes

   When you are not authenticated, the app redirect to Account/Login, to change that
   we need to change the LoginPath when configuring services
   `services.ConfigureApplicationCookie(o => o.LoginPath = "/Authentication/Login");`