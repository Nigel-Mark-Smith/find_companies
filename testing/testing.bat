REM This script will run all commands specified in document
REM 'find_companies_testing.txt'.
cd ..
perl find_companies.pl 
perl find_companies.pl testing\input.csv 
perl find_companies.pl testing\no_input.csv testing\criteria.csv
perl find_companies.pl testing\input.csv testing\no_criteria.csv
perl find_companies.pl testing\input.csv testing\criteriaEmpty.csv
perl find_companies.pl testing\input.csv testing\criteriaInvalidColumn1.csv
perl find_companies.pl testing\input.csv testing\criteriaInvalidColumn2.csv
perl find_companies.pl testing\input.csv testing\criteriaMissing1.csv
perl find_companies.pl testing\input.csv testing\criteriaMissing2.csv
perl find_companies.pl testing\input.csv testing\criteriaMissing3.csv
perl find_companies.pl testing\inputNew.csv testing\criteria.csv
perl find_companies.pl testing\input.csv testing\criteria.csv
perl find_companies.pl testing\input.csv testing\criteriaReversed.csv
perl find_companies.pl testing\input.csv testing\criteriaAgencies.csv
perl find_companies.pl testing\input.csv testing\criteriaIT.csv