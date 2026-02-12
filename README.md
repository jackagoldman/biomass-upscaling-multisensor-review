# biomass-upscaling-multisensor-review

This repository presents an automated literature review workflow and an extended framework to conduct metanalysis. 

## HOW TO RUN:

1. make sure dependencies are installed using `renv` 
- if you are forking this repo, use renv::restore() to restore dependencies from renv.lock

2. create `.Renviron` file in project root 
- in the `.Renviron` file store you will set your scopus_api_key, the scopus API key allows you to search scopus. To get the api key go to https://dev.elsevier.com/. For more details see the `rscopus`  package for details.
- Once you have your API key, set it in the file using the following syntax `scopus_api_key="your_api_key_here"`. When you load the project, R will automatically find read the .Renviron file for details.
- the .Renviron file is ignored via `.gitignore` and will not be pushed to remote repository.

3. Check `config.yml` configuration file defaults
- The config file is used to set the search keywords. 
- **currently this repository is based on the initial search being a scopus search which inclues TITLE-ABS-KEY , whereby the search criteria is words that come appear only in the article's title, abstract or keywords. This functionally may be altered in future versions**
- the config file is called in scripts using `config::get()`
- see `?config` for details

4. Run `lit_search` from `R/lit_search.R`
- recommend running for .qmd file for reproducibility

5. Make sure to document steps in the `notebook.md` outline


## NOTES

To manage modules, this repository uses the `box` package via calls to `box::use()`. See `?box` for details.