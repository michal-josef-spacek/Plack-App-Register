package Plack::App::Register;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Plack::Util::Accessor qw(generator redirect_register redirect_error register title);
use Tags::HTML::Container;
use Tags::HTML::Login::Register;

our $VERSION = 0.01;

sub _css {
	my $self = shift;

	$self->{'_container'}->process_css;
	$self->{'_login_register'}->process_css;

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

	if (defined $self->register) {
		$env->{'psgi.errors'}->print("Register\n");
		my $req = Plack::Request->new($env);
		my $res = Plack::Response->new;
		my $body_params_hr = $req->body_parameters;
		my ($status, $messages_ar) = $self->_register_check($body_params_hr);
		$env->{'psgi.errors'}->print("Status: $status\n");
		$env->{'psgi.errors'}->print("Messages: ".(join "|", @{$messages_ar})."\n");
		# TODO Save messages to session.
		if ($status) {
			if ($self->register->($env, $body_params_hr->{'username'},
				$body_params_hr->{'password1'})) {

				$res->redirect($self->redirect_register);
			} else {
				$res->redirect($self->redirect_error);
			}
			$self->psgi_app($res->finalize);
		}
	}

	return;
}

sub _register_check {
	my ($self, $body_parameters_hr) = @_;

	if (! defined $body_parameters_hr) {
		return (0, ['No POST.']);
	}
	if (! exists $body_parameters_hr->{'register'}
		|| $body_parameters_hr->{'register'} ne 'register') {

		return (0, ['There is no register POST.']);
	}
	if (! defined $body_parameters_hr->{'username'}) {
		return (0, ["Parameter 'username' doesn't defined."]);
	}
	if (! defined $body_parameters_hr->{'password1'}) {
		return (0, ["Parameter 'password1' doesn't defined."]);
	}
	if (! defined $body_parameters_hr->{'password2'}) {
		return (0, ["Parameter 'password2' doesn't defined."]);
	}
	if ($body_parameters_hr->{'password1'} ne $body_parameters_hr->{'password2'}) {
		return (0, ['Passwords are not same.']);
	}

	return (1, []);
}

sub _tags_middle {
	my $self = shift;

	$self->{'_container'}->process(
		sub {
			$self->{'_login_register'}->process;
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

© 2021 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
