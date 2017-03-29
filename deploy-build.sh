#!/bin/bash
#
# Manage the deployment of platform code via GitHub webhook.
#
# Note: For private repositories, the deploy relationships should be configured
# on the server first so that the public key is properly entered in the
# repository's deployment settings.

if [ $# -ne 4 ]; then
    echo "This script expects 4 arguments."
    exit 1;
fi

# If a deployment is not yet configured, expect a third argument containing
# the repository URL. We'll need to configure private repositories manually.
if [ ! -d "/var/repos/$2" ]; then
  cd /var/repos/
  git clone $3 $2
fi
cd "/var/repos/$2"

# Checkout the project's master, fetch all changes, and then check out the
# tag specified by the deploy request.
unset GIT_DIR
git checkout -- .
git checkout master
git fetch --all
git checkout $1

# Ensure all files are set to be group read/write so that our www-data and
# www-deploy users can handle them. This corrects possible issues in local
# development where elevated permissions can be set.
find "/var/repos/$2" -type d -exec chmod 775 {} \;
find "/var/repos/$2" -type f -exec chmod 664 {} \;

# Individual plugins, mu-plugins, and themes are all deployed the same way
# and can be private or public repositories.
if [ 'theme-individual' == $4 ] || [ 'plugin-individual' == $4 ] || [ 'mu-plugin-individual' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_$4_$2.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_$4_$2.txt"
fi

# Private and public collections of plugins are deployed in the same way.
if [ 'build-plugins-private' == $4 ] || [ 'build-plugins-public' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_plugin-collection_$2.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_plugin-collection_$2.txt"
fi

# Private and public collections of themes are deployed in the same way.
if [ 'build-themes-private' == $4 ] || [ 'build-themes-public' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_theme-collection_$2.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_theme-collection_$2.txt"
fi

# Process only the WSUWP Platform files.
if [ 'platform' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_platform.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_platform.txt"
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
