package Plack::App::Register;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Plack::Util::Accessor qw(generator message_cb redirect_register redirect_error register_cb title);
use Plack::Request;
use Plack::Response;
use Plack::Session;
use Tags::HTML::Container;
use Tags::HTML::Login::Register;

our $VERSION = 0.01;

sub _css {
	my ($self, $env) = @_;

	$self->{'_container'}->process_css;
	$self->{'_login_register'}->process_css({
		'info' => 'blue',
		'error' => 'red',
	});

	return;
}

sub _message {
	my ($self, $env, $message_type, $message) = @_;

	if (defined $self->message_cb) {
		$self->message_cb->($env, $message_type, $message);
	}

	return;
}

sub _prepare_app {
	my $self = shift;

	# Defaults which rewrite defaults in module which I am inheriting.
	if (! defined $self->generator) {
		$self->generator(__PACKAGE__.'; Version: '.$VERSION);
	}

	if (! defined $self->title) {
		$self->title('Register page');
	}

	# Inherite defaults.
	$self->SUPER::_prepare_app;

	# Defaults from this module.
	my %p = (
		'css' => $self->css,
		'tags' => $self->tags,
	);
	$self->{'_login_register'} = Tags::HTML::Login::Register->new(%p);
	$self->{'_container'} = Tags::HTML::Container->new(%p);

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	if (defined $self->register_cb && $env->{'REQUEST_METHOD'} eq 'POST') {
		my $req = Plack::Request->new($env);
		my $body_params_hr = $req->body_parameters;
		my ($status, $messages_ar) = $self->_register_check($env, $body_params_hr);
		my $res = Plack::Response->new;
		if ($status) {
			if ($self->register_cb->($env, $body_params_hr->{'username'},
				$body_params_hr->{'password1'})) {

				$self->_message($env, 'info',
					"User '$body_params_hr->{'username'}' is registered.");
				$res->redirect($self->redirect_register);
			} else {
				$res->redirect($self->redirect_error);
			}
		} else {
			$res->redirect($self->redirect_error);
		}
		$self->psgi_app($res->finalize);
	}

	return;
}

sub _register_check {
	my ($self, $env, $body_parameters_hr) = @_;

	if (! exists $body_parameters_hr->{'register'}
		|| $body_parameters_hr->{'register'} ne 'register') {

		$self->_message($env, 'error', 'There is no register POST.');
		return 0;
	}
	if (! defined $body_parameters_hr->{'username'} || ! $body_parameters_hr->{'username'}) {
		$self->_message($env, 'error', "Parameter 'username' doesn't defined.");
		return 0;
	}
	if (! defined $body_parameters_hr->{'password1'} || ! $body_parameters_hr->{'password1'}) {
		$self->_message($env, 'error', "Parameter 'password1' doesn't defined.");
		return 0;
	}
	if (! defined $body_parameters_hr->{'password2'} || ! $body_parameters_hr->{'password2'}) {
		$self->_message($env, 'error', "Parameter 'password2' doesn't defined.");
		return 0;
	}
	if ($body_parameters_hr->{'password1'} ne $body_parameters_hr->{'password2'}) {
		$self->_message($env, 'error', 'Passwords are not same.');
		return 0;
	}

	return 1;
}

sub _tags_middle {
	my ($self, $env) = @_;

	my $messages_ar = [];
	if (exists $env->{'psgix.session'}) {
		my $session = Plack::Session->new($env);
		$messages_ar = $session->get('messages');
		$session->set('messages', []);
	}
	$self->{'_container'}->process(
		sub {
			$self->{'_login_register'}->process($messages_ar);
		},
	);

	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Plack::App::Register - Plack register application.

=head1 SYNOPSIS

 use Plack::App::Register;

 my $obj = Plack::App::Register->new(%parameters);
 my $psgi_ar = $obj->call($env);
 my $app = $obj->to_app;

=head1 METHODS

=head2 C<new>

 my $obj = Plack::App::Register->new(%parameters);

Constructor.

Returns instance of object.

=over 8

=item * C<css>

Instance of CSS::Struct::Output object.

Default value is CSS::Struct::Output::Raw instance.

=item * C<generator>

HTML generator string.

Default value is 'Plack::App::Login; Version: __VERSION__'.

=item * C<login_link>

Login link.

Default value is 'login'.

=item * C<login_title>

Login title.

Default value is 'LOGIN'.

=item * C<tags>

Instance of Tags::Output object.

Default value is Tags::Output::Raw->new('xml' => 1) instance.

=item * C<title>

Page title.

Default value is 'Login page'.

=back

=head2 C<call>

 my $psgi_ar = $obj->call($env);

Implementation of login page.

Returns reference to array (PSGI structure).

=head2 C<to_app>

 my $app = $obj->to_app;

Creates Plack application.

Returns Plack::Component object.

=head1 EXAMPLE

 use strict;
 use warnings;

 use CSS::Struct::Output::Indent;
 use Plack::App::Register;
 use Plack::Runner;
 use Tags::Output::Indent;

 # Run application.
 my $app = Plack::App::Register->new(
         'css' => CSS::Struct::Output::Register->new,
         'tags' => Tags::Output::Register->new(
                 'preserved' => ['style'],
                 'xml' => 1,
         ),
 )->to_app;
 Plack::Runner->new->run($app);

 # Output:
 # HTTP::Server::PSGI: Accepting connections at http://0:5000/

 # > curl http://localhost:5000/
 # TODO

=head1 DEPENDENCIES

L<CSS::Struct::Output::Raw>,
L<Plack::Util::Accessor>,
L<Tags::HTML::Login::Button>,
L<Tags::HTML::Page::Begin>,
L<Tags::HTML::Page::End>,
L<Tags::Output::Raw>,
L<Unicode::UTF8>.

=head1 SEE ALSO

=over

=item L<Plack::App::Login>

Plack login application.

=back

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/Plack-App-Register>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2023 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
