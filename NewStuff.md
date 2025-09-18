Interesting commands
====================
--------------------
- ab -n 10 -c 2 -v 3 http://localhost:8072/eazybank/cards/api/contact-info" To perform load testing on API by sending 10 requests


Spring Boot new stuff
====================
--------------------

- Inside BaseEntity the columns are using @Column(insertable = false)this is useful because it already managed by the Database like updated_at and created_at that are DEFAULT CURRENT_TIMESTAMP and ON UPDATE CURRENT_TIMESTAMP

- @Column(updatable = false) is useful for created_at because it should not be updated after creation

- @MappedSuperclass is used to indicate that the class is a superclass of entities and its properties should be inherited by subclasses

- Auditing Using AuditAware and the anotations @CreatedBy, @CreatedDate, @LastModifiedBy, @LastModifiedDate to automatically populate auditing fields in entities and @EntityListeners(AuditingEntityListener.class) to enable auditing functionality then @EnableJpaAuditing in the main class to activate it

- handleGlobalException inside GlobalExceptionHandler uses the @ControllerAdvice annotation to handle exceptions globally across all controllers, by handling the @ExceptionHandler(Exception.class) it will catch all exceptions and return a custom response
