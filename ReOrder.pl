#!/usr/bin/env perl
my $USAGE = "Usage: $0 [--inifile inifile.ini] [--section ReOrder] [--recmark lx] [--eolrep #] [--reptag __hash__] [--debug] [file.sfm]\n";
=pod
This script is taken from the stub that provides the code for opl'ing and de_opl'ing an input file
It includes code to:
	- use an ini file (commented out)
	- process command line options including debugging

The ini file should have sections with syntax like this:
[ReOrder]
recmark=ge
NewOrder=lx,pr,va,va_pr,ge,df,co,co1

=cut
use 5.020;
use utf8;
use open qw/:std :utf8/;

use strict;
use warnings;
use English;
use Data::Dumper qw(Dumper);


use File::Basename;
my $scriptname = fileparse($0, qr/\.[^.]*/); # script name without the .pl
$USAGE =~ s/inifile\./$scriptname\./;

use Getopt::Long;
GetOptions (
	'inifile:s'   => \(my $inifilename = "$scriptname.ini"), # ini filename
	'section:s'   => \(my $inisection = "ReOrder"), # section of ini file to use
# additional options go here.
# 'sampleoption:s' => \(my $sampleoption = "optiondefault"),
	'recmark:s' => \(my $recmark = "lx"), # record marker, default lx
	# recmark=xx line in the inifile will over-ride the command line option
	'eolrep:s' => \(my $eolrep = "#"), # character used to replace EOL
	'reptag:s' => \(my $reptag = "__hash__"), # tag to use in place of the EOL replacement character
	# e.g., an alternative is --eolrep % --reptag __percent__

	# Be aware # is the bash comment character, so quote it if you want to specify it.
	#	Better yet, just don't specify it -- it's the default.
	'debug'       => \my $debug,
	) or die $USAGE;

# check your options and assign their information to variables here
$recmark =~ s/[\\ ]//g; # no backslashes or spaces in record marker

# if you do not need a config file uncomment the following and modify it for the initialization you need.
# if you have set the $inifilename & $inisection in the options, you only need to set the parameter variables according to the parameter names
# =pod
use Config::Tiny;
my $config = Config::Tiny->read($inifilename, 'crlf');
die "Quitting: couldn't find the INI file $inifilename\n$USAGE\n" if !$config;
$recmark = $config->{"$inisection"}->{recmark};
say STDERR "recmark:$recmark" if $debug;
my $neworder = $config->{"$inisection"}->{neworder}; # list of the order of the output SFMs
say STDERR "neworder:$neworder" if $debug;
# =cut

# generate array of the input file with one SFM record per line (opl)
my @opledfile_in;
my $line = ""; # accumulated SFM record
while (<>) {
	s/\R//g; # chomp that doesn't care about Linux & Windows
	#perhaps s/\R*$//; if we want to leave in \r characters in the middle of a line
	s/$eolrep/$reptag/g;
	$_ .= "$eolrep";
	if (/^\\$recmark /) {
		$line =~ s/$eolrep$/\n/;
		push @opledfile_in, $line;
		$line = $_;
		}
	else { $line .= $_ }
	}
push @opledfile_in, $line;

my @orderarray = split /,/ , $neworder;
say STDERR "order array:", Dumper(@orderarray) if $debug;
for my $oplline (@opledfile_in) {
	my $newoplline = "";
	for my $mark (reverse @orderarray) { # fields are moved to the front in reverse order
		say STDERR "for mark= >$mark<" if $debug;
		say STDERR "before oplline= >$oplline<" if $debug;
		say STDERR "before newoplline= >$newoplline<" if $debug;
		say STDERR "look for \\$mark .*?$eolrep" if $debug;
		while ($oplline =~ m/\\$mark .*?$eolrep/) {
			say STDERR "Found:$MATCH" if $debug;
			$newoplline = $MATCH . $newoplline;
			$oplline = $PREMATCH . $POSTMATCH;
			}
		say STDERR "after oplline= >$oplline<" if $debug;
		say STDERR "after newoplline= >$newoplline<" if $debug;
		}
	$oplline = $newoplline . $oplline ; # unmatched fields go to the end
say STDERR "oplline:", Dumper($oplline) if $debug;
#de_opl this line
	for ($oplline) {
		s/$eolrep/\n/g;
		s/$reptag/$eolrep/g;
		print;
		}
	}
