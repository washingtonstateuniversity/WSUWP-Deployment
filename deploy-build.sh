#!/bin/bash
#
# Manage the deployment of platform code via GitHub webhook.
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

# Individual themes can be private or public. All go into the individual directory
# on the server. For private repositories, the deploy relationship should be
# configured on the server first so that the public key is properly entered in
# the repository's deployment settings.
if [ 'theme-individual' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_$4_$2.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_$4_$2.txt"
fi

# Individual plugins can be private or public. All go into the individual directory
# on the server. For private repositories, the deploy relationship should be
# configured on the server first so that the public key is properly entered in
# the repository's deployment settings.
if [ 'plugin-individual' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_$4_$2.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_$4_$2.txt"
fi

# Loop through the public plugins directory and sync each individual plugin.
if [ 'build-plugins-public' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_plugin-collection_$2.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_plugin-collection_$2.txt"
fi

# Loop through the private plugins directory and sync each individual plugin.
if [ 'build-plugins-private' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_plugin-collection_$2.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_plugin-collection_$2.txt"
fi

# Loop through the public themes directory and sync each individual theme.
if [ 'build-themes-public' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_theme-collection_$2.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_theme-collection_$2.txt"
fi

# Loop through the private themes directory and sync each individual theme.
if [ 'build-themes-private' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_theme-collection_$2.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_theme-collection_$2.txt"
fi

# Process only the WSUWP Platform files.
if [ 'platform' == $4 ]; then
  touch "/var/repos/wsuwp-deployment/deploy_platform.txt"
  echo "$2" > "/var/repos/wsuwp-deployment/deploy_platform.txt"
fi

exit 1
