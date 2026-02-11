#' Fix queries from other formats (e.g. Scopus) to be compatible with PubMed
#'
#' @param query
#'
#' @returns
#'
#' @export
#' @examples query <- fix_query(config::get("query"))
fix_query <- function(query, search = "pubmed"){
  # remove TITLE-ABS-KEY from query
  query <- gsub("TITLE-ABS-KEY", "", query)
  if (search == "pubmed") {
     # add parentheses around query
  query <- paste0("(", query, ")")
  } else if (search == "gscholar") { 
   #remove AND from query
    query <- gsub("AND", "", query)
  }
 
  return(query)
}


