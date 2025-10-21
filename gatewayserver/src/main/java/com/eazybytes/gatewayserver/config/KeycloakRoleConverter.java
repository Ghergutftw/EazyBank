package com.eazybytes.gatewayserver.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;

import java.util.*;
import java.util.stream.Collectors;


public class KeycloakRoleConverter  implements Converter<Jwt, Collection<GrantedAuthority>> {

    private static final Logger logger = LoggerFactory.getLogger(KeycloakRoleConverter.class);


    @Override
    public Collection<GrantedAuthority> convert(Jwt source) {
        logger.debug("Converting JWT to authorities. Subject: {}", source.getSubject());

        Object realmAccessObj = source.getClaims().get("realm_access");
        if (!(realmAccessObj instanceof Map<?, ?> realmAccess)) {
            logger.warn("realm_access claim is missing or not a Map. Type: {}",
                    realmAccessObj != null ? realmAccessObj.getClass().getName() : "null");
            return Collections.emptyList();
        }

        Object rolesObj = realmAccess.get("roles");
        if (!(rolesObj instanceof Collection<?> roles)) {
            logger.warn("roles claim is missing or not a Collection. Type: {}",
                    rolesObj != null ? rolesObj.getClass().getName() : "null");
            return Collections.emptyList();
        }

        logger.debug("Found {} role(s) in realm_access.roles", roles.size());

        List<GrantedAuthority> authorities = roles.stream()
                .filter(role -> role instanceof String)
                .map(role -> {
                    String roleName = "ROLE_" + role;
                    logger.debug("Mapping role '{}' to authority '{}'", role, roleName);
                    return new SimpleGrantedAuthority(roleName);
                })
                .collect(Collectors.toList());

        int skipped = roles.size() - authorities.size();
        if (skipped > 0) {
            logger.warn("Skipped {} non-String role(s)", skipped);
        }

        logger.info("Converted {} role(s) to authorities for user: {}", authorities.size(), source.getSubject());
        return authorities;
    }

}
