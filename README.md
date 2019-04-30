# ICML
## ICML run
```
perl ICML.pl <first species expression counts file> <first species expression counts file> <file with similarity between species proteins>  <file with orthopairs> <number of iterations> <output files prefix>
```
## ICML test run.
Input data for test run are located in *test_sample/input_data* directory. The directory *test_sample/input_data* contains files *expression.1_species.sample_data.txt*, *expression.2_species.sample_data.txt*,*1_species_vs_2_species.sim* and *orthopairs.sample_data.txt*.\
Run script *ICML.pl*: 
```
perl ICML.pl test_sample/input_data/expression.1_species.sample_data.txt test_sample/input_data/expression.2_species.sample_data.txt test_sample/input_data/1_species_vs_2_species.sim test_sample/input_data/orthopairs.sample_data.txt 2 output_test_sample
```
As a result,  will be created the following files: *output_test_sample.predictions.pairs.txt* – file, which contains expression score values
*output_test_sample.expressogroups.txt* – file, which contains expressogroups in form of tab-delimited table with gene names.\
Resulting files should coincide with the files from the directory *test_sample/output_data*. 
