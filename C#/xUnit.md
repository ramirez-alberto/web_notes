https://auth0.com/blog/xunit-to-test-csharp-code/
https://code-maze.com/asp-net-core-testing/

# Unit test 
  [MicrosoftLearn](https://docs.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-dotnet-test)

    dotnet new sln -o <carpeta_De_la_solucion>  Crear nueva solucion

    dotnet new classlib -o <carpeta_libreria_de_clases> 

    dotnet sln add <ruta-csproj> add the class library project to the solution.

    dotnet new xunit -o PrimeService.Tests  Create the test project

    dotnet sln add ./PrimeService.Tests/PrimeService.Tests.csproj   Add the test project to the solution file.

    dotnet add <carpeta-tests/csproj-file> reference <carpeta-source/csproj-file>  Add the PrimeService class library as a dependency to the PrimeService.Tests project.

    Name the test: public class ReferenceClass_thingToBeTested
    Use ARRANGE,ACTION,ASSERT

## Attributes

* [Fact] – attribute states that the method should be executed by the test runner ####
*    [Theory] – attribute implies that we are going to send some parameters to our testing code. So, it is similar to the [Fact] attribute, because it states that the method should be executed by the test runner, but additionally implies that we are going to send parameters to the test method
*    [InlineData] – attribute provides those parameters we are sending to the test method. If we are using the [Theory] attribute, we have to use the [InlineData] as well

## Writing tests
  * well organized and easy to maintain
  * Naming test convention : [ MethodWeTest_StateUnderTest_ExpectedBehavior ]
  * We should mock external dependencies

## Moq Package
  Install Moq , syntax Mock< IEmployeeRepository >
  ### Methods:
  * Setup(method => method.methodToMock() and Returns(returnValue)
  * Setup(method => method.methodToMock(It.IsAny<dataType>())).Callback()
  * Verify(method => method.methodToMock(It.IsAny<dataType>() <--any object with type parameter,
      Times.Never or Times.Once, etc..)

# Integration Tests  