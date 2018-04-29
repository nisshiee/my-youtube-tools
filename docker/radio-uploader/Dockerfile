FROM python:3.6.5-jessie

RUN set -ex \
        \
        && apt-get update \
        && pip install pytube awscli

COPY docker-entrypoint.sh download-webm.py /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD []
