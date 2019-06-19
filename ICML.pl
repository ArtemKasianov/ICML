use strict;

my $firstSpExpressionFile = $ARGV[0];
my $secondSpExpressionFile = $ARGV[1];
my $similarityFile = $ARGV[2];

my $orthopairsFile = $ARGV[3];

my $maxIterations = $ARGV[4];
my $output_prefix = $ARGV[5];

for(my $iter = 0;$iter <=$maxIterations;$iter++ )
{
	mkdir("iter_$iter");
	mkdir("iter_$iter/results");
	mkdir("iter_$iter/results/data_for_learning");
	mkdir("iter_$iter/negative_sample");
	
	system("cp -r $similarityFile iter_$iter/results/data_for_learning/filtered_table.sim");
	system("perl GetNegativeRandomSet.pl $orthopairsFile 1000000 $firstSpExpressionFile $secondSpExpressionFile iter_$iter/negative_sample/Negative_Sample.list");
	system("cp $firstSpExpressionFile iter_$iter/results/data_for_learning/expression.predict");
	system("cp $orthopairsFile iter_$iter/results/data_for_learning/orthopairs.list");
	mkdir("iter_$iter/results/data_for_learning/folds");
	mkdir("iter_$iter/results/data_for_learning/negative_folds");
	mkdir("iter_$iter/results/data_for_learning/svm");
	system("perl GetRandomFoldOfOrthopairs.pl iter_$iter/results/data_for_learning/orthopairs.list 10 iter_$iter/results/data_for_learning/folds");
	system("perl GetRandomFoldOfOrthopairs.pl iter_$iter/negative_sample/Negative_Sample.list 10 iter_$iter/results/data_for_learning/negative_folds");
	
	
	mkdir("iter_$iter/results/training");
	mkdir("iter_$iter/results/training/expression");
	for(my $i = 0;$i <= 9;$i++)
	{
		mkdir("iter_$iter/results/training/expression/folds_$i");
		mkdir("iter_$iter/results/training/expression/folds_$i/model");
		
		my $strCat = "cat";
		
		for(my $j = 0;$j <= 9;$j++)
		{
			if ($i != $j) {
				$strCat = $strCat." iter_$iter/results/data_for_learning/folds/fold_$j.orthopairs";
			}
		}
		$strCat = $strCat." >iter_$iter/results/training/expression/folds_$i/not_fold_$i.orthopairs"; 
		system("$strCat");
		
		
		my $strCat = "cat";
		
		for(my $j = 0;$j <= 9;$j++)
		{
			if ($i != $j) {
				$strCat = $strCat." iter_$iter/results/data_for_learning/negative_folds/fold_$j.orthopairs";
			}
		}
		$strCat = $strCat." >iter_$iter/results/training/expression/folds_$i/not_negative_fold_$i.orthopairs"; 
		system("$strCat");
		
		system("perl GenerateSVMFile.expression.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/results/training/expression/folds_$i/not_fold_$i.orthopairs 1 0 iter_$iter/results/training/expression/folds_$i/positive.examples.not_fold_$i.svm");
		system("perl GenerateSVMFile.expression.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/results/training/expression/folds_$i/not_negative_fold_$i.orthopairs 0 0 iter_$iter/results/training/expression/folds_$i/negative.examples.not_fold_$i.svm");
		system("perl GenerateSVMFile.expression.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/results/data_for_learning/folds/fold_$i.orthopairs 1 0 iter_$iter/results/training/expression/folds_$i/positive.examples.fold_$i.svm");
		system("perl GenerateSVMFile.expression.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/results/data_for_learning/negative_folds/fold_$i.orthopairs 0 0 iter_$iter/results/training/expression/folds_$i/negative.examples.fold_$i.svm");
		
		system("cat iter_$iter/results/training/expression/folds_$i/positive.examples.not_fold_$i.svm iter_$iter/results/training/expression/folds_$i/negative.examples.not_fold_$i.svm >iter_$iter/results/training/expression/folds_$i/neg.pos.examples.not_fold_$i.svm");
		system("cat iter_$iter/results/training/expression/folds_$i/negative.examples.fold_$i.svm iter_$iter/results/training/expression/folds_$i/positive.examples.fold_$i.svm >iter_$iter/results/training/expression/folds_$i/positive.negative.test.fold_$i.svm");
		system("python XGBoostTree.saveModel.py iter_$iter/results/training/expression/folds_$i/neg.pos.examples.not_fold_$i.svm iter_$iter/results/training/expression/folds_$i/positive.negative.test.fold_$i.svm 0 0.3 1 1 1 1 0 4 1 50 auc 2436 iter_$iter/results/training/expression/folds_$i/model/model_1_1_1_1000.test");
		
	}
	
	mkdir("iter_$iter/results/training/expression/folds_all");
	mkdir("iter_$iter/results/training/expression/folds_all/model");
	
	my $strCat = "cat";
	
	for(my $j = 0;$j <= 9;$j++)
	{
		$strCat = $strCat." iter_$iter/results/data_for_learning/folds/fold_$j.orthopairs";
	}
	$strCat = $strCat." >iter_$iter/results/training/expression/folds_all/fold_all.orthopairs"; 
	system("$strCat");
	
	system("perl GenerateSVMFile.expression.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/results/training/expression/folds_all/fold_all.orthopairs 1 0 iter_$iter/results/training/expression/folds_all/positive.examples.fold_all.svm");
	system("perl GenerateSVMFile.expression.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/negative_sample/Negative_Sample.list 0 0 iter_$iter/results/training/expression/folds_all/negative.examples.fold_all.svm");
	system("perl GenerateSVMFile.expression.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/results/data_for_learning/folds/fold_0.orthopairs 1 0 iter_$iter/results/training/expression/folds_all/positive.examples.fold_0.svm");
	system("perl GenerateSVMFile.expression.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/negative_sample/Negative_Sample.list 0 0 iter_$iter/results/training/expression/folds_all/negative.examples.fold_0.svm");
	system("cat iter_$iter/results/training/expression/folds_all/positive.examples.fold_all.svm iter_$iter/results/training/expression/folds_all/negative.examples.fold_all.svm >iter_$iter/results/training/expression/folds_all/neg.pos.examples.fold_all.svm");
	system("cat iter_$iter/results/training/expression/folds_all/negative.examples.fold_0.svm iter_$iter/results/training/expression/folds_all/positive.examples.fold_0.svm >iter_$iter/results/training/expression/folds_all/positive.negative.test.fold_0.svm");
	system("python XGBoostTree.saveModel.py iter_$iter/results/training/expression/folds_all/neg.pos.examples.fold_all.svm iter_$iter/results/training/expression/folds_all/positive.negative.test.fold_0.svm 0 0.3 1 1 1 1 0 4 1 50 auc 2436 iter_$iter/results/training/expression/folds_all/model/model_1_1_1_1000.test");
	
	
	mkdir("iter_$iter/results/predictions");
	for(my $j = 0;$j <= 9;$j++)
	{
		system("perl GenerateSVMFile.expression.pairs.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/results/data_for_learning/folds/fold_$j.orthopairs 0 0 iter_$iter/results/data_for_learning/svm/fold_$j.expression.svm iter_$iter/results/data_for_learning/svm/fold_$j.expression.pairs");
		system("python PredictByModelXGBoost.10.py iter_$iter/results/data_for_learning/svm/fold_$j.expression.svm iter_$iter/results/data_for_learning/svm/fold_$j.expression.pairs iter_$iter/results/training/expression/folds_$j/model/model_1_1_1_1000.test 50 >iter_$iter/results/predictions/fold_$j.positive.orthopairs.expression.predictions");
		
		system("perl GenerateSVMFile.expression.pairs.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/results/data_for_learning/negative_folds/fold_$j.orthopairs 0 0 iter_$iter/results/data_for_learning/svm/fold_$j.expression.negative.svm iter_$iter/results/data_for_learning/svm/fold_$j.expression.negative.pairs");
		system("python PredictByModelXGBoost.10.py iter_$iter/results/data_for_learning/svm/fold_$j.expression.negative.svm iter_$iter/results/data_for_learning/svm/fold_$j.expression.negative.pairs iter_$iter/results/training/expression/folds_$j/model/model_1_1_1_1000.test 50 >iter_$iter/results/predictions/fold_$j.negative.orthopairs.expression.predictions");
	}
	my $strCat = "cat";
	my $strCatPositive = "cat";
	my $strCatNegative = "cat";
	for(my $j = 0;$j <= 9;$j++)
	{
		$strCat = $strCat." iter_$iter/results/predictions/fold_$j.positive.orthopairs.expression.predictions";
		$strCat = $strCat." iter_$iter/results/predictions/fold_$j.negative.orthopairs.expression.predictions";
		
		$strCatPositive = $strCatPositive." iter_$iter/results/predictions/fold_$j.positive.orthopairs.expression.predictions";
		$strCatNegative = $strCatNegative." iter_$iter/results/predictions/fold_$j.negative.orthopairs.expression.predictions";
	}
	$strCat = $strCat." >iter_$iter/results/predictions/expression.predictions";
	$strCatPositive = $strCatPositive." >iter_$iter/results/predictions/positive.expression.predictions";
	$strCatNegative = $strCatNegative." >iter_$iter/results/predictions/negative.expression.predictions";
	
	system("$strCat");
	system("$strCatPositive");
	system("$strCatNegative");
	system("perl GetPairsNotInOrthopairsAndVOGs.pl iter_$iter/results/data_for_learning/filtered_table.sim iter_$iter/results/data_for_learning/orthopairs.list iter_$iter/negative_sample/Negative_Sample.list iter_$iter/results/data_for_learning/others.pairs");
	system("perl GenerateSVMFile.expression.pairs.pl iter_$iter/results/data_for_learning/expression.predict $secondSpExpressionFile iter_$iter/results/data_for_learning/others.pairs 0 0 iter_$iter/results/data_for_learning/svm/others.expression.svm iter_$iter/results/data_for_learning/svm/others.expression.pairs");
	system("python PredictByModelXGBoost.10.py iter_$iter/results/data_for_learning/svm/others.expression.svm iter_$iter/results/data_for_learning/svm/others.expression.pairs iter_$iter/results/training/expression/folds_all/model/model_1_1_1_1000.test 50 >iter_$iter/results/predictions/others.expression.predictions");
  	system("cat iter_$iter/results/predictions/others.expression.predictions iter_$iter/results/predictions/expression.predictions >iter_$iter/results/predictions/expression.1.predictions");
	system("cat iter_$iter/results/predictions/expression.1.predictions >iter_$iter/results/predictions/expression.predictions");
	
	
}

mkdir("combined");
mkdir("combined/results");
mkdir("combined/results/predictions");
system("perl GenerateListFileFromIterations.pl . 0 $maxIterations combined/filesToCombine.list");
system("perl GenerateTableWithAllReadCounts.pl combined/filesToCombine.list combined/results/predictions/expression.combined.predictions >filesProcessed.list");
system("perl CountMediansForTableRows.pl combined/results/predictions/expression.combined.predictions combined/results/predictions/expression.combined.median.predictions");
mkdir("combined/results/graphs");
mkdir("combined/results/graphs/graphviz");
system("perl PrintOrthogroupsAfterCutByTreshold.pl iter_0/results/data_for_learning/filtered_table.sim combined/results/predictions/expression.combined.median.predictions 0.5 combined/results/final.orthogroups.list");

system("cp combined/results/predictions/expression.combined.median.predictions $output_prefix.predictions.pairs.txt");
system("cp combined/results/final.orthogroups.list $output_prefix.expressogroups.txt");
system("rm -r combined");
for(my $iter = 0;$iter <=$maxIterations;$iter++ )
{
	system("rm -r iter_$iter");
}

