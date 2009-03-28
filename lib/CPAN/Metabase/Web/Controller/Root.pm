use strict;
use warnings;
package CPAN::Metabase::Web::Controller::Root;
use base 'Catalyst::Controller::REST';

our $VERSION = '0.001';
$VERSION = eval $VERSION; # convert '1.23_45' to 1.2345

use Data::GUID;

# /submit/Test-Report/dist/RJBS/Acme-ProgressBar-1.124.tar.gz/
#  submit 0           dist 0    1
sub submit : Chained('/') Args(1) ActionClass('REST') {
  my ($self, $c, $type) = @_;

  $c->stash->{type} = $type;
}

sub submit_POST {
  my ($self, $c) = @_;

  # XXX: This is a tremendous bodge.  -- rjbs, 2009-03-28
  my $struct = $c->req->data->[0];
  $struct->{content} = $c->req->data->[1];

  Carp::confess("URL and POST types do not match")
    unless $c->stash->{type} eq $struct->{core_metadata}{type}[1];

  # XXX: In the future, this might be a queue id.  That might be a guid.  Time
  # will tell! -- rjbs, 2008-04-08
  my $guid = eval {
    $c->model('Metabase')->gateway->handle({
      request => {
        user_id => 'rjbs',
      },
      struct  => $struct,
    });
  };

  unless ($guid) {
    my $error = $@ || '(unknown error)';
    warn $error; # XXX: we should catch and report Permission exceptions, etc
                 # -- rjbs, 2008-04-07

    return $self->status_bad_request($c, message => "gateway failure: $error");
  }

  return $self->status_created(
    $c,
    location => '/guid/' . $guid->as_string, # XXX: uri_for or something?
    entity   => { guid => $guid->as_string },
  );
}

# /guid/CC3F4AF4-0571-11DD-AA50-85A198B5225E
#  guid 0
sub guid : Chained('/') Args(1) ActionClass('REST') {
  my ($self, $c, $guid) = @_;

  if (my $guid = eval { Data::GUID->from_string($guid) }) {
    $c->stash->{guid} = $guid;
  }
}

sub guid_GET {
  my ($self, $c) = @_;

  return $self->status_bad_request($c, message => "invalid guid")
    unless my $guid = $c->stash->{guid};

  return $self->status_not_found($c, message => 'no such resource')
    unless my $fact = $c->model->librarian->extract($guid);
  
  return $self->status_ok(
    $c,
    entity => {
      dist_author    => $fact->dist_author,
      dist_file      => $fact->dist_file,
      type           => $fact->type,
      schema_version => $fact->schema_version,
      content        => $fact->content_as_string,
      user_id        => 'unknown',
    },
  );
}

# /search/.....
sub search : Chained('/') CaptureArgs(0) {
}

sub simple : Chained('search') ActionClass('REST') {
}

sub simple_GET {
  my ($self, $c, @args) = @_;

  my $data = $c->model('Metabase')->librarian->search(@args);

  return $self->status_ok(
    $c,
    entity => $data,
  );
}

1;
