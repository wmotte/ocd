
#Ethovision software (Noldus Information Technology B.V., Netherlands) was used to automatically track the locomotor trajectories for the open field tests at the MRI time points. The open field area was virtually divided into 25 rectangles of 40x40 cm of which the outer zones extended 20cm outside the open field. We scored the frequency of visits for each zone during the observation period and defined the home-base as the most frequently visited zone. Checking behaviour was characterized relative to this home-base, and included frequency of checking (amount of checks at the home-base), length of checks (average time of a check at the home-base), recurrence time of checking (average time spend at other areas before returning to the home-base) and stops before returning to the home-base (average number of areas an animal visits before returning to the home-base; Szechtman et al., 1998; Tucci et al., 2014). 

# a. the most frequently visited zone => 'homebase'
# b. frequency of homebase visit => 'homebase.freq'
# c. overall average velocity => 'median.velocity'

# 1. frequency of checking (amount of checks at the home-base) => 'homebase.freq'
# 2. length of checks (average time of a check at the home-base) => 'mean.time.at.homebase' 
# 3. recurrence time of checking (average time spend at other areas before returning to the home-base) => 'median.distance.between.visits'
# 4. stops before returning to the home-base (average number of areas an animal visits before returning to the home-base) => 'median.other.field.visits'

library( 'ggplot2' )
library( 'stringr' ) 	# for 0 string padding
library( 'plyr' ) 		# for freq determination


################################################################
# FUNCTIONS
################################################################

colr <- c( '#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99', '#e31a1c', '#fdbf6f', '#ff7f00', '#cab2d6', '#6a3d9a', '#ffff99', '#b15928' )
colr2 <- c( '#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3', '#fdb462', '#b3de69', '#fccde5', '#d9d9d9', '#bc80bd', '#ccebc5', '#ffed6f' )
colr3 <- c( 'pink', colr, colr2 )


###
# Get frequency per fields (nr of time frames the animal is in a specific field
##
get.freqs <- function( df )
{
	freqs <- na.omit( ddply( df, .( field ), summarise, freq = length( field ) ) )
	freqs$field <- as.numeric( as.character( freqs$field ) )
	freqs$freq <- as.numeric( as.character( freqs$freq ) )

	return( freqs )
}

###
# Add field number and grids
##
add.field.attributes <- function( p, add.numbers = TRUE )
{
	p <- p + 

		# table sides
		geom_hline( yintercept = 80, linetype = 'solid', colour = 'gray20' ) +
		geom_hline( yintercept = -80, linetype = 'solid', colour = 'gray20' ) +
		geom_vline( xintercept = 80, linetype = 'solid', colour = 'gray20' ) +
		geom_vline( xintercept = -80, linetype = 'solid', colour = 'gray20' ) +

		# grid (horizontal)
		geom_vline( xintercept = -100, linetype = 'dotted', colour = 'gray70' ) +
		geom_vline( xintercept = -60, linetype = 'dotted', colour = 'gray70' ) +
		geom_vline( xintercept = -20, linetype = 'dotted', colour = 'gray70' ) +
		geom_vline( xintercept = 20, linetype = 'dotted', colour = 'gray70' ) +
		geom_vline( xintercept = 60, linetype = 'dotted', colour = 'gray70' ) +
		geom_vline( xintercept = 100, linetype = 'dotted', colour = 'gray70' ) +

		# grid (vertical)
		geom_hline( yintercept = -100, linetype = 'dotted', colour = 'gray70' ) +
		geom_hline( yintercept = -60, linetype = 'dotted', colour = 'gray70' ) +
		geom_hline( yintercept = -20, linetype = 'dotted', colour = 'gray70' ) +
		geom_hline( yintercept = 20, linetype = 'dotted', colour = 'gray70' ) +
		geom_hline( yintercept = 60, linetype = 'dotted', colour = 'gray70' ) +
		geom_hline( yintercept = 100, linetype = 'dotted', colour = 'gray70' ) +

		# proper scaling of axis labels
		scale_x_continuous( breaks = c( -80, -60, -40, -20, 0, 20, 40, 60, 80 ) ) +
		scale_y_continuous( breaks = c( -80, -60, -40, -20, 0, 20, 40, 60, 80 ) ) 

		# field labels 
		if( add.numbers == TRUE )
		{
			p <- p + annotate( "text", label = "18", x = -80, y = 80, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "19", x = -40, y = 80, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "20", x = 0, y = 80, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "21", x = 40, y = 80, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "22", x = 80, y = 80, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "17", x = -80, y = 40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "6", x = -40, y = 40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "7", x = 0, y = 40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "8", x = 40, y = 40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "23", x = 80, y = 40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "16", x = -80, y = 0, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "5", x = -40, y = 0, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "1", x = 0, y = 0, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "9", x = 40, y = 0, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "24", x = 80, y = 0, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "15", x = -80, y = -40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "4", x = -40, y = -40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "3", x = 0, y = -40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "2", x = 40, y = -40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "25", x = 80, y = -40, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "14", x = -80, y = -80, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "13", x = -40, y = -80, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "12", x = 0, y = -80, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "11", x = 40, y = -80, size = 5, colour = "black", fontface = "bold" ) +
			annotate( "text", label = "10", x = 80, y = -80, size = 5, colour = "black", fontface = "bold" ) 
		}

	return( p )
}

###
# Get trace plot
##
get.trace.plot <- function( df, add.numbers = FALSE )
{
	p.field <- 
	ggplot( data = df, aes( x = x, y = y, color = field, fill = field ) ) + 
			geom_point( colour = "gray10", pch = 21, alpha = 1, size = 1 ) +
			xlab( "Position x (cm)" ) +  
			ylab( "Position y (cm)" ) +
			scale_fill_manual( values = colr3 ) +
			scale_color_manual( values = colr3 ) +
			theme_classic( base_size = 14 ) + 
			theme( legend.position = 'none', axis.title = element_text( face = "bold" ) )

	p.field.att <- add.field.attributes( p.field, add.numbers = add.numbers )
	return( p.field.att )
}

###
# Get density plot
##
get.density.plot <- function( df )
{
	# density plot
	p.density <- 
		ggplot( data = df, aes( x = x, y = y ) ) + 
		geom_bin2d( bins = 20 ) +
		scale_fill_distiller( palette = "Spectral" ) +
		xlab( "Position x (cm)" ) +  
		ylab( "Position y (cm)" ) +
		theme_classic( base_size = 14 ) + 
		theme( legend.position = 'none', axis.title = element_text( face = "bold" ) )

	p.density.att <- add.field.attributes( p.density, add.numbers = TRUE )

	return( p.density.att )
}

###
# Determine number of traces per field
##
get.trace.frequencies <- function( df )
{
	# get field frequencies
	freqs <- get.freqs( df )
	
	# plot	
	p <- ggplot( data = freqs, aes( x = field, y = freq, fill = as.factor( field ) ) ) + geom_bar( stat = 'identity', colour = 'gray30' ) +
		scale_x_continuous( breaks = 1:25 ) +
		xlab( "Field code" ) +  
		ylab( "Frequency (traces)" ) +
		theme_classic( base_size = 12 ) + 
		scale_fill_manual( values = colr3 ) +
		scale_color_manual( values = colr3 ) +
		theme( legend.position = 'none', axis.title = element_text( face = "bold" ) )

	return( p )
}

###
# Return data.frame with fields and x,y
##
get.data <- function( infile )
{
	# read data
	df <- read.csv( infile, row.names = 1 )

	# remove rows with x or y position == NA
	df <- df[ !( is.na( df$x ) | is.na( df$y ) ), ]

	# remove fields == NA
	df <- df[ ! is.na( df$field ), ] 

	# session and field as factor
	df$session <- as.factor( df$session )
	df$field <- as.factor( df$field )
	
	return( df )
}

###
# Get frequency per fields; number of times an animal enters a specific field
##
get.entry.freqs <- function( df )
{
	summary( df$new.field )

	freqs <- ddply( df, .( new.field ), summarise, freq = length( new.field ) )
	freqs$new.field <- as.numeric( as.character( freqs$new.field ) )
	freqs$freq <- as.numeric( as.character( freqs$freq ) )

	freqs <- freqs[ freqs$new.field != 0, ]

	return( freqs )
}

###
# Determine number of traces per field
##
get.field.entry.frequencies <- function( df )
{
	# get field frequencies
	freqs <- get.entry.freqs( df )
	
	# plot	
	p <- ggplot( data = freqs, aes( x = new.field, y = freq, fill = as.factor( new.field ) ) ) + geom_bar( stat = 'identity', colour = 'gray30' ) +
		scale_x_continuous( breaks = 1:25 ) +
		xlab( "Field code" ) +  
		ylab( "Frequency (field entries)" ) +
		theme_classic( base_size = 12 ) + 
		scale_fill_manual( values = colr3 ) +
		scale_color_manual( values = colr3 ) +
		theme( legend.position = 'none', axis.title = element_text( face = "bold" ) )

	return( p )
}

###
# Determine change in field position and add extra vectors.
# 0 == same field
# 1 == field change
##
get.field.change <- function( df )
{
	df$field <- as.numeric( as.character( df$field ) )

	# shift field with 1 row (impute last row with identical value)
	df$new.field <- c( df$field[ 2:nrow( df ) ], df$field[ nrow( df ) ] )

	# init field change
	df$field.changed <- 0

	# determine field change
	df[ df$field != df$new.field, 'field.changed' ] <- 1

	# only keep new field where change occurred
	df$new.field <- as.factor( df$field.changed * df$new.field )
	df$field <- as.factor( df$field )

 	return( df )
}

###
# Write composite image (use system pngappend to merge pngs)
##
write.composite.png <- function( p1, p2, p3, p4, outdir, animal, session )
{
	file1 <- paste0( outdir, '/animal-', animal, '-session-', session, '__trace.png' )
	file2 <- paste0( outdir, '/animal-', animal, '-session-', session, '__density.png' )
	file3 <- paste0( outdir, '/animal-', animal, '-session-', session, '__freq.png' )
	file4 <- paste0( outdir, '/animal-', animal, '-session-', session, '__entries.png' )

	file.top <- paste0( outdir, '/animal-', animal, '-session-', session, '__top.png' )
	file.bottom <- paste0( outdir, '/animal-', animal, '-session-', session, '__bottom.png' )
	file.total <- paste0( outdir, '/animal-', animal, '-session-', session, '.png' )

	# save plots
	ggsave( plot = p1, file = file1, dpi = 100, width = 6, height = 6 )
	ggsave( plot = p2, file = file2, dpi = 100, width = 6, height = 6 )
	ggsave( plot = p3, file = file3, dpi = 100, width = 6, height = 3 )
	ggsave( plot = p4, file = file4, dpi = 100, width = 6, height = 3 )

	png.top <- paste0( "pngappend ", file4, " - ", file1, " ", file.top )
	png.bottom <- paste0( "pngappend ", file3, " - ", file2, " ", file.bottom )
	png.total <- paste0( "pngappend ", file.top, " + ", file.bottom, " ", file.total )

	# call external linux merging program 'pngappend'
	system( png.top )
	system( png.bottom )
	system( png.total )

	if( file.exists( file1 ) ){ file.remove( file1 ) }
	if( file.exists( file2 ) ){ file.remove( file2 ) }
	if( file.exists( file3 ) ){ file.remove( file3 ) }
	if( file.exists( file4 ) ){ file.remove( file4 ) }
	if( file.exists( file.top ) ){ file.remove( file.top ) }
	if( file.exists( file.bottom ) ){ file.remove( file.bottom ) }
}

###
# Get number of all other field visited between homebase entries.
##
get.other.field.visits <- function( df, homebase )
{
	# cumulative field change
	df$cum.field.changed <- cumsum( df$field.changed )

	# get all rows of field change
	df.changed <- df[ df$field.changed > 0, ]

	# get all rows where homebase is entered
	df.home <- df.changed[ df.changed$new.field == homebase, ]

	# determine total of different fields visited before return to homebase
	df.home$field.visited <- c( 0, diff( df.home$cum.field.changed ) )

	return( df.home$field.visited )
}

###
# Get distances traveled between homebase visits.
##
get.distances.between.visits <- function( df, homebase )
{
	# if no distance data is available, set distance to 0
	df[ is.na( df$Distance_moved ), 'Distance_moved' ] <- 0

	# cumulative field change
	df$cum.distance <- cumsum( df$Distance_moved )

	# get all rows of field change
	df.changed <- df[ df$field.changed > 0, ]

	# get all rows where homebase is entered
	df.home <- df.changed[ df.changed$new.field == homebase, ]

	# determine total of different fields visited before return to homebase
	df.home$distance.between.visits <- c( 0, diff( df.home$cum.distance ) )

	return( df.home$distance.between.visits )
}

###
#Calculate entropy
###
PREDICTABILITY <- function(Sequence, Max_String) 
  {

  output     <- matrix(NA,nrow=length(Sequence), ncol=1)
  dictionary <- NULL
  ## cycle through each entry, i, in the Sequence
  for (i in 1:(length(Sequence)-Max_String) )
    {
    ## Compile list of increasingly-long substrings, starting at position i; i+0,i+1,i+2,...,i+Max_String
    codons <- matrix(NA, nrow=Max_String, ncol=1)
    for (STRL in 0:Max_String)
      {
      codons[STRL,] <- paste(Sequence [i:(i+STRL-1)], collapse="")
      }
    ## Find which of these codons have NOT been seen before
    new <- codons[!codons %in% dictionary]
    ## check for no new codons
    ifelse ((length(new)>0),
      record <- min(nchar(new)),    ## if we have new codons, find the shortest among them
      record <- NA )                ## if none are new (because we aren't searching far enough ahead), assign NA... 
    ## find the shortest of these unseen codons
    output[i,] <- record

    ## Finally, add the unseen codons to the dictionary
    dictionary <- c(dictionary, new)
    }##i
  ## Calculate source entropy (i.e. predictability) from formula in Song et al (2010)
  n <- length(output[!is.na(output)])  
  S <- 1/((1/n * sum(output, na.rm=TRUE))) * log(n)  

  return(S)
}

###
# Determine predictability of locations (for animals with at least 9 visits; look for predictability of max 3 zones in a row. You can change these numbers to another minumum number of zones, or maximum number of zones in a row
###

get.predictability.9.3 <- function(df)
{
	# get all rows of field change
	data.changed <- df[ df$field.changed > 0, ]
	# add extra row which contains the last field that is visited by the aniaml
	last.row <- data.changed$Trial_time[nrow(data.changed)]
	trial.time <- last.row + 0.067
	extra.row <- df[df$Trial_time == trial.time,]
	data.changed <- rbind(data.changed, extra.row) 

	# Only select animals that visited at least 9 zones
	if(nrow(data.changed) > 8 ){
	fields <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y")
	selected.fields <- fields[1:length(levels(data.changed$field))]

	#Change field numbers to field letters
	levels(data.changed$field) <- selected.fields
	locations <- data.changed$field
	#calculate entropy value
	entropy.value.9.3 <- PREDICTABILITY(locations,3)
	} else {
	entropy.value.9.3 <- NA
	}
return(entropy.value.9.3)	
}

###
# Get average time at homebase
##
get.time.at.homebase <- function( df, homebase )
{
	# delta time per frame
	df$delta.time <- c( 0, diff( df$Trial_time ) )

	# get frames at homebase only
	df.home <- df[ df$field == homebase, ]

	# sum time at homebase (sec)
	time.at.homebase <- sum( df.home$delta.time, na.rm = TRUE )

	return( time.at.homebase )
}

###
# Get homebase frequency
##
get.homebase.freq <- function( df, homebase )
{
	freqs <- ddply( df, .( new.field ), summarise, freq = length( new.field ) )
	freqs$new.field <- as.numeric( as.character( freqs$new.field ) )
	freqs$freq <- as.numeric( as.character( freqs$freq ) )

	freqs <- freqs[ freqs$new.field == homebase, ]

	return( freqs$freq )
}

###
# Get time traveled between homebase visits.
##
get.mean.time.between.visits <- function( df, homebase )
{
	# delta time per frame
	df$delta.time <- c( 0, diff( df$Trial_time ) )

	# get all rows where homebase is entered
	freq <- nrow( df[ df$field.changed > 0 & df$field == homebase, ] )

	# get data.frames not in homebase
	df.outside <- df[ df$field != homebase, ]	

	# get cumulative time when animal is outside homebase 
	cum.time <- sum( df.outside$delta.time )

	# mean time outside homebase
	mean.time <- cum.time / freq

	return( mean.time )
}

###
# Get immobility time (travelled <0.01 cm per frame)
#

get.immobility <- function(df)
{
	df$delta.time <- c(0, diff(df$Trial_time))
	immobility <- df[df$Distance_moved < 0.01,]
	immobility.complete <- immobility[complete.cases(immobility),]
	immobile.time <- sum(immobility.complete$delta.time)
}

###
# Get homebase (field with max entries)
##
get.homebase <- function( df )
{
	# if animal stays within single field, return NA
	if( length( unique( df$field ) ) == 1 ){ 
		return( NA )
	}

	# frequency of stay
	stayfreqs  <- ddply( df, .( field ), summarise, stayfreq = length( field ) )
	stayfreqs$field <- as.numeric( as.character( stayfreqs$field ) )
	stayfreqs$stayfreq <- as.numeric( as.character( stayfreqs$stayfreq ) )
	head( stayfreqs <- stayfreqs[ stayfreqs$field != 0, ] )

	# frequency of entry
	freqs <- ddply( df, .( new.field ), summarise, freq = length( new.field ) )
	freqs$new.field <- as.numeric( as.character( freqs$new.field ) )
	freqs$freq <- as.numeric( as.character( freqs$freq ) )
	head( freqs <- freqs[ freqs$new.field != 0, ] )

	# max frequencies
	sel <- freqs[ freqs$freq == max( freqs$freq ), ]
	sel2 <- stayfreqs[ stayfreqs$stayfreq == max( stayfreqs$stayfreq ), ]

	# if equal entries in multiple fields, choose one with highest frequency of stay	
	if( nrow( sel ) == 1 )
	{
		homebase <- sel$new.field
	} else { # two or more field with equal entry frequencies

		# return first field with max stay (highly unlikely to have more than one)
		homebase <- sel2[ 1, 'field' ]
	}

	return( homebase )
}


################################################################
# END FUNCTIONS
################################################################

# input data
indir <- ''

# write to output
outdir <- ''

# create output directory
dir.create( outdir, showWarnings = FALSE )

# meta data
meta <- read.csv( paste0( 'meta.label.with.data.csv' ), row.names = 1 ) 

# init new columns
meta$homebase <- meta.15$homebase <- NA
meta$median.other.field.visits <- meta.15$median.other.field.visits <- NA
meta$mean.other.field.visits <- meta.15$mean.other.field.visits <- NA
meta$median.distance.between.visits <- meta.15$median.distance.between.visits <- NA
meta$mean.time.between.visits <- meta.15$mean.time.between.visits <- NA
meta$median.velocity <- meta.15$median.velocity <- NA
meta$mean.velocity <- meta.15$mean.velocity <- NA
meta$time.at.homebase <- meta.15$time.at.homebase <- NA
meta$homebase.freq <- meta.15$homebase.freq <- NA
meta$total.distance <- meta.15$total.distance <- NA
meta$immobility.time <- meta.15$immobility.time <- NA
meta$entropy.9.3 <- meta.15$entropy.9.3 <- NA

# loop over meta rows
for( i in 1:nrow( meta )) 
{
	animal <- meta[ i, 'animal' ]
	session <- meta[ i, 'session' ]

	# input file
	infile <- as.character( meta[ i, 'csvfile' ] )
	print( paste( "Animal:", animal, " session:", session ) )

	# get data
	df <- get.data( infile )

	# check if df is empty (i.e. only NA)
	if( nrow( df ) > 2 )
	{
		# get field changes
		df <- get.field.change( df )

		# get trace plot
		p1 <- get.trace.plot( df, add.numbers = TRUE )

		# get density plot
		p2 <- get.density.plot( df )

		# get frequency of traces
		p3 <- get.trace.frequencies( df )

		# get field entry plot
		p4 <- get.field.entry.frequencies( df )

		# write 4 x 4 composite image
		write.composite.png( p1, p2, p3, p4, outdir, animal, session )

		# get homebase
		homebase <- get.homebase( df )

		if( !is.na( homebase ) )
		{
			# get homebase visits
			homebase.freq <- get.homebase.freq( df, homebase )

			# other field visits
			other.field.visits <- get.other.field.visits( df, homebase )

			# get distance between homebase entries
			distance.between.visits <- get.distances.between.visits( df, homebase )

			# median other field visits between homebase entries
			median.other.field.visits <- median( other.field.visits, na.rm = TRUE )

			# mean other field visits between homebase entries
			mean.other.field.visits <- mean( other.field.visits, na.rm = TRUE )

			# median distance between visits
			median.distance.between.visits <- median( distance.between.visits, na.rm = TRUE )

			# mean time between visits
			mean.time.between.visits <- get.mean.time.between.visits( df, homebase )

			# get time at homebase (sec)
			time.at.homebase <- get.time.at.homebase( df, homebase )
		}
	
		#Get total distance moved
		total.distance <- sum(df$Distance_moved, na.rm=TRUE)
			
		#Get immobility time
		immobility.time <- get.immobility(df)

		#Get predictability of timeseries (entropy)
		entropy.9.3 <- get.predictability.9.3(df)
		
		# get average velocity of animal
		median.velocity <- median( df$Velocity, na.rm = TRUE )
		mean.velocity <- mean( df$Velocity, na.rm = TRUE )

		# get homebase
		meta[ i, 'homebase' ] <- homebase
		meta[ i, 'median.other.field.visits' ] <- median.other.field.visits
		meta[ i, 'mean.other.field.visits' ] <- mean.other.field.visits
		meta[ i, 'median.distance.between.visits' ] <- median.distance.between.visits 	# cm
		meta[ i, 'mean.time.between.visits' ] <- mean.time.between.visits 				# s
		meta[ i, 'median.velocity' ] <- median.velocity 								# cm/s
		meta[ i, 'mean.velocity' ] <- mean.velocity 									# cm/s
		meta[ i, 'time.at.homebase' ] <- time.at.homebase 								# s
		meta[ i, 'homebase.freq' ] <- homebase.freq
		meta[ i, 'total.distance' ] <- total.distance
		meta[ i, 'immobility.time' ] <- immobility.time
		meta[ i, 'entropy.9.3' ] <- entropy.9.3
		
		# sanity cleanup
		other.field.visits <- NA
		distance.between.visits <- NA

		homebase <- NA
		median.other.field.visits <- NA
		mean.other.field.visits <- NA
		median.distance.between.visits <- NA
		mean.time.between.visits <- NA
		median.velocity  <- NA		
		mean.velocity  <- NA				
		time.at.homebase  <- NA
		homebase.freq <- NA
		total.distance <- NA
		immobility.time <- NA
		entropy.9.3 <- NA
		
	}

	df <- NULL
}

# average time in homebase
meta$mean.time.at.homebase <- meta$time.at.homebase / meta$homebase.freq

# save new meta with homebases
write.csv( meta, file = paste0( outdir, '/stats.csv' ), quote = TRUE )


