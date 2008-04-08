use strict;
use warnings;
package CPAN::Metabase::Client;

our $VERSION = '0.001';

use HTTP::Request;
use JSON::XS;
use LWP::UserAgent;
use URI;

my @valid_args;
BEGIN { @valid_args = qw(user key url) };
use Object::Tiny @valid_args;

sub new {
  my ($class, @args) = @_;

  my %args = Params::Validate::validate(
    @args,
    { map { $_ => 1 } @valid_args }
  );

  my $self = bless \%args, $class;

  return $self;
}   

sub user_agent {
  $_[0]->{_ua} ||= LWP::UserAgent->new;
}

sub submit_fact {
  my ($self, $fact) = @_;

  my $path = sprintf 'submit/dist/%s/%s/%s',
    $fact->dist_author,
    $fact->dist_file,
    $fact->type;

  my $req_uri = URI->new($path)->abs($self->url);

  my $req = HTTP::Request->new(
    PUT => $req_uri,
    [
      'Content-type' => 'text/x-json',
      'Accept'       => 'text/x-json',
    ],
    JSON::XS->new->encode({
      version => $fact->schema_version,
      content => $fact->content_as_string,
    }),
  );

  # Is it reasonable to return an HTTP::Response?  I don't know.  For now,
  # let's say yes.
  my $response = $self->user_agent->request($req);
}

sub retrieve_fact {
  my ($self, $guid) = @_;

  my $req_uri = URI->new("guid/$guid")->abs($self->url);

  my $res = $self->user_agent->get(
    $req_uri,
    'Content-type' => 'text/x-json',
    'Accept'       => 'text/x-json',
  );
}

1;
