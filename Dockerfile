FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
  screen \
  locate \
  libapache2-mod-tile \
  renderd \
  git-core \
  tar \
  unzip \
  wget \
  bzip2 \
  apache2 \
  lua5.1 \
  mapnik-utils \
  python3-mapnik \
  python3-psycopg2 \
  python3-yaml \
  gdal-bin \
  npm \
  node-carto \
  postgresql \
  postgresql-contrib \
  postgis \
  postgresql-16-postgis-3 \
  postgresql-16-postgis-3-scripts \
  osm2pgsql \
  net-tools \
  curl \
  sudo \
  vim

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY scripts/run.sh /run.sh
RUN chmod +x /run.sh

COPY configs/renderd.conf /etc/renderd.conf
COPY configs/apache.renderd.conf /etc/apache2/conf-available/renderd.conf

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/run.sh" ]