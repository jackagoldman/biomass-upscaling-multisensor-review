# biomass-upscaling-multisensor-review

This repository presents an automated literature review workflow and an extended framework to conduct metanalysis. 

## HOW TO RUN:

1. make sure dependencies are installed using `renv` 
- if you are forking this repo, use renv::restore() to restore dependencies from renv.lock

2. Check `config.yml` configuration file defaults
- if you are forking this repo, you must create a configuration file in the project root called `config.yml` see `?config` for details
- if you are going to use scopus, you have to get a scopus API key. see the `rscopus`  package for details

3. Run `lit_search` from `R/lit_search.R`
- recommend running for .qmd file for reproducibility

4. Make sure to document steps in the `notebook.md` outline