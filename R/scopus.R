# modules for working with scopus api

#' check scopus api key
#'
#' @returns
#'
#' @export
#' @examples check_scopus_api_key()
check_scopus_api_key <- function() { 
  if (isTRUE(rscopus::is_elsevier_authorized())) {
    print("Scopus API key is set.")
  } else {
    print("Setting Scopus API key...")
    scopus_api_key <- config::get("scopus-api-key")
    rscopus::set_api_key(scopus_api_key)
    if (isTRUE(rscopus::is_elsevier_authorized())) {
      print("Scopus API key is now set.")
    } 
  }
}

#' Search scopus and return dataframe of results
#'
#' @param query
#' @param ...
#'
#' @returns
#'
#' @export
#' @examples test <- search_scopus(query = config::get("query"), start =0, count = 25)
search_scopus <- function(query, count = 25, start = 0) {
   res = rscopus::scopus_search(query = query, view = "STANDARD", count = count, start = start)
    df = rscopus::gen_entries_to_df(res$entries)
    head(df$df)
  return(df)
}


#' Get abstract text from Scopus using EID
#'
#' @param eid
#'
#' @returns
#'
#' @export
#' @examples
get_scopus_abstract <- function(eid) {
  res = rscopus::abstract_retrieval(id = eid, identifier = "eid", view = "FULL")
  return(res$abstract)
}

#' Wrapper to process abstracts for a dataframe of Scopus results
#'
#' @param df
#'
#' @returns
#'
#' @export
#' @examples abtracts  <- process_abstracts(test$df)
process_abstracts <- function(df) {
  df$abstract <- sapply(df$eid, get_scopus_abstract)
  return(df)
}

