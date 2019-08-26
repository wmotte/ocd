
## extract meta-information from Ethovision data.


################################################################
# FUNCTIONS
################################################################

###
# get files
##
get.files <- function( datadir )
{
	files <- dir( datadir )

	# get useful files
	files <- files[ grep( ".txt", files ) ]
	files <- files[ grep( "Arena", files ) ]
	files <- paste0( datadir, '/', files )

	return( files )
}

### 
# return data.frame
##
get.data <- function( file )
{
	# get data
	head( df <- read.table( file, skip = 34, sep = ';', fileEncoding = 'UTF16LE' ) ) #
	df$V13 <- NULL

	# read a 'Windows Unicode' file
	con <- file( file, encoding = "UCS-2LE" )
	header <- readLines( con, n = 34 )
	close( con )

	# get group and time data
	t <- as.vector( strsplit( header[ 19 ], ';\"' ))[[ 1 ]][ 2 ]
	t <- strsplit( strsplit( t, '\\\\t' )[[ 1 ]][ 2 ], '.wmv' )[[ 1 ]][ 1 ]
	t <- substr(t,1,6)

	# get animal and session
	animal <- strsplit( t, '_' )[[ 1 ]][ 1 ]
	session <- strsplit( t, '_' )[[ 1 ]][ 2 ]

	labels <- as.vector( strsplit( header[ 33 ], ';\"' ))[[1]]
	labels <- gsub( " ", "_", labels )
	labels <- gsub( '\"', '', labels )
	labels <- gsub( ';', '', labels )
	units <- as.vector( strsplit( header[ 34 ], ';\"' ))[[1]]
	units <- gsub( '\"', '', units )
	units <- gsub( ';', '', units )

	# get missed samples percentage from Ethovision
	missed.samples <- as.vector( strsplit( header[ 29 ], 'samples\"' ) )[[1]][2]
	missed.samples <- gsub( '\"', '', missed.samples )
	missed.samples <- gsub( ';', '', missed.samples )
	missed.samples <- gsub( ' ', '', missed.samples )
	missed.samples <- gsub( '%', '', missed.samples )

	# not found percentage from Ethovision
	not.found <- as.vector( strsplit( header[ 30 ], 'found\"' ) )[[1]][2]
	not.found <- gsub( '\"', '', not.found )
	not.found <- gsub( ';', '', not.found )
	not.found <- gsub( ' ', '', not.found )
	not.found <- gsub( '%', '', not.found )

	# not found percentage from Ethovision
	rawfile <- as.vector( strsplit( header[ 19 ], 'file\"' ) )[[1]][2]
	rawfile <- gsub( '\"', '', rawfile )
	rawfile <- gsub( ';', '', rawfile )
	rawfile <- gsub( ' ', '', rawfile )

	# set columnnames to label + unit
	colnames( df ) <- paste0( labels, "[", units, "]" )

	# remove unrequired data
	df$"Result_1[]" <- df$"In_zone[]" <- df$"In_zone_2[]"<- NULL

	# animal and time labels
	df$animal <- animal
	df$session <- session

	# get time in minutes
	max.time.min <- max( df$"Recording_time[s]" ) / 60

	# meta
	meta <- data.frame(	file = file, rawfile = rawfile, animal = animal, session = session, 
						not.found = not.found, missed.samples = missed.samples, max.time.min = max.time.min )
	
	return( meta )
}

###
# label Ethovision data with group and drug.
##
label.meta <- function( meta )
{
	task2 <- sort( c( 105,115,125,131,101,103,107,109,111,113,117,119,121,123,127,129,
					106,116,126,132,102,104,108,110,112,114,118,120,122,124,128,130 ) )

	task3.4 <- sort( c( 301,303,309,311,313,327,329,305,307,315,317,321,323,325,331,
					302,304,310,312,314,318,320,328,306,308,316,319,322,324,326,330,332 ) )

	group1 <- sort( c( 105,115,125,131,101,103,107,109,111,113,117,119,121,123,127,129,
				301,303,309,311,313,327,329,305,307,315,317,319,321,323,325,331 ) )

	group2 <- sort( c( 106,116,126,132, 102,104,108,110,112,114,118,120,122,124,
				128,130,302,304,310,312,314,318,320,328, 306,308,316,322,324,326,330,332 ) )

	drug1 <- sort( c( 105,115,125,131,106,116,126,132,301,303,309,311,313,319,327,329,302,304,310,312,314,318,320,328 ) )

	drug2 <- sort( c( 101,103,107,109,111,113,117,119,121,123,127,102,104,108,110,112,114,118,120,122,124,
					128,129,130,306,308,316,322,324,326,330,332,305,307,315,317,321,323,325,331 ) )

	# new columns
	meta$task <- NA
	meta$group <- NA
	meta$drug <- NA

	# tasks 1,2 and 3-4
	meta[ meta$animal %in% task2, 'task' ] <- 'task2'
	meta[ meta$animal %in% task3.4, 'task' ] <- 'task3-4'
	meta[ is.na( meta$task ), 'task' ] <- 'task1'

	meta[ meta$animal %in% group1, 'group' ] <- 'group1'
	meta[ meta$animal %in% group2, 'group' ] <- 'group2'

	meta[ meta$animal %in% drug1, 'drug' ] <- 'drug1'
	meta[ meta$animal %in% drug2, 'drug' ] <- 'drug2'

	# animals from task1, uneven ocd, even control
	meta$animal <- as.numeric( as.character( meta$animal ) )
	meta[ meta$task == 'task1' & ( meta$animal %% 2 == 0 ), 'group' ] <- 'group1'
	meta[ meta$task == 'task1' & ( meta$animal %% 2 == 1 ), 'group' ] <- 'group2'
	
	return( meta )
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

# get files
files <- get.files( datadir )

# container
meta <- NULL

# loop over animals
for( file in files )
{
	print( file )
	
	# get data
	meta.df <- get.data( file )
	meta <- rbind( meta, meta.df )
}

# label data
meta.label <- label.meta( meta )

# write
write.csv( meta, file( paste0( outdir, '/meta.csv' ) ) )

# write labeled data
write.csv( meta.label, file( paste0( outdir, '/meta.label.csv' ) ) )

