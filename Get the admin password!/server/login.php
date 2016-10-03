<?php
if($_SERVER["REQUEST_METHOD"] == "POST") {
  session_start();
  // Login
  try {
    $mongo = new Mongo();
    $db = $mongo->selectDB("login");
    $collection = $db->selectCollection("users");
    $cursor = $collection->find(array(
      'username' => $_POST['user'],
      'password' => $_POST['password']
    ));
    $users = iterator_to_array($cursor);
    if(empty($users)) {
      $error = 'Wrong user name or password';
    } else {
      $_SESSION['user'] = reset($users)['username'];
      header("Location: /");
      return;
    }
  } catch (Exception $e) {
    $error = "Exception: {$e->getMessage()}";
  }
}
?>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Login as admin(10)</title>
    <link rel="stylesheet" href="/css/pure-min.css">
    <link rel="stylesheet" href="/css/common.css">
  </head>
  <body>
    <div id="layout">
      <div id="main">
        <h1>Login</h1>
<?php if(isset($error)) { ?>
        <div class="error"><?= $error ?></div>
<?php } ?>
        <form class="pure-form pure-form-stacked" method="POST">
          <fieldset>
            <label for="user">User</label>
            <input id="user" name="user" type="text" placeholder="User">

            <label for="password">Password</label>
            <input id="password" name="password" type="password" placeholder="Password">

            <button type="submit" class="pure-button pure-button-primary">Log in</button>
          </fieldset>
        </form>
      </div>
    </div>
  </body>
</html>
