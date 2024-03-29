https://github.com/CodeMazeBlog/ef-core-series/tree/efcore-migrations

Entity Framework Power Tools

Make a new API project
- Install libraries from NuGet: Microsoft.EntityFrameworkCore , Microsoft.EntityFrameworkCore.SqlServer

- Make a folder structure: In the project, create folder Entities and inside a 
class named MyModelName
    All the public properties from this class are going to be mapped to the table’s 
    columns with the same names. Finally, EF Core uses a naming convention to create 
    a primary key, from the StudentId property

- Provide a connection string for development is ok in appsettings.json file, for 
    production save in a ENVIRONMENT VARIABLE   
        "ConnectionStrings": {
            "sqlConnection": "server=.; database=CodeMaze; Integrated Security=true" },

- Make a context class , must inherit from DbContext base which contains information
     and configuration for accessing the database. 
     DbContext has three properties Database, ChangeTracker and Model

     Structure: Folder Entities > ApplicationContext.cs (NETCORE 6 use Data > Context)
     Additional options are sent to the base DbContext class through the 
     ApplicationContext constructor by using DbContextOptions parameter take it from the base

     EF Core looks for all the public DbSet properties, inside the application’s context class, 
     and then maps their names to the names of the tables in the database. Then it goes inside a 
     class which is provided in the DbSet<T> property (in our case it is a Student class) and maps 
     all the public properties to the table columns in the table with the same names and types 
     (StudentId, Name, and Age).If our Student class has any references towards other classes, 
     EF Core would use those reference properties and create relationships in the database.

- Register the context in the IOC container: find ConfigureServices and register the context class. You can use either 
    AddDbContext method or AddDbContextPool method

        services.AddDbContext<ApplicationContext>(opts =>
            opts.UseSqlServer(Configuration.GetConnectionString("sqlConnection")));
            
- We can test via Dependency Injection in a controller 
    Install Microsoft.EntityFrameworkCore.Relational
    Modify the GET action:
        var entity = _context.Model.FindEntityType(typeof(Student).FullName);

        var tableName = entity.GetTableName();
        var schemaName = entity.GetSchema();
        var key = entity.FindPrimaryKey();
        var properties = entity.GetProperties();

- Add configurations by convention, Data Annotations or FluentAPI 

- Make migrations: Install Microsoft.EntityFrameworkCore.Tools library
    For VStudio Package manager> Add-Migration MigrationName [options] or through the dotnet CLI:
        dotnet ef migrations add MigrationName [options]
    Update Database with migrations:
        Update-Database [options] for the command prompt window, the command is: 
        dotnet ef database update [options]
    Remove-Migration

- Data Seed : Insert initial values (data) in tables, for simple things we can use OnModelCreating.
    PM> Add-Migration SeedInitialData and apply it: Update-Database
    For larger projects we can use IEntityTypeConfiguration<T> interface

Concepts:
    Relationships:
        One-to-Many:
            By convention:
                You can add a ICollection (Collection navigation property) in the parent (Principal entity)
                representing one-to-many relationship, or,in the child (Dependent entity) add a 
                 reference navigation property, if it isn't fully defined, efcore create a shadow property 
                 like parentID.
                 
Detecting concurrency conflicts> DbConcurrencyException         


Design inheritance in db (called table-per-hierarchy (TPH) inheritance )
  discriminator column to indicate which type each row represents
  This pattern of making a database table for each entity class
   is called table-per-type (TPT) inheritance


## DataAnnotations

System.ComponentModel.DataAnnotations.Schema;
System.ComponentModel.DataAnnotations;

```
Formatting
    [Display(Name = "Number")]
    [DataType(DataType.Date)]
    [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
    [DataType(DataType.Currency)]
    [Timestamp] //Concurrency
    [DisplayFormat(NullDisplayText = "No grade")]

Validation:
    [Range(0, 5)]
    [EmailAddress]
    [StringLength(50, MinimumLength = 3)]
    [MaxLength(20, ErrorMessage = "Maximum length for the Position is 20 characters.")]
    [MaxLength(100, "{0} can have a max of {1} characters")]
        {0} = Property Name
        {1} = Max Length
        {2} = Min Length
    [Required]
    [Required(ErrorMessage = "Email is required")]
    [Compare("Password")]

EFCore
    [Table("Owner")]
    [Column(TypeName = "money")] //defined using the SQL Server money type in the database
    [Column("OwnerId")]
    [DatabaseGenerated(DatabaseGeneratedOption.None)]
    [Key]
    [ForeignKey(nameof(Owner))]

```