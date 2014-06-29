use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name	 'RZL-XKeyScore';
all_from 'lib/RZL/XKeyScore.pm';
author   q{Simon Elsbrock <simon@iodev.org>};
license  'GPL';

perl_version 5.006;

tests_recursive('t');

resources (
	license	=> 'GPL',
	repository => 'git://github.com/raumzeitlabor/rzl-xkeyscore',
	bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=RZL-XKeyScore',
);

configure_requires (
	'Module::Install' => 0,
);

build_requires (
	'Test::More' => 0,
);

requires (
	'DBI' => 0,
	'EV' => 0,
	'Getopt::Long' => 0,
	'Sys::Syslog' => 0,
	'YAML::Syck' => 0,
	'AnyEvent::MQTT' => 0,
	'SQL::Abstract'  => 0
);

install_script 'rzl-xkeyscore';

postamble <<'END_OF_MAKEFILE';
install:: extra_install
pure_install:: extra_install
install_vendor:: extra_install

extra_install:
	install -dm 755 $(DESTDIR)/etc
	install -m 640 rzl-xkeyscore.yml.ex $(DESTDIR)/etc/rzl-xkeyscore.yml
END_OF_MAKEFILE

WriteAll;
