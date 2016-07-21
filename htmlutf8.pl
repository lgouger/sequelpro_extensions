#!/usr/bin/env perl

# Works with styling, here's an example style:
#
# 	<style>
# 	#sequelpro
# 	{
# 		font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;
# 		width:100%;
# 		border-collapse:collapse;
# 	}
# 	#sequelpro td, #sequelpro th 
# 	{
# 		font-size:1em;
# 		border:1px solid #98bf21;
# 		padding:3px 7px 2px 7px;
# 	}
# 	#sequelpro th 
# 	{
# 		font-size:1.1em;
# 		text-align:left;
# 		padding-top:5px;
# 		padding-bottom:4px;
# 		background-color:#A7C942;
# 		color:#ffffff;
# 	}
# 	#sequelpro tr.alt td 
# 	{
# 		color:#000000;
# 		background-color:#EAF2D3;
# 	}
# 	</style>
#  
#  Sample Output:
#  
#  <table id="sequelpro">
#    <thead>
#      <tr>
#        <th>integer</th>
#        <th>string</th>
#        <th>NULL</th>
#        <th>float</th>
#        <th>date</th>
#        <th>boolean</th>
#      </tr>
#    </thead>
#    <tbody>
#      <tr>
#        <td style="text-align: right;">42</td>
#        <td style="text-align: left;">sample</td>
#        <td style="text-align: left; color: #cccccc;">NULL</td>
#        <td style="text-align: right;">3.141592</td>
#        <td style="text-align: left;">2013-05-25 14:15:05</td>
#        <td style="text-align: right;">1</td>
#      </tr>
#    <tbody>
#  </table>


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
while(<META>) {
	chomp();
	my @arr = split(/\t/);
	push @meta, \@arr;
}
close(META);

open(PB, "|pbcopy") or die $!;

print PB "<table id=\"sequelpro\">\n";
print PB "  <thead>\n";
print PB "    <tr>\n";
for my $col ( @header ) {
	print PB "      <th>$col</th>\n";
}
print PB "    </tr>\n";
print PB "  </thead>\n";
print PB "  <tbody>\n";

# read row data of each selected row
my $rowCount = 0;
while (<>) {
	# remove line ending
	chomp();

	# escape "
	$_ =~ s/\"/\\\"/g;

	# split column data which are tab-delimited
	@row = split(/\t/);

	printf(PB "    <tr%s>\n", ($rowCount % 2 == 1 ? " class=\"alt\"" : "") );

	for (my $i=0; $i < $num_columns; $i++) {
		my $cellData = $row[$i];

		$cellData =~ s/↵/<br>/g;
		$cellData =~ s/⇥/&emsp;/g;

		my $cellStr = "";

		# check for data types
		if ($cellData eq "NULL") {
			$cellStr =  "<td style=\"text-align: left; color: #cccccc;\">NULL</td>";
		} elsif ($meta[$i]->[1] eq "integer") {
			$cellStr = sprintf("<td style=\"text-align: right;\">%d</td>", $cellData);
		} elsif ($meta[$i]->[1] eq "float") {
			$cellStr = sprintf("<td style=\"text-align: right;\">%.6f</td>", $cellData);
		} else {
			$cellStr = sprintf("<td style=\"text-align: left;\">%s</td>", $cellData);
		}
		print PB "      $cellStr\n";

		$rowCount++;
	}

	print PB "    </tr>\n";
}
print PB "  <tbody>\n";
print PB "</table>\n"; 

close PB;
