#!/usr/bin/env bash

# Invoke the script from anywhere (e.g .bashrc alias)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
  FIRST_ARG=$1

  if [[ "$FIRST_ARG" == "--help" ]]; then
cat <<EOF
--dev         Prepare drucker for development work with no caching and helper. modules enabled. WARNING: when running automated tests, 'twig_debug'
should be set to FALSE.
--prod        Opinionated setup with all known performance best practices enabled.
--reinstall   Deletes the existing drucker codebase and database and reinstalls from the latest dev tarball.
--import      Imports the database, files and codebase from the import directory. Database must be have the .sql extension.
EOF
    exit 0
  elif [[ -n "${FIRST_ARG}" ]] && \
       [[ "${FIRST_ARG}" != "--dev" ]] && \
       [[ "${FIRST_ARG}" != "--prod" ]] && \
       [[ "${FIRST_ARG}" != "--reinstall" ]] && \
       [[ "${FIRST_ARG}" != "--import" ]]; then
    echo "Usage: drucker {--dev|--prod|--reinstall|--import}"
    exit 0
  fi
}

usage "$@"

CONTAINER_DIR="containers"
CONTAINER_FILES="variables init ssh orchestration base reverse_proxy web db"
# web2 has been excluded for now

for FILES in ${CONTAINER_FILES} ; do
  source "${DIR}/${CONTAINER_DIR}/${FILES}"
done

check_requirements
configure_ssh_access
create_custom_bridge_network
pull_base_image_from_docker_hub
build_init_image
provision_base_container
provision_reverse_proxy_container
provision_db_container
provision_web_container
allow_web_to_db_ssh_access
# provision_web2_container has been excluded for now
