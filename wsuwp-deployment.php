<?php
/*
Plugin Name: WSUWP Deployment
Plugin URI: https://web.wsu.edu/
Description: Receive deploy requests in WordPress and act accordingly.
Author: washingtonstateuniversity, jeremyfelt
Version: 2.1.0
*/

// If this file is called directly, abort.
if ( ! defined( 'WPINC' ) ) {
	die;
}

// The core plugin class.
require dirname( __FILE__ ) . '/includes/class-wsuwp-deployment.php';

add_action( 'after_setup_theme', 'WSUWP_Deployment' );
/**
 * Start things up.
 *
 * @return \WSUWP_Deployment
 */
function WSUWP_Deployment() {
	require dirname( __FILE__ ) . '/includes/wsuwp-deployment.php';

	return WSUWP_Deployment::get_instance();
}
