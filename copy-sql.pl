#!/usr/bin/env perl

#
#  Sample Query:
#    select 32 as "integer", "sample string" as "string", NULL as "NULL", 3.141592 as "float", cast("2013-05-25 14:15:05" as DATETIME) as "datetime", TRUE as "boolean";
#  
#  Sample Output
#
#    +---------+---------------+------+----------+---------------------+---------+
#    | integer | string        | NULL | float    | datetime            | boolean |
#    +---------+---------------+------+----------+---------------------+---------+
#    |      32 | sample string | NULL | 3.141592 | 2013-05-25 14:15:05 |       1 |
#    +---------+---------------+------+----------+---------------------+---------+
#

$ENV{LANG}="en_US.UTF-8";

binmode(STDIN, ":utf8");
use open ':encoding(utf8)'; 

# # read first line to get the column names (header)
# my $firstLine = <>;

# # bail if nothing could read
# if (!defined($firstLine)) {
#   exit 0;
# }

# # store the column names
# chomp($firstLine);
# $firstLine =~ s/\"/\\\"/g;  # escape "
# my $num_columns = @header = split(/\t/, $firstLine);

# get the column definitions
# open(META, $ENV{"SP_BUNDLE_INPUT_TABLE_METADATA"}) or die $!;
# my @meta = ();
# while (<META>) {
#   chomp();
#   my @arr = split(/\t/);
#   push @meta, \@arr;
# }
# close(META);



open(PB, "|pbcopy") or die $!;


# for each row
while (<>) {
  # remove line ending
  # chomp;

  # print row data
  print PB Encode::encode_utf8($_);
}

close PB;
