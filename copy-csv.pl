#!/usr/bin/env perl

#  Sample SQL query:
#    select 42 as "integer",
#           '{\n   "menu":{\n      "id":"file",\n      "value":"File",\n      "popup":{\n         "menuitem":[\n            {\n               "value":"New",\n               "onclick":"CreateNewDoc()"\n            },\n            {\n               "value":"Open",\n               "onclick":"OpenDoc()"\n            },\n            {\n               "value":"Close",\n               "onclick":"CloseDoc()"\n            }\n         ]\n      }\n   }\n}' as "string",
#           NULL as "NULL",
#           3.141592 as "float",
#           cast("2013-05-25 14:15:05" as DATETIME) as "datetime",
#           TRUE as "boolean";
#
#  Sample Output:
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
while (<META>) {
    chomp();
    my @arr = split(/\t/);
    push @meta, \@arr;
}
close(META);


open(PB, "|pbcopy") or die $!;


# read row data of each selected row
$rowData=<>;
while ($rowData) {

    # remove line ending
    chomp($rowData);

    # split column data which are tab-delimited
    @data = split(/\t/, $rowData);

    for (my $i=0; $i < $num_columns; $i++) {

        $cellData = Encode::encode_utf8($data[$i]);

        $cellData =~ s/↵/\n/g;
        $cellData =~ s/⇥/\t/g;

        print PB "      \"$header[$i]\": ";

        # to see the type information...
        print PB "(", join(",", @{$meta[$i]}), ") ";

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
        } elsif ($meta[$i]->[1] eq "string") {
            # not quoting string, because we're taking the database content raw for CHAR/VARCHAR columns
            print PB $cellData;
        } else {
            $cellData =~ s/"/\"/g;
            print PB "\"$cellData\"";
        }

        # suppress last ,
        if ($i < $#data) {
            print PB ", ";
        }
    }

    # get next row
    $rowData = <>;

    # suppress last ,
    if ($rowData) {
        print PB ", ";
    }

    print PB "\n";
}

close PB;

0;
