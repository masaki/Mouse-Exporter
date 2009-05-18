use strict;
use Test::More tests => 26;

{
    package MouseX::Also;
    use Mouse;
    use Mouse::Exporter;
    Mouse::Exporter->setup_import_methods(
        also => 'Mouse',
    );

    package MyClass::Also;
    MouseX::Also->import;

    sub foo { 1 }
}

can_ok 'MyClass::Also', 'has';
can_ok 'MyClass::Also', 'with';
can_ok 'MyClass::Also', 'foo';

{
    package MyClass::Also;
    MouseX::Also->unimport;
}

ok not MyClass::Also->can('has');
ok not MyClass::Also->can('with');
can_ok 'MyClass::Also', 'foo';
isa_ok MyClass::Also->meta, 'Mouse::Meta::Class';
isa_ok MyClass::Also->new, 'Mouse::Object';

{
    package MooseX::WithCaller;
    use Mouse;
    use Mouse::Exporter;

    sub bar { 1 }

    Moose::Exporter->setup_import_methods(
        with_caller => ['bar'],
    );

    package MyClass::WithCaller;
    MooseX::WithCaller->import;

    sub foo { 1 }
}

can_ok 'MyClass::WithCaller', 'foo';
can_ok 'MyClass::WithCaller', 'bar';

{
    package MyClass::WithCaller;
    MouseX::WithCaller->unimport;
}

can_ok 'MyClass::WithCaller', 'foo';
ok not MyClass::WithCaller->can('bar');

{
    package MooseX::Complex;
    use Mouse;
    use Mouse::Exporter;

    sub bar { 1 }
    sub baz { 1 }

    Moose::Exporter->setup_import_methods(
        with_caller => ['bar'],
        as_is       => ['baz'],
        also        => 'Mouse',
    );

    package MyClass::Complex;
    MooseX::Complex->import;

    sub foo { 1 }
}

can_ok 'MyClass::Complex', 'has';
can_ok 'MyClass::Complex', 'with';
can_ok 'MyClass::Complex', 'foo';
can_ok 'MyClass::Complex', 'bar';
can_ok 'MyClass::Complex', 'baz';

{
    package MyClass::Complex;
    MouseX::Complex->unimport;
}

ok not MyClass::Complex->can('has');
ok not MyClass::Complex->can('with');
can_ok 'MyClass::Complex', 'foo';
ok not MyClass::Complex->can('bar');
ok not MyClass::Complex->can('baz');
