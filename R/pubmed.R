#' Title
#'
#' @param query
#' @param retmax
#'
#' @returns
#'
#' @export
#' @examples test <- pubmed_search(query = config::get("query"), retmax = 1000)
pubmed_search <- function(query, retmax = 1000){
  # remove TITLE-ABS-KEY from query if present
  if (grepl("TITLE-ABS-KEY", query)) {
    query <- fix_query(query)
  }
  
  # search pubmed
  res <- rentrez::entrez_search(db = "pubmed", term = query, retmax = retmax)
  
  return(res)
}

#' Search PubMed records as XML text
#'
#' @param seacrch_res
#'
#' @returns
#'
#' @export
#' @examples records_xml_text <- get_records(test)
get_records <- function(search_res) {
  pmids <- search_res$ids
  records_xml_text <- rentrez::entrez_fetch(
    db = "pubmed",
    id = pmids,
    rettype = "xml",
    parsed = FALSE
  )
  return(records_xml_text)
}

#' Parse PubMed records from XML text to dataframe
#'
#' @param search_res
#'
#' @returns
#'
#' @export
#' @examples
#' Parse PubMed records from XML text
#'
#' @param records_xml_text XML text from get_records
#'
#' @returns A tibble with parsed PubMed data
#'
#' @export
#' @examples final_results <- parse_pubmed_records(records_xml_text)
parse_pubmed_records <- function(records_xml_text) {
  records_xml <- xml2::read_xml(records_xml_text)
  
  final_results_pubmed <- tibble::tibble(
    title = xml2::xml_find_all(records_xml, ".//PubmedArticle") %>%
      purrr::map_chr(~ xml_text_or_na(.x, ".//ArticleTitle")),
    
    authors = xml2::xml_find_all(records_xml, ".//PubmedArticle") %>%
      purrr::map_chr(~ {
        auths <- xml2::xml_find_all(.x, ".//Author/LastName")
        if (length(auths) == 0) NA_character_
        else paste(xml2::xml_text(auths), collapse = "; ")
      }),
    
    journal = xml2::xml_find_all(records_xml, ".//PubmedArticle") %>%
      purrr::map_chr(~ xml_text_or_na(.x, ".//Journal/Title")),
    
    year = xml2::xml_find_all(records_xml, ".//PubmedArticle") %>%
      purrr::map_chr(~ {
        y <- xml_text_or_na(.x, ".//PubDate/Year")
        if (is.na(y)) xml_text_or_na(.x, ".//PubDate/MedlineDate") else y
      }),
    
    doi = xml2::xml_find_all(records_xml, ".//PubmedArticle") %>%
      purrr::map_chr(~ xml_text_or_na(.x, ".//ArticleId[@IdType='doi']")),
    
    abstract = xml2::xml_find_all(records_xml, ".//PubmedArticle") %>%
      purrr::map_chr(~ xml_text_or_na(.x, ".//AbstractText"))
  )
  
  return(final_results_pubmed)
}

#' Helper function for XML text extraction with NA handling
#'
#' @param node
#' @param xpath
#'
#' @returns
#'
#' @export
#' @examples
xml_text_or_na <- function(node, xpath) {
  res <- xml2::xml_find_first(node, xpath)
  if (length(res) == 0 || xml2::xml_text(res) == "") NA_character_ else xml2::xml_text(res)
}


