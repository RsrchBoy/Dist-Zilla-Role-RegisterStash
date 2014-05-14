package Dist::Zilla::Role::RegisterStash;

# ABSTRACT: A plugin that can register stashes

use Moose::Role;
use namespace::autoclean;
use Class::Load;

use Dist::Zilla 4.3 ();

=method _register_stash($name => $stash_instance)

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

=method _register_or_retrieve_stash

Given a stash name (e.g. C<%Store::Git>), return that stash.  If our C<dzil>
claims to not be aware of any such stash we register a new instance of the
stash in question and return it.

=cut

sub _register_or_retrieve_stash {
    my ($self, $name) = @_;

    my $stash = $self->zilla->stash_named($name);
    return $stash
        if $stash;

    # TODO isn't there a better way?!
    (my $stash_pkg = $name) =~ s/^%/Dist::Zilla::Stash::/;

    ### $stash_pkg;
    Class::Load::load_class($stash_pkg);
    $stash = $stash_pkg->new();
    $self->_register_stash($name => $stash);
    return $stash;
}

!!42;
__END__

=for :stopwords zilla somesuch

=head1 SYNOPSIS

    # in your plugin...
    with 'Dist::Zilla::Role::RegisterStash';

    # and elsewhere...
    $self->_register_stash('%Foo' => $stash);

=head1 DESCRIPTION

Sometimes it's handy for a plugin to register a stash, and there's no easy way
to do that (without touching $self->zilla->_local_stashes or somesuch).

This role provides a _register_stash() method to your plugin, allowing you to
register stashes.  Yes, the leading underscore is intentional: the purpose of
this method is to allow the consuming plugin to register stashes, not anyone
else, so this method is private to the consumer.

=cut
