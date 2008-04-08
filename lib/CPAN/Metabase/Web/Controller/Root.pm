use strict;
use warnings;
package CPAN::Metabase::Web::Controller::Root;
use base 'Catalyst::Controller::REST';

use lib "$ENV{HOME}/code/projects/CPAN-Metabase/lib";

our $VERSION = '0.001';
$VERSION = eval $VERSION; # convert '1.23_45' to 1.2345

use CPAN::Metabase::Gateway;
use CPAN::Metabase::Analyzer::TestFact;
use CPAN::Metabase::Storage::Filesystem;

my $gateway;
BEGIN {
   $gateway ||= CPAN::Metabase::Gateway->new({
    analyzers => [ CPAN::Metabase::Analyzer::TestFact->new ],
    storage   => CPAN::Metabase::Storage::Filesystem->new({
      root_dir => './mb',
    }),
  });
}

sub _gateway { $gateway }

# /submit/dist/RJBS/Acme-ProgressBar-1.124.tar.gz/Test-Report
#  submit dist 0    1                             2
sub submit : Chained('/') CaptureArgs(0) {
}

sub dist : Chained('submit') Args(3) ActionClass('REST') {
  my ($self, $c, $dist_author, $dist_file, $type) = @_;

  { # XXX: 
    return $self->status_bad_request($c, message => 'invalid dist author')
      unless $dist_author =~ /\A[A-Z]+\z/;

    return $self->status_bad_request($c, message => 'invalid distribution')
      unless $dist_file =~ /\.tar\.gz\z/;
  }

  $c->stash(
    user_id     => 'rjbs', # this needs to come from auth and a shared source
    dist_author => $dist_author,
    dist_file   => $dist_file,
    type        => $type,
  );
}

sub dist_POST {
  my ($self, $c) = @_;

  $c->stash->{content} = $c->req->data->{content};

  my $result = eval { $self->_gateway->handle($c->stash); 1; };

  unless ($result) {
    my $error = $@;
    warn $error; # XXX: we should catch and report Permission exceptions
                 # -- rjbs, 2008-04-07

    return $self->status_bad_request($c, message => "gateway failure: $error");
  }

  return $self->status_created(
    $c,
    location => 'http://www.google.com/',
    entity   => { guid => 'unknown' },
  );
}

BEGIN{ *dist_PUT = \&dist_POST; }

1;
