use strict;
use warnings;

use CSS::Struct::Output::Indent;
use HTTP::Request;
use Plack::App::Register;
use Plack::Test;
use Tags::Output::Indent;
use Test::More 'tests' => 3;
use Test::NoWarnings;

# Test.
my $app = Plack::App::Register->new;
my $test = Plack::Test->create($app);
my $res = $test->request(HTTP::Request->new(GET => '/'));
my $right_ret = <<"END";
<!DOCTYPE html>
<html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta name="generator" content="Plack::App::Register; Version: $Plack::App::Register::VERSION" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /><title>Register page</title><style type="text/css">
*{box-sizing:border-box;margin:0;padding:0;}.container{display:flex;align-items:center;justify-content:center;height:100vh;}.form-register{width:300px;background-color:#f2f2f2;padding:20px;border-radius:5px;box-shadow:0 0 10px rgba(0, 0, 0, 0.2);}.form-register fieldset{border:none;padding:0;margin-bottom:20px;}.form-register legend{font-weight:bold;margin-bottom:10px;}.form-register p{margin:0;padding:10px 0;}.form-register label{display:block;font-weight:bold;margin-bottom:5px;}.form-register input[type="text"],.form-register input[type="password"]{width:100%;padding:8px;border:1px solid #ccc;border-radius:3px;}.form-register button[type="submit"]{width:100%;padding:10px;background-color:#4CAF50;color:#fff;border:none;border-radius:3px;cursor:pointer;}.form-register button[type="submit"]:hover{background-color:#45a049;}.form-register .messages{text-align:center;}.error{color:red;}.info{color:blue;}
</style></head><body><div class="container"><div class="inner"><form class="form-register" method="post"><fieldset><legend>Register</legend><p><label for="username" />User name<input type="text" name="username" id="username" autofocus="autofocus" /></p><p><label for="password1">Password #1</label><input type="password" name="password1" id="password1" /></p><p><label for="password2">Password #2</label><input type="password" name="password2" id="password2" /></p><p><button type="submit" name="register" value="register">Register</button></p></fieldset></form></div></div></body></html>
END
chomp $right_ret;
my $ret = $res->content;
is($ret, $right_ret, 'Get default main page in raw mode.');

# Test.
$app = Plack::App::Register->new(
	'css' => CSS::Struct::Output::Indent->new,
	'tags' => Tags::Output::Indent->new(
		'preserved' => ['style'],
		'xml' => 1,
	),
);
$test = Plack::Test->create($app);
$res = $test->request(HTTP::Request->new(GET => '/'));
$right_ret = <<"END";
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="generator" content="Plack::App::Register; Version: $Plack::App::Register::VERSION" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>
      Register page
    </title>
    <style type="text/css">
* {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}
.container {
	display: flex;
	align-items: center;
	justify-content: center;
	height: 100vh;
}
.form-register {
	width: 300px;
	background-color: #f2f2f2;
	padding: 20px;
	border-radius: 5px;
	box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
}
.form-register fieldset {
	border: none;
	padding: 0;
	margin-bottom: 20px;
}
.form-register legend {
	font-weight: bold;
	margin-bottom: 10px;
}
.form-register p {
	margin: 0;
	padding: 10px 0;
}
.form-register label {
	display: block;
	font-weight: bold;
	margin-bottom: 5px;
}
.form-register input[type="text"], .form-register input[type="password"] {
	width: 100%;
	padding: 8px;
	border: 1px solid #ccc;
	border-radius: 3px;
}
.form-register button[type="submit"] {
	width: 100%;
	padding: 10px;
	background-color: #4CAF50;
	color: #fff;
	border: none;
	border-radius: 3px;
	cursor: pointer;
}
.form-register button[type="submit"]:hover {
	background-color: #45a049;
}
.form-register .messages {
	text-align: center;
}
.error {
	color: red;
}
.info {
	color: blue;
}
</style>
  </head>
  <body>
    <div class="container">
      <div class="inner">
        <form class="form-register" method="post">
          <fieldset>
            <legend>
              Register
            </legend>
            <p>
              <label for="username" />
              User name
              <input type="text" name="username" id="username" autofocus=
                "autofocus" />
            </p>
            <p>
              <label for="password1">
                Password #1
              </label>
              <input type="password" name="password1" id="password1" />
            </p>
            <p>
              <label for="password2">
                Password #2
              </label>
              <input type="password" name="password2" id="password2" />
            </p>
            <p>
              <button type="submit" name="register" value="register">
                Register
              </button>
            </p>
          </fieldset>
        </form>
      </div>
    </div>
  </body>
</html>
END
chomp $right_ret;
$ret = $res->content;
is($ret, $right_ret, 'Get default main page in indent mode.');
