use strict;
use warnings;
use Crypt::OpenSSL::RSA;
use Data::Section::Simple qw/ get_data_section /;
use Data::UUID;
use File::Basename qw/ dirname /;
use File::Spec;
use MIME::Base64 qw/ encode_base64 /;
use Plack::Builder;
use Plack::Request;
use Plack::Response;

my $uuid = Data::UUID->new;

my $app = sub {
    my $env = shift;
    my $request  = Plack::Request->new($env);
    my $response = $request->new_response(200);

    if ($request->path eq '/') {
        $response->content_type('text/html');
        $response->body( get_data_section('index.html') );
    }
    elsif ($request->path eq '/generate' && $request->method eq 'POST') {
        my $rsa = Crypt::OpenSSL::RSA->new_public_key($request->param('pubkey'));
        $rsa->use_pkcs1_padding;

        my $cipher = $rsa->encrypt($uuid->create_str);

        $response->content_type('text/plain');
        $response->body(encode_base64($cipher));
    }
    else {
        $response->status(404);
        $response->content_type('text/html');
        $response->body( get_data_section('404.html') );
    }

    return $response->finalize;
};

builder {
    enable 'Plack::Middleware::Static', (
        path => qr{^(?:/assets/)},
        root => File::Spec->catdir( dirname(__FILE__) ),
    );

    $app;
}


__DATA__

@@ index.html
<!DOCTYPE html>
<html lang="ja">
  <head>
    <title>JP RSA</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet">
    <link href="/assets/css/main.css" rel="stylesheet">
  </head>
  <body>
    <nav class="navbar navbar-default" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <span class="navbar-brand">JP RSA</span>
        </div>
      </div>
    </nav>

    <div class="container">
      <div class="page-header">
        <h1>RSA Communication</h1>
      </div>

      <section id="encryption">
        <h2>Encryption and Decryption</h2>
        <p class="text-muted">Sample application of the RSA communication between Perl (Encryptor) and JavaScript (Decryptor).</p>
        <div class="row">
          <div class="col-lg-6 col-md-12">
            <h3>Cryptogram</h3>
            <p class="text-muted">Encrypt on server (Perl) using public key</p>
            <pre id="cryptogram"></pre>
          </div>

          <div class="col-lg-6 col-md-12">
            <h3>Plain Text <small>Received UUID</small></h3>
            <p class="text-muted">Decrypt on client (JavaScript) using private key</p>
            <pre id="plain-text"></pre>
          </div>
        </div>

        <div class="btn-area">
          <div class="text-center">
            <a id="generate" class="btn btn-success" data-href="/generate">
              <i class="icon-refresh"></i> Regenerate UUID
            </a>
          </div>
        </div>
      </section>

      <section id="rsakey">
        <h2>RSA Keys</h2>
        <p class="text-muted">RSA Keys were generated by JavaScript on client side.</p>
        <div class="row">
          <div class="col-lg-6 col-md-12">
            <h3>Public Key</h3>
            <pre id="public-key"></pre>
          </div>

          <div class="col-lg-6 col-md-12">
            <h3>Private Key</h3>
            <pre id="private-key"></pre>
          </div>
        </div>

        <div class="btn-area">
          <div class="text-center">
            <a id="newkey" class="btn btn-info">
              <i class="icon-refresh"></i> Regenerate RSA Key
            </a>
          </div>
        </div>
      </section>
    </div>


    <footer>
      <div class="container">
        <p class="text-muted">
          JP RSA - Created and Maintained by <a href="//twitter.com/hatyuki">@hatyuki</a><br />
          Code licensed under <a href="http://opensource.org/licenses/Artistic-2.0">Artistic License 2.0</a>.
        </p>
        <ul class="list-inline">
          <li><a href="http://getbootstrap.com">Bootstrap</a><li>
          <li><a href="http://travistidwell.com/jsencrypt">JSEncrypt</a></li>
          <li><a href="https://github.com/hatyuki/p5-jprsa"><i class="icon-github"></i></a><li>
          <li><a href="http://fortawesome.github.io/Font-Awesome"><i class="icon-flag"></i></a><li>
          <li><i class="icon-html5"></i><li>
          <li><i class="icon-css3"></i><li>
        </ul>
      </div>
    </footer>

    <script src="//code.jquery.com/jquery-latest.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
    <script src="/assets/js/jsencrypt.min.js"></script>
    <script src="/assets/js/main.js"></script>
  </body>
</html>

@@ 404.html
<!DOCTYPE html>
<html lang="ja">
  <head>
    <title>JP RSA</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet">
    <link href="/assets/css/main.css" rel="stylesheet">
  </head>
  <body>
    <nav class="navbar navbar-default" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="/">JP RSA</a>
        </div>
      </div>
    </nav>

    <div class="container">
      <div class="jumbotron">
        <div class="container">
          <h1>404 Not Found</h1>
          <p>The server has not found anything matching the Request-URI.</p>
          <p>
            <a class="btn btn-primary btn-lg" href="/">
              <i class="icon-reply icon-large"></i> Return to top page
            </a>
          </p>
        </div>
      </div>
    </div>

    <footer>
      <div class="container">
        <p class="text-muted">
          JP RSA - Created and Maintained by <a href="//twitter.com/hatyuki">@hatyuki</a><br />
          Code licensed under <a href="http://opensource.org/licenses/Artistic-2.0">Artistic License 2.0</a>.
        </p>
        <ul class="list-inline">
          <li><a href="http://getbootstrap.com">Bootstrap</a><li>
          <li><a href="http://travistidwell.com/jsencrypt">JSEncrypt</a></li>
          <li><a href="https://github.com/hatyuki/p5-jprsa"><i class="icon-github"></i></a><li>
          <li><a href="http://fortawesome.github.io/Font-Awesome"><i class="icon-flag"></i></a><li>
          <li><i class="icon-html5"></i><li>
          <li><i class="icon-css3"></i><li>
        </ul>
      </div>
    </footer>
  </body>
</html>
