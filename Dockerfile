ARG BASE_IMAGE=heroku/heroku:24-build
FROM $BASE_IMAGE

ARG STACK
USER root


ARG REPO_OWNER=heroku
ARG REPO_PROJECT=heroku-applink-service-mesh

RUN mkdir -p /app /cache /env
RUN echo "${REPO_OWNER}" > /env/HEROKU_APPLINK_SERVICE_MESH_REPO_OWNER
RUN echo "${REPO_PROJECT}" > /env/HEROKU_APPLINK_SERVICE_MESH_REPO_PROJECT

COPY . /buildpack
# Sanitize the environment seen by the buildpack, to prevent reliance on
# environment variables that won't be present when it's run by Heroku CI.
RUN env -i PATH=$PATH HOME=$HOME STACK=$STACK /buildpack/bin/detect /app
RUN env -i PATH=$PATH HOME=$HOME STACK=$STACK /buildpack/bin/compile /app /cache /env
WORKDIR /app
