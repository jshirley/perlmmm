use inc::Module::Install;

name 'PerlMMM';

all_from 'lib/PerlMMM/Manager.pm';

requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'MooseX::Types';
requires 'MooseX::Types::DateTime';

requires 'Data::Microformat';

requires 'Net::MovableType';

auto_include;
auto_install;

WriteAll;
