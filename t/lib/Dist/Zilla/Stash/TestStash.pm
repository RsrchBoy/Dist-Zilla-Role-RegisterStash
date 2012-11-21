package Dist::Zilla::Stash::TestStash;

use Moose;
use namespace::autoclean;
use MooseX::AttributeShortcuts;

with 'Dist::Zilla::Role::Stash';

__PACKAGE__->meta->make_immutable;
!!42;
__END__
