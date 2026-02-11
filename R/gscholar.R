box::use(./helpers)

#' Title
#'
#' @returns
#'
#' @export
#' @examples test <- build_gscholar_query(config::get("query"))
build_gscholar_query <- function(query) {
# remove TITLE-ABS-KEY from query if present
    if (grepl("TITLE-ABS-KEY", query)) {
      query <- helpers$fix_query(query, search = "gscholar")
    }
    
     # Encode query for URL
    search_url <- "https://scholar.google.com/scholar"
  

  return(list(search_url = search_url, query = query))

}

#' Get total number of pubs for a query on Google Scholar
#'
#' @param scholar_page
#'
#' @returns
#'
#' @export
#' @examples test <- num_results(config::get("query"))
num_results <- function(query) {
  query_encoded <- URLencode(query)
  search_url <- paste0("https://scholar.google.com/scholar?q=", query_encoded)
  scholar_page <- rvest::read_html(search_url)
  num_results <- scholar_page |> 
    rvest::html_nodes(".gs_ab_mdw") |> 
    rvest::html_text()
  
  # Extract number of results
  numpubs <- stringr::str_extract(num_results[[2]], "\\d{1,3}(,\\d{3})*")
  numpubs <- as.numeric(gsub(",", "", numpubs))  
  
  return(numpubs)
}

#' Fetch a Google Scholar page
#'
#' @param gs_url The URL to fetch
#' @returns A list with wbpage and response_delay
#' 
#' 
#' @export
#' @examples
fetch_gscholar_page <- function(gs_url) {
  t0 <- Sys.time()
  session <- rvest::session(gs_url)
  t1 <- Sys.time()
  response_delay <- as.numeric(t1 - t0)
  wbpage <- rvest::read_html(session)
  return(list(wbpage = wbpage, response_delay = response_delay))
}

#' Extract data from a Google Scholar page
#'
#' @param wbpage The HTML page
#' @returns A list of extracted data
#' 
#' 
#' @export
#' @examples
extract_gscholar_data <- function(wbpage) {
  # Raw data
  titles <- rvest::html_text(rvest::html_elements(wbpage, ".gs_rt"))
  authors_years <- rvest::html_text(rvest::html_elements(wbpage, ".gs_a"))
  part_abstracts <- rvest::html_text(rvest::html_elements(wbpage, ".gs_rs"))
  bottom_row_nodes <- rvest::html_elements(wbpage, ".gs_fl")
  bottom_row_nodes <- bottom_row_nodes[!grepl("gs_ggs gs_fl", as.character(bottom_row_nodes), fixed = TRUE)]
  bottom_row <- rvest::html_text(bottom_row_nodes)
  
  # Processed data
  authors <- gsub("^(.*?)\\W+-\\W+.*", "\\1", authors_years, perl = TRUE)
  years <- gsub("^.*(\\d{4}).*", "\\1", authors_years, perl = TRUE)
  citations <- strsplit(gsub("(?!^)(?=[[:upper:]])", " ", bottom_row, perl = TRUE), "  ")
  citations <- lapply(citations, "[", 3)
  n_citations <- suppressWarnings(as.numeric(sub("\\D*(\\d+).*", "\\1", citations)))
  
  list(
    title = titles,
    authors = authors,
    year = years,
    n_citations = n_citations,
    abstract = part_abstracts
  )
}

#' Search Google Scholar for a query and return results as a data frame.
#'
#' @param query The search query
#' @param pages Vector of page numbers to fetch (e.g., 1:10)
#' @param crawl_delay Delay between requests (default 1 second)
#' @returns Data frame of results
#' 
#' @export gscholar_search
#' @examples test <- gscholar_search(config::get("query"), pages = 1:2)
gscholar_search <- function(query, pages, crawl_delay = 1) {
  # build google scholar query
  query_obs <- build_gscholar_query(query)
  
  result_list <- list()
  i <- 1
  
  for (n_page in (pages - 1) * 10) {  # gs page indexing starts with 0; 10 articles per page
    gs_url <- paste0(query_obs$search_url, "?start=", n_page, "&q=", noquote(gsub("\\s+", "+", trimws(query_obs$query))))
    
    # Fetch page
    page_data <- fetch_gscholar_page(gs_url)
    wbpage <- page_data$wbpage
    response_delay <- page_data$response_delay
    
    # Sleep to avoid rate limits
    Sys.sleep(crawl_delay + 3 * response_delay + runif(1, 0.5, 1))
    if (i %% 10 == 0) {
      message("Taking a break")
      Sys.sleep(10 + 10 * response_delay + runif(1, 0, 1))
    }
    i <- i + 1
    
    # Extract data
    data <- extract_gscholar_data(wbpage)
    
    # Store in list
    result_list <- append(
      result_list,
      list(
        list(
          page = n_page / 10 + 1,
          term = query_obs$query,
          title = data$title,
          authors = data$authors,
          year = data$year,
          n_citations = data$n_citations,
          abstract = data$abstract
        )
      )
    )
  }
  
  # Return as data frame
  if (length(result_list) == 0) return(data.frame())
  result_df <- lapply(result_list, as.data.frame)
  result_df <- do.call(rbind, result_df)
  result_df
}



