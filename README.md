R interface to the Harmonized World Soil Database
=================================================

Forked from https://github.com/dlebauer/rhwsd/

This is a wrapper package containing the HWSD and helper functions

Code:

    Based on "Technical note: Processing the Harmonized World Soil Database (Version 1.2) in R" By D G Rossiter Dec 7, 2012 ([available online](http://www.itc.nl/~rossiter/teach/R/R_HWSD.pdf), with copy in the rwhsd package `man` folder).

Data:

    © 2008-2009 COPYRIGHT FAO, IIASA, ISRIC, ISSCAS, JRC 
    All rights reserved. No part of this Harmonized World Soil Database may be reproduced, stored in a retrieval system or transmitted by any means for resale or other commercial purposes without written permission of the copyright holders. Reproduction and dissemination of material in this information product for educational or other noncommercial purposes are authorized without any prior written permission from the copyright holders provided the source is fully acknowledged. Full acknowledgement and referencing of all sources must be included in any documentation using any of the material contained in the Harmonized World Soil Database, as follows:
    Citation FAO/IIASA/ISRIC/ISSCAS/JRC, 2009. Harmonized World Soil Database (version 1.1). FAO, Rome, Italy and IIASA, Laxenburg, Austria.
    


## How Data were imported:

1. Download [HWSD_RASTER.zip](http://webarchive.iiasa.ac.at/Research/LUC/External-World-soil-database/HWSD_Data/HWSD_RASTER.zip) from [HWSD](http://webarchive.iiasa.ac.at/Research/LUC/External-World-soil-database/HTML/HWSD_Data.html?sb=4) and extract.


```r
system("wget http://webarchive.iiasa.ac.at/Research/LUC/External-World-soil-database/HWSD_Data/HWSD_RASTER.zip")
require(raster)
hwsd <- raster("</path/to>/HWSD_RASTER/hwsd.bil")
proj4string(hwsd) <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
save(hwsd, file = "hwsd.RData")
```

## How to install

```r

library(devtools)

install_github("constantinoantunes/rhwsd")

```

## A quick example:


This example uses the get.hwsd.latlon function, which builds a box on the provided coordinates with a grid size of 0.1:

```r

library(hwsd)

con = get.hwsd.con("data/HWSD.sqlite3")
lat = 51.528308
lon = -0.3817805

get.hwsd.latlon(lat, lon, con=con, hwsd.bil="data/HWSD_RASTER/hwsd.bil")

```
