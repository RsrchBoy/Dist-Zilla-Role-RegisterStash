package Dist::Zilla::Role::RegisterStash;

# ABSTRACT: A plugin that can register stashes

use Moose::Role;
use namespace::autoclean;

with 'Dist::Zilla::Role::Plugin';

=method _register_stash($name => $stash)

Given a name and a stash instance, register it with our zilla object.

=cut

# so, we're a little sneaky here.  It's possible to register stashes w/o
# touching any "private" attributes or methods in the zilla object while it is
# being built from the configuration, but we don't always want to create them
# then.  (Think of it like a lazy attribute -- we don't want to build it until
# we need it, and it may be created further down in the configuration
# anyways.)
#
# instead we generate a coderef capturing our assembler, and stash that away.
# If we need to register a stash later, we'll be able to access the
# registration method as if we were during the build stage.

has _register_stash_method => (
    traits  => ['Code'],
    is      => 'ro',
    isa     => 'CodeRef',
    handles => {
        _register_stash => 'execute',
    },
);

before register_component => sub {
    my ($class, $name, $arg, $section) = @_;

    my $assembler = $section->sequence->assembler;
    $arg->{_register_stash_method} ||= sub {
        $assembler->register_stash(@_);
    };

    return;
};

!!42;
__END__

=for :stopwords zilla

=head1 SYNOPSIS

    # in your plugin...
    with 'Dist::Zilla::Role::RegisterStash';

    # and elsewhere...
    $self->_register_stash('%Foo' => $stash);

=head1 DESCRIPTION

Sometimes it's handy for a plugin to register a stash, and there's no easy way
to do that (without touching $self->zilla->_local_stashes or somesuch).

This role provides a _register_stash() method to your plugin, allowing you to
register stashes.

=cut
