##' function to find a UTM zone
##' \url{UTMzone}{http://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system#UTM_zone}
##' @title long2UTM 
##' @param long longitude
##' @return UTM Zone (integer)
##' @export
##' @author D G Rossiter
long2UTM <- function(long) {
  utmzone <- (floor((long + 180)/6) + 1)%%60 #floor(long + 180)/6) + 1) %% 60
  return(utmzone)
}

##' function to create a box
##'
##' distinct (and simpler) from \code{rgeos::get.box}
##' @title get box 
##' @param lat latitude
##' @param lon longitude
##' @param gridsize area around the point (size of Dx and Dy)
##' @return abox is a vecotr of xmin, xmax, ymin, ymax
##' @export
##' @author David LeBauer
get.box <- function(lat, lon, gridsize = 0.1){
  tmp <- c(lat, lat, lon, lon) + gridsize/2*c(-1,1,-1,1)# * c(sign(lati)*c(-1, 1), sign(loni)*c(-1, 1))
  abox <- extent(tmp)
  return(abox)
}

##' Function to extract and format one rectangular window
##'
##' @title extract hwsd data from a region
##' @param abox a raster-style extent argument, i.e., a vector of xmin, xmax, ymin, ymax
##' @return records queried from region
##' @author D G Rossiter, David LeBauer
##' @export
##' @examples
##' \dontrun{
##' lat <- 44; lon <- -80; gridsize <- 0.1
##' abox <- c(lon, lon, lat, lat) + gridsize/2 * c(-1, 1, -1, 1)
##' get.hwsd.box(abox, con = con, hwsd.bil = "./hwsd.bil")
##' }
get.hwsd.box <- function(abox, con = con, hwsd.bil = NULL) {
  hwsd <- get.hwsd.raster(hwsd.bil)
  
  if(is.null(names(abox))) {
    names(abox) <- c("lon", "lon", "lat", "lat")
  }
  hwsd.win <- crop(hwsd, extent(abox))

  ## extract attributes for just this window
  dbWriteTable(con, name = "WINDOW_TMP", 
               value = data.frame(smu_id = raster::unique(hwsd.win)),overwrite = TRUE)
  result <- dbGetQuery(con, "select T.* from HWSD_DATA as T join
                        WINDOW_TMP as U on T.mu_global=u.smu_id order by su_sym90")
  dbRemoveTable(con, "WINDOW_TMP")
 
  return(result)
  
}

##' Function to extract and format one rectangular window
##'
##' @title extract hwsd data from a region defined by a box
##' @param lat  degrees latitude
##' @param lon degrees longitude
##' @param gridsize size of bounding box in degrees 
##' @param con database connection
##' @param hwsd.bil raster file path
##' @return records queried from region
##' @author D G Rossiter, David LeBauer
##' @export
##' @examples
##' \dontrun{
##' get.hwsd.latlon(lat = 44, lon = -80, gridsize = 0.1, con = con, hwsd.bil = "./hwsd.bil")
##' }
get.hwsd.latlon <- function(lat, lon, gridsize = 0.1, con=con, hwsd.bil=hwsd.bil){
  abox <- c(lon, lon, lat, lat) + gridsize/2 * c(-1, 1, -1, 1)
  result <- get.hwsd.box(abox, con = con, hwsd.bil = hwsd.bil)
  return(result)
}

##' Function to extract and format one rectangular window
##'
##' convenience wrapper for get.hwsd.latlon and get.hwsd.box
##' @title extract hwsd data from a region
##' @param abox (optional) 
##' @param lat (optional)
##' @param lon (optional)
##' @return records queried from region
##' @author D G Rossiter, David LeBauer
##' @export
##' @examples
##' \dontrun{
##' lat <- 44; lon <- -80; gridsize <- 0.1
##' abox<-c(lon, lon, lat, lat) + gridsize/2 * c(-1, 1, -1, 1)
##' extract.one(abox)
##' }
get.hwsd <- function(...){
  ## http://stackoverflow.com/a/19259158/199217
  .args <- as.list(match.call())[-1]
  print(names(.args))
  if("abox" %in% names(.args)){
    hwsd.fn <- "get.hwsd.box"
  } else if (all(c("lat", "lon") %in% names(.args))) {
    hwsd.fn <- "get.hwsd.latlon"
  }
  print(hwsd.fn)
  result <- do.call(hwsd.fn, .args)
  return(result)
}


##' Function to create connection to HWSD.sqlite database
##'
##' copies database so that any changes are not saved in package 
##' @title get HWSD connection
##' @return connection to HWSD.sqlite database
##' @author David LeBauer
##' @export
get.hwsd.con <- function(hwsd.sqlite = NULL){
  if (is.null(hwsd.sqlite)) {
    hwsd.sqlite <- system.file("extdata/HWSD.sqlite", package = "rhwsd")
  }
  if(hwsd.sqlite == "") {
    hwsd.sqlite <- system.file("inst/extdata/HWSD.sqlite", package = "rhwsd")  
  }
  file.copy(hwsd.sqlite, tempdir())
  db <- file.path(tempdir(), "HWSD.sqlite")
  con <<- dbConnect(dbDriver("SQLite"), dbname = hwsd.sqlite)
  return(con)
}

##' Function to create connection to HWSD.sqlite database
##'
##' copies database so that any changes are not saved in package 
##' @title get HWSD con
##' @param hwsd.bil (optional) location of file hwsd.bil. Too big for package repository. If necessary, this can be downloaded 
##' @param download (optional) boolean field indicating whether the database should be downloaded
##' @param download.url (optional) string field indicating from where the database should be downloaded
##' \url{here}{http://webarchive.iiasa.ac.at/Research/LUC/External-World-soil-database/HWSD_Data/HWSD_RASTER.zip}
##' @export
##' @return hwsd a RasterLayer object with WGS84 projection
get.hwsd.raster <- function(hwsd.bil = NULL, download = FALSE, download.url = NULL){
  if(is.null(hwsd.bil)){
    hwsd.bil <- system.file("extdata/hwsd.bil", package = "rhwsd")
  }
  if(!file.exists(hwsd.bil)){
    if(download){
      if (is.null(download.url)) {
        download.url = "http://file-server.igb.illinois.edu/~dlebauer/hwsd/hwsd.zip"
      }
      download.file(url = download.url, destfile = tempfile())
      data.dir <- system.file("extdata", package = "rhwsd")
      unzip(tempfile(), exdir = data.dir)
    } else {
      print("hwsd.is not available. It can be downloaded by setting the 'download = TRUE'\n")
      print("i.e.: get.hwsd.raster(download=TRUE)")
      print("if you already have the file, set hwsd.bil = '/path/to/hwsd.bil'")
    }
  }
  hwsd <- raster(hwsd.bil)
  proj4string(hwsd) <-  "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
  return(hwsd)
}