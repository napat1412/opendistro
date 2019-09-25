/usr/share/elasticsearch/plugins/opendistro_security/tools/securityadmin.sh \
  -cd /usr/share/elasticsearch/plugins/opendistro_security/securityconfig/ -icl -nhnv \
  -cacert /usr/share/elasticsearch/config/root-ca.pem \
  -cert /usr/share/elasticsearch/config/esnode.pem \
  -key /usr/share/elasticsearch/config/esnode-key.pem
