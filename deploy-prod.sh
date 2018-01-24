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

     chown -R webadmin:webadmin "/var/www/wp-content/$theme"

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

    chown -R webadmin:webadmin "/var/www/wp-content/$plugin"

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

    chown -R webadmin:webadmin "/var/www/wp-content/$muplugin"

    rm -rf "/var/www/wp-content/uploads/deploys/$muplugin"

    slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"$muplugin deployed\", \"icon_emoji\": \":rocket:\"}'"
    slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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"
    eval $slack_command
  done
fi

if [ ! -z "$(ls -A build-plugins)" ]; then
  for plugin in `ls -d build-plugins/public-plugins-build/*/ | sed "s/build-plugins\/public-plugins-build\///g"`
  do
    find "/var/www/wp-content/uploads/deploys/build-plugins/public-plugins-build/$plugin" -type d -exec chmod 775 {} \;
    find "/var/www/wp-content/uploads/deploys/build-plugins/public-plugins-build/$plugin" -type f -exec chmod 664 {} \;

    mkdir -p "/var/www/wp-content/plugins/$plugin"

    rsync -rgvzh --delete --exclude '.git' "/var/www/wp-content/uploads/deploys/build-plugins/public-plugins-build/$plugin" "/var/www/wp-content/plugins/$plugin"

    chown -R webadmin:webadmin "/var/www/wp-content/plugins/$plugin"

    rm -rf "/var/www/wp-content/uploads/deploys/build-plugins/public-plugins-build/$plugin"
  done

  for plugin in `ls -d build-plugins/private-plugins-build/*/ | sed "s/build-plugins\/private-plugins-build\///g"`
  do
    find "/var/www/wp-content/uploads/deploys/build-plugins/private-plugins-build/$plugin" -type d -exec chmod 775 {} \;
    find "/var/www/wp-content/uploads/deploys/build-plugins/private-plugins-build/$plugin" -type f -exec chmod 664 {} \;

    mkdir -p "/var/www/wp-content/plugins/$plugin"

    rsync -rgvzh --delete --exclude '.git' "/var/www/wp-content/uploads/deploys/build-plugins/private-plugins-build/$plugin" "/var/www/wp-content/plugins/$plugin"

    chown -R webadmin:webadmin "/var/www/wp-content/plugins/$plugin"

    rm -rf "/var/www/wp-content/uploads/deploys/build-plugins/private-plugins-build/$plugin"
  done

  rm -rf "/var/www/wp-content/uploads/deploys/build-plugins/private-plugins-build"
  rm -rf "/var/www/wp-content/uploads/deploys/build-plugins/public-plugins-build"

  slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"public and private build plugins deployed\", \"icon_emoji\": \":rocket:\"}'"
  slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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"
  eval $slack_command
fi

if [ ! -z "$(ls -A platform)" ]; then
  find "/var/www/wp-content/uploads/deploys/platform/wsuwp-platform/" -type d -exec chmod 775 {} \;
  find "/var/www/wp-content/uploads/deploys/platform/wsuwp-platform/" -type f -exec chmod 664 {} \;

  rsync -rgvzh --delete /var/www/wp-content/uploads/deploys/platform/wsuwp-platform/www/wordpress/ /var/www/wordpress/

  cp -f /var/www/wp-content/uploads/deploys/platform/wsuwp-platform/www/wp-content/*.php /var/www/wp-content/
  cp -f /var/www/wp-content/uploads/deploys/platform/wsuwp-platform/www/wp-content/mu-plugins/*.php /var/www/wp-content/mu-plugins/

  chown -R webadmin:webadmin /var/www/wordpress/
  chown -R webadmin:webadmin /var/www/wp-content/*.php
  chown -R webadmin:webadmin /var/www/wp-content/mu-plugins/*.php

  rm -rf "/var/www/wp-content/uploads/deploys/platform/wsuwp-platform"

  slack_payload="'payload={\"channel\": \"#wsuwp\", \"username\": \"wsuwp-deployment\", \"text\": \"platform/wsuwp-platform deployed\", \"icon_emoji\": \":rocket:\"}'"
  slack_command="curl -X POST --data-urlencode $slack_payload https://hooks.slack.com/services/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"
eval $slack_command
fi
