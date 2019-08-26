
## read open field data into data.frames and save as joint data.


################################################################
# FUNCTIONS
################################################################

### 
# return data.frame
##
get.data <- function( file, shift.x, shift.y, alpha )
{
	# get data from 'Windows Unicode' file
	head( df <- read.table( file, skip = 34, sep = ';', fileEncoding = 'UTF16LE' ) )
	df$V13 <- NULL

	# read header from 'Windows Unicode' file
	con <- file( file, encoding = "UCS-2LE" )
	header <- readLines( con, n = 34 )
	close( con )

	labels <- as.vector( strsplit( header[ 33 ], ';\"' ))[[1]]
	labels <- gsub( " ", "_", labels )
	labels <- gsub( '\"', '', labels )
	labels <- gsub( ';', '', labels )
	units <- as.vector( strsplit( header[ 34 ], ';\"' ))[[1]]
	units <- gsub( '\"', '', units )
	units <- gsub( ';', '', units )

	# set columnnames to label + unit
	colnames( df ) <- paste0( labels, "[", units, "]" )

	# remove unrequired data
	df$"Result_1[]" <- df$"In_zone[]" <- df$"In_zone_2[]" <- NULL

	# animal and time labels
	df$animal <- animal
	df$session <- session

	# get time in minutes
	max.time.min <- max( df$"Recording_time[s]" ) / 60

	# get starting time with 30 minutes of recording
	starttime30min <- max( df$"Recording_time[s]" ) - ( 30 * 60 )
	
	# report warning if time is < 30 min
	if( starttime30min > 0 ) { 
		df30min <- df[ df$"Recording_time[s]" >= starttime30min, ]
	} else {
		warning( "*** WARNING *** recording not 30 minutes!" )
		df30min <- df
	}	

	# rename labels
	colnames( df30min ) <- c( "Trial_time", "Recording_time", "x", "y", "Area", "Areachange", "Elongation", "Distance_moved", "Velocity", "animal", "session" )

	# remove unrequired columns
	df30min$Area <- NULL
	df30min$Areachange <- NULL
	df30min$Elongation <- NULL

	df30min[ df30min$Distance_moved == '-', 'Distance_moved' ] <- NA
	df30min[ df30min$Velocity == '-', 'Velocity' ] <- NA

	# set '-' to NA
	df30min[ df30min$x == '-', 'x' ] <- NA
	df30min[ df30min$y == '-', 'y' ] <- NA

	# convert to numeric
	df30min$x <- as.numeric( as.character( df30min$x ) )
	df30min$y <- as.numeric( as.character( df30min$y ) )

	# horizontal shift (in cm)
	df30min$x <- df30min$x + shift.x
	
    # vertical shift (in cm)
	df30min$y <- df30min$y + shift.y

	# rotate all points with alpha (rad)
	df30min <- rotate.x.y( df30min, alpha )

	# determine field for every set of x,y
	df30min$field <- mapply( get.field, df30min$x, df30min$y )
	
	return( df30min )
}

###
# Rotate all x,y around 0,0 given alpha angle in rad, because openfield table rotated a bit
##
rotate.x.y <- function( df, alpha )
{
	#rotation matrix
	rotmat <- matrix( c( cos( alpha ), sin( alpha ), -sin( alpha ), cos( alpha ) ), ncol = 2 )
 
	A <- matrix( c( df$x, df$y ), nrow = 2, byrow = TRUE )   
	admat <- rotmat %*% A                        
	df$x <- admat[ 1, ]
	df$y <- admat[ 2, ]

	return( df )
}

###
# Return field code (1 - 25), or NA if x or y is not specified.
##
get.field  <- function( x, y )
{
	if( !is.numeric( x ) & !is.na( x ) ){ stop( "*** ERROR ***: x is not numeric!" ) }
	if( !is.numeric( y ) & !is.na( y ) ){ stop( "*** ERROR ***: y is not numeric!" ) }

	# return NA if x or y is undefined
	if( is.na( x ) | is.na( y ) ){ return( NA ) }

	# col from left to right
	if( x >= -90 & x < -60 ) col.id <- 1 # 10 cm overlap
	if( x >= -60 & x < -20 ) col.id <- 2
	if( x >= -20 & x < 20 ) col.id <- 3
	if( x >= 20 & x < 60 ) col.id <- 4
	if( x >= 60 & x < 90 ) col.id <- 5 # 10 cm overlap

	# row from bottom to top
	if( y >= -90 & y < -60 ) row.id <- 1 # 10 cm overlap
	if( y >= -60 & y < -20 ) row.id <- 2
	if( y >= -20 & y < 20 ) row.id <- 3
	if( y >= 20 & y < 60 ) row.id <- 4
	if( y >= 60 & y < 90 ) row.id <- 5 # 10 cm overlap 

	# return field == NA if tracking is outside 10 cm around table area
	if( y >= 90 | y < -90 ){ return( NA ) }
 	if( x >= 90 | x < -90 ){ return( NA ) }

	# return field code
	if( col.id == 1 & row.id == 1 ){ return( 14 ) }
	if( col.id == 1 & row.id == 2 ){ return( 15 ) }
	if( col.id == 1 & row.id == 3 ){ return( 16 ) }
	if( col.id == 1 & row.id == 4 ){ return( 17 ) }
	if( col.id == 1 & row.id == 5 ){ return( 18 ) }	

	if( col.id == 2 & row.id == 1 ){ return( 13 ) }
	if( col.id == 2 & row.id == 2 ){ return( 4 ) }
	if( col.id == 2 & row.id == 3 ){ return( 5 ) }
	if( col.id == 2 & row.id == 4 ){ return( 6 ) }
	if( col.id == 2 & row.id == 5 ){ return( 19 ) }	

	if( col.id == 3 & row.id == 1 ){ return( 12 ) }
	if( col.id == 3 & row.id == 2 ){ return( 3 ) }
	if( col.id == 3 & row.id == 3 ){ return( 1 ) }
	if( col.id == 3 & row.id == 4 ){ return( 7 ) }
	if( col.id == 3 & row.id == 5 ){ return( 20 ) }	

	if( col.id == 4 & row.id == 1 ){ return( 11 ) }
	if( col.id == 4 & row.id == 2 ){ return( 2 ) }
	if( col.id == 4 & row.id == 3 ){ return( 9 ) }
	if( col.id == 4 & row.id == 4 ){ return( 8 ) }
	if( col.id == 4 & row.id == 5 ){ return( 21 ) }	

	if( col.id == 5 & row.id == 1 ){ return( 10 ) }
	if( col.id == 5 & row.id == 2 ){ return( 25 ) }
	if( col.id == 5 & row.id == 3 ){ return( 24 ) }
	if( col.id == 5 & row.id == 4 ){ return( 23 ) }
	if( col.id == 5 & row.id == 5 ){ return( 22 ) }	
}

################################################################
# END FUNCTIONS
################################################################


# datadir with Ethovision data stored as unicode files
datadir <- ''

# write to output
outdir <- ''

# create output directory
dir.create( outdir, showWarnings = FALSE )

# read meta-data
meta <- read.csv( 'meta.label.csv', row.names = 1 )


# init new column
meta$csvfile <- NA

for( i in 1:nrow( meta ) )
{
	file <- as.character( meta[ i, 'file' ] )
	animal <- meta[ i, 'animal' ]
	session <- meta[ i, 'session' ]
	task <- meta[ i, 'task' ]

	print( paste0( "Processing: ", animal, " - session: ", session ) )

	if( task == 'task1' )
	{
		shift.x <- 5 	# horizontal shift in cm
		shift.y <- 2 	# vertical shift in cm
		angle <- 0.0 	# radian rotation
	} else{ 
		shift.x <- 12 	# horizontal shift in cm
		shift.y <- 0 	# horizontal shift in cm
		angle <- -0.02 	# radian rotation
	}

	# get data
	df <- get.data( file, shift.x, shift.y, angle )

	# output file
	outfile <- paste0( outdir, '/animal-', animal, '__session-', session, '.csv.gz' )
	write.csv( df, gzfile( outfile ) )

	# store outfile path in meta
	meta[ i, 'csvfile' ] <- outfile

}

# write
write.csv( file = 'meta.label.with.data.csv', meta )

