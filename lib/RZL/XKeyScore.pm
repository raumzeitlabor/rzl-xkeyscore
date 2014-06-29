package RZL::XKeyScore;

use 5.006;
use strict;
use warnings FATAL => 'all';

use DBI;
use YAML::Syck;
use Sys::Syslog;
use AnyEvent::MQTT;
use SQL::Abstract;

=head1 NAME

RZL::XKeyScore - The great new RZL::XKeyScore!

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

my $cfg;
if (-e 'rzl-xkeyscore.yml') {
    $cfg = LoadFile('rzl-xkeyscore.yml');
} elsif (-e '/etc/rzl-xkeyscore.yml') {
    $cfg = LoadFile('/etc/rzl-xkeyscore.yml');
} else {
    die "Could not load ./rzl-xkeyscore.yml or /etc/rzl-xkeyscore.yml";
}

if (!exists($cfg->{Database}) || !exists($cfg->{MQTT})) {
    die "Configuration sections incomplete: need 'Database' and 'MQTT'";
}

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use RZL::XKeyScore;

    my $foo = RZL::XKeyScore->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 run

=cut

sub run {
    my $sql = SQL::Abstract->new();

    syslog('info', 'Starting up…');

    my $dbh = DBI->connect($cfg->{Database}->{dsn}, $cfg->{Database}->{user}, $cfg->{Database}->{passwd}, {
        RaiseError => 1,
        AutoCommit => 1,
    });

    my $mqtt = AnyEvent::MQTT->new(
        host => $cfg->{MQTT}->{host},
        timeout => $cfg->{MQTT}->{timeout},
        keep_alive_timer => $cfg->{MQTT}->{keepalive},
        clean_session => $cfg->{MQTT}->{cleansession},
        client_id => $cfg->{MQTT}->{clientid},
        message_log_callback => sub {
            syslog('debug', join (',', @_));
        },
    );

    my $cv = AE::cv;

    $mqtt->subscribe(
        topic => '#',
        callback => sub {
            my ($topic, $msg, $d) = @_;

            $dbh->ping;

            # filter out blacklisted topics
            if (grep /^$topic/, @{$cfg->{MQTT}->{blacklist}}) {
                return;
            }

            my ($stmnt, @bind) = $sql->insert('messages', {
                topic => $topic,
                payload => $msg,
                qos => $d->{qos},
                retain => $d->{retain},
            });

            my $sth = $dbh->prepare($stmnt);
            $sth->execute(@bind);

        })->recv;

    $cv->recv;

    syslog('info', 'subscribed to MQTT topic');
}

=head1 AUTHOR

Simon Elsbrock, C<< <simon at iodev.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-rzl-xkeyscore at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=RZL-XKeyScore>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc RZL::XKeyScore


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=RZL-XKeyScore>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/RZL-XKeyScore>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/RZL-XKeyScore>

=item * Search CPAN

L<http://search.cpan.org/dist/RZL-XKeyScore/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Simon Elsbrock.

This program is released under the following license: GPL


=cut

1; # End of RZL::XKeyScore
