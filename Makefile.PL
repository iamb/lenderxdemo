use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  VERSION   => '0.01',
  PREREQ_PM => {
    'IO::Socket::SSL' => '2.009',
    'Mojolicious' => '0'
    'Mojolicious::Plugin::OpenAPI' => '0',
    'OpenAPI::Client' => '0',
  },
  TEST_REQUIRES => {
    'Test::Exception' => '0',
    'Test::More' => '0.96',
  },
  test => {TESTS => 't/*.t'}
);
