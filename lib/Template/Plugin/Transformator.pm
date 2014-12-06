use strict;
use warnings;

package Template::Plugin::Transformator;

# ABSTRACT: TemplateToolkit plugin for Net::NodeTransformator

use Net::NodeTransformator;
use Template::Plugin::Filter;
use base qw( Template::Plugin::Filter );

# VERSION

=head1 SYNOPSIS

    [% USE Transformator %]
    
    [% FILTER Transformator 'jade' %]
    
    span
		| Hi!
    
    [% END %]

=head1 DESCRIPTION

This module is a filter for L<Net::NodeTransformator>.

=head1 CONFIGURATION

	Template->new({
		PLUGIN_CONFIG => {
			Transformator => {
				connect => 'hostname:port'
			}
		}
	});

=head1 USAGE EXAMPLES

=over 4

=item * Generic object, name engine each invocation

	[% USE Transformator %]
	[% FILTER Transformator 'engine_name' %]
		Lorem Ipsum
	[% END %]

=item * Specialized object, engine named as construction argument

	[% USE some_engine = Transformator 'engine_name' %]
	[% FILTER $some_engine %]
		Dolorem Sit Amet
	[% END %]

=item * Specialized object, using configuration override

	[% USE other_transformator = Transformator connect = 'some.other.hostname' %]
	[% FILTER $other_transformator 'engine_name' %]
	[% END %]

=item * Specialized object, using configuration override with engine name

	[% USE special_transformator = Transformator
	       connect = 'some.other.hostname'
		   engine = 'engine_name'
	%]
	[% FILTER $special_transformator %]
	[% END %]

=item * Parameterized engine invocation

	[% USE Transformator %]
	[% FILTER Transformator 'jade', name = 'Peter' %]
	| Hi #{name}!
	[% END %]

	[% vars = { name = 'Peter' } %]
	[% FILTER Transformator 'jade', vars %]
	| Hi #{name}!
	[% END %]

	[% USE jade = Transformator 'jade' %]
	[% FILTER $jade name = 'Peter' %]
	| Hi #{name}!
	[% END %]

	[% FILTER $jade vars %]
	| Hi #{name}!
	[% END %]

=back

=cut

=for Pod::Coverage init

=cut

sub init {
    my $self = shift;

    $self->{config} =
      $self->{_CONTEXT}->{CONFIG}->{PLUGIN_CONFIG}->{Transformator} || {};

    my %config = %{ $self->{_CONFIG} };
    my @args   = @{ $self->{_ARGS} };

    my $name = $config{name} || 'Transformator';

    $self->{_DYNAMIC} = 1;

    $self->install_filter($name);

    $self->{nnt} =
      $self->{config}->{connect}
      ? Net::NodeTransformator->new( $self->{config}->{connect} )
      : Net::NodeTransformator->standalone;

    $self->{engine} = $config{engine} || $args[0];

    return $self;
}

=for Pod::Coverage filter

=cut

sub filter {
    my ( $self, $text, $args, $conf ) = @_;

    my %config = %$conf;

    my $nnt =
      $config{connect}
      ? Net::NodeTransformator->new( $config{connect} )
      : $self->{nnt};

    my $engine = $self->{engine};
    $engine ||= shift @$args;

    $text = $nnt->transform( $engine, $text, $conf );
}

1;
