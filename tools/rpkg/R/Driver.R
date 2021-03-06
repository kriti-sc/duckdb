DBDIR_MEMORY <- ":memory:"

#' @title DuckDB Driver
#'
#' @description A DuckDB database instance. 
#'
#' @param dbdir The file in which the DuckDB database should be stored
#' @param read_only Whether the database file should be opened in read-only mode
#'
#' @name duckdb_driver
#' @import methods DBI
#' @export
#' @examples
#' \dontrun{
#' #' library(DBI)
#' duckdb::duckdb()
#' }
#'
duckdb <- function(dbdir = DBDIR_MEMORY, read_only = FALSE) {
  check_flag(read_only)
  new(
    "duckdb_driver",
    database_ref = .Call(duckdb_startup_R, dbdir, read_only),
    dbdir = dbdir,
    read_only = read_only
  )
}

check_flag <- function(x) {
  if (is.null(x) || length(x) != 1 || is.na(x) || !is.logical(x)) {
    stop("flags need to be scalar logicals")
  }
}

#' @rdname duckdb_driver
#' @export
setClass("duckdb_driver", contains = "DBIDriver", slots = list(database_ref = "externalptr", dbdir = "character", read_only = "logical"))

extptr_str <- function(e, n = 5) {
  x <- .Call(duckdb_ptr_to_str, e)
  substr(x, nchar(x) - n + 1, nchar(x))
}

drv_to_string <- function(drv) {
  if (!is(drv, "duckdb_driver")) {
    stop("pass a duckdb_driver object")
  }
  sprintf("<duckdb_driver %s dbdir='%s' read_only=%s>", extptr_str(drv@database_ref), drv@dbdir, drv@read_only)
}

#' @rdname duckdb_driver
#' @inheritParams methods::show
#' @export
setMethod(
  "show", "duckdb_driver",
  function(object) {
    cat(drv_to_string(object))
    cat("\n")
  }
)

#' @rdname duckdb_driver
#' @inheritParams DBI::dbConnect
#' @param debug Print additional debug information such as queries
#' @export
setMethod(
  "dbConnect", "duckdb_driver",
  function(drv, dbdir = DBDIR_MEMORY, ..., debug = getOption("duckdb.debug", FALSE), read_only = FALSE) {

    check_flag(debug)

    missing_dbdir <- missing(dbdir)
    dbdir <- path.expand(as.character(dbdir))


    # aha, a late comer. let's make a new instance.
    if (!missing_dbdir && dbdir != drv@dbdir) {
      duckdb_shutdown(drv)
      drv <- duckdb(dbdir, read_only)
    }

    duckdb_connection(drv, debug = debug)
  }
)

#' @rdname duckdb_driver
#' @inheritParams DBI::dbDataType
#' @export
setMethod(
  "dbDataType", "duckdb_driver",
  function(dbObj, obj, ...) {

    if (is.null(obj)) stop("NULL parameter")
    if (is.data.frame(obj)) {
      return(vapply(obj, function(x) dbDataType(dbObj, x), FUN.VALUE = "character"))
    }
    #  else if (int64 && inherits(obj, "integer64")) "BIGINT"
    else if (inherits(obj, "Date")) {
      "DATE"
    } else if (inherits(obj, "difftime")) {
      "TIME"
    } else if (is.logical(obj)) {
      "BOOLEAN"
    } else if (is.integer(obj)) {
      "INTEGER"
    } else if (is.numeric(obj)) {
      "DOUBLE"
    } else if (inherits(obj, "POSIXt")) {
      "TIMESTAMP"
    } else if (is.list(obj) && all(vapply(obj, typeof, FUN.VALUE = "character") == "raw" || is.na(obj))) {
      "BLOB"
    } else {
      "STRING"
    }

  }
)

#' @rdname duckdb_driver
#' @inheritParams DBI::dbIsValid
#' @export
setMethod(
  "dbIsValid", "duckdb_driver",
  function(dbObj, ...) {
    valid <- FALSE
    tryCatch(
      {
        con <- dbConnect(dbObj)
        dbExecute(con, SQL("SELECT 1"))
        dbDisconnect(con)
        valid <- TRUE
      },
      error = function(c) {
      }
    )
    valid
  }
)

#' @rdname duckdb_driver
#' @inheritParams DBI::dbGetInfo
#' @export
setMethod(
  "dbGetInfo", "duckdb_driver",
  function(dbObj, ...) {
    list(driver.version = NA, client.version = NA)
  }
)


#' @rdname duckdb_driver
#' @export
duckdb_shutdown <- function(drv) {
  if (!is(drv, "duckdb_driver")) {
    stop("pass a duckdb_driver object")
  }
  if (!dbIsValid(drv)) {
    warning("invalid driver object, already closed?")
    invisible(FALSE)
  }
  .Call(duckdb_shutdown_R, drv@database_ref)
  invisible(TRUE)
}

is_installed <- function(pkg) {
  as.logical(requireNamespace(pkg, quietly = TRUE)) == TRUE
}


#' @importFrom DBI dbConnect
#' @importFrom dbplyr src_dbi
#' @param path The file in which the DuckDB database should be stored
#' @param create Create a new database if none is present in `path`
#' @rdname duckdb_driver
#' @export
src_duckdb <- function(path = ":memory:", create = FALSE, read_only = FALSE) {
  if (!is_installed("dbplyr")) {
    stop("Need package `dbplyr` installed.")
  }
  if (path != ":memory:" && !create && !file.exists(path)) {
    stop("`path` '", path, "' must already exist, unless `create` = TRUE")
  }
  con <- DBI::dbConnect(duckdb::duckdb(), path, read_only = read_only)
  dbplyr::src_dbi(con, auto_disconnect = TRUE)
}
