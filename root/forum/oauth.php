<?php

define('IN_PHPBB', true);
$phpbb_root_path = (defined('PHPBB_ROOT_PATH')) ? PHPBB_ROOT_PATH : './';
$phpEx = substr(strrchr(__FILE__, '.'), 1);
require($phpbb_root_path . 'common.' . $phpEx);
require($phpbb_root_path . 'includes/functions_user.' . $phpEx);
require($phpbb_root_path . 'includes/functions_module.' . $phpEx);

define('IN_LOGIN', true);

// Start session management
$user->session_begin();
$auth->acl($user->data);
$user->setup('ucp');

function oauth_show_register($oauth_info, $nickname_repeat = false, $nickname_too_short = false)
{
	global $phpEx, $template;
	
	if (session_id() == '')
		session_start();
	
	$_SESSION['oauth_info'] = $oauth_info;
	
	$template->assign_vars(array(
		'S_OAUTH_REG_ACTION' => './oauth.' . $phpEx . '?mode=register',
		'EMAIL' => $oauth_info->email,
		'USERNAME' => $oauth_info->name,
		'USERNAME_EXISTS' => $nickname_repeat,
		'USERNAME_TOO_SHORT' => $nickname_too_short,
	));
	
	page_header($user->lang['LOGIN'], false);
	
	$template->set_filenames(array(
			'body' => 'oauth_register.html')
	);
	make_jumpbox(append_sid("{$phpbb_root_path}viewforum.$phpEx"));
	
	page_footer();
}

function oauth_login()
{
	global $phpEx, $config, $auth, $user;
	
	$info = false;
	$method = trim(basename($config['auth_method']));
	include_once($phpbb_root_path . 'includes/auth/auth_' . $method . '.' . $phpEx);
	$method = 'oauth_redirect_info_' . $method;
	if (function_exists($method))
	{
		$info = $method();
	}
	if (!$info)
	{
		redirect('index.' . $phpEx);
	}
	
	// // Hack code
	// $_POST['login'] = 'Login';
	// $_REQUEST['credential'] = ($info->admin) ? md5(unique_id()) : false;
	// $_REQUEST['redirect'] = $info ->redirect;
	
	// login_box($info ->redirect, $info->l_explain, $info->l_success, $info->admin);
	
	$admin 		= $info->admin;
	$redirect	= $info->redirect;
	
	if ($admin && !$auth->acl_get('a_'))
	{
		// Not authd
		// anonymous/inactive users are never able to go to the ACP even if they have the relevant permissions
		if ($user->data['is_registered'])
		{
			add_log('admin', 'LOG_ADMIN_AUTH_FAIL');
		}
		trigger_error('NO_AUTH_ADMIN');
	}
	
	// If authentication is successful we redirect user to previous page
	$result = $auth->login('', '', false, 0, $admin);
	
	// If admin authentication and login, we will log if it was a success or not...
	// We also break the operation on the first non-success login - it could be argued that the user already knows
	if ($admin)
	{
		if ($result['status'] == LOGIN_SUCCESS)
		{
			add_log('admin', 'LOG_ADMIN_AUTH_SUCCESS');
		}
		else
		{
			// Only log the failed attempt if a real user tried to.
			// anonymous/inactive users are never able to go to the ACP even if they have the relevant permissions
			if ($user->data['is_registered'])
			{
				add_log('admin', 'LOG_ADMIN_AUTH_FAIL');
			}
		}
	}
	
	// The result parameter is always an array, holding the relevant information...
	if ($result['status'] == LOGIN_SUCCESS)
	{
		$message = ($l_success) ? $l_success : $user->lang['LOGIN_REDIRECT'];
		$l_redirect = ($admin) ? $user->lang['PROCEED_TO_ACP'] : (($redirect === "{$phpbb_root_path}index.$phpEx" || $redirect === "index.$phpEx") ? $user->lang['RETURN_INDEX'] : $user->lang['RETURN_PAGE']);
	
		// append/replace SID (may change during the session for AOL users)
		$redirect = reapply_sid($redirect);
	
		// Special case... the user is effectively banned, but we allow founders to login
		if (defined('IN_CHECK_BAN') && $result['user_row']['user_type'] != USER_FOUNDER)
		{
			return;
		}
	
		$redirect = meta_refresh(3, $redirect);
		trigger_error($message . '<br /><br />' . sprintf($l_redirect, '<a href="' . $redirect . '">', '</a>'));
	}
	
	if ($result['status'] == LOGIN_CONTINUE)
	{
		oauth_show_register($result['oauth_extra']);
	}
	
	trigger_error("Extern auth error!");
}

function oauth_new_user_row($userinfo)
{
	global $db, $config, $user;
	$sql = 'SELECT group_id
			FROM ' . GROUPS_TABLE . "
			WHERE group_name = '" . $db->sql_escape('REGISTERED') . "'
			AND group_type = " . GROUP_SPECIAL;
	$result = $db->sql_query($sql);
	$row = $db->sql_fetchrow($result);
	$db->sql_freeresult($result);

	if (!$row)
	{
		trigger_error('NO_GROUP');
	}

	return array(
		'username'		=> $userinfo->name,
		'user_password'	=> '',
		'user_email'	=> $userinfo->email,
		'group_id'		=> (int) $row['group_id'],
		'user_type'		=> USER_NORMAL,
		'user_ip'		=> $user->ip,
		'user_new'		=> ($config['new_member_post_limit']) ? 1 : 0,
	);
}

function oauth_register()
{
	global $db, $phpEx;
	
	if (session_id() == '')
		session_start();
	
	$oauth_info = $_SESSION['oauth_info'];
	unset($_SESSION['oauth_info']);
	if (!$oauth_info)
	{
		trigger_error("Extern auth error!");
	}
	$oauth_info->name = $_POST['USERNAME'];
	
	if (strlen($oauth_info->name) <= 3)
	{
		oauth_show_register($oauth_info, false, true);
	}
	
	$username_clean = utf8_clean_string($oauth_info->name);
	
	$sql = 'SELECT * FROM ' . USERS_TABLE . ' WHERE username_clean = "' . $username_clean . '"';
	$result = $db->sql_query($sql);
	$row = $db->sql_fetchrow($result);
	$db->sql_freeresult($result);
	
	if ($row)
	{
		oauth_show_register($oauth_info, true);
	}
	$row = oauth_new_user_row($oauth_info);
	
	if (!function_exists('user_add'))
	{
		include($phpbb_root_path . 'includes/functions_user.' . $phpEx);
	}
	$id = user_add($row);
	$sql = 'UPDATE ' . USERS_TABLE . ' SET oauth_method = "' . $oauth_info->oauth_method . '", oauth_id = "'
				 . $oauth_info->id . '", oauth_token="' . $oauth_info->access_token . '" WHERE user_id = ' . $id;
	$db->sql_query($sql);
	
	redirect("./ucp." . $phpEx . "?mode=login");
}

if ($_REQUEST['mode'] == 'register')
{
	oauth_register();
}
else
{
	oauth_login();
}

?>
