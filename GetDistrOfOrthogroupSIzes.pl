use strict;
use OrthologousGroups;


my $orthogroupFile = $ARGV[0];

my %distrBySizes = ();


open(FTR,"<$orthogroupFile") or die;


while (my $input = <FTR>) {
    chomp($input);
    
    my @arrInp = split(/\t/,$input);
    
    my $orthoGroupObj = OrthologousGroups->new();
    
    
    for(my $i = 0;$i <= $#arrInp;$i++)
    {
	my $gNam = $arrInp[$i];
	$orthoGroupObj->AddGene($gNam);
    }
    
    my $ptrAthArr = $orthoGroupObj->GetAthArr();
    my $ptrFescArr = $orthoGroupObj->GetFescArr();
    
    
    my $sizeOfOrthogroup = $#$ptrAthArr + $#$ptrFescArr + 2;
    
    if (exists $distrBySizes{$sizeOfOrthogroup}) {
	$distrBySizes{$sizeOfOrthogroup} = $distrBySizes{$sizeOfOrthogroup} + 1;
    }
    else
    {
	$distrBySizes{$sizeOfOrthogroup} = 1;
    }
}

close(FTR);


my @arrSizes = sort {$a <=> $b} keys %distrBySizes;


for(my $i = 0;$i <= $#arrSizes;$i++)
{
    my $currSize = $arrSizes[$i];
    my $currCount = $distrBySizes{$currSize};
    print "$currSize\t$currCount\n";
}



