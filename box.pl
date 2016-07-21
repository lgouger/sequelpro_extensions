#!/usr/bin/env perl

#  Sample Output
#  
#  +---------+--------+------+----------+---------------------+---------+
#  | integer | string | NULL | float    | date                | boolean |
#  +---------+--------+------+----------+---------------------+---------+
#  |      42 | sample | NULL | 3.141592 | 2013-05-25 14:15:05 |       1 |
#  +---------+--------+------+----------+---------------------+---------+

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
my $num_columns = @header = split(/\t/, $firstLine);

# get the column definitions
open(META, $ENV{"SP_BUNDLE_INPUT_TABLE_METADATA"}) or die $!;
my @meta = ();
while (<META>) {
	chomp();
	my @arr = split(/\t/);
	push @meta, \@arr;
}
close(META);

my @max_width = ();
for (my $i=0; $i < $num_columns; $i++) {
	$max_width[$i] = length($header[$i]);
}

# read row data of each selected row
my @rows = ();
while (<>) {

	# remove line ending
	chomp;

	# escape "
	$_ =~ s/\"/\\\"/g;

	# split column data which are tab-delimited
	@data = split(/\t/);

	# save the row
	push @rows, [ @data ];

	for (my $i=0; $i < $num_columns; $i++) {

		# re-escape \t and \n
		$cellData = $data[$i];
		$cellData =~ s/↵/\n/g;
		$cellData =~ s/⇥/\t/g;

		my $cellStr = "";

		# check for data types
		if ($cellData eq "NULL") {
			$cellStr =  sprintf("NULL");
		} elsif ($meta[$i]->[1] eq "integer") {
			$cellStr = sprintf("%d", $cellData);
		} elsif ($meta[$i]->[1] eq "float") {
			$cellStr = sprintf("%.6f", $cellData);
		} else {
			$cellStr = sprintf("%s", $cellData);
		}

		my $col_width = length($cellStr);
		if ($col_width > $max_width[$i]) {
			$max_width[$i] = $col_width;
		}
	}
}


open(PB, "|pbcopy") or die $!;

# print top of box
print PB "+";
for (my $i=0; $i < $num_columns; $i++) {
	print PB "-" x ($max_width[$i]+2);
	print PB "+";
}
print PB "\n";

# print header
print PB "|";
for (my $i=0; $i < $num_columns; $i++) {
	printf(PB " %-$max_width[$i]s |", $header[$i]);
}
print PB "\n";

# print separator
print PB "+";
for (my $i=0; $i < $num_columns; $i++) {
	print PB "-" x ($max_width[$i]+2);
	print PB "+";
}
print PB "\n";

# for each row
for my $row ( @rows ) {

	# print row data
	print PB "|";
	for (my $i=0; $i < $num_columns; $i++) {
		my $cellData = $row->[$i];

		$cellData =~ s/↵/\n/g;
		$cellData =~ s/⇥/\t/g;

		my $cellStr = "";

		# check for data types
		if ($cellData eq "NULL") {
			$cellStr =  sprintf("%-$max_width[$i]s", "NULL");
		} elsif ($meta[$i]->[1] eq "integer") {
			$cellStr = sprintf("%$max_width[$i]d", $cellData);
		} elsif ($meta[$i]->[1] eq "float") {
			my $fmt = sprintf("%%%d.6f", $max_width[$i]);
			$cellStr = sprintf($fmt, $cellData);
		} else {
			$cellStr = sprintf("%-$max_width[$i]s", $cellData);
		}

		print PB " $cellStr |";
	}
	print PB "\n";
}

# print bottom of box
print PB "+";
for (my $i=0; $i < $num_columns; $i++) {
	print PB "-" x ($max_width[$i]+2);
	print PB "+";
}
print PB "\n";

close PB;