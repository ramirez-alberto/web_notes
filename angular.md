https://code-maze.com/net-core-web-development-part7/
https://code-maze.com/angular-series/

Angular is a framework for building SPA (Single Page Application) applications. 
That is why we only have the index.html page inside the src folder. In the index.html file all content is going to be generated inside <app-root></app-root> selector, which comes from the app.component.ts file.

## Install angular cli
npm install -g @angular/cli
ng version -> Check version
## Uninstall
npm uninstall -g @angular/cli
npm cache clean --force

Create a new project: ng new AccountOwnerClient --strict false
Third-Party Libraries as Part Of Angular Project Preparation:
    ng add ngx-bootstrap  -> [Angular bootstrap](https://valor-software.com/ngx-bootstrap/#/components/datepicker?tab=overview)
Run our app and also open it in a browser automatically (-o flag): ng serve -o

Creating Angular Components
    ng g component home --skip-tests or ng g component dir/not-found --skip-tests
Creating Angular Modules with routes
    ng g module owner --routing=true --module app.module
Create a new services>
    ng g service shared/services/environment-url --skip-tests
Create a new shared module
    ng g module shared --module owner
Create a new directive
    ng g directive shared/directives/append --skip-tests

## Template Basics
    {{ var }} -> Interpolation
    <tag *ngFor="let var of var[]"> or *ngIf="condition" -> Structural Directives
    [property]="var" -> property binding
    (event)="function()" -> Event binding
    [(ngModel)]="property in class" -> two way binding , data can flow in both directions 
        from the class to the view and viceversa.
    [class.selected] ="condition" -> Class binding add and remove a CSS class conditionally. 
            Add to the element you want to style


## Components
    Define an area of responsability in the UI and allow shared functionality. Must be declared in
    exactly one NgModule.
## Important pages
    app.component.html -> app root html
    AppRoutingModlue -> app routes
    src/environments -> prod env and dev

## Add modules to app root
    Other files and libraries the application requires is called metadata.
    import { CollapseModule } from 'ngx-bootstrap/collapse'; add module in imports array
        CollapseModule.forRoot() --> for root is for app root if another use forChild()
## Markup for html
 {{notFoundText}} put var in html , its called interpolation
 (click)="isCollapsed = !isCollapsed" -> click event
 [attr.aria-expanded]="!isCollapsed"
 [collapse]="!isCollapsed" [isAnimated]="true"
    + Styling Links
        [routerLink]="['/home']" replace href in linka (<a>) when using routing
        [routerLinkActiveOptions]="{exact: true}"
    *ngFor="let owner of owners"> => *ngFor directive loop over all the owners, put in the host tag
    <td>{{owner.dateOfBirth | date: 'dd/MM/yyyy'}}</td>>  Date pipe | date: 'dd/MM/yyyy' to format
    <div class="row" *ngIf='owner?.accounts.length <= 2; else advancedUser'> *ngIf directive
        <ng-template #advancedUser>some template <ng-template>


## Routes
    1.- Import the component if you use in the route 
        and add router-outlet tag in html is a container for the routing content
  { path: 'home', component: HomeComponent }, 
  { path: '', redirectTo: '/home', pathMatch: 'full' }
  { path: '**' --> wildcard route, match any route. A wildcard route is the last route

## Redirection
    this.router.navigate(['/owner/list']); or inject Location and use back() > (location.back())

## Angular HTTP Client
    import the HttpClientModule inside the app.module.ts and  place it inside the imports array,
    make a wrapper for CRUD request, Create,Update must provide a body and headers. If you receive a response object must createa strongly typed HTTP method, like http.put<Model>(values)
    + Subscription on the HTTP Calls
        wrapper functions need a subscription, and these function not be executed until we call the subscribe function.   this.repo.getOwners('api/owner').subscribe(lambda)

## Angular Services
Services are just classes, which provide us with some business logic relevant to our components. These services must be injected into a component using constructor injection.
We should use services whenever we have code that we can reuse in other components, or extract part of the code from our components.
Components shouldn't fetch or save data directly and they certainly shouldn't knowingly present fake data.
and delegate data access to a service 
Create a new services -> ng g service shared/services/environment-url --skip-tests

## Angular Lazy Loading
    loadChildren: () => import('./owner/owner.module').then(m => m.OwnerModule) },
    using the loadChildren property which means, that the owner module with its components won’t be loaded until we explicitly ask for them. By doing this, we are configuring Angular lazy loading from the owner module content.
## Subscription
    implement that subscription to our HTTP requests in order to display the data on the page.

## Input and Output decorator
    In the situations where we want to send some content from a parent to a child component, we need to use the @Input decorator in a child component to provide a property binding between those components. Moreover, we can have some events in a child component that reflect its behavior back to a parent component. For that purpose, we are going to use @Output decorator with the EventEmitter.

## Shared modules
    When we want to register our reusable component it is a good practice to create a shared module and to register and export our components inside that module. Then, we can use those reusable components in any higher-level component we want by registering the shared module inside a module responsible for that higher-order component.
## Directives (manipulate DOM)
    Change the appearance or behavior of DOM elements and Angular components with attribute directives.

## Form validation
    Template-driven (via html)
    Reactive form (validation in component): Add the ReactiveFormModule in the parent module, format the html:
    each input must have formControlName attribute inside every control. That attribute represents the control name which we are going to validate, onInit create a FormGroup with FormatControl and pass an array of Validators, handle errors (check if user place cursor in control (touched and if its valid)), handle creation and redirection


## Libraries
    Errors: HttpErrorResponse
    Redirection and navigation: Router
    ReferenceDOM: ElementRef
    ManipulateDOM: Renderer2
    Check for changes: OnChanges interface and add ngOnChanges method lifecyle in class.
    Reactive form validation module: ReactiveFormsModule 

## General
    var? -> is a optional property. In template is a safe navigation operator and check if the 
        property exists.
    `${accNum}` text format

## Pipes
    https://angular.io/guide/pipes

Troubleshoot ngx boostrap
Change oath in angular.json ( is wrong by default)
"styles": [
  "./node_modules/ngx-bootstrap/datepicker/bs-datepicker.css",
  "./node_modules/bootstrap/dist/css/bootstrap.min.css",
  "src/styles.css"
]

Recipe: 
Installation of the Angular CLI and Starting a New Project
Third-Party Libraries like bootstrap and ngx-bootstrap
Creating Angular Components and incorporate in app.component.html
Add Navigation and Routing and Styling Links if use routing
Add a not found page, internal server error, standard errors and add routes
Make a wrapper for CRUD functions as a service, add interface with Model you receive,
     modify Environment Files, Add the url and makea a auxiliary service for getting the url
Add Lazy Loading
Subscription and Data Display
Create a service for error handling