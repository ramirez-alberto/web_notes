https://auth0.com/blog/xunit-to-test-csharp-code/
https://code-maze.com/asp-net-core-testing/

# Unit test 
  [MicrosoftLearn](https://docs.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-dotnet-test)

```
    dotnet new sln -o <carpeta_De_la_solucion>  Crear nueva solucion

    dotnet new classlib -o <carpeta_libreria_de_clases> 

    dotnet sln add <ruta-csproj> add the class library project to the solution.

    dotnet new xunit -o PrimeService.Tests  Create the test project

    dotnet sln add ./PrimeService.Tests/PrimeService.Tests.csproj   Add the test project to the solution file.

    dotnet add <carpeta-tests/csproj-file> reference <carpeta-source/csproj-file>  Add the PrimeService class library as a dependency to the PrimeService.Tests project.

    Name the test: public class ReferenceClass_thingToBeTested
    Use ARRANGE,ACTION,ASSERT
```

## Attributes

* `[Fact]` – attribute states that the method should be executed by the test runner 
*    `[Theory]` – attribute implies that we are going to send some parameters to our testing code. So, it is similar to the `[Fact]` attribute, because it states that the method should be executed by the test runner, but additionally implies that we are going to send parameters to the test method
*    `[InlineData]` – attribute provides those parameters we are sending to the test method. If we are using the `[Theory]` attribute, we have to use the `[InlineData]` as well

## Writing tests
  * well organized and easy to maintain
  * Naming test convention : [ `MethodWeTest_StateUnderTest_ExpectedBehavior` ]
  * We should mock external dependencies

## Moq Package
  Install Moq , syntax `Mock<IEmployeeRepository>`
  ### Methods:
  * `Setup(method => method.methodToMock()).Returns(returnValue)`
  * `Setup(method => method.methodToMock(It.IsAny<dataType>())).Callback()`
  * `Verify(method => method.methodToMock(It.IsAny<dataType>()` <--any object with type parameter
  `,Times.Never` or `Times.Once etc..)`

# Integration Tests  
Ensures diferent components inside the application function correctly when working together.
Includes application’s infrastructure components like database, file system, etc.

  * Create a class implementing WebApplicationFactory: change Program class to be partial, instruct to use in-memory db and seed the data.
  * Make the tests: implement IClassFixture and generate a httpclient in the constructor
  
  Install two packages:
  * `AspNetCore.Mvc.Testing` provides TestServer and WebApplicationFactory to help us bootstrap our app in-memory
  * `Microsoft.EntityFrameworkCore.InMemory` – In-memory database provider

  ### Methods
  We can use `Assert.Equal("value", response)` for test the response;
  Get a instance of HttpClient in order to make requests and `response.Content.ReadAsStringAsync()`

  #### Note:
  When testing htttp Post method, we need to include AntiForgeryToken:
  ### Include AntiForgeryValues:

  #### Step 1 ####
  * Injecting AntiForgeryToken into the IserviceCollection:
      
      Create a class to wrap the logic for extracting the antiforgerytoken, make two properties and define the cookie and field names.

      Assign the field and cookie names in the Antiforgery service. With this we can extract the token from the html response.

  #### Step 2 ####
  * Extracting the Field and Cookie from the HTML Response
    * Make two private methods to extract the cookie and field values.
    * Get the "Set-Cookie" cookie from response.Headers.GetValues("Set-Cookie"), throw exception if the cookie is not found. Get the value with  SetCookieHeaderValue.Parse(antiForgeryCookie).Value.ToString();
    * Extract the token field value with Regex.Match, check for Success and return requestVerificationTokenMatch.Groups[1].Captures[0].Value. Throw a exception if not found.
    * Wrap in a public method an return a tuple task (fieldValue: token, cookieValue: cookie);

  #### Step 3 ####
  * Add the AntiForgeryToken
    * Fetch the response from the GET method and create a new CookieHeaderValue with the values
    * Add the token to the formModel