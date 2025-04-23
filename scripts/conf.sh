#!/bin/bash

# return codes
SUCCESS=0
FAILURE=1

CARTO_DIR="/root/src/openstreetmap-carto"

wait_for_postgresql()
{
  until pg_isready -U postgres; do
    echo "Waiting for PostgreSQL to be ready..."
    sleep 1
  done

  return $SUCCESS
}

init_postgresql()
{
  if [ -f "/.init_postgresql_complete" ]; then
    echo "init_postgresql already ran, skipping."s
    return $SUCCESS
  fi
  sudo -u postgres bash <<-EOF
    createuser _renderd
    createdb -E UTF8 -O _renderd gis
    psql gis -c "CREATE EXTENSION postgis;" \
            -c "CREATE EXTENSION hstore;" \
            -c "ALTER TABLE geometry_columns OWNER TO _renderd;" \
            -c "ALTER TABLE spatial_ref_sys OWNER TO _renderd;"
EOF

  touch /.init_postgresql_complete

  return $SUCCESS
}

populate_db()
{
  if [ -f "/.populate_db_complete" ]; then
    echo "populate_db already ran, skipping."
    return $SUCCESS
  fi
  echo "======================================================"
  sudo -u _renderd osm2pgsql -d gis --create --slim  -G --hstore --tag-transform-script /root/src/openstreetmap-carto/openstreetmap-carto.lua -C 2500 --number-processes 1 -S ~/src/openstreetmap-carto/openstreetmap-carto.style /root/data/data.osm.pbf
  echo "======================================================"
  touch /.populate_db_complete

  return $SUCCESS
}

create_db_indexes()
{
  if [ -f "/.create_db_indexes_complete" ]; then
    echo "create_db_indexes already ran, skipping."
    return $SUCCESS
  fi
  cd "$CARTO_DIR"
  sudo -u _renderd psql -d gis -f indexes.sql

  touch /.create_db_indexes_complete

  return $SUCCESS
}

create_db_functions()
{
  if [ -f "/.create_db_functions_complete" ]; then
    echo "create_db_functions already ran, skipping."
    return $SUCCESS
  fi
  cd "$CARTO_DIR"
  sudo -u _renderd psql -d gis -f functions.sql

  touch /.create_db_functions_complete

  return $SUCCESS
}

get_shape_file()
{
  if [ -f "/.get_shape_file_complete" ]; then
    echo "get_shape_file already ran, skipping."
    return $SUCCESS
  fi
  cd "$CARTO_DIR"
  mkdir data
  sudo chown _renderd data
  sudo -u _renderd scripts/get-external-data.py

  touch /.get_shape_file_complete

  return $SUCCESS
}

get_carto_fonts()
{
  if [ -f "/.get_carto_fonts_complete" ]; then
    echo "get_carto_fonts already ran, skipping."
    return $SUCCESS
  fi
  cd "$CARTO_DIR"
  scripts/get-fonts.sh

  touch /.get_carto_fonts_complete

  return $SUCCESS
}

main()
{
  service postgresql start
  wait_for_postgresql
  init_postgresql
  chmod o+rx ~
  populate_db
  create_db_indexes
  create_db_functions
  get_shape_file
  get_carto_fonts
  a2enconf renderd

  return $SUCCESS
}

main