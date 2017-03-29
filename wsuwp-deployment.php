<?php
/*
Plugin Name: WSUWP Deployment
Plugin URI: https://web.wsu.edu/
Description: Receive deploy requests in WordPress and act accordingly.
Author: washingtonstateuniversity, jeremyfelt
Version: 1.1.2
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
	return WSUWP_Deployment::get_instance();
}
