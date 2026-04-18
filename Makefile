.PHONY: install run run-full

install:
	Rscript -e 'install.packages(c("remotes","chromote","collegebaseball","jsonlite","rvest","xml2","dplyr","stringr","yaml"), repos="https://cloud.r-project.org")'
	Rscript -e 'remotes::install_local(".", dependencies = TRUE)'

run:
	Rscript scripts/sync_ncaa_stats.R --config config.yml --mode incremental

run-full:
	Rscript scripts/sync_ncaa_stats.R --config config.yml --mode full
