#!/usr/bin/env perl

# Works with styling, here's an example style:
#
#  Works with styling, here's an example style:
#    <style>
#    #sequelpro
#    {
#      font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;
#      /* width:100%; */
#      border-collapse:collapse;
#    }
#    #sequelpro td, #sequelpro th 
#    {
#      font-size:1em;
#      border:1px solid #98bf21;
#      padding:3px 7px 2px 7px;
#    }
#    #sequelpro th 
#    {
#      font-size:1.1em;
#      text-align:left;
#      padding-top:5px;
#      padding-bottom:4px;
#      background-color:#A7C942;
#      color:#ffffff;
#    }
#    #sequelpro tr.alt td 
#    {
#      /* color:#000000; */
#      background-color:#EAF2D3;
#    }
#    #sequelpro td.null
#    {
#      text-align: left;
#      color: #cccccc;
#    }
#    </style>
#
#  Sample SQL query:
#    select 42 as "integer", '&quot;<span style="color:red">red</span>&quot;, &apos;<span style="color:white;background-color:black;">white</span>&apos; &amp; <span style="color:blue">blue</span>' as "string", NULL as "NULL", 3.141592 as "float", "2013-05-25 14:15:05" as "datetime", TRUE as "boolean"
#    union all select 42 as "integer", '&quot;<span style="color:red">red</span>&quot;, &apos;<span style="color:white;background-color:black;">white</span>&apos; &amp; <span style="color:blue">blue</span>' as "string", NULL as "NULL", 3.141592 as "float", "2013-05-25 14:15:05" as "datetime", TRUE as "boolean";
#  
#  Sample Output:
#    <table id="sequelpro" border="1" cellpadding="0" cellspacing="0">
#      <thead>
#        <tr>
#          <th>integer</th>
#          <th>string</th>
#          <th>NULL</th>
#          <th>float</th>
#          <th>datetime</th>
#          <th>boolean</th>
#        </tr>
#      </thead>
#      <tbody>
#        <tr>
#          <td style="text-align: right;">42</td>
#          <td style="text-align: left;">&amp;quot;&lt;span&nbsp;style=&quot;color:red&quot;&gt;red&lt;/span&gt;&amp;quot;,&nbsp;&amp;apos;&lt;span&nbsp;style=&quot;color:white;background-color:black;&quot;&gt;white&lt;/span&gt;&amp;apos;&nbsp;&amp;amp;&nbsp;&lt;span&nbsp;style=&quot;color:blue&quot;&gt;blue&lt;/span&gt;</td>
#          <td class="null">NULL</td>
#          <td style="text-align: right;">3.141592</td>
#          <td style="text-align: left;">2013-05-25&nbsp;14:15:05</td>
#          <td style="text-align: right;">1</td>
#        </tr>
#        <tr class="alt">
#          <td style="text-align: right;">42</td>
#          <td style="text-align: left;">&amp;quot;&lt;span&nbsp;style=&quot;color:red&quot;&gt;red&lt;/span&gt;&amp;quot;,&nbsp;&amp;apos;&lt;span&nbsp;style=&quot;color:white;background-color:black;&quot;&gt;white&lt;/span&gt;&amp;apos;&nbsp;&amp;amp;&nbsp;&lt;span&nbsp;style=&quot;color:blue&quot;&gt;blue&lt;/span&gt;</td>
#          <td class="null">NULL</td>
#          <td style="text-align: right;">3.141592</td>
#          <td style="text-align: left;">2013-05-25&nbsp;14:15:05</td>
#          <td style="text-align: right;">1</td>
#        </tr>
#      <tbody>
#    </table>
#   
#  


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

print PB "<table id=\"sequelpro\" border=\"1\" cellpadding=\"0\" cellspacing=\"0\">\n";
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
	# $_ =~ s/\"/\\\"/g;

	# split column data which are tab-delimited
	@columns = split(/\t/);

	printf(PB "    <tr%s>\n", ($rowCount % 2 == 1 ? " class=\"alt\"" : "") );

	for (my $i=0; $i < $num_columns; $i++) {
		my $cellData = Encode::encode_utf8($columns[$i]);

		$cellData =~ s/&/&amp;/g;
		$cellData =~ s/'/&apos;/g;
		$cellData =~ s/"/&quot;/g;
		$cellData =~ s/</&lt;/g;
		$cellData =~ s/>/&gt;/g;

		$cellData =~ s/↵/<br>/g;
		$cellData =~ s/⇥/&emsp;/g;
		$cellData =~ s/\x20/&nbsp;/g;

		my $cellStr = "";

		# check for data types
		if ($cellData eq "NULL") {
			$cellStr =  "<td class=\"null\">NULL</td>";
		} elsif (($meta[$i]->[1] eq "integer") ||
		         ($meta[$i]->[1] eq "float")) {
			$cellStr = sprintf("<td style=\"text-align: right;\">%s</td>", $cellData);
		} else {
			$cellStr = sprintf("<td style=\"text-align: left;\">%s</td>", $cellData);
		}
		print PB "      $cellStr\n";
	}

	print PB "    </tr>\n";

	$rowCount++;
}
print PB "  <tbody>\n";
print PB "</table>\n"; 

close PB;
