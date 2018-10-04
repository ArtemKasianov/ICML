use strict;


my $orthopairsFile = $ARGV[0];
my $identFile = $ARGV[1];
my $expressionFile = $ARGV[2];
my $trivialNamesFile = $ARGV[3];
my $outFile = $ARGV[4];
my $outFileTrivial = $ARGV[5];


open(FTW,">$outFile") or die;
open(FTW_T,">$outFileTrivial") or die;

my %orthopairs = ();
my %not_orthopairs = ();
my %trivialNames = ();

open(FTR,"<$orthopairsFile") or die;

while(my $input = <FTR>)
{
    chomp($input);
    my @arrInp = split(/\t/,$input);
    
    my $athNam = $arrInp[0];
    my $fescNam = $arrInp[1];
    
    my @arrVals = ();
    
    $orthopairs{"$athNam\t$fescNam"}=\@arrVals;
    
}

close(FTR);

open(FTR,"<$trivialNamesFile") or die;
while(my $input = <FTR>)
{
    chomp($input);
    
    my @arrInp = split(/\t/,$input);
    
    my $atNam = $arrInp[0];
    my $trivNam = $arrInp[1];
    
    $trivialNames{"$atNam"}=$trivNam;
    
}


close(FTR);

open(FTR,"<$expressionFile") or die;

while(my $input = <FTR>)
{
    chomp($input);
    my @arrInp = split(/\t/,$input);
    
    my $athNam = $arrInp[0];
    my $fescNam = $arrInp[1];
    my $exprVal = $arrInp[2];
    
    if(not exists $orthopairs{"$athNam\t$fescNam"})
    {
        my $ptrArrTmp = $orthopairs{"$athNam\t$fescNam"};
        my @arrVals = ();
        push @arrVals,$exprVal;
        $not_orthopairs{"$athNam\t$fescNam"} = \@arrVals;
        push @$ptrArrTmp,$exprVal;
    }
    
}

close(FTR);

open(FTR,"<$identFile") or die;

while(my $input = <FTR>)
{
    chomp($input);
    my @arrInp = split(/\t/,$input);
    
    my $athNam = $arrInp[0];
    my $fescNam = $arrInp[1];
    my $identVal = $arrInp[2];
    
    if(exists $not_orthopairs{"$athNam\t$fescNam"})
    {
        my $ptrArrTmp = $not_orthopairs{"$athNam\t$fescNam"};
        
        die if($#$ptrArrTmp == -1);
        
        if($#$ptrArrTmp == 0)
        {
            push @$ptrArrTmp,$identVal;
        }
        
        
    }
    
}

close(FTR);

my @arrPairs = keys %not_orthopairs;

for(my $i = 0;$i <= $#arrPairs;$i++)
{
    my $currPair = $arrPairs[$i];
    my $ptrArrTmp = $not_orthopairs{"$currPair"};
    print "$#$ptrArrTmp\n";
    die if($#$ptrArrTmp != 1);
    my @arrPair = split(/\t/,$currPair);
    my $athNam = $arrPair[0];
    my $fescNam = $arrPair[1];
    
    my $athNamTriv = $athNam;
    if(exists $trivialNames{"$athNam"})
    {
        $athNamTriv = $trivialNames{"$athNam"};
    }
    print FTW "$athNam\t$fescNam";
    print FTW_T "$athNam\_$athNamTriv\t$fescNam";
    for(my $i = 0;$i <= $#$ptrArrTmp;$i++)
    {
        my $currVal = $ptrArrTmp->[$i];
        print FTW "\t$currVal";
        print FTW_T "\t$currVal";
    }
    print FTW_T "\n";
    print FTW "\n";
}


close(FTW);
close(FTW_T);


