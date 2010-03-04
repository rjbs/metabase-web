package Metabase::Web::Model::Metabase;
use strict;
use warnings;

our $VERSION = '0.002';
$VERSION = eval $VERSION;

use Moose;

extends 'Catalyst::Model::Adaptor';

around 'COMPONENT' => sub {
  my ($method, $self, @args) = @_;

  my $component = $self->$method(@args);

  unless ( $component->does('Metabase::Gateway') ) {
    die ref($component) . " does not provide the Metabase::Gateway role\n"
  }

  # XXX: This is sort of a massive hack, but it makes testing easy by giving us
  # access to the gateway the test server will use. -- rjbs, 2009-03-30
  if (my $code = our $COMPONENT_CALLBACK) {
    $code->($component);
  }

  return $component;
};


=head1 AUTHOR

=over 

=item * David A. Golden (DAGOLDEN)

=item * Ricardo J. B. Signes (RJBS)

=back

=head1 COPYRIGHT AND LICENSE

  Portions copyright (c) 2008-2009 by David A. Golden
  Portions copyright (c) 2008-2009 by Ricardo J. B. Signes

Licensed under the same terms as Perl itself (the "License").
You may not use this file except in compliance with the License.
A copy of the License was distributed with this file or you may obtain a
copy of the License from http://dev.perl.org/licenses/

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

1;
