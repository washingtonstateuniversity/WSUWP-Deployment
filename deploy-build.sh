#!/bin/bash
#
# Manage the preparation for deployment of a theme via GitHub webhook.

# Remove any existing deploy trigger to prevent concurrent operations in the
# case where multiple projects are being deployed at once.
rm /var/repos/wsuwp-deployment/deploy.json

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
git checkout master
git fetch --all
git checkout $1

# Ensure all files are set to be group read/write so that our www-data and
# www-deploy users can handle them. This corrects possible issues in local
# development where elevated permissions can be set.
find "/var/repos/$2" -type d -exec chmod 775 {} \;
find "/var/repos/$2" -type f -exec chmod 664 {} \;

# Remove the old theme directory if it exists.
if [ -d "/var/repos/wsuwp-platform/build-themes/private/$2" ]; then
  rm -fr "/var/repos/wsuwp-platform/build-themes/private/$2"
fi

# Copy over the new theme directory and remove its .git directory. We are
# unable to use rsync for this due to some restrictions on the server.
cp -r "/var/repos/$2" "/var/repos/wsuwp-platform/build-themes/private/$2"
rm -rf "/var/repos/wsuwp-platform/build-themes/private/$2/.git"

# Build the project to prep for deployment.
cd /var/repos/wsuwp-platform/
rm -rf /var/repos/wsuwp-platform/build
grunt

# Tell cron that we're again ready for deploy.
touch /var/repos/wsuwp-deployment/deploy.json

exit 1