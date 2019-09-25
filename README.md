# Open Distro For Elasticsearch

Open Distro for Elasticsearch is modify openid verification to revoked token.

[Security]( https://github.com/opendistro-for-elasticsearch/security)


## Compile
[Security-parent]( https://github.com/opendistro-for-elasticsearch/security-parent)
```
cd security-parent
mvn clean install
cd ../security
mvn clean install
cd ../security-advanced-modules
mvn clean install
cd ../security
mvn clean package -Padvanced

ls target/releases
```

## Docker-build
Plugin: target/release is used build docker

## Run
### Run & Install plugin manually
```
docker run --entrypoint /bin/bash -it -v security/target/releases:/mnt \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  docker.elastic.co/elasticsearch/elasticsearch-oss:7.1.1


elasticsearch-plugin install -b \
  file:///mnt/opendistro_security-1.1.0.3.zip
cd plugins/opendistro_security
chmod +x tools/*
tools/install_demo_configuration.sh -y
docker-entrypoint.sh


cat <<EOF > plugins/opendistro_security/securityconfig/config.yml
opendistro_security:
  dynamic:
    http:
      anonymous_auth_enabled: false
      xff:
        enabled: false
    authc:
      basic_internal_auth_domain:
        http_enabled: true
        order: 0
        http_authenticator:
          type: basic
          challenge: false
        authentication_backend:
          type: internal
      openid_auth_domain:
        http_enabled: true
        order: 1
        http_authenticator:
          type: openid
          challenge: false
          config:
            subject_key: preferred_username
            roles_key: roles
            openid_connect_url: https://<host>/auth/realms/<realm>/.well-known/openid-configuration
            
            ### Revoke JWT by key: jti (Json Token ID) ###
            revoked_key: jti
            revoked_IDs:
              - "0b5ce96c-94c6-4eb7-96f2-186af191eb73"
              - "0b5ce96c-94c6-4eb7-96f2-186af191eb72"
              - "0b5ce96c-94c6-4eb7-96f2-186af191eb71"

        authentication_backend:
          type: noop
    authz:
EOF
plugins/opendistro_security/securityadmin_demo.sh
```
### Run with Docker-compose
[lokios/opendistro]( https://hub.docker.com/r/lokios/opendistro)

See file: docker/docker-compose.yml

