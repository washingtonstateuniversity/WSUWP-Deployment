# WSUWP Deployments

[![Build Status](https://travis-ci.org/washingtonstateuniversity/WSUWP-Deployment.svg?branch=master)](https://travis-ci.org/washingtonstateuniversity/WSUWP-Deployment)

Manages the deployment of themes and plugins on WSU's instance of the [WSUWP Platform](https://github.com/washingtonstateuniversity/WSUWP-Platform).

## Overview

WSU maintains all WordPress projects in GitHub repositories and uses this plugin to deploy those repositories to production. This plugin provides a custom post type on the main site's dashboard that manages webhooks for each deployment.

When an administrator adds a new deployment, the plugin generates a URL that the maintainer of a GitHub repository can add to its webhook configuration. The repository maintainer configures the webhook to fire whenever someone tags a new release on the repository.

Each time GitHub fires a webhook in response to a new tag, the plugin captures a deployment instance as a custom post type and provides a log of past deployments.

Tags can consist of any alphanumeric string with any number of `.` or `-` characters. WSU typically uses a [semver](https://semver.org/) like version number (1.2.3) when tagging individual projects and an incremental number with leading zeros (00123) when tagging plugin and theme collections.

## Requirements

* A `deploys` directory in `/var/www/wp-content/uploads`.
* `mu-plugins`, `themes`, `plugins`, `build-plugins`, `build-themes`, and `platform` directories in that `deploys` directory.
* The web application user must be able to write to the `deploys` directory and each of its individual sub-directories.
* A regular cron event should fire `deploy-prod.sh` as another, non-web application user. WSU's cron configuration runs every minute: `*/1 * * * * sh /var/www/wp-content/plugins/wsuwp-deployment/deploy-prod.sh`
* If deploying private repositories, define `WSUWP_PRIVATE_DEPLOY_TOKEN` in `wp-config.php`. This should be a token that provides authentication to private repositories in your organization. See the [GitHub REST API Authentication](https://developer.github.com/v3/#authentication) documentation.

## Deployment types

Each deployment type matches the expected format of a repository with its expected location on the server. Deployments can be configured as public (default) or private. If private repositories are used, then `WSUWP_PRIVATE_DEPLOY_TOKEN` should be defined so that the plugin can retrieve the GitHub repository's archive file.

The final slug at which individual themes and plugins deploy to is the slug generated when creating a deployment post type. For example, if a deployment is named "WSUWP Super Cool Plugin", it will, unless edited, deploy to `/wp-content/plugins/wsuwp-super-cool-plugin/`.

### Individual Theme

Individual WordPress themes ([example](https://github.com/washingtonstateuniversity/WSUWP-spine-parent-theme)) are deployed to the `/var/www/wp-content/themes/{theme-slug}` directory.

### Individual Plugin

Individual WordPress plugins ([example](https://github.com/washingtonstateuniversity/WSUWP-Content-Syndicate)) are deployed to the `/var/www/wp-content/plugins/{plugin-slug}` directory.

### Individual MU Plugin

Individual WordPress must-use plugins ([example](https://github.com/washingtonstateuniversity/WSUWP-Plugin-MU-Simple-Filters)) are deployed to the `/var/www/wp-content/mu-plugins/{mu-plugin-slug}` directory.

WSU uses an [MU plugin loader](https://github.com/washingtonstateuniversity/WSUWP-Plugin-Load-MU-Plugins) that works [alongside the WSUWP Platform](https://github.com/washingtonstateuniversity/WSUWP-Platform/blob/master/www/wp-content/mu-plugins/index.php#L25-L41) to load MU plugins from individual directories via a whitelist. MU plugins that exist as individual `.php` files in the `wp-content/mu-plugins/` directory are not handled by WSUWP Deployment.

### Plugin Collection

Collections of plugins ([example](https://github.com/washingtonstateuniversity/WSUWP-Build-Plugins-Public)) are collectively synced to their respective `/var/www/wp-content/themes/{plugin-slug}` directories.

### MU Plugin Collection

Collections of mu-plugins ([example](https://github.com/washingtonstateuniversity/WSUWP-MU-Plugin-Collection)) are collectively synced to their respective `/var/www/wp-content/mu-plugins/{mu-plugin-slug}` directories.

### Theme Collection

Collections of themes ([example](https://github.com/washingtonstateuniversity/WSUWP-Build-Themes-Public)) are collectively synced to their respective `/var/www/wp-content/themes/{theme-slug}` directories.

## Development

### Testing payloads from GitHub

Deployments can be tested locally by using `curl` to send a sample payload:

* `curl --header "x-github-event: create" --data-urlencode payload@test-plugin-payload.txt http://wp.wsu.test/deployment/test-plugin-slug`

Use `wp cron event run wsuwp_run_scheduled_deployment` to trigger the cron event.
