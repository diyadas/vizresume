FROM rocker/binder:latest

USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}

## Become normal user again
USER ${NB_USER}
RUN wget https://github.com/diyadas/vizresume/raw/shiny/DESCRIPTION && \
R -e "devtools::install_deps()"