use strict;
use OrthologGraphList;
use OrthologousGroups;

my $identFile = $ARGV[0];
my $predictFile = $ARGV[1];
my $treshold = $ARGV[2];
my $outOrthogroupsFile = $ARGV[3];




my %predictPairs = ();
my %identPairs = ();

my %allAthHash = ();
my %allFescHash = ();






open(FTR,"<$predictFile") or die;

while (my $input = <FTR>) {
    chomp($input);
    
    my @arrInp = split(/\t/,$input);
    
    my $athNam = $arrInp[0];
    my $fescNam = $arrInp[1];
    my $predictVal = $arrInp[2];
    
    $allAthHash{"$athNam"} = 1;
    $allFescHash{"$fescNam"} = 1;
    
    
    $predictPairs{"$athNam\t$fescNam"}=$predictVal;
    
    
}


close(FTR);


my @allAth = keys %allAthHash;
my @allFesc = keys %allFescHash;

open(FTR,"<$identFile") or die;

while (my $input = <FTR>) {
    chomp($input);
    
    my @arrInp = split(/\t/,$input);
    
    my $athNam = $arrInp[0];
    my $fescNam = $arrInp[1];
    my $identVal = $arrInp[2];
    if (exists $predictPairs{"$athNam\t$fescNam"}) {
	$identPairs{"$athNam\t$fescNam"}=$identVal;
    }
    
    
}


close(FTR);




my $orthologGraph = OrthologGraphList->new();
for(my $i = 0;$i <= $#allAth;$i++)
{
    my $currAth = $allAth[$i];
    for(my $j = 0;$j <= $#allFesc;$j++)
    {
	my $currFesc = $allFesc[$j];
	
	next if(not exists $predictPairs{"$currAth\t$currFesc"});
	next if(not exists $identPairs{"$currAth\t$currFesc"});
	
	my $predictVal = $predictPairs{"$currAth\t$currFesc"};
	my $identVal = $identPairs{"$currAth\t$currFesc"};
	
	$orthologGraph->AddEdge($currAth,$currFesc,$predictVal,$identVal);
	
    }
}


$orthologGraph->RemoveEdgesWithWeightBelowTreshold($treshold,0);
$orthologGraph->PrintOrthogroups($outOrthogroupsFile);

