FROM ubuntu:18.04
ENV PATH /usr/local/bin:$PATH
ENV NOMAD_PORT_http=5000
ADD app /tmp/app
RUN chmod +x /tmp/app/provision.sh
RUN bash -c "/tmp/app/provision.sh"
WORKDIR /tmp/app
ENTRYPOINT export LC_ALL=C.UTF-8 && export LANG=C.UTF-8 && pipenv run flask run --host=0.0.0.0 --port=${NOMAD_PORT_http} && /bin/bash
EXPOSE ${NOMAD_PORT_http}
