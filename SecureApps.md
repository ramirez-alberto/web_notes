Preventing SQL Injection Attacks

    Prepared statements with parametrized queries: this approach to writing SQL code forces developers to pass parameters separately into the query, which will prevent attackers from taking advantage of the SQL syntax.
    Doublecheck imported packages.
    Make a checklist of potential vulnerabilities
    Scan your application: in addition to static application security testing tools , you can also utilize dynamic application security testing tools

Resources:
 SQL injection attacks, how to detect and prevent them
* https://owasp.org/www-project-web-security-testing-guide/?utm_medium=Exinfluencer&utm_source=Exinfluencer&utm_content=000026UJ&utm_term=10006555&utm_id=NA-SkillsNetwork-Channel-SkillsNetworkCoursesIBMCD0267ENSkillsNetwork35747552-2022-01-01
* https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html?utm_medium=Exinfluencer&utm_source=Exinfluencer&utm_content=000026UJ&utm_term=10006555&utm_id=NA-SkillsNetwork-Channel-SkillsNetworkCoursesIBMCD0267ENSkillsNetwork35747552-2022-01-01
* https://cheatsheetseries.owasp.org/cheatsheets/Query_Parameterization_Cheat_Sheet.html?utm_medium=Exinfluencer&utm_source=Exinfluencer&utm_content=000026UJ&utm_term=10006555&utm_id=NA-SkillsNetwork-Channel-SkillsNetworkCoursesIBMCD0267ENSkillsNetwork35747552-2022-01-01

## Cross-site Scripting (XSS)

Type 1: Stored XSS

XSS attacks are divided into three types depending upon where an attacker places an injection script for execution:

    Stored XSS (Persistent)
    Reflected XSS (Non-persistent) Check lab for EXAMPLES
    DOM-based XSS (Document Object Model-based)
Types of vulnerable websites

These are certain types of websites that are more vulnerable to XSS attacks than others:

    Blogs
    Forums
    Any website that stores data and subsequently sends that data to client machines

Websites are vulnerable when there is no input or output validation.

Reflected XSS, you can inclue the next meta tag to prevent this
<meta http-equiv="Content-Security-Policy" content="default-src https:">
[Multiple Content Security Policies]('https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy?utm_medium=Exinfluencer&utm_source=Exinfluencer&utm_content=000026UJ&utm_term=10006555&utm_id=NA-SkillsNetwork-Channel-SkillsNetworkCoursesIBMCD0267ENSkillsNetwork35747552-2022-01-01#examples')

The key to prevention is to validate user input and sanitize outputs.
1.  validate that all user input fields do not contain \<SCRIPT> or \<script> or any variations in mixed cases.

Example: 
```JAVASCRIPT
   const username = document.getElementById('username').value;
   if (username.toLowerCase().includes("<script>")){
    alert('Error: Detected script in input');
}
```
Or encode HTML input fields to unicode characterse with `he` javascript library. For example, converting "<" to "&lt". Syntax -> he.encode(string)

More information: [ OWASP Cross-site Scripting Prevention Cheat Sheet ]('https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html?utm_medium=Exinfluencer&utm_source=Exinfluencer&utm_content=000026UJ&utm_term=10006555&utm_id=NA-SkillsNetwork-Channel-SkillsNetworkCoursesIBMCD0267ENSkillsNetwork35747552-2022-01-01')


## Code Practices
follow the DevSecOps model
    Setting HTTP headers -> adding security headers to every response
        X-Frame-Options: SAMEORIGIN
        X-XSS-Protection: 1; mode=block
        X-Content-Type-Options: nosniff
        Content-Security-Policy: default-src 'self'
        Referrer-Policy: strict-origin-when-cross-origin

    Implementing Cross Origin Resource Sourcing (CORS) policies
     In production, developers store the origins/URLs they want to give permissions to in environment variables, as the origin of a client application can be different in staging or testing environments.
     
    Working with Credentials and GitHub
    Using the Vault

## Secure your development environment

* Securely storing secrets required for your production application.
* Secure the internet connection. Use a VPN, if necessary.
* Implement a firewall with strong ingress/egress policies.
* Regularly check for open ports and closing ports not needed.
* Use Docker containers for development, if possible, and use separate computers for development tasks and business tasks.
* Logging the behaviors in your developer’s environments.
* Use multifactor authentication to prevent identity theft.
* Add additional security for developers who need to access the production environment from their developer machines.
* Track all commits and changes made by developers, for future reference, in case problems arise.

