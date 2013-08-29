<?php
/**
* Database auth plug-in for phpBB3
*
* Authentication plug-ins is largely down to Sergey Kanareykin, our thanks to him.
*
* This is for authentication via the integrated user table
*
* @package login
* @version $Id$
* @copyright (c) 2005 phpBB Group
* @license http://opensource.org/licenses/gpl-license.php GNU Public License
*
*/

/**
* @ignore
*/
if (!defined('IN_PHPBB'))
{
	exit;
}

function oauth_exchange_code()
{
	global $config;
	
	$code = $_GET['code'];
	$postdata = array(
		'code' => $code,
		'client_id' => $config['oauth_client_id'],
		'client_secret' => $config['oauth_client_secret'],
		'redirect_uri' => $config['server_protocol'] . $config['server_name'] . $config['script_path'] . '/oauth.php',
		'grant_type' => 'authorization_code',
		);
	
	
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, 'https://accounts.google.com/o/oauth2/token');
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_POST, 1);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);
	$output = curl_exec($ch);
	curl_close($ch);
	$access_token = json_decode($output)->access_token;
	if (!$access_token)
		return false;
	
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, 'https://www.googleapis.com/oauth2/v2/userinfo?access_token=' . $access_token);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	$output = curl_exec($ch);
	curl_close($ch);
	$userinfo = json_decode($output);
	
	$userinfo->access_token = $access_token; 
	
	return $userinfo;
}

function get_user_row_google($userinfo)
{
	global $db;
	
	$sql = 'SELECT * FROM ' . USERS_TABLE . ' WHERE oauth_id = "' . $userinfo->id . '" and oauth_method = "google" ';
	$result = $db->sql_query($sql);
	$row = $db->sql_fetchrow($result);
	$db->sql_freeresult($result);
	return $row;
}

function update_userinfo_google($row, $userinfo)
{
	global $db;
	
	if ($row['user_avatar_type'] != AVATAR_REMOTE || $row['user_avatar'] != $userinfo->picture 
			|| $row['user_avatar_width'] != 128 || $row['user_avatar_height'] != 128
			|| $row['oauth_token'] != $userinfo->access_token)
	{
		$sql = 'UPDATE ' . USERS_TABLE . ' SET user_avatar = "' . $userinfo->picture . '", user_avatar_type = ' . AVATAR_REMOTE
				. ", user_avatar_width = 128, user_avatar_height = 128"
				. ", oauth_token = \"" .  $userinfo->access_token . "\""
				. ' WHERE user_id = ' . $row['user_id'];
		$result = $db->sql_query($sql);
		$db->sql_freeresult($result);
		
		return get_user_row_google($userinfo);
	}
	return $row;
}

function verify_session_google()
{
	global $user;
	
	$a = json_decode(base64_decode($_GET['state']));
	if ($a && $a->session == $user->session_id)
	{
		return true;
	}
	return false;
}

/* exported function */
function login_google($useless_username, $useless_password)
{
	global $user, $db;
	
	if (!verify_session_google())
	{
		return array(
			'status'		=> LOGIN_ERROR_EXTERNAL_AUTH,
			'error_msg'		=> 'GOOGLE_INTERNAL_AUTH_ERROR',
			'user_row'		=> array('user_id' => ANONYMOUS),
			);
	}

	$userinfo = oauth_exchange_code();
	if (!$userinfo)
	{
		return array(
			'status'		=> LOGIN_ERROR_EXTERNAL_AUTH,
			'error_msg'		=> 'GOOGLE_INTERNAL_AUTH_ERROR',
			'user_row'		=> array('user_id' => ANONYMOUS),
			);
	}
	
	$row = get_user_row_google($userinfo);
	if (!$row)
	{
		$userinfo->oauth_method = 'google';
		return array(
			'status'		=> LOGIN_CONTINUE,
			'error_msg'		=> '',
			'user_row'		=> array('user_id' => ANONYMOUS),
			'oauth_extra'	=> $userinfo,
			);		
	}
	$row = update_userinfo_google($row, $userinfo);
	return array(
		'status'	=> LOGIN_SUCCESS,
		'error_msg'	=> false,
		'user_row'	=> $row,
	);
}

/* exported function */
function auth_redirect_google($info)
{
	global $config, $user;
	
	$client_id = $config['oauth_client_id'];
	$redirect_uri = $config['server_protocol'] . $config['server_name'] . $config['script_path'] . '/oauth.php';
	$scope = 'https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile';
	$response_type = 'code';
	$append_info = array(
		'session' => $user->session_id,
		'info' => $info,
		);
	$state = base64_encode(json_encode($append_info));
	
	return 'https://accounts.google.com/o/oauth2/auth' . 
			'?client_id=' . $client_id . 
			'&response_type=' . $response_type . 
			'&scope=' . $scope . 
			'&redirect_uri=' . $redirect_uri . 
			'&state=' . $state;
}

/* exported function */
function oauth_redirect_info_google()
{
	if (!verify_session_google())
		return false;

	$a = json_decode(base64_decode($_GET['state']));
	return $a->info;
}

?>
