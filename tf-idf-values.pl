use strict;

opendir(DIR,"gutenberg");
my @files = readdir(DIR);

my %df;
foreach my $f (@files)
{
    my %tf; my $word_count=0;
    #make sure not to process files that start with a "."
    if($f !~ /^\./) 
    {
        print "Processing file: ".$f."\n";
        open(IN,"gutenberg/$f");
        my @text = <IN>;
        close(IN);
        foreach my $txt (@text)
        {
            #remove endline character
            chomp($txt);
            #remove extra space characters
            $txt =~ s/[\h\v]+/ /g;
            #remove caps
            $txt =~ tr/[A-Z]/[a-z]/;
            #remove non-alphanumeric characters
            $txt =~ s/[^a-zA-Z\d\s]//g;

            my @data = split(/ +/,$txt);
            foreach my $d (@data)
            {
                $word_count++;
                #make sure the key is not an empty character
                if($d ne "")
                {
                    $tf{$d}++;
                    $df{$d}{$f}=1;
                }
            }
        }
        #print out the normalized tf for each word for each file
        open(OUT,">output/tf/$f");
        foreach my $t (sort keys %tf)
        {
            print OUT $t."\t".($tf{$t}/$word_count)."\n";
        }
        close(OUT);
    }
}

#print it all into text files
my $n = $#files;
my %idf;
open(OUT,">output/df.txt");
print OUT "word \t #docs it exists in \t doc names\n";
open(OUT2,">output/idf.txt");
foreach my $t (sort keys %df)
{
    my @vals = keys %{ $df{$t} };
    print OUT $t."\t".($#vals+1)."\t";
    foreach my $v (@vals)
    {
        print OUT $v.", ";
    }
    print OUT "\n";
    my $idf_val = log($n/($#vals+1));
    print OUT2 $t."\t".$idf_val."\n";
}
close(OUT2);
close(OUT);