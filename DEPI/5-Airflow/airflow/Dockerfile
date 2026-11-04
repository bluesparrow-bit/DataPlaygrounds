# Custom Airflow image.
#
# Extra Python dependencies are installed here, once, at build time, instead of
# being pip-installed on every container start (the _PIP_ADDITIONAL_REQUIREMENTS
# behaviour). All services in docker-compose.yaml share this single image.
#
#   docker compose build     # rebuild after editing requirements.txt
#   docker compose up -d
ARG AIRFLOW_VERSION=3.3.2
FROM apache/airflow:${AIRFLOW_VERSION}

# The base image ships a pip wrapper that refuses to run as root and expects the
# default "airflow" user (installs land in /home/airflow/.local). Do not add
# USER root here, and do not override the user for this RUN step.
COPY --chown=airflow:root requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt
