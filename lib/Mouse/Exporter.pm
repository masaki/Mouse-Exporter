package Mouse::Exporter;

use 5.008_001;
use strict;
use warnings;
use Mouse ();
use Data::Util qw(
    get_code_ref get_code_info
    install_subroutine uninstall_subroutine
);

our $VERSION = '0.01';

sub import {
    strict->import;
    warnings->import;
}

sub setup_import_methods {
    my ($class, %args) = @_;

    $args{exporting_package} ||= caller;
    my ($import, $unimport) = $class->build_import_methods(%args);

    no strict 'refs';
    *{ $args{exporting_package} . '::import'   } = $import;
    *{ $args{exporting_package} . '::unimport' } = $unimport;
}

sub build_import_methods {
    my ($class, %args) = @_;

    my $caller = $args{exporting_package} ||= caller;
    my ($exports, $is_removable) = $class->_build_keywords(%args);

    my $import   = $class->_make_import_sub($exports);
    my $unimport = $class->_make_unimport_sub($is_removable);

    return ($import, $unimport);
}

sub _build_keywords {
    my ($class, %args) = @_;
    my (%exports, %is_removable);

    for my $name (@{ $args{with_caller} || [] }) {
        $exports{$name} = get_code_ref($args{exporting_package}, $name);
        $is_removable{$name}++;
    }

    for my $name (@{ $args{as_is} || [] }) {
        my $code;

        if (ref $name) {
            $code = $name;
            (my $package, $name) = get_code_info($code);
            $is_removable{$name}++ if $package eq $args{exporting_package};
        }
        else {
            $code = get_code_ref($args{exporting_package}, $name);
            $is_removable{$name}++;
        }

        $exports{$name} = $code;
    }

    if (exists $args{also}) {
        my @also = ref $args{also} ? @{ $args{also} } : ($args{also});

        no strict 'refs';
        for my $package (@also) {
            Mouse::load_class($package);
            next unless my @export = @{ $package . '::EXPORT' };
            for my $name (@export) {
                $exports{$name} = get_code_ref($package, $name);
                $is_removable{$name}++;
            }
        }
    }

    return (\%exports, \%is_removable);
}

sub _make_import_sub {
    my ($class, $exports) = @_;

    return sub {
        my $class = shift;

        strict->import;
        warnings->import;

        my $opts = (ref $_[0] && ref $_[0] eq 'HASH') ? shift : {};
        my $caller = exists $opts->{into} ? $opts->{into} : caller($opts->{into_level} || 0);

        if ($caller eq 'main') {
            warn qq{$class does not export its sugar to the 'main' package.\n};
            return;
        }

        install_subroutine($caller, %$exports);
    };
}

sub _make_unimport_sub {
    my ($class, $is_removable) = @_;

    return sub {
        my $caller = caller;
        uninstall_subroutine($caller, keys %$is_removable);
    };
}

1;

=head1 NAME

Mouse::Exporter

=head1 SYNOPSIS

    use Mouse::Exporter;

=head1 DESCRIPTION

Mouse::Exporter is

=head1 METHODS

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
