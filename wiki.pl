#!/usr/bin/env perl

#  Sample Output
#
#  {table-plus:columnTypes=I,S,S,F,S,I}
#  || integer || string || NULL || float || date || boolean ||
#  | 42 | sample | NULL | 3.141592 | 2013-05-25 14:15:05 | 1 |
#  {table-plus}


$ENV{LANG}="en_US.UTF-8";

binmode(STDIN, ":utf8");
use open ':encoding(utf8)'; 

# read first line to get the column names (header)
my $firstLine = <>;

# bail if nothing could read
if (!defined($firstLine)) {
	exit 0;
}

# store the column names
chomp($firstLine);
$firstLine =~ s/\"/\\\"/g;  # escape "
@header = split(/\t/, $firstLine);
my $num_columns = @header = split(/\t/, $firstLine);

# get the column definitions
open(META, $ENV{"SP_BUNDLE_INPUT_TABLE_METADATA"}) or die $!;
@meta = ();
while(<META>) {
	chomp();
	my @arr = split(/\t/);
	push @meta, \@arr;
}
close(META);

open(PB, "|pbcopy") or die $!;

print PB "{table-plus:columnTypes=";
for (my $i=0; $i < $num_columns; $i++) {
	my $cellData = $header[$i];

	if ($cellData eq "NULL") {
		$align =  "S";
	} elsif ($meta[$i]->[1] eq "integer") {
		$align = "I";
	} elsif ($meta[$i]->[1] eq "float") {
		$align = "F";
	} elsif ($meta[$i]->[1] eq "date") {
		$align = "D";
	} else {
		$align = "S";
	}
	print PB ($i > 0 ? "," : ""), $align;
}
print PB "}\n";

print PB "||";
for my $col ( @header ) {
	print PB " $col ||";
}
print PB "\n";


# read row data of each selected row
while (<>) {

	print PB "|";

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
		print PB " $col |";
	}

	print PB "\n";
}
print PB "{table-plus}\n";

close PB;
