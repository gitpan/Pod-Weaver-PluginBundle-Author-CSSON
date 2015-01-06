use 5.10.1;
use strict;
use warnings;

package Pod::Weaver::PluginBundle::Author::CSSON;

our $VERSION = '0.1000'; # VERSION

use strict;
use warnings;
use Pod::Weaver::Config::Assembler;
use Path::Tiny;

sub xp {
    Pod::Weaver::Config::Assembler->expand_package(shift);
}

sub mvp_bundle_config {
    my @plugins = ();

    # check git config
    my $include_default_github = 0;
    my $git_config = path('.git/config');
    if($git_config->exists) {
        my $git_config_contents = $git_config->slurp_utf8;
        if($git_config_contents =~ m{github\.com:([^/]+)/(.+)\.git}) {
            $include_default_github = 1;
        }
        else {
            warn ('[PW/@Author::CSSON] No github url found');
        }
    }

    push @plugins => (
        ['@Author::CSSON/CorePrep',       xp('@CorePrep'),       { } ],
        ['@Author::CSSON/SingleEncoding', xp('-SingleEncoding'), { } ],
        ['@Author::CSSON/Name',           xp('Name'),            { } ],
        ['@Author::CSSON/Version',        xp('Version'),         { format => q{Version %v, released %{YYYY-MM-dd}d.} } ],
        ['@Author::CSSON/Prelude',        xp('Region'),          { region_name => 'prelude' } ],
    );

    foreach my $plugin (qw/Synopsis Description Overview Stability/) {
        push @plugins => ['@Author::CSSON/'.$plugin, xp('Generic'), { header => uc $plugin } ];
    }

    foreach my $plugin ( ['Attributes', 'attr'],
                         ['Methods', 'method'],
                         ['Functions', 'func'],
    ) {
        push @plugins => [ $plugin->[0], xp('Collect'), { command => $plugin->[1], header => uc $plugin->[0] } ];
    }
    push @plugins => (
        ['@Author::CSSON/Leftovers',             xp('Leftovers'), { } ],
        ['@Author::CSSON/postlude',              xp('Region'),    { } ],
        (
            !$ENV{'ILLER_MINTING'} && $include_default_github ?
            ['@Author::CSSON/Source::DefaultGitHub', xp('Source::DefaultGitHub'), { text => 'L<%s>' } ]
            :
            ()
        ),
        ['@Author::CSSON/Homepage::DefaultCPAN', xp('Homepage::DefaultCPAN'), { text => 'L<%s>' } ],
        ['@Author::CSSON/Authors',               xp('Authors'),   { } ],
        ['@Author::CSSON/Legal',                 xp('Legal'),     { } ],

        ['@Author::CSSON/List', xp('-Transformer'), { transformer => 'List' } ],
    );


    return @plugins;
}

1;

# ABSTRACT: Weave Pod like CSSON

__END__

=pod

=encoding UTF-8

=head1 NAME

Pod::Weaver::PluginBundle::Author::CSSON - Weave Pod like CSSON

=head1 VERSION

Version 0.1000, released 2015-01-07.

=head1 SOURCE

L<https://github.com/Csson/p5-Pod-Weaver-PluginBundle-Author-CSSON>

=head1 HOMEPAGE

L<https://metacpan.org/release/Pod-Weaver-PluginBundle-Author-CSSON>

=head1 AUTHOR

Erik Carlsson <info@code301.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Erik Carlsson <info@code301.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
