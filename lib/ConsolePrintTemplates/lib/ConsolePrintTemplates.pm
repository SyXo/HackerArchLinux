use strict;
use warnings 'FATAL' => 'all';
use Exporter;


package ConsolePrintTemplates;
use Term::ANSIColor;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use ConsolePrintTemplates ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( CheckReturn CategoryHeading CategoryFooter OperTitle OperHeading UserInput SuccessMessage ErrorOutMessage GetUsername );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &CheckReturn &CategoryHeading &CategoryFooter &OperTitle &OperHeading &UserInput &SuccessMessage &ErrorOutMessage &GetUsername ) ] );


# Preloaded methods go here.
sub CheckReturn {
	my $return = 0;
	if ( "$?" != 0 ) {
		print color( "bold red" );
		print "FAILED!!" , "\n";
		if ( $_[0] ) {
			print $_[1] , "\n\n";
			die;
		}
		else {
			print $_[1] , "\n\n";
			$return = 1;
		}
		print color( "reset" );
	}

	SuccessMessage();
	return $return;
}

sub CategoryHeading {
	print color( "bold cyan" );
	print "<<|_  " , $_[0] , " ... " , "\n";
	print color( "reset" );
}

sub CategoryFooter {
	print color( "bold cyan" );
	print "$_[0]" , "  _|>>" , "\n\n";
	print color( "reset" );
}

sub OperTitle {
	print color( "bold cyan" );
	print $_[0] , "... \n";
	print color( "reset" );
}

sub OperHeading {
	print color( "bold yellow" );
	print $_[0] , " ... ";
	print color( "reset" );
}

sub UserInput {
	print color( "bold yellow" );
	print $_[0] , ": ";
	print color( "reset" );
}

sub SuccessMessage {
	print color( "bold green" );
	print "SUCCESS!" , "\n\n";
	print color( "reset" );
}

sub ErrorOutMessage {
	print color( "bold red" );
	print "FAILED!" , "\n";
	print "$_[1]" , "\n";
	print color( "reset" );

	if ( $_[0] ) {
		die;
	}
}

sub GetUsername {
	my $username = `cat /etc/passwd | grep 1000 | awk -F ':' '{print \$1}' `;
	chomp( $username );

	return $username;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

ConsolePrintTemplates - Perl extension for blah blah blah

=head1 SYNOPSIS

  use ConsolePrintTemplates;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for ConsolePrintTemplates, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

root, E<lt>root@nonetE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by root

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
