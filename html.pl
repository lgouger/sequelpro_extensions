#!/usr/bin/env perl

use Encode;
use Encode::Alias;

# read first line to get the column names (header)
$firstLine = <>;

# bail if nothing could read
if (!defined($firstLine)) {
	exit 0;
}

# store the column names
chomp($firstLine);
$firstLine =~ s/\"/\\\"/g;  # escape "
@header = split(/\t/, $firstLine);

# # get the column definitions
# open(META, $ENV{"SP_BUNDLE_INPUT_TABLE_METADATA"}) or die $!;
# @meta = ();
# while(<META>) {
# 	chomp();
# 	my @arr = split(/\t/);
# 	push @meta, \@arr;
# }
# close(META);

open(PB, "|pbcopy") or die $!;

print PB "<table border=\"1\" cellpadding=\"0\" cellspacing=\"0\">\n";
print PB "<tr>";
for my $col ( @header ) {
	Encode::from_to($col, "utf8", "ascii", Encode::HTMLCREF);
	print PB "<th>$col</th>";
}
print PB "</tr>\n";

# read row data of each selected row
while (<>) {

	print PB "<tr>";

	# remove line ending
	chomp();

	# escape "
	$_ =~ s/\"/\\\"/g;

	# split column data which are tab-delimited
	@row = split(/\t/);
	for my $col ( @row ) {
		# re-escape \t and \n
		$col =~ s/↵/\n/g;
		$col =~ s/⇥/\t/g;

		chomp($col);
		Encode::from_to($col, "utf8", "ascii", Encode::HTMLCREF);
		print PB "<td>$col</td>";
	}

	print PB "</tr>\n";
}

print PB "</table>\n"; 

close PB;