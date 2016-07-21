#!/usr/bin/env perl

#
#  Sample Output
#  
#  *************************** 1. row ***************************
#           id: 1
#      tinyint: 5
#     smallint: 99
#    mediumint: 2170
#      integer: 65000
#       bigint: 7100765075
#        float: 3.14159
#       double: 1.61803398874
#      decimal: 1.54
#         date: 1963-07-07
#     datetime: 2013-07-07 19:45:55
#    timestamp: 2006-05-04 03:02:01
#         time: 13:22:31
#         year: 1969
#      char_10: twitter
#  varchar_255: Bacon ipsum dolor sit amet ribeye venison pastrami, shoulder meatball short ribs pancetta jerky short loin filet mignon. 
#         text: 	We the People of the United States, in Order to form a more perfect Union,
#  establish Justice, insure domestic Tranquility, provide for the common defence,
#  promote the general Welfare, and secure the Blessings of Liberty to ourselves and our Posterity,
#  do ordain and establish this Constitution for the United States of America.
#

$ENV{LANG}="en_US.UTF-8";

binmode(STDIN, ":utf8");
use open ':encoding(utf8)'; 

# read first line to get the column names (header)
my $firstLine = <>;

# bail if nothing could be read
if (!defined($firstLine)) {
  exit 0;
}

chomp($firstLine);

my $num_columns = @header = split(/\t/, $firstLine);

my $max_width = 0;
for (my $i=0; $i < $num_columns; $i++) {
    if ($max_width < length($header[$i])) {
        $max_width = length($header[$i]);
    }
}

open(PB, "|pbcopy") or die $!;

# read row data of each selected row
my $row_count = 0;
while (<>) {
  $row_count++;

  printf(PB "*************************** %d. row ***************************\n", $row_count);

  # remove line ending
  chomp;

  # split column data which are tab-delimited
  @data = split(/\t/);

  for (my $i=0; $i < $num_columns; $i++) {

    printf(PB "%*s: ", $max_width, $header[$i]);

    my $cellData = Encode::encode_utf8($data[$i]);

    $cellData =~ s/\xe2\x87\xa5/\t/g; # tab characters are replaced by ⇥ U+21E5 UTF-8: E287A5
    $cellData =~ s/\s*\xe2\x86\xb5/\n/g;  # newline characters by ↵ U+21B5 UTF-8: E286B5
    # $cellData =~ s/⇥/\t/g;
    # $cellData =~ s/\s*↵/\n/g;

    print PB $cellData, "\n";
  }

}

close PB;

exit 0;