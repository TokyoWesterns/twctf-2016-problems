<?php
session_start();
$_SESSION['user'] = NULL;
header('Location: /login.php');
?>
