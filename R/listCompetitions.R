#' Return Competitions data
#'
#' \code{listCompetitions} simply lists all competitions associated with the
#' selected parameters (e.g. soccer competitions with markets closing in the
#' next 24 hours). This data is useful for finding specific event identifiers
#' (e.g. EPL = 31, Champions League = 228), which are then usually passed to
#' further functions. By default, \code{listCompetitions} returns are limited to
#' the forthcoming 24-hour period. However, this can be changed by user
#' specified date/time stamps.
#'
#' @seealso \code{\link{loginBF}}, which must be executed first.
#'
#' @param eventTypeIds vector <String>. Restrict competitions by event type
#'   associated with the market. (e.g., Football = 1, Horse Racing = 7, etc).
#'   Accepts multiple IDs (See examples). IDs can be obtained via
#'   \code{\link{listEventTypes}}. Required. No default.
#'
#' @param marketTypeCodes vector <String>. Restrict to competitions that match
#'   the type of the market (i.e. MATCH_ODDS, HALF_TIME_SCORE). You should use
#'   this instead of relying on the market name as the market type codes are the
#'   same in all locales. Accepts multiple market type codes (See examples).
#'   Market type codes can be obtained via \code{\link{listMarketTypes}}.
#'   Optional. Default is NULL.
#'
#' @param fromDate The start date from which to return matching competitions.
#'   Format is \%Y-\%m-\%dT\%TZ. Optional. If not defined, it defaults to
#'   current system date and time minus 2 hours (to allow searching of all
#'   in-play football matches).
#'
#' @param toDate The end date to stop returning matching competitions. Format is
#'   \%Y-\%m-\%dT\%TZ. Optional. If not defined defaults to the current system
#'   date and time plus 24 hours.
#'
#' @param eventIds vector <String>. Restrict to competitions that are associated
#'   with the specified eventIDs (e.g. "27675602"). Optional. Default is NULL.
#'
#' @param competitionIds vector <String>. Restrict to competitions that are
#'   associated with the specified competition IDs (e.g. EPL = "31", La Liga =
#'   "117"). Competition IDs can obtained via \code{\link{listCompetitions}}.
#'   Optional. Default is NULL.
#'
#' @param marketIds vector <String>. Restrict to competitions that are
#'   associated with the specified marketIDs (e.g. "1.122958246"). Optional.
#'   Default is NULL.
#'
#' @param marketCountries vector <String>. Restrict to competitions that are in
#'   the specified country or countries. Accepts multiple country codes. Codes
#'   can be obtained via \code{\link{listCountries}}. Optional. Default is NULL.
#'
#' @param venues vector <String>. Restrict competitions by the venue associated
#'   with the market. This functionality is currently only available for horse
#'   racing markets (e.g.venues=c("Exeter","Navan")).  Codes can be obtained
#'   via \code{\link{listVenues}}. Optional. Default is NULL.
#'
#' @param bspOnly Boolean. Restrict to betfair staring price (bsp) competitions
#'   only if TRUE or non-bsp events if FALSE. Optional. Default is NULL, which
#'   means that both bsp and non-bsp competitions are returned.
#'
#' @param turnInPlayEnabled Boolean. Restrict to competitions that will turn in
#'   play if TRUE or will not turn in play if FALSE. Optional. Default is NULL,
#'   which means that both competitions are returned.
#'
#' @param inPlayOnly Boolean. Restrict to competitions that are currently in
#'   play if TRUE or not inplay if FALSE. Optional. Default is NULL, which means
#'   that both inplay and non-inplay competitions are returned.
#'
#' @param marketBettingTypes vector <String>. Restrict to competitions that
#'   match the betting type of the market (i.e. Odds, Asian Handicap Singles, or
#'   Asian Handicap Doubles). Optional. Default is NULL. See
#'   \url{https://api.developer.betfair.com/services/webapps/docs/display/1smk3cen4v3lu3yomq5qye0ni/Betting+Enums#BettingEnums-MarketBettingType}
#'    for a full list (and description) of viable parameter values.
#'
#' @param withOrders String. Restrict to competitions in which the user has bets
#'   of a specified status. The two viable values are "EXECUTION_COMPLETE" (an
#'   order that does not have any remaining unmatched portion) and "EXECUTABLE"
#'   (an order that has a remaining unmatched portion). Optional. Default is
#'   NULL.
#'
#' @param textQuery String. Restrict competitions by any text associated with
#'   the event type, such as the Name, Event, Competition, etc. The string can
#'   include a wildcard (*) character as long as it is not the first character.
#'   Optional. Default is NULL.
#'
#' @param suppress Boolean. By default, this parameter is set to FALSE, meaning
#'   that a warning is posted when the listCompetitions call throws an error.
#'   Changing this parameter to TRUE will suppress this warning.
#'
#' @param sslVerify Boolean. This argument defaults to TRUE and is optional. In
#'   some cases, where users have a self signed SSL Certificate, for example
#'   they may be behind a proxy server, Betfair will fail login with "SSL
#'   certificate problem: self signed certificate in certificate chain". If this
#'   error occurs you may set sslVerify to FALSE. This does open a small
#'   security risk of a man-in-the-middle intercepting your login credentials.
#'
#' @return Response from Betfair is stored in the listCompetitions variable,
#'   which is then parsed from JSON as a list. Only the first item of this list
#'   contains the required event type identification details. If the
#'   listCompetitions call throws an error, a data frame containing error
#'   information is returned.
#'
#' @section Note on \code{listCompetitionsOps} variable: The
#'   \code{listCompetitionsOps} variable is used to firstly build an R data
#'   frame containing all the data to be passed to Betfair, in order for the
#'   function to execute successfully. The data frame is then converted to JSON
#'   and included in the HTTP POST request.
#'
#' @examples
#' \dontrun{
#' # Return all football and tennis competitions (and number of
#' corresponding markets) for the upcoming day.
#' listCompetitions(eventTypeIds = c("1","2"))
#'
#' # Return competitions that currently have at least one football market inplay.
#' listCompetitions(eventTypeIds = c("1"),inPlayOnly=TRUE)
#'
#' # Return upcoming competitions that allow Betfair starting prices (BSPs) on
#' specific football markets.
#' listCompetitions(eventTypeIds = c("1"),bspOnly=TRUE)
#' }
#'

listCompetitions <-
  function(eventTypeIds , marketTypeCodes=NULL,
           fromDate = (format(Sys.time() -7200, "%Y-%m-%dT%TZ")),
           toDate = (format(Sys.time() + 86400, "%Y-%m-%dT%TZ")),
           eventIds = NULL, competitionIds = NULL, marketIds =NULL,
           marketCountries = NULL, venues = NULL, bspOnly = NULL,
           turnInPlayEnabled = NULL, inPlayOnly = NULL, marketBettingTypes = NULL,
           withOrders = NULL, textQuery = NULL, suppress = FALSE, sslVerify = TRUE) {
    options(stringsAsFactors = FALSE)

    listCompetitionsOps <-
      data.frame(jsonrpc = "2.0", method = "SportsAPING/v1.0/listCompetitions", id = "1")

    listCompetitionsOps$params <-
      data.frame(filter = c(""))
    listCompetitionsOps$params$filter <-
      data.frame(marketStartTime = c(""))

    if (!is.null(eventIds)) {
      listCompetitionsOps$params$filter$eventIds <- list(eventIds)
    }

    if (!is.null(eventTypeIds)) {
      listCompetitionsOps$params$filter$eventTypeIds <-
        list(eventTypeIds)
    }

    if (!is.null(competitionIds)) {
      listCompetitionsOps$params$filter$competitionIds <-
        list(competitionIds)
    }

    if (!is.null(marketIds)) {
      listCompetitionsOps$params$filter$marketIds <- list(marketIds)
    }

    if (!is.null(venues)) {
      listCompetitionsOps$params$filter$venues <- list(venues)
    }

    if (!is.null(marketCountries)) {
      listCompetitionsOps$params$filter$marketCountries <-
        list(marketCountries)
    }

    if (!is.null(marketTypeCodes)) {
      listCompetitionsOps$params$filter$marketTypeCodes <-
        list(marketTypeCodes)
    }

    listCompetitionsOps$params$filter$bspOnly <- bspOnly
    listCompetitionsOps$params$filter$turnInPlayEnabled <-
      turnInPlayEnabled
    listCompetitionsOps$params$filter$inPlayOnly <- inPlayOnly
    listCompetitionsOps$params$filter$textQuery <- textQuery

    if (!is.null(marketBettingTypes)) {
      listCompetitionsOps$params$filter$marketBettingTypes <-
        list(marketBettingTypes)
    }

    if (!is.null(withOrders)) {
      listCompetitionsOps$params$filter$withOrders <- list(withOrders)
    }

    listCompetitionsOps$params$filter$marketStartTime <-
      data.frame(from = fromDate, to = toDate)


    listCompetitionsOps <-
      listCompetitionsOps[c("jsonrpc", "method", "params", "id")]

    listCompetitionsOps <-
      jsonlite::toJSON(listCompetitionsOps, pretty = TRUE)

    # Read Environment variables for authorisation details
    product <- Sys.getenv('product')
    token <- Sys.getenv('token')


    listCompetitions <-
      as.list(
        jsonlite::fromJSON(
          httr::content(
            httr::POST(
              url = "https://api.betfair.com/exchange/betting/json-rpc/v1",
              config = httr::config(
                ssl_verifypeer = sslVerify
              ),
              body = listCompetitionsOps,
              httr::add_headers(
                Accept = "application/json",
                `X-Application` = product,
                `X-Authentication` = token)
            ),
            as = "text",
            encoding = "UTF-8"
          )
        )
      )


    if(is.null(listCompetitions$error))
      as.data.frame(listCompetitions$result[1])
    else({
      if(!suppress)
        warning("Error- See output for details")
      as.data.frame(listCompetitions$error)})
  }
