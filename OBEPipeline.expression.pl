use strict;

my $identTreshold = $ARGV[0];
my $identFile = $ARGV[1];
my $athExpressionFile = $ARGV[2];
my $fescExpressionFile = $ARGV[3];
my $athCodonFreqFile = $ARGV[4];
my $fescCodonFreqFile = $ARGV[5];
my $athMrnaFile = $ARGV[6];
my $orthopairsFile = $ARGV[7];
my $trivialNamesFile = $ARGV[8];
my $maxIterations = $ARGV[9];

for(my $iter = 0;$iter <=99;$iter++ )
{
	mkdir("iter_$iter");
	mkdir("iter_$iter/results_treshold_$identTreshold");
	mkdir("iter_$iter/results_treshold_$identTreshold/data_for_learning");
	mkdir("iter_$iter/negative_sample");
	#system("perl FilterIdentFileByTreshold.pl $identFile $identTreshold results_treshold_$identTreshold/data_for_learning/Ath_vs_Fesc.gt$identTreshold.ident");
	system("cp -r negative_sample/* iter_$iter/negative_sample");
	system("cp -r filtered_ident/* iter_$iter/results_treshold_$identTreshold/data_for_learning");
	system("perl iter_$iter/negative_sample/GetNegativeRandomSet.pl $orthopairsFile 1000000 $athMrnaFile $fescExpressionFile iter_$iter/negative_sample/Ath_Fesc_Negative_Sample.list");
	system("perl FilterIdentityByMRnaList.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/Ath_vs_Fesc.gt$identTreshold.ident $athMrnaFile iter_$iter/results_treshold_$identTreshold/data_for_learning/Ath_vs_Fesc.gt$identTreshold.filtered.ident");
	system("perl FilterExpressionFileByAthMrna.pl $athExpressionFile $athMrnaFile iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict");
	system("perl FilterByMrnaAndNotIdentity.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/Ath_vs_Fesc.gt$identTreshold.filtered.ident $athMrnaFile $orthopairsFile iter_$iter/results_treshold_$identTreshold/data_for_learning/orthopairs.filtered.list");
	mkdir("iter_$iter/results_treshold_$identTreshold/data_for_learning/folds");
	mkdir("iter_$iter/results_treshold_$identTreshold/data_for_learning/negative_folds");
	mkdir("iter_$iter/results_treshold_$identTreshold/data_for_learning/svm");
	mkdir("iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG");
	system("perl GetRandomFoldOfOrthopairs.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/orthopairs.filtered.list 10 iter_$iter/results_treshold_$identTreshold/data_for_learning/folds");
	system("perl GetRandomFoldOfOrthopairs.pl iter_$iter/negative_sample/Ath_Fesc_Negative_Sample.list 10 iter_$iter/results_treshold_$identTreshold/data_for_learning/negative_folds");
	
	system("perl GetHitsOnlyForAthAndFesc.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/Ath_vs_Fesc.gt$identTreshold.filtered.ident iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/fesc_for_ath.list iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/ath_for_fesc.list temp.ath.stats temp.fesc.stats");
	#
	for(my $i = 0;$i <= 9;$i++)
	{
		system("perl CreateVOGs.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/fesc_for_ath.list iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/ath_for_fesc.list $athMrnaFile iter_$iter/results_treshold_$identTreshold/data_for_learning/folds/fold_$i.orthopairs iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/virtual.orthogroup.fold_$i.list");
		system("perl GetPairsFromOrthogroupsStr.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/virtual.orthogroup.fold_$i.list iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/virtual.orthogroup.fold_$i.pairs.list");
	}
	mkdir("iter_$iter/results_treshold_$identTreshold/training");
	mkdir("iter_$iter/results_treshold_$identTreshold/training/expression");
	for(my $i = 0;$i <= 9;$i++)
	{
		mkdir("iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i");
		mkdir("iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/model");
		
		my $strCat = "cat";
		
		for(my $j = 0;$j <= 9;$j++)
		{
		if ($i != $j) {
			$strCat = $strCat." iter_$iter/results_treshold_$identTreshold/data_for_learning/folds/fold_$j.orthopairs";
		}
		}
		$strCat = $strCat." >iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/not_fold_$i.orthopairs"; 
		system("$strCat");
		
		
		my $strCat = "cat";
		
		for(my $j = 0;$j <= 9;$j++)
		{
		if ($i != $j) {
			$strCat = $strCat." iter_$iter/results_treshold_$identTreshold/data_for_learning/negative_folds/fold_$j.orthopairs";
		}
		}
		$strCat = $strCat." >iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/not_negative_fold_$i.orthopairs"; 
		system("$strCat");
		
		$strCat = "cat";
		
		for(my $j = 0;$j <= 9;$j++)
		{
		if ($i != $j) {
			$strCat = $strCat." iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/virtual.orthogroup.fold_$j.pairs.list";
		}
		}
		$strCat = $strCat." >iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/virtual.orthogroup.not_fold_$i.pairs.list"; 
		system("$strCat");
		system("perl GenerateSVMFile.expression.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/not_fold_$i.orthopairs 1 0 iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.positive.examples.not_fold_$i.svm");
		system("perl GenerateSVMFile.expression.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/not_negative_fold_$i.orthopairs 0 0 iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.negative.examples.not_fold_$i.svm");
		system("perl GenerateSVMFile.expression.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/data_for_learning/folds/fold_$i.orthopairs 1 0 iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.positive.examples.fold_$i.svm");
		system("perl GenerateSVMFile.expression.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/virtual.orthogroup.fold_$i.pairs.list 0 0 iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.negative.examples.fold_$i.svm");
		system("cat iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.positive.examples.not_fold_$i.svm iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.negative.examples.not_fold_$i.svm >iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.neg.pos.examples.not_fold_$i.svm");
		system("cat iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.negative.examples.fold_$i.svm iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.positive.examples.fold_$i.svm >iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.positive.negative.test.fold_$i.svm");
		system("python XGBoostTree.saveModel.py iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.neg.pos.examples.not_fold_$i.svm iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/orthoMCL.oma.intersect.positive.negative.test.fold_$i.svm 0 0.3 1 1 1 1 0 4 1 50 auc 2436 iter_$iter/results_treshold_$identTreshold/training/expression/folds_$i/model/model_1_1_1_1000.test");
		
	}
	
	mkdir("iter_$iter/results_treshold_$identTreshold/training/expression/folds_all");
	mkdir("iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/model");
	
	my $strCat = "cat";
	
	for(my $j = 0;$j <= 9;$j++)
	{
		$strCat = $strCat." iter_$iter/results_treshold_$identTreshold/data_for_learning/folds/fold_$j.orthopairs";
	}
	$strCat = $strCat." >iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/fold_all.orthopairs"; 
	system("$strCat");
	
	$strCat = "cat";
	
	for(my $j = 0;$j <= 9;$j++)
	{
		$strCat = $strCat." iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/virtual.orthogroup.fold_$j.pairs.list";
	}
	$strCat = $strCat." >iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/virtual.orthogroup.fold_all.pairs.list"; 
	system("$strCat");
	system("perl GenerateSVMFile.expression.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/fold_all.orthopairs 1 0 iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.positive.examples.fold_all.svm");
	system("perl GenerateSVMFile.expression.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/negative_sample/Ath_Fesc_Negative_Sample.list 0 0 iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.negative.examples.fold_all.svm");
	system("perl GenerateSVMFile.expression.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/data_for_learning/folds/fold_0.orthopairs 1 0 iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.positive.examples.fold_0.svm");
	system("perl GenerateSVMFile.expression.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/virtual.orthogroup.fold_0.pairs.list 0 0 iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.negative.examples.fold_0.svm");
	system("cat iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.positive.examples.fold_all.svm iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.negative.examples.fold_all.svm >iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.neg.pos.examples.fold_all.svm");
	system("cat iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.negative.examples.fold_0.svm iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.positive.examples.fold_0.svm >iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.positive.negative.test.fold_0.svm");
	system("python XGBoostTree.saveModel.py iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.neg.pos.examples.fold_all.svm iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/orthoMCL.oma.intersect.positive.negative.test.fold_0.svm 0 0.3 1 1 1 1 0 4 1 50 auc 2436 iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/model/model_1_1_1_1000.test");
	
	$strCat = "cat";
	
	for(my $j = 0;$j <= 9;$j++)
	{
		$strCat = $strCat." iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/virtual.orthogroup.fold_$j.pairs.list";
	}
	$strCat = $strCat." >iter_$iter/results_treshold_$identTreshold/data_for_learning/virtual_OG/virtual.orthogroup.fold_all.pairs.list";
	system("$strCat");
	
	system("perl GetPairsNotInOrthopairsAndVOGs.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/Ath_vs_Fesc.gt$identTreshold.filtered.ident iter_$iter/results_treshold_$identTreshold/data_for_learning/orthopairs.filtered.list iter_$iter/negative_sample/Ath_Fesc_Negative_Sample.list iter_$iter/results_treshold_$identTreshold/data_for_learning/others.pairs");
	
	
	mkdir("iter_$iter/results_treshold_$identTreshold/predictions");
	for(my $j = 0;$j <= 9;$j++)
	{
		system("perl GenerateSVMFile.expression.pairs.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/data_for_learning/folds/fold_$j.orthopairs 0 0 iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/fold_$j.expression.svm results_treshold_$identTreshold/data_for_learning/svm/fold_$j.expression.pairs");
		system("perl GenerateSVMFile.expression.pairs.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/data_for_learning/negative_folds/fold_$j.orthopairs 0 0 iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/virtual.orthogroup.fold_$j.expression.svm iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/virtual.orthogroup.fold_$j.expression.pairs");
		system("python PredictByModelXGBoost.10.py iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/fold_$j.expression.svm iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/fold_$j.expression.pairs iter_$iter/results_treshold_$identTreshold/training/expression/folds_$j/model/model_1_1_1_1000.test 50 >iter_$iter/results_treshold_$identTreshold/predictions/fold_$j.positive.orthopairs.expression.predictions");
		system("python PredictByModelXGBoost.10.py iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/virtual.orthogroup.fold_$j.expression.svm iter_$iter/results_treshold_$identTreshold/data_for_learning/negative_folds/fold_$j.orthopairs iter_$iter/results_treshold_$identTreshold/training/expression/folds_$j/model/model_1_1_1_1000.test 50 >iter_$iter/results_treshold_$identTreshold/predictions/fold_$j.negative.orthopairs.expression.predictions");
		
	}
	
	system("perl GenerateSVMFile.expression.pairs.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/ath.expression.filtered.predict $fescExpressionFile iter_$iter/results_treshold_$identTreshold/data_for_learning/others.pairs 0 0 iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/others.expression.svm iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/others.expression.pairs");
	system("python PredictByModelXGBoost.10.py iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/others.expression.svm iter_$iter/results_treshold_$identTreshold/data_for_learning/svm/others.expression.pairs iter_$iter/results_treshold_$identTreshold/training/expression/folds_all/model/model_1_1_1_1000.test 50 >iter_$iter/results_treshold_$identTreshold/predictions/others.expression.predictions");
	
	
	

	
	$strCat = "cat";
	$strCatPositive = "cat";
	$strCatNegative = "cat";
	for(my $j = 0;$j <= 9;$j++)
	{
		$strCat = $strCat." iter_$iter/results_treshold_$identTreshold/predictions/fold_$j.positive.orthopairs.expression.predictions";
		$strCat = $strCat." iter_$iter/results_treshold_$identTreshold/predictions/fold_$j.negative.orthopairs.expression.predictions";
		
		$strCatPositive = $strCatPositive." iter_$iter/results_treshold_$identTreshold/predictions/fold_$j.positive.orthopairs.expression.predictions";
		$strCatNegative = $strCatNegative." iter_$iter/results_treshold_$identTreshold/predictions/fold_$j.negative.orthopairs.expression.predictions";
	}
	$strCat = $strCat." iter_$iter/results_treshold_$identTreshold/predictions/others.expression.predictions >iter_$iter/results_treshold_$identTreshold/predictions/expression.predictions";
	$strCatPositive = $strCatPositive." >iter_$iter/results_treshold_$identTreshold/predictions/positive.expression.predictions";
	$strCatNegative = $strCatNegative." >iter_$iter/results_treshold_$identTreshold/predictions/negative.expression.predictions";
	
	system("$strCat");
	system("$strCatPositive");
	system("$strCatNegative");
	
	

	mkdir("iter_$iter/results_treshold_$identTreshold/graphs");
	mkdir("iter_$iter/results_treshold_$identTreshold/graphs/graphviz");
	
	for(my $i = 0.5;$i < 0.51;$i+=0.01)
	{
		system("perl PrintOrthogroupsAfterCutByTreshold.pl iter_$iter/results_treshold_$identTreshold/data_for_learning/Ath_vs_Fesc.gt$identTreshold.ident iter_$iter/results_treshold_$identTreshold/predictions/expression.predictions $i iter_$iter/results_treshold_$identTreshold/graphs/orthogroups.treshold_$i.list");
		system("perl GetDistrOfOrthogroupSIzes.pl iter_$iter/results_treshold_$identTreshold/graphs/orthogroups.treshold_$i.list >iter_$iter/results_treshold_$identTreshold/graphs/orthogroups.treshold_$i.distr.list");
		
	}

}

mkdir("combined");
mkdir("combined/results_treshold_30");
mkdir("combined/results_treshold_30/predictions");
system("perl GenerateListFileFromIterations.pl . 0 99 combined/filesToCombine.list");
system("perl GenerateTableWithAllReadCounts.pl combined/filesToCombine.list combined/results_treshold_30/predictions/expression.combined.predictions >filesProcessed.list");
system("perl CountMediansForTableRows.pl combined/results_treshold_30/predictions/expression.combined.predictions combined/results_treshold_30/predictions/expression.combined.median.predictions");
system("perl GetIdentExpressionForOrthopairs.pl iter_0/results_treshold_30/data_for_learning/orthopairs.filtered.list /mnt/lustre/kasianov/Projects/ArabFagop/newProtocol/diffTresholds/model_50/iteration/combined/results_treshold_30/graphs/Ath_vs_Fesc.orthoMCL.ident combined/results_treshold_30/predictions/expression.combined.median.predictions Gene_Names.new.txt combined/orthoMCL.orthopairs.ident.predictions.txt combined/orthoMCL.orthopairs.ident.predictions.trivial.txt");
system("perl GetIdentExpressionForNotOrthopairs.pl iter_0/results_treshold_30/data_for_learning/orthopairs.filtered.list /mnt/lustre/kasianov/Projects/ArabFagop/newProtocol/diffTresholds/model_50/iteration/combined/results_treshold_30/graphs/Ath_vs_Fesc.orthoMCL.ident combined/results_treshold_30/predictions/expression.combined.median.predictions Gene_Names.new.txt combined/orthoMCL.not_orthopairs.ident.predictions.txt combined/orthoMCL.not_orthopairs.ident.predictions.trivial.txt");