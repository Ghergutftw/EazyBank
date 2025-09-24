Interesting commands
====================
--------------------
- ab -n 10 -c 2 -v 3 http://localhost:8072/eazybank/cards/api/contact-info" To perform load testing on API by sending 10 requests


Spring Boot new stuff - The document is very well made
====================
--------------------

- Inside BaseEntity the columns are using @Column(insertable = false)this is useful because it already managed by the Database like updated_at and created_at that are DEFAULT CURRENT_TIMESTAMP and ON UPDATE CURRENT_TIMESTAMP

- @Column(updatable = false) is useful for created_at because it should not be updated after creation

- @MappedSuperclass is used to indicate that the class is a superclass of entities and its properties should be inherited by subclasses

- Auditing Using AuditAware and the anotations @CreatedBy, @CreatedDate, @LastModifiedBy, @LastModifiedDate to automatically populate auditing fields in entities and @EntityListeners(AuditingEntityListener.class) to enable auditing functionality then @EnableJpaAuditing in the main class to activate it

- handleGlobalException inside GlobalExceptionHandler uses the @ControllerAdvice annotation to handle exceptions globally across all controllers, by handling the @ExceptionHandler(Exception.class) it will catch all exceptions and return a custom response

- How to rightsize your Spring Boot Microservices using diffrerent strategies

- How to migrate from Monolith to Microservices, using the Fig Tree pattern

- Java Configuration, the 3 ways of configuring
    1. @Value("${property.name}") to inject property values from application.properties or application.yml files into Spring-managed beans
    2. Environment object to access properties programmatically using env.getProperty("property.name")
    3. @ConfigurationProperties to bind external configuration properties to a strongly typed Java record or class, useful for grouping related properties together
        - The file gets the @ConfigurationProperties(prefix = "accounts")
        - And the main class gets @EnableConfigurationProperties(value = {AccountsContactInfoDto.class})
        - And you use that Record inside the class by injecting it in the constructor

- To see al the mappings in a spring boot app you go to http://localhost:8071/actuator/mappings

- Profiling
- Configuration Managment
- Docker Compose DRY