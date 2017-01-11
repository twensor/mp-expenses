#!/usr/bin/perl -s

my $period = $ARGV[0];
my $period_num = $period;
$period_num =~ s/(P\d+)\_.+/\1/;

if ( -d $period ) {
   print "== $0 period[$period] period_num[$period_num]\n";
}
else {
    print <<USAGE;
$0 period-directory-name [limit]

   Perl script which downloads pdfs and pdftotext text extraction
   for Australian Federal Parliament MP expenses bi-annual reports.

   To download all pdfs and convert to raw text for the P38 period,
   you would run something like:

   Example: ./run.sh P38_2016a 5

          Will download and run pdftotext for the first 5 files for period P38.
          Omit the 5 for the whole shebang.

   You must start the directory name with the correct period "P" number and create it yourself first.
   This period number, "P38" in the example above, specifies the 6 monthly period you require.
   All PDFs (up to the limit number optionally specified) will be downloaded from:
       http://www.finance.gov.au/publications/parliamentarians-reporting/parliamentarians-expenditure-Pnn/
   and pdftotext will be run. 
   
   Dependancies:
    * You will need to install poppler-utils which provides pdftotext
    * wget is required

   Latest version: https://github.com/twensor/mp-expenses

USAGE
   exit 0;
}
if ( $period_num eq "" ) {
    print "##error## failed to detect period_num.\n";
    exit 1
}

my $period_number = $period_num; $period_number =~ s/^P//;
my $INDEX_URL = "http://www.finance.gov.au/publications/parliamentarians-reporting/parliamentarians-expenditure-$period_num/";
# from 2013 and earlier the name is .html with underscores not hyphens
if ( $period_number <= 2013 ) {
     $INDEX_URL = "http://www.finance.gov.au/publications/parliamentarians-reporting/parliamentarians_expenditure_${period_num}.html";
}
my $INDEX_FILE = "$period/index.html";
my $URLS_FILE = "$period/index-urls.txt";
my $PDIR = "$period/pdfs";
my $TDIR = "$period/text";

# create dirs for pdfs, text, if needed
if ( !-d $PDIR ) { system("mkdir $PDIR"); print "Created $PDIR\n"; }
if ( !-d $TDIR ) { system("mkdir $TDIR"); print "Created $TDIR\n"; }

# get html index files if needed
if ( -s $INDEX_FILE ) {
    print "Have INDEX_FILE[$INDEX_FILE]\n";
}
else {
    # get the html page containing the urls
    print "-- getting $INDEX_FILE from $INDEX_URL\n";
    my $cmd = "wget -O $INDEX_FILE $INDEX_URL";
    print "$cmd\n";
    system($cmd);
    if ( ! -s $INDEX_FILE ) {
        print "##error## failed to find INDEX_FILE[$INDEX_FILE] ?? Cannot proceed.\n";
        exit 2;
    }
}

# get urls file if needed
if ( -s $URLS_FILE ) {
    print "Have URLS_FILE[$URLS_FILE]\n";
}
else {
    print "-- making $URLS_FILE from $INDEX_FILE\n";
    my $cmd = "grep ${period_num}_ $INDEX_FILE | perl -pe 's/^.+href=\"([^\"]+).+/\\1/;' ";
    print "   $cmd > $URLS_FILE\n";
    system("$cmd > $URLS_FILE");
}

print "-- directory $period contains:\n";
system("ls -la $period");

my $n = 0;
my $limit = $ARGV[1];

open (F,$URLS_FILE) || die "$0 failed to open URLS_FILE[$URLS_FILE] [$!]\n";
while (<F>) {
    chop;
    my $url = $_;
    # if url starts with /sites/, prepend http://www.finance.gov.au
    if ( $url =~ m~^/sites~ ) {
        $url = "http://www.finance.gov.au" . $url;
    }
    my $name = $url;
    $name =~ s/'//g;
    $name =~ s/.+${period_num}_(.+)\.pdf/\1/;
    my $pdf = "$PDIR/$name.pdf";
    if ( -s $pdf ) {
        # print "++ have pdf[$pdf]\n";
        1;
    }
    else {
        print "-- getting name[$name] [$url]\n";
        my $cmd = "wget -O $pdf \"$url\"";
        print ".. $cmd\n";
        system($cmd);
        sleep 1;
        $n++;
    }

    # process text
    my $txt_1 = "$PDIR/$name.txt";
    my $txt_2 = "$TDIR/$name.txt";
    if ( -s $txt_2 ) {
        print "++ have txt_2[$txt_2]\n";
    }
    else {
        print "-- converting name[$name]\n";
        my $cmd = "pdftotext -layout $pdf; mv $txt_1 $txt_2";
        system($cmd);
        my $rc = $?;
        print "   rc[$rc] $cmd\n";
        if ( "$rc" ne "0" ) {
            print "##woops##\n";
            exit $rc;
        }
    }

    if ($limit && $n >= $limit) { 
        print "\nLimit[$limit] reached, exiting, normal eoj\n";
        exit 0; 
    }
}
close(F);

print "== Normal eoj.\n";
exit 0;
