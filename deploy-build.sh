#!/bin/bash
#
# Manage the deployment of platform code via GitHub webhook.
#
# Note: For private repositories, the deploy relationships should be configured
# on the server first so that the public key is properly entered in the
# repository's deployment settings.

# Expected arguments:
#   $1 The tag to deploy, formated as #.#.#
#   $2 The directory slug
#   $3 The GitHub URL to the repository or tar file
#   $4 The type of deployment.
#   $5 Whether the repository is "public" or "private".
if [ $# -ne 5 ]; then
  echo "This script expects 5 arguments."
  exit 1;
fi

# Public repositories should start with a clean slate for every deployment. Remove
# an existing directory if it is found.
if [ 'public' == $5 ] && [ -d "/var/repos/$2" ]; then
  rm -rf "/var/repos/$2"
fi

# Private repositories must be preconfigured on the server.
if [ 'private' == $5 ] && [ ! -d "/var/repos/$2" ]; then
  echo "An existing private repository was not found."
  exit 1;
fi

# Checkout the project's master, fetch all changes, and then check out the
# tag specified by the deploy request.
if [ 'private' == $5 ]; then
  cd "/var/repos/$2"
  unset GIT_DIR
  git checkout -- .
  git checkout master
  git fetch --all
  git checkout $1
fi

if [ 'public' == $5 ]; then
  wget $3 -O "$2.tar.gz"

  if [ ! -s "$2.tar.gz" ]; then
    echo "Download of $3 failed."
    exit 1;
  fi

  mkdir "/var/repos/$2";
  gzip -d "$2.tar.gz"
  tar -xvf "$2.tar" -C $2 --strip-components 1
  rm $2.tar
fi

# Ensure all files are set to be group read/write so that our www-data and
# www-deploy users can handle them. This corrects possible issues in local
# development where elevated permissions can be set.
find "/var/repos/$2" -type d -exec chmod 775 {} \;
find "/var/repos/$2" -type f -exec chmod 664 {} \;

# Individual plugins, mu-plugins, and themes are all deployed the same way
# and can be private or public repositories.
if [ 'theme-individual' == $4 ] || [ 'plugin-individual' == $4 ] || [ 'mu-plugin-individual' == $4 ]; then
  touch "/var/repos/deploy_$4_$2.txt"
  echo "$2" > "/var/repos/deploy_$4_$2.txt"
fi

# Private and public collections of plugins are deployed in the same way.
if [ 'build-plugins-private' == $4 ] || [ 'build-plugins-public' == $4 ]; then
  touch "/var/repos/deploy_plugin-collection_$2.txt"
  echo "$2" > "/var/repos/deploy_plugin-collection_$2.txt"
fi

# Private and public collections of themes are deployed in the same way.
if [ 'build-themes-private' == $4 ] || [ 'build-themes-public' == $4 ]; then
  touch "/var/repos/deploy_theme-collection_$2.txt"
  echo "$2" > "/var/repos/deploy_theme-collection_$2.txt"
fi

# Process only the WSUWP Platform files.
if [ 'platform' == $4 ]; then
  touch "/var/repos/deploy_platform.txt"
  echo "$2" > "/var/repos/deploy_platform.txt"
fi

# When this deployment repository is deployed, replace the build scripts
# with the latest versions and ensure they remain executable.
if [ 'wsuwp-deployment' == $2 ]; then
  cp -f "/var/repos/wsuwp-deployment/deploy-build.sh" "/var/repos/deploy-build.sh"
  cp -f "/var/repos/wsuwp-deployment/deploy-prod.sh" "/var/repos/deploy-prod.sh"
  chmod 775 "/var/repos/deploy-build.sh"
  chmod 775 "/var/repos/deploy-prod.sh"
fi
exit 1
