# mp-expenses
Australian Federal Parliament MP expenses processing utilities and sample data.

Contents:
 * run.pl : perl script to run downloads of all pdfs and run pdftotext to extract text
 * mp-expenses_P37_pdftotext.tar.gz : extracted text files for P37 (2nd half 2015)
 * mp-expenses_P38_pdftotext.tar.gz : extracted text files for P38 (1st half 2016)

Note the text files were created using the -layout option of pdftotext.

The text files are NOT parsed or reduced to clean transaction data.

To get pdfs and/or other periods of data, use the run.pl perl script as follows.

-------------------------------------------------------------------------------------
Script Usage: ./run.pl period-directory-name [limit]

   Perl script which downloads pdfs and pdftotext text extraction
   for Australian Federal Parliament MP expenses bi-annual reports.

   To download all pdfs and convert to raw text for the P38 period,
   you would run something like:

   Example: 
       ./run.sh P38_2016a 5

   Will download and run pdftotext for the first 5 files for period P38. Omit the 5 for the whole shebang.

   You must start the directory name with the correct period "P" number and create it yourself first.
   This period number, "P38" in the example above, specifies the 6 monthly period you require.
   All PDFs (up to the limit number optionally specified) will be downloaded from:
       http://www.finance.gov.au/publications/parliamentarians-reporting/parliamentarians-expenditure-Pnn/
   and pdftotext will be run.

Dependancies:
* You will need to install poppler-utils which provides pdftotext
* wget is required

Latest version: https://github.com/twensor/mp-expenses
--------------------------------------------------------------------------------------

Enjoy. Hope this helps someone be an active citizen.

Twitter: @twensor
