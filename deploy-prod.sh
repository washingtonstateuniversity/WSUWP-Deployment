#!/bin/bash
#
# Process staged deployments on a cron schedule.

cd /var/www/wp-content/uploads/deploys

if [ ! -z "$(ls -A themes)" ]; then
   for theme in `ls -d themes/*/`
   do
     find "/var/www/wp-content/uploads/deploys/$theme" -type d -exec chmod 775 {} \;
     find "/var/www/wp-content/uploads/deploys/$theme" -type f -exec chmod 664 {} \;

     mkdir -p "/var/www/wp-content/$theme"

     rsync -rgvzh --delete --exclude '.git' "/var/www/wp-content/uploads/deploys/$theme" "/var/www/wp-content/$theme"

     chown -R www-data:www-data "/var/www/wp-content/$theme"

     rm -rf "/var/www/wp-content/uploads/deploys/$theme"

     slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"$theme deployed\", \"icon_emoji\": \":rocket:\"}'"
     slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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"
     eval $slack_command
   done
fi

cd /var/www/wp-content/uploads/deploys

if [ ! -z "$(ls -A plugins)" ]; then
  for plugin in `ls -d plugins/*/`
  do
    find "/var/www/wp-content/uploads/deploys/$plugin" -type d -exec chmod 775 {} \;
    find "/var/www/wp-content/uploads/deploys/$plugin" -type f -exec chmod 664 {} \;

    mkdir -p "/var/www/wp-content/$plugin"

    rsync -rgvzh --delete --exclude '.git' "/var/www/wp-content/uploads/deploys/$plugin" "/var/www/wp-content/$plugin"

    chown -R www-data:www-data "/var/www/wp-content/$plugin"

    rm -rf "/var/www/wp-content/uploads/deploys/$plugin"

    slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"$plugin deployed\", \"icon_emoji\": \":rocket:\"}'"
    slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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"
    eval $slack_command
  done
fi

cd /var/www/wp-content/uploads/deploys

if [ ! -z "$(ls -A mu-plugins)" ]; then
  for muplugin in `ls -d mu-plugins/*/`
  do
    find "/var/www/wp-content/uploads/deploys/$muplugin" -type d -exec chmod 775 {} \;
    find "/var/www/wp-content/uploads/deploys/$muplugin" -type f -exec chmod 664 {} \;

    mkdir -p "/var/www/wp-content/$muplugin"

    rsync -rgvzh --delete --exclude '.git' "/var/www/wp-content/uploads/deploys/$muplugin" "/var/www/wp-content/$muplugin"

    chown -R www-data:www-data "/var/www/wp-content/$muplugin"

    rm -rf "/var/www/wp-content/uploads/deploys/$muplugin"

    slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"$muplugin deployed\", \"icon_emoji\": \":rocket:\"}'"
    slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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"
    eval $slack_command
  done
fi
