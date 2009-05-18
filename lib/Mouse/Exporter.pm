package Mouse::Exporter;

use 5.008_001;
use strict;
use warnings;
use Mouse ();
use Data::Util ();

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

    my $caller = $args{exporting_package} || caller;
    my (%exports, %unimports);

    for my $name (@{ $args{with_caller} || [] }) {
        my $code = do {
            no strict 'refs';
            \&{ $caller . '::' . $name };
        };

        $exports{$name} = $code;
        $unimports{$name}++;
    }

    for my $name (@{ $args{as_is} || [] }) {
        my $code;

        if (ref $name) {
            $code = $name;

            my $package;
            ($package, $name) = Data::Util::get_code_info($name);

            $unimports{$name}++ if $package eq $caller;
        }
        else {
            $code = do {
                no strict 'refs';
                \&{ $caller . '::' . $name };
            };

            $unimports{$name}++;
        }

        $exports{$name} = $code;
    }

    my @packages = ref $args{also} ? @{ $args{also} } : ($args{also});

    return $class->_make_import_methods(
        exports   => \%exports,
        unimports => \%unimports,
        packages  => \@packages,
    );
}

sub _make_import_methods {
    my ($class, %args) = @_;

    my $import = sub {
        strict->import;
        warnings->import;

        # TODO: not implemented yet
    };

    my $unimport = sub {
        # TODO: not implemented yet
    };

    return ($import, $unimport);
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
