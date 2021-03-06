use strict;
use Test::More tests => 26;

{
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
}

{
    {
        package MouseX::WithCaller;
        use Mouse;
        use Mouse::Exporter;

        sub bar { 1 }

        Mouse::Exporter->setup_import_methods(
            with_caller => ['bar'],
        );

        package MyClass::WithCaller;
        MouseX::WithCaller->import;

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
}

{
    {
        package MyClass::AsIs::Foo;
        sub foo { 1 }

        package MouseX::AsIs;
        use Mouse;
        use Mouse::Exporter;

        sub bar { 1 }

        Mouse::Exporter->setup_import_methods(
            as_is => ['bar', \&MyClass::AsIs::foo],
        );

        package MyClass::AsIs;
        MouseX::AsIs->import;

        sub baz { 1 }
    }

    can_ok 'MyClass::AsIs', 'foo';
    can_ok 'MyClass::AsIs', 'bar';
    can_ok 'MyClass::AsIs', 'baz';

    {
        package MyClass::AsIs;
        MouseX::AsIs->unimport;
    }

    can_ok 'MyClass::AsIs', 'foo';
    ok not MyClass::AsIs->can('bar');
    can_ok 'MyClass::AsIs', 'baz';
}

{
    {
        package MouseX::Complex;
        use Mouse;
        use Mouse::Exporter;

        sub bar { 1 }
        sub baz { 1 }

        Mouse::Exporter->setup_import_methods(
            with_caller => ['bar'],
            as_is       => ['baz'],
            also        => 'Mouse',
        );

        package MyClass::Complex;
        MouseX::Complex->import;

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
}
