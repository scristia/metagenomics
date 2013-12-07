## Get gids or taxon ids from a lookup to a taxonomy database from ncbi
## We didn't end up doing something like this - Stephen

#!/home/student/scristia/bin/python
import gzip
## 1224 - proteobacteria (phlyum level)
## 1236 - gammaproteobacteria (class level, e. coli in this set)
## 28126 - betaproteobacteria (class level)

## For small number of IDs, there is a quicker solution. Didn't think of one.
## taxids you want to look up
taxids = ['1224', '1236', '28216']
## create a set
taxids = set(taxids)
## file to output to
gi_taxid_output = open('small_gi_taxid.txt', 'w')
## loop through taxon id database and print hits
### NOTE ###
# the database has tab delimited IDs on each line:
# gid   taxid
# match to taxid and output both gid and taxid
with gzip.open('gi_taxid_nucl.dmp.gz', 'r') as dmp:
    found = 0
    for line in dmp:
        line_split = line.split('\t')
        print line_split[0], line_split[1].rstrip("\n"), found
        if str(line_split[1].rstrip('\n')) in taxids:
            found = found + 1
            print >> gi_taxid_output, line.rstrip('\n')
