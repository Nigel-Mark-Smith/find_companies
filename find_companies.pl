# find_companies
#
# This script will search through a csv file containing company data
# using regular expressions defined in a configuration file. The data
# which matches (see below ) these criteria will be output to the console 
# and can be redirected to a file. The input csv file is provided by Companies 
# House and it's contents are detailed at:
# 
# http://download.companieshouse.gov.uk/en_output.html 
#
# To use the 'find_companies' script the following commmand line syntax is required:
#
# find_companies <companies data file name> <configuration file name>
# 
# A typical invokation of this script where the output is captured to file would
# be as follows:
# 
# perl find_companies.pl testing\input.txt testing\criteria.txt > results.csv
#
# Where all file names are specified relative to c:\find_companies.
#
# The format of the configuration file is as follows where each line
# contains one or more regular expressions which the data in the 
# specified field ( column ) could match. The contents of a specified 
# field must match a least one of the criteria specified for that
# field to be output and all fields for which criteria are specified must 
# match at least one of the match criteria specified for that field for
# any data for a specific company to be output ( see OutputRow ).
#
#  Column Name , Regex 1, Regex 2,....Regex 3
# 
# e.g.
# 
# CompanyName,^ITECCO,STRAT
# RegAddress.PostTown,.*
# RegAddress.County,.*
# RegAddress.Country,.*
# CompanyStatus,Active
# SICCode.SicText_1,.*
# SICCode.SicText_2,.*
# SICCode.SicText_3,.*
# SICCode.SicText_4,.*
#
# This example configuration file will output the following data:
#
# The company name when this starts with 'ITECCO' or contains string  'STRAT'
# The town in which the company is registered ( this is always displayed as '.*' matches all strings.
# The county in which the company is registered
# The country in which the company is registered
# The conmpany status if this is 'Active'
# The first SIC code used to classify the company
# The second SIC code used to classify the company
# The third SIC code used to classify the company
# The fourth SIC code used to classify the company
#
# This scripts does limited checks on:
#
# - The command line arguments given
# - The configuration file specified 
# - The number of data fields in the input file specified
#
# It will exit displaying an error message if an
# issue with either of these is found. 


###############
### DECLARE ###
###############

use strict;
my $home_directory = 'c:\\find_companies\\';
my $input_file;
my $input_filename;
my $criteria_file;
my $criteria_filename;
my @criteria_specifications;
my $field_name;
my @field_names;
my %field_numbers;
my $fields_file;
my $fields_filename = $home_directory.'field_names.txt';

# Documentation indicates the each line in the csv data file
# contains 55 values ( data columns )

my $max_column = 55;

##################
### PROCEDURES ###
##################

sub DisplayError {

# Displays an error message and exits.

    die "$_[0]\n";
}

sub ProcessInput {

# Replaces field delimiter "," with "#~" to allow
# split to be used. (NOTE) So far I have not found any data rows
# with "#~" included.

my $input_line;

$input_line = $_[0];
$input_line =~ s/","/#~/g;
$input_line =~ s/"//g;

return $input_line;

}

sub BuildHash {

# Builds a hash where the key is the data file field name
# and the value is the data file field number ( index ).
# This routine also writes out a list of the data fields 
# available in the data file.

my $field_name;
my $field_number = 0;

foreach $field_name (@field_names) {

    # Trim leading spaces.
	$field_name =~ s/^\s+//;
	$field_numbers{$field_name} = $field_number;
	$field_number++;
}

}

sub CheckCriteria {

# Checks if the criteria file is empty and if not that: 
#
# - The first value defined in each line of the criteria file is a valid column number 
# - That no match criteria are empty strings
#
# Sub routine BuildHash must be called prior to this sub-routine.

my $specification_index = 0;
my $specification_line;
my @criteria_array;
my $criteria_index;
my $match_criteria;
my $match_length;
my $column_name;
my $column_number;
my $line_number;

if ( @criteria_specifications == 0 ) {

	DisplayError ( "ERROR : Criteria file $criteria_filename is empty" );
}

foreach $specification_line (@criteria_specifications) {

    $line_number = $specification_index + 1;
	@criteria_array = split(',',$specification_line);
	
	if ( @criteria_array > 1 ) {
		
		$column_name = $criteria_array[0];
		
		if( exists($field_numbers{$column_name}) ) {

			$column_number = $field_numbers{$column_name};
   
		} else {

			DisplayError ( "ERROR : Invalid data column name $column_name used on line $line_number of $criteria_filename see file $fields_filename" );
		}
	
	
		foreach $match_criteria (@criteria_array) {
	
	        $match_criteria =~ s/\n//;
			$match_length = length($match_criteria);

			if ( $match_length == 0 ) {
			
				DisplayError ( "ERROR : Missing column name or match criteria on line $line_number of $criteria_filename" );
			}
		}
		
	}	else {
	
		DisplayError ( "ERROR : Missing column name or match criteria on line $line_number of $criteria_filename" );
	
	}
	
	$specification_index++;
}

}

sub OutputRow {

# Outputs company data matching criteria.

my @input_array;
my $column_name;
my $column_number;
my $specification_index = 0;
my $specification_line;
my @criteria_array;
my $criteria_index;
my $output_line;
my $criteria_matched;
my $match_criteria;
my $partial_matches = 0;

# Split input row contents.

@input_array = split('#~',@_[0]);

# Iterate through all match criteria specified.

$output_line = '';

foreach $specification_line ( @criteria_specifications ) {

	# Determine which field (column) the match criteria relate to.

	@criteria_array = split(',',$specification_line);
	$column_name = $criteria_array[0];
	$column_number = $field_numbers{$column_name};
	
	# Do nothing if the column does not exist.
	
	if ( $column_number < @input_array ) {
	
		# Prepare the output line.
	
		$output_line = $output_line.$input_array[$column_number].",";
	
		# Perform searches using all match criteria specified.
		
		$criteria_matched = 0;
		
		for ( $criteria_index = 1 ; $criteria_index < @criteria_array ; $criteria_index++ ) {
			
			# Remove any LF's.
			
			$match_criteria = chomp($criteria_array[$criteria_index]);
			
			# Regex expressions must be precompiled before use.
			
			$match_criteria = qr/$criteria_array[$criteria_index]/;
					
							
			if ( $input_array[$column_number] =~ $match_criteria ) {
					
				$criteria_matched = $criteria_index
			}
		
		}
		
		if ( $criteria_matched > 0 ) {
		
				$partial_matches++
		}
	}
	
	$specification_index++;
}

# Output line of company data if at least one criteria per column is met i.e. an OR.
# of all column results.

if ( $partial_matches == @criteria_specifications ) {
	
	chop($output_line);
	print "$output_line\n";
}

}

#############
### MAIN ####
#############

# Check command line. 

if ( @ARGV != 2 ) {

	DisplayError ( "ERROR : This script requires an input and a criteria file name as arguments" );
}

$input_filename = $home_directory.$ARGV[0];
$criteria_filename = $home_directory.$ARGV[1];

# Open input file.

$input_file = "<".$input_filename;
open (INPUT,$input_file) or DisplayError ( "ERROR : Input file $input_filename could not be openned" );
@field_names = split(',',<INPUT>);

if ( $max_column != @field_names ) {

	DisplayError ( "ERROR : The number of data fields in the input file has changed from $max_column  " );
}

# Build field name/field number hash and output field names data

BuildHash;

$fields_file = ">".$fields_filename;
open (FIELDS,$fields_file) or DisplayError ( "ERROR : fields file $fields_filename could not be created" );

foreach $field_name (@field_names) {

    # Trim leading white space
    $field_name =~ s/^\s+//;
	print FIELDS "$field_name\n";

}
close(FIELDS);

# Open criteria file and read data.

$criteria_file = "<".$criteria_filename;
open (CRITERIA,$criteria_file) or DisplayError ( "ERROR : Criteria file $criteria_filename could not be openned" );
@criteria_specifications = <CRITERIA>;
close(CRITERIA);

# Check criteria data.

CheckCriteria;

# Read input file and output rows matching search criteria.

while (<INPUT>) {
	
	OutputRow(ProcessInput($_));
}

# Close open files.

close(INPUT);
close(OUTPUT);




