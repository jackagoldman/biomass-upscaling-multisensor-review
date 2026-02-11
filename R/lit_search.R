setwd(config::get('r-folder-path'))
box::use(./gscholar, ./helpers, ./pubmed, ./scopus)

#' Title
#'
#' @param query
#' @param count
#' @param start
#'
#' @returns
#'
#' @export
#' @examples
lit_search_scopus <- function(query, count = 25, start = 0) {
  scopus$check_scopus_api_key()
  df_scopus <- scopus$search_scopus(query = query, count = count, start = start)
  df_scopus$abstract <- scopus$process_abstracts(df_scopus)
  return(df_scopus)
}

#' Title
#'
#' @param query
#' @param retmax
#'
#' @returns
#'
#' @export
#' @examples
lit_search_pubmed <- function(query, retmax = 100) {
  pbmd <- pubmed$pubmed_search(query = config::get("query"), retmax = 1000)
  records_xml_text <- pubmed$get_records(pbmd)
  final_results_pubmed <- pubmed$parse_pubmed_records(records_xml_text)
  return(final_results_pubmed)
  }

#' Title
#'
#' @param query
#' @param pages
#' @param crawl_delay
#'
#' @returns
#'
#' @export
#' @examples
lit_search_gscholar <- function(query, pages, crawl_delay = 1) {
  result_df <- gscholar$gscholar_search(query, pages, crawl_delay)
  return(result_df)
}

# put them all together
#' Title
#' @param query
#' @param retmax  
#' @param pages
#' @param crawl_delay
#' @returns
#' @export
#' @examples test <- lit_search(config::get("query"), retmax = 100, pages = 1:2, crawl_delay = 1)
lit_search <- function(query, retmax = 100, pages = 1:2, crawl_delay = 1) {
  pubmed_results <- lit_search_pubmed(query, retmax)
  gscholar_results <- lit_search_gscholar(query, pages, crawl_delay)
  scopus_results <- lit_search_scopus(query, count = retmax, start = 0)
  return(list(pubmed = pubmed_results, gscholar = gscholar_results, scopus = scopus_results))
}
