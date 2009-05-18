use inc::Module::Install;
name 'Mouse-Exporter';
all_from 'lib/.pm';

# requires '';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::UseAllModules';
author_tests 'xt';
use_test_base;

auto_include_deps;
WriteAll;
