#!/usr/bin/env perl

#  Sample Output
#  {
#    "data": [
#      {
#        "integer": 42,
#        "string": "sample",
#        "NULL": null,
#        "float": 3.141592,
#        "date": "2013-05-25 14:15:05",
#        "boolean": true
#      }
#    ]
#  }

$ENV{LANG}="en_US.UTF-8";

binmode(STDIN, ":utf8");
use open ':encoding(utf8)'; 

# read first line to get the column names (header)
$firstLine = <>;

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
@meta = ();
while (<META>) {
	chomp();
	my @arr = split(/\t/);
	push @meta, \@arr;
}
close(META);


open(PB, "|pbcopy") or die $!;

print PB "{\n  \"data\": [\n";

# read row data of each selected row
$rowData=<>;
while ($rowData) {

	print PB "    {\n";

	# remove line ending
	chomp($rowData);

	# split column data which are tab-delimited
	@data = split(/\t/, $rowData);

	for (my $i=0; $i < $num_columns; $i++) {

		# escape \t and \n and "
		$cellData = $data[$i];
		$cellData =~ s/\\/\\\\/g;
		$cellData =~ s/\"/\\\"/g;
		$cellData =~ s/↵/\n/g;
		$cellData =~ s/⇥/\t/g;

		print PB "      \"$header[$i]\": ";

		# to see the type information...
		# print PB "(", join(",", @{$meta[$i]}), ") ";

		# check for data types
		if ($cellData eq "NULL") {
			print PB "null";
		} elsif ($meta[$i]->[1] eq "bit") {
			printf(PB "%s", ($cellData eq "1" ? "true" : "false"));
		} elsif ($meta[$i]->[1] eq "integer") {
			if ($meta[$i]->[0] eq "TINYINT") {
				printf(PB "%s", ($cellData eq "1" ? "true" : "false"));
			} else {
				printf(PB "%d", $cellData);
			}
		} elsif ($meta[$i]->[1] eq "float") {
			printf(PB "%f", $cellData);
		} else {
			print PB "\"$cellData\"";
		}

		# suppress last ,
		if ($i < $#data) {
			print PB ",";
		}

		print PB "\n";
	}

	print PB "    }";

	# get next row
	$rowData = <>;

	# suppress last ,
	if ($rowData) {
		print PB ",";
	}

	print PB "\n";
}

print PB "  ]\n}";

close PB;