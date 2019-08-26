#!/usr/bin/php
<?php
 
//use strict
error_reporting(E_ALL | E_STRICT);  

/**
 * Author: W.M. Otte
 * Check dimension of input image.
 */


// command-line parse
$args = new Args( $argv );

// usage message
$usage =
  "   -i            filename    : input image\n";

// input
$inputFileName       = $args -> get( "i"       );

// required
if ( !$inputFileName )
{
	print "Usage:\n" . $usage . "\n";
	exit( -1 );
}

if( ! file_exists( $inputFileName ) )
{
    print( "*** ERROR ***: $inputFileName does not exist!\n" );
    exit( -1 );
}
else 
{
    //$dim = chop( shell_exec( "fslinfo $inputFileName|grep 'dim1'" ) );
    $dim = chop( shell_exec( "fslinfo $inputFileName | grep dim1 |grep -v pixdim | awk -F \" \" '{print $2}'" ) );
    $pixdim = chop( shell_exec( "fslinfo $inputFileName | grep pixdim1 | awk -F \" \" '{print $2}'" ) );

    //print( $dim . " " . $pixdim . "\n" );
    
    $prod = $dim * $pixdim;
    
    //print( $prod . "\n" );


    # typical 4.7T field-of-view is 32 mm or 40 mm, but let's be liberal: 80 mm
    if( $prod > 80 )
        print( "human\n" );
    else
        print( "rat\n" );
}

/** ************************************************************
 * Argument class **********************************************
 * *************************************************************/
class Args {

	/**
	 * Constructor.
	 *
	 * @param $argv
	 * @param $mapping
	 * @return unknown_type
	 */
	function __construct( $argv, $mapping = array() ) {
		$this -> parseCmd( $argv, $mapping );
	}

	/**
	 *
	 * @param $key
	 * @return unknown_type
	 */
	function has( $key ) {
		return array_key_exists( $key, $this -> m_Argv );
	}

	/**
	 *
	 * @param $key
	 * @return unknown_type
	 */
	function size( $key ) {
		if ( !$this -> has( $key ) ) {
			return 0;
		}
		return count( $this -> m_Argv[ $key ] );
	}

	/**
	 *
	 * @param $key
	 * @return unknown_type
	 */
	function getall( $key ) {
		if ( !$this -> has( $key ) ) {
			return array();
		}

		return $this -> m_Argv[ $key ];
	}

	/**
	 *
	 * @param $key
	 * @param $index
	 * @param $default
	 * @return unknown_type
	 */
	function get( $key, $index = 0, $default = NULL ) {
		$items = array();

		if ( $this -> has( $key ) ) {
			$items = $this -> m_Argv[ $key ];
		}

		if ( $index >= count( $items ) ) {
			return $default;
		}

		return $items[ $index ];
	}

	/**
	 *
	 * @param $argv
	 * @param $mapping
	 * @return unknown_type
	 */
	function parseCmd( $argv, $mapping ) {
		$argc = count( $argv );
			
		$args = array();

		$key = "";
		$value = array();

		foreach( $argv as $arg ) {
			if ( preg_match( '/^-{1,2}([a-zA-Z].*)$/', $arg, $m ) ) {
				if ( $key != "" || count( $value) > 0 ) {
					if ( !array_key_exists( $key, $args ) ) {
						$args[ $key ] = array();
					}

					foreach( $value as $v ) {
						array_push( $args[ $key ], $v );
					}
				}
					
				$key = $m[ 1 ];
				if ( array_key_exists( $key, $mapping ) ) {
					$key = $mapping[ $key ];
				}
					
				$value = array();
			} else {
				array_push( $value, $arg );
			}
		}

		if ( $key != "" || count( $value ) > 0 ) {
			if ( !array_key_exists( $key, $args ) ) {
				$args[ $key ] = array();
			}

			foreach( $value as $v ) {
				array_push( $args[ $key ], $v );
			}
		}
			
		$this -> m_Argv = $args;
	}

	private $m_Argv;
}

?>
