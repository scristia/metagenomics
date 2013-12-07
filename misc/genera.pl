####################
## Code for extracting genus names of all genera in Proteobacterium
### Does not need to be run again -Stephen
####################
#!/usr/bin/perl
use lib '/home/student/scristia/lib/';

open(MYFILE, 'taxa.txt');
sub uniq {
    my %seen = ();
    my @r = ();
    foreach my $a (@_) {
        unless ($seen{$a}) {
            push @r, $a;
            $seen{$a} = 1;
        }
    }
    return @r;
}

my @genera = [];
while (<MYFILE>) {
    chomp;
    if($_ =~ m{_}) {
        #$_ =~ s/^*[^_]+(?=_)//;
        $_ =~ s/_.*//;
        $_ =~ s/ '//;
        push(@genera, $_);
    }
}

foreach $i (uniq(@genera)) { 
    chomp;
    if($i =~ /^[[:upper:]]/) {
        print "$i\n" 
    }
}
close (MYFILE);

