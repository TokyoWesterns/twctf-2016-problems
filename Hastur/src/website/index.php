<?php
$name = "Hastur";
$text = "";

$submitted = isset($_POST["text"]);
if ($submitted) {
    $name = $_POST["name"];
    $text = $_POST["text"];
}

?>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Hastur</title>
</head>
<body>
<form method="POST">
<div>
<select name="name">
  <option value="Hastur"<?php if ($name == "Hastur") echo " selected"; ?>>Hastur</option>
  <option value="Cthugua"<?php if ($name == "Cthugua") echo " selected"; ?>>Cthugua</option>
  <option value="Nyarlathotep"<?php if ($name == "Nyarlathotep") echo " selected"; ?>>Nyarlathotep</option>
</select>
</div>
<div><textarea rows="16" cols="80" name="text"><?php
if ($submitted) {
    echo htmlspecialchars($text);
}
?></textarea></div>
<div><input type="submit"></div>
</form>

<?php
if ($submitted) {
    hastur_set_name($name);
    $result = hastur_ia_ia($text);
    echo "<pre>" . htmlspecialchars($result) . "</pre>";
}
?>

</body>
</html>
