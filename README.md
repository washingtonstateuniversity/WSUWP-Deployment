# WSUWP Deployments

Manages the deployment of themes and plugins on WSU's instance of the WSUWP Platform.

## Requirements

* A `deploys` directory in `/var/www/wp-content/uploads`.
* `mu-plugins`, `themes`, and `plugins` directories in that `deploys` directory.
* The web application user must be able to write to the `deploys` directory.
* The cron for `deploy-prod.sh` should be setup under another user.

## Testing payloads

Deployments can be tested locally by using `curl` to send a sample payload:

* `curl --header "x-github-event: create" --data-urlencode payload@test-plugin-payload.txt http://wp.wsu.dev/deployment/test-plugin-slug`

Use `wp cron event run wsuwp_run_scheduled_deployment` to trigger the cron event.
