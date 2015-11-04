#!/bin/bash
#
# Process queued deployments on a cron schedule.

# Handle individual plugin deployments
for deploy in `ls /var/repos/wsuwp-deployment/deploy_plugin-individual_*`
do
  repo=$(cat $deploy)
  find "/var/repos/$repo/" -type d -exec chmod 775 {} \;
  find "/var/repos/$repo/" -type f -exec chmod 664 {} \;

  mkdir -p "/var/www/wp-content/plugins/$repo"

  rsync -rgvzh --delete --exclude '.git' "/var/repos/$repo/" "/var/www/wp-content/plugins/$repo/"

  chown -R www-data:www-data "/var/www/wp-content/plugins/$repo"
  rm "$deploy"
done

# Handle individual theme deployments
for deploy in `ls /var/repos/wsuwp-deployment/deploy_theme-individual_*`
do
  repo=$(cat $deploy)
  find "/var/repos/$repo/" -type d -exec chmod 775 {} \;
  find "/var/repos/$repo/" -type f -exec chmod 664 {} \;

  mkdir -p "/var/www/wp-content/themes/$repo"

  rsync -rgvzh --delete --exclude '.git' "/var/repos/$repo/" "/var/www/wp-content/themes/$repo/"

  chown -R www-data:www-data "/var/www/wp-content/themes/$repo"
  rm "$deploy"
done

# Handle plugin collection deployments
for deploy in `ls /var/repos/wsuwp-deployment/deploy_plugin-collection_*`
do
  repo=$(cat $deploy)
  find "/var/repos/$repo/" -type d -exec chmod 775 {} \;
  find "/var/repos/$repo/" -type f -exec chmod 664 {} \;

  for dir in `ls "/var/repos/$repo"`
  do
    if [ -d "/var/repos/$repo/$dir" ]; then
      mkdir -p "/var/www/wp-content/plugins/$dir"
      rsync -rgvzh --delete --exclude '.git' "/var/repos/$repo/$dir/" "/var/www/wp-content/plugins/$dir/"
    fi
  done

  chown -R www-data:www-data /var/www/wp-content/plugins
  rm "$deploy"
done

# Handle theme collection deployments
for deploy in `ls /var/repos/wsuwp-deployment/deploy_theme-collection_*`
do
  repo=$(cat $deploy)
  find "/var/repos/$repo/" -type d -exec chmod 775 {} \;
  find "/var/repos/$repo/" -type f -exec chmod 664 {} \;

  for dir in `ls "/var/repos/$repo"`
  do
    if [ -d "/var/repos/$repo/$dir" ]; then
      mkdir -p "/var/www/wp-content/themes/$dir"
      rsync -rgvzh --delete --exclude '.git' "/var/repos/$repo/$dir/" "/var/www/wp-content/themes/$dir/"
    fi
  done

  chown -R www-data:www-data /var/www/wp-content/themes
  rm "$deploy"
done

# Handle general platform deployment
for deploy in `ls /var/repos/wsuwp-deployment/deploy_platform.txt`
do
  find "/var/repos/wsuwp-platform/" -type d -exec chmod 775 {} \;
  find "/var/repos/wsuwp-platform/" -type f -exec chmod 664 {} \;

  rsync -rgvzh --delete --exclude '.git' --exclude 'html/' --exclude 'cgi-bin/' --exclude 'wp-config.php' --exclude 'wp-content/plugins' --exclude 'wp-content/themes' --exclude 'wp-content/uploads' /var/repos/wsuwp-platform/www/ /var/www/

  chown -R www-data:www-data /var/www/
  rm "$deploy"
done