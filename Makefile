.PHONY: install run run-full doctor doc check

install:
	Rscript -e 'install.packages(c("remotes","chromote","collegebaseball","jsonlite","rvest","xml2","dplyr","stringr","yaml","digest"), repos="https://cloud.r-project.org")'
	Rscript -e 'remotes::install_local(".", dependencies = TRUE)'

doctor:
	Rscript scripts/ncaa_stats_doctor.R

doc:
	Rscript -e 'install.packages(c("pkgdown","knitr","rmarkdown"), repos="https://cloud.r-project.org"); pkgdown::build_site()'

check:
	Rscript -e 'if (!requireNamespace("devtools", quietly=TRUE)) install.packages("devtools", repos="https://cloud.r-project.org"); devtools::check(document = FALSE, vignettes = FALSE, manual = FALSE, build_args = c("--no-build-vignettes"), args = c("--no-manual"), error_on = "warning")'

run:
	Rscript scripts/sync_ncaa_stats.R --config config.yml --mode incremental

run-full:
	Rscript scripts/sync_ncaa_stats.R --config config.yml --mode full
