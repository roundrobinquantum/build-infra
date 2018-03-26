FROM serhangny/ansible

RUN pip install pyapi-gitlab

ADD . /config

ARG GITLAB_USER
ARG GITLAB_PASS   

RUN ansible-playbook -i "localhost," -c local /config/playbook.yml

ENTRYPOINT /bin/bash