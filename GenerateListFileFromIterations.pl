use strict;

my $baseDir = $ARGV[0];
my $minIterationNumberFile = $ARGV[1];
my $maxIterationNumberFile = $ARGV[2];
my $outFile = $ARGV[3];


open(FTW,">$outFile") or die;

for(my $i = $minIterationNumberFile;$i <= $maxIterationNumberFile;$i++)
{
	print FTW "$baseDir/iter_$i/results/predictions/expression.predictions\t$baseDir/iter_$i/negative_sample/Negative_Sample.list\t$baseDir/iter_$i/results/data_for_learning/others.pairs\titer_$i\n";
}


close(FTW);
