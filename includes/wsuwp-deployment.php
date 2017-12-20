<?php

namespace WSUWP\Deployment;

add_action( 'wsuwp_run_scheduled_deployment', 'WSUWP\Deployment\run_scheduled_deployment', 10, 5 );

/**
 * Run a scheduled deployment of a public repository using the arguments
 * stored when the schedule was set.
 *
 * @since 3.0.0
 *
 * @param string $tag         The version of the package being deployed (x.y.z).
 * @param string $directory   The directory name the package should be installed under.
 * @param string $url         The URL from which to download the package.
 * @param string $deploy_type Type of deployment. Currently supported: theme-individual,
 *                            plugin-individual, mu-plugin-individual
 * @param string $sender      The GitHub user who tagged the release.
 */
function run_scheduled_deployment( $tag, $directory, $url, $deploy_type, $sender ) {

	if ( ! in_array( $deploy_type, array(
		'theme-individual',
		'plugin-individual',
		'mu-plugin-individual',
	) ) ) {
		return;
	}

	// Load file and upgrade management files from WordPress core.
	require_once ABSPATH . 'wp-admin/includes/file.php';
	require_once ABSPATH . 'wp-admin/includes/plugin-install.php';
	require_once ABSPATH . 'wp-admin/includes/class-wp-upgrader.php';
	require_once ABSPATH . 'wp-admin/includes/plugin.php';

	// Start up the WP filesystem global, required by things like unzip_file().
	WP_Filesystem();

	$temp_file = download_url( $url );

	if ( is_wp_error( $temp_file ) ) {
		send_slack_notification( $temp_file->get_error_message() );
		return;
	}

	$deploy_file = WP_CONTENT_DIR . '/uploads/deploys/' . $tag . '.zip';

	// use copy and unlink because rename breaks streams.
	$move_new_file = @ copy( $temp_file, $deploy_file );
	@ unlink( $temp_file );

	if ( false === $move_new_file ) {
		send_slack_notification( 'Unable to move ' . $deploy_file );
		return;
	}

	$unzip_result = unzip_file( $deploy_file, WP_CONTENT_DIR . '/uploads/deploys' );

	if ( is_wp_error( $unzip_result ) ) {
		send_slack_notification( $unzip_result->get_error_message() );
		return;
	}

	if ( 'plugin-individual' === $deploy_type ) {
		$destination = 'plugins/' . $directory;
	} elseif ( 'theme-individual' === $deploy_type ) {
		$destination = 'themes/' . $directory;
	} elseif ( 'mu-plugin-individual' === $deploy_type ) {
		$destination = 'mu-plugins/' . $directory;
	}

	// Given a URL like https://github.com/washingtonstateuniversity/WSUWP-spine-parent-theme/archive/0.27.16.zip
	// Determine a directory name like WSUWP-spine-parent-theme-0.27.16
	$url_pieces = explode( '/', $url );
	$unzipped_directory = $url_pieces[ 4 ] . '-' . $tag;

	$skin = new \Automatic_Upgrader_Skin;
	$upgrader = new \WP_Upgrader( $skin );

	// "Install" the package to a shadow directory to be looped through by an external script.
	$install_result = $upgrader->install_package( array(
		'source' => WP_CONTENT_DIR . '/uploads/deploys/' . $unzipped_directory,
		'destination' => WP_CONTENT_DIR . '/uploads/deploys/' . $destination,
		'clear_destination' => true,
		'clear_working' => true,
		'abort_if_destination_exists' => true,
	) );

	if ( is_wp_error( $install_result ) ) {
		error_log( $install_result->get_error_message() );
		return;
	}

	$message = 'Version ' . $tag . ' of ' . $directory . ' has been staged for deployment on ' . gethostname() . ' by ' . $sender . '.';
	send_slack_notification( $message );

	return;
}

/**
 * Send a notification to the WSU Web Slack.
 *
 * @since 3.0.0
 *
 * @param string $message
 */
function send_slack_notification( $message ) {
	$payload_json = json_encode( array(
		'channel'      => '#wsuwp',
		'username'     => 'wsuwp-deployment',
		'text'         => esc_js( $message ),
		'icon_emoji'   => ':rocket:',
	) );

	wp_remote_post( 'https://hooks.slack.com/services/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', array(
		'body'       => $payload_json,
		'headers' => array(
			'Content-Type' => 'application/json',
		),
	) );
}
