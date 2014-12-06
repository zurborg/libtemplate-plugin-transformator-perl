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

=cut

=method init

=cut

sub init {
    my $self = shift;

    my %config = %{ $self->{_CONFIG} };
    my @args = @{ $self->{_ARGS} };

    my $name = $config{name} || 'Transformator';

    $self->{_DYNAMIC} = 1;

    $self->install_filter($name);

    $self->{nnt} =
      $config{connect}
      ? Net::NodeTransformator->new( $config{connect} )
      : Net::NodeTransformator->standalone;

    $self->{engine} = $config{engine} || $args[0];

    return $self;
}

=method filter

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
