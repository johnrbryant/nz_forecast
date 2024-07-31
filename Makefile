
YEAR_MAX = 2050

COL_FILL = "steelblue1"
COL_LINE = "black"
COL_POINT = "red"

.PHONY: all
all: out/fig_direct_births.pdf \
     out/fig_direct_deaths.pdf \
     out/fig_rates_deaths.pdf \
     out/fig_hyper_deaths.pdf \
     out/fig_lifeexp.pdf

## Prepare data

out/births.rds: src/births.R \
  data/VSB355804_20240719_033528_19.csv.gz
	Rscript $^ $@

out/deaths.rds: src/deaths.R \
  data/VSD349204_20240719_033016_10.csv.gz
	Rscript $^ $@

out/popn.rds: src/popn.R \
  data/DPE403905_20240719_034147_54.csv.gz
	Rscript $^ $@


## Graph direct estimates of rates

out/fig_direct_births.pdf: src/fig_direct_births.R \
  out/births.rds \
  out/popn.rds
	Rscript $^ $@

out/fig_direct_deaths.pdf: src/fig_direct_deaths.R \
  out/deaths.rds \
  out/popn.rds
	Rscript $^ $@



## Fit models

out/mod_deaths.rds: src/mod_deaths.R \
  out/deaths.rds \
  out/popn.rds
	Rscript $^ $@


## Forecasts of rates

out/fig_rates_deaths.pdf: src/fig_rates_deaths.R \
  out/mod_deaths.rds
	Rscript $^ $@ --year_max=$(YEAR_MAX)

out/fig_hyper_deaths.pdf: src/fig_hyper_deaths.R \
  out/mod_deaths.rds
	Rscript $^ $@ --year_max=$(YEAR_MAX)

out/fig_lifeexp.pdf: src/fig_lifeexp.R \
  out/mod_deaths.rds
	Rscript $^ $@ --year_max=$(YEAR_MAX)


## Clean

.PHONY: clean
clean:
	rm -rf out
	mkdir out
