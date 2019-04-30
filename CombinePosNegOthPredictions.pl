use strict;

my $posFile = $ARGV[0];
my $negFile = $ARGV[1];
my $otherFile = $ARGV[2];
my $outFile = $ARGV[3];


my %predictionsList = ();

open(FTW,">$outFile") or die;


open(FTR,"<$posFile") or die;
<FTR>;
while(my $input = <FTR>)
{
	chomp($input);
	
	next if(substr($input,0,1) eq "[");
	my @arrInp = split(/\t/,$input);
	
	
	my $gNam1 = $arrInp[0];
	my $gNam2 = $arrInp[1];
	my $predVal = $arrInp[2];
	
	next if(exists $predictionsList{"$gNam1\t$gNam2"});
	$predictionsList{"$gNam1\t$gNam2"} = $predVal;
}


close(FTR);


open(FTR,"<$negFile") or die;
<FTR>;
while(my $input = <FTR>)
{
	chomp($input);
	next if(substr($input,0,1) eq "[");
	
	my @arrInp = split(/\t/,$input);
	
	
	my $gNam1 = $arrInp[0];
	my $gNam2 = $arrInp[1];
	my $predVal = $arrInp[2];
	
	next if(exists $predictionsList{"$gNam1\t$gNam2"});
	$predictionsList{"$gNam1\t$gNam2"} = $predVal;
}


close(FTR);


open(FTR,"<$otherFile") or die;
<FTR>;
while(my $input = <FTR>)
{
	chomp($input);
	next if(substr($input,0,1) eq "[");
	
	my @arrInp = split(/\t/,$input);
	
	
	my $gNam1 = $arrInp[0];
	my $gNam2 = $arrInp[1];
	my $predVal = $arrInp[2];
	
	next if(exists $predictionsList{"$gNam1\t$gNam2"});
	$predictionsList{"$gNam1\t$gNam2"} = $predVal;
}


close(FTR);




my @genePairs = keys %predictionsList;


for(my $i = 0;$i <= $#genePairs;$i++)
{
	my $currGenePair = $genePairs[$i];
	my $predVal = $predictionsList{"$currGenePair"};
	print FTW "$currGenePair\t$predVal\n";
}


close(FTW);


