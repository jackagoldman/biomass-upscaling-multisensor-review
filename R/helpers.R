#' Fix queries from other formats (e.g. Scopus) to be compatible with PubMed
#'
#' @param query
#'
#' @returns
#'
#' @export
#' @examples query <- fix_query(config::get("query"))
fix_query <- function(query){
  # remove TITLE-ABS-KEY from query
  query <- gsub("TITLE-ABS-KEY", "", query)
  
  # add [TIAB] to restrict to title/abstract
  #query <- gsub('"([^"]*)"', '"\\1"[TIAB]', query)
  query <- paste0("(", query, ")")
  return(query)
}


