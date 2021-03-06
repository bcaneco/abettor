#' Return market profit and loss
#'
#' \code{listMarketPandL} Retrieve profit and loss for a given list of OPEN
#' markets. The values are calculated using matched bets and optionally settled
#' bets
#'
#' @seealso \code{\link{loginBF}}, which must be executed first. Do NOT use the
#'   DELAY application key. The DELAY application key does not support price
#'   data.
#'
#' @seealso \code{\link{listClearedOrders}} to retrieve your profit and loss for
#'   CLOSED markets
#'
#'   Note that \code{listMarketPandL} does not include any information about the
#'   value of your bets on the markets e.g. value of profit/loss if you were to
#'   cashout at current prices. It simply returns the money you'd win/lose if
#'   specific selections were to win. If you wish to calculate your cashout
#'   position, then we'll need to design a new function combining
#'   \code{listCurrentOrders} and \code{listMarketBook} (it's on the to-do
#'   list).
#'
#' @param marketIds Vector<String>. A set of market ID strings from which the
#'   corresponding market profit and losses will be returned. Required.
#'   No default.
#'
#' @param includeSettledBetsValue Boolean. Option to include settled bets
#'   (partially settled markets only). This parameter defaults to NULL, which
#'   Betfair interprets as false. Optional.
#'
#' @param includeBspBetsValue Boolean. Option to include Betfair Starting Price
#'   (BSP) bets. This parameter defaults to NULL, which Betfair interprets as
#'   FALSE. Optional.
#'
#' @param netOfCommissionValue Boolean. Option to return profit and loss net of
#'   user's current commission rate for this market, including any special
#'   tariffs. This parameter defaults to NULL, which Betfair interprets as
#'   FALSE. Optional.
#'
#' @param sslVerify Boolean. This argument defaults to TRUE and is optional. In
#'   some cases, where users have a self signed SSL Certificate, for example
#'   they may be behind a proxy server, Betfair will fail login with "SSL
#'   certificate problem: self signed certificate in certificate chain". If this
#'   error occurs you may set sslVerify to FALSE. This does open a small
#'   security risk of a man-in-the-middle intercepting your login credentials.
#'
#'@param suppress Boolean. By default, this parameter is set to FALSE, meaning
#'   that a warning is posted when the listMarketPandL call throws an error.
#'   Changing this parameter to TRUE will suppress this warning.
#'
#' @return Response from Betfair is stored in listPandL variable, which is then
#'   parsed from JSON as a data frame of at least two varialbes (more if the
#'   optional parameters are included). The first column records the market IDs,
#'   while the corresponding market P&Ls are stored within a list.
#'
#' @section Note on \code{listPandLOps} variable: The
#'   \code{listPandLOps} variable is used to firstly build an R data frame
#'   containing all the data to be passed to Betfair, in order for the function
#'   to execute successfully. The data frame is then converted to JSON and
#'   included in the HTTP POST request. If the listMarketPandL call throws an
#'   error, a data frame containing error information is returned.
#'
#' @examples
#' \dontrun{
#' Return the P&L (net of comission) for the requested markets. The actual
#' market IDs are unlikely to work and are just for demonstration purposes.
#'
#' listMarketPandL(marketIds = c("1.122323121","1.123859413"),
#'                netOfCommission = TRUE)
#' }
#'


listMarketPandL <-
  function(marketIds, includeSettledBetsValue = NULL,includeBspBetsValue = NULL,
           netOfCommissionValue = NULL, suppress = FALSE, sslVerify = TRUE) {
    options(stringsAsFactors = FALSE)

    listPandLOps <-
      data.frame(jsonrpc = "2.0", method = "SportsAPING/v1.0/listMarketProfitAndLoss", id = "1")

    listPandLOps$params <- data.frame(marketIds = c(marketIds))
    listPandLOps$params$marketIds <- list(listPandLOps$params$marketIds)

    listPandLOps$params$includeSettledBets <- includeSettledBetsValue
    listPandLOps$params$includeBspBets <- includeBspBetsValue
    listPandLOps$params$netOfCommission <- netOfCommissionValue

    listPandLOps <- listPandLOps[c("jsonrpc", "method", "params", "id")]

    listPandLOps <- jsonlite::toJSON(jsonlite::unbox(listPandLOps), pretty = TRUE)

    # Read Environment variables for authorisation details
    product <- Sys.getenv('product')
    token <- Sys.getenv('token')

    listPandL <-
      jsonlite::fromJSON(
        httr::content(
          httr::POST(
            url = "https://api.betfair.com/exchange/betting/json-rpc/v1",
            config = httr::config(ssl_verifypeer = sslVerify),
            body = listPandLOps,
            httr::add_headers(
              Accept = "application/json",
              `X-Application` = product,
              `X-Authentication` = token)
          ),
          as = "text",
          encoding = "UTF-8"
        )
      )


    if(is.null(listPandL$error))
      as.data.frame(listPandL$result)
    else({
      if(!suppress)
        warning("Error- See output for details")
      as.data.frame(listPandL$error)})
  }
