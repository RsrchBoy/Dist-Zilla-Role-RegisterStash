package Dist::Zilla::Plugin::TestAddStash;

use Moose;
use namespace::autoclean;

use aliased 'Dist::Zilla::Stash::TestStash';

with
    'Dist::Zilla::Role::BeforeRelease',
    'Dist::Zilla::Role::RegisterStash',
    ;

use Test::More;

sub before_release {
    my $self = shift @_;

    # add stash
    pass 'in before_release()';
    $self->_register_stash(
        '%TestStash' => TestStash->new(),
    );
    return;
}


__PACKAGE__->meta->make_immutable;
!!42;
__END__
