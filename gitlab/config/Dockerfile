FROM alpine:3.5

ARG GITLAB_LDAP_PASS
ADD . /configure

RUN sed -i 's/GITLAB_LDAP_PASS/'"${GITLAB_LDAP_PASS}"'/g' /configure/gitlab.rb

ENTRYPOINT cp /configure/gitlab.rb /config/gitlab.rb