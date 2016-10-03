<?php
session_start();
if(empty($_SESSION['user'])) {
  header('Location: /login.php');
  return;
}
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello!!</title>
    <link rel="stylesheet" href="/css/pure-min.css">
    <link rel="stylesheet" href="/css/common.css">
  </head>
  <body>
    <div id="layout">
      <div id="main">
        You are <?= $_SESSION['user'] ?>.<br/>
<?php if($_SESSION['user'] === 'admin') {
        echo 'The flag is admin password. Admin password format is "TWCTF{...}".';
} ?>
        <br>
        <a href="/logout.php">Log out</a>
      </div>
    </div>
  </body>
</html>
