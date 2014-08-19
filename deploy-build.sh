#!/bin/bash
#
# Manage the preparation for deployment of a theme via GitHub webhook.

# Remove any existing deploy trigger to prevent concurrent operations in the
# case where multiple projects are being deployed at once.
if [ -f "/var/repos/wsuwp-deployment/deploy.json" ]; then
  rm /var/repos/wsuwp-deployment/deploy.json
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
  # Remove the old theme directory if it exists.
  if [ -d "/var/repos/wsuwp-platform/build-themes/individual/$2" ]; then
    rm -fr "/var/repos/wsuwp-platform/build-themes/individual/$2"
  fi

  # Cpy over the new theme directory and remove its .git directory.
  cp -r "/var/repos/$2" "/var/repos/wsuwp-platform/build-themes/individual/$2"
  rm -rf "/var/repos/wsuwp-platform/build-themes/individual/$2/.git"
fi

# Individual public plugins are deployed to the private build directory as they are
# not part of the wider public repository. Public in this case indicates that the
# repository is public.
if [ 'plugin-public' == $4 ]; then
  # Remove the old plugin directory if it exists.
  if [ -d "/var/repos/wsuwp-platform/build-plugins/private/$2" ]; then
    rm -fr "/var/repos/wsuwp-platform/build-plugins/private/$2"
  fi

  # Copy over the new plugin directory and remove its .git directory. We are
  # unable to use rsync for this due to some restrictions on the server.
  cp -r "/var/repos/$2" "/var/repos/wsuwp-platform/build-plugins/private/$2"
  rm -rf "/var/repos/wsuwp-platform/build-themes/plugins/$2/.git"
fi

# Private plugins are deployed to the private build directory. These deploys
# should be configured on the server first as a public key and proper SSH alias
# configuration is necessary before this will work.
if [ 'plugin-private' == $4 ]; then
  # Remove the old plugin directory if it exists.
  if [ -d "/var/repos/wsuwp-platform/build-plugins/private/$2" ]; then
    rm -fr "/var/repos/wsuwp-platform/build-plugins/private/$2"
  fi

  # Copy over the new plugin directory and remove its .git directory. We are
  # unable to use rsync for this due to some restrictions on the server.
  cp -r "/var/repos/$2" "/var/repos/wsuwp-platform/build-plugins/private/$2"
  rm -rf "/var/repos/wsuwp-platform/build-themes/plugins/$2/.git"
fi

# Our public plugins build is in a very specific place and does not follow
# the git procedure that other actions follow.
if [ 'build-plugins-public' == $4 ]; then
  # Remove the old public directory if it exists.
  if [ -d "/var/repos/wsuwp-platform/build-plugins/public" ]; then
    rm -fr "/var/repos/wsuwp-platform/build-plugins/public"
  fi

  # Copy over the new public plugins directory and remove its .git directory.
  cp -r "/var/repos/$2" "/var/repos/wsuwp-platform/build-plugins/public"
  rm -rf "/var/repos/wsuwp-platform/build-plugins/public/.git"
fi

# Our public themes build is in a very specific place and does not follow
# the git procedure that other actions follow.
if [ 'build-themes-public' == $4 ]; then
  # Remove the old public directory if it exists.
  if [ -d "/var/repos/wsuwp-platform/build-themes/public" ]; then
    rm -rf "/var/repos/wsuwp-platform/build-themes/public"
  fi

  # Copy over the new public themes directory and remove its .git directory.
  cp -r "/var/repos/$2" "/var/repos/wsuwp-platform/build-themes/public"
  rm -rf "/var/repos/wsuwp-platform/build-themes/public/.git"
fi

# Build the project to prep for deployment.
cd /var/repos/wsuwp-platform/
rm -rf /var/repos/wsuwp-platform/build
grunt

# Ensure all files are set to be group read/write so that our www-data and
# www-deploy users can handle them. This corrects possible issues in local
# development where elevated permissions can be set.
find "/var/repos/wsuwp-platform/build/" -type d -exec chmod 775 {} \;
find "/var/repos/wsuwp-platform/build/" -type f -exec chmod 664 {} \;

# Tell cron that we're again ready for deploy.
touch /var/repos/wsuwp-deployment/deploy.json
echo "$2 $1" > /var/repos/wsuwp-deployment/deploy.json

chmod 664 /var/repos/wsuwp-deployment/deploy.json

exit 1