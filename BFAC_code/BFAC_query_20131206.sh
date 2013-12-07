perl BFAC_query_20131206.pl ./simdata/NC_mixed_005363_010473-454.fna -b filter_Bdello.txt -dbpr ./ -op 454mixed_final
perl BFAC_query_20131206.pl ./simdata/NC_mixed_005363_010473-454.fna -b filter_Ecoli.txt -dbpr ./ -op 454mixed_final
perl BFAC_query_20131206.pl ./simdata/NC_mixed_005363_010473-454.fna -b filter_Ecoli2.txt -dbpr ./ -op 454mixed_final
Rscript BFAC BFAC_summary_20131206.r


