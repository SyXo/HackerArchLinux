use strict;
use warnings 'FATAL' => 'all';
use Exporter qw( import );


package HackerArch::FuncHeaders;
use Term::ANSIColor;

our $VERSION = v0.1;
our @ISA = qw( Exporter );
our @EXPORT = ();
our @EXPORT_OK = qw( CheckReturn CategoryHeading CategoryFooter OperTitle OperHeading UserInput SuccessMessage ErrorOutMessage GetUsername );
our %EXPORT_TAGS = ( 'ALL' => [ qw( &CheckReturn &CategoryHeading &CategoryFooter &OperTitle &OperHeading &UserInput &SuccessMessage &ErrorOutMessage &GetUsername ) ] );

#	1>filename
#	# Redirect stdout to file "filename."
#	1>>filename
#	# Redirect and append stdout to file "filename."
#	2>filename
#	# Redirect stderr to file "filename."
#	2>>filename
#	# Redirect and append stderr to file "filename."
#	&>filename
#	# Redirect both stdout and stderr to file "filename."
#	# This operator is now functional, as of Bash 4, final release.

sub CheckReturn {
	unless ( "$?" == 0 ) {
		print color( "bold red" );
		print "FAILED!!" , "\n";
		if ( $_[0] ) {
			print $_[1] , "\n\n";
			die;
		}
		else {
			print $_[1] , "\n\n";
		}
		print color( "reset" );
	}

	SuccessMessage();
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
	print color( "bold yellow" );
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
	print "SUCCESS!!" , "\n\n";
	print color( "reset" );
}

sub ErrorOutMessage {
	print color( "bold red" );
	print "FAILED!!" , "\n";
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
