#!/usr/bin/perl

#  Assume obs with pressures, dates, positions, but no hour, were made at noon

use strict;
use warnings;
use Getopt::Long;
use lib "/home/h03/hadpb/Projects/IMMA/Perl";
use MarineOb::IMMA;
use MarineOb::lmrlib
  qw(rxltut ixdtnd rxnddt );
use Date::Calc qw(check_date);

my $Year;
my $Month;
GetOptions(
    "year=i"     => \$Year,
    "month=i"    => \$Month
);

my $Imma_file=sprintf("%s/ICOADS3+/merged.filled/IMMA1_R3.0.0_%04d-%02d.gz",
                      $ENV{'SCRATCH'},$Year,$Month);
open(DIN, "gunzip -c $Imma_file |") || die "can’t open pipe to $Imma_file";

my $OP_file=sprintf("%s/ICOADS3+/noon.assumptions/IMMA1_R3.0.0_%04d-%02d.gz",
                      $ENV{'SCRATCH'},$Year,$Month);

open(DOUT, "| gzip -c > $OP_file") || die "can’t open pipe to $OP_file";

while ( my $Record = imma_read( \*DIN ) ) {

    if(!defined($Record->{HR}) && defined($Record->{SLP}) && defined($Record->{YR}) &&
                                  defined($Record->{MO})  && defined($Record->{DY}) &&
                                  defined($Record->{LAT}) && defined($Record->{LON}) &&
                                  check_date($Record->{YR},$Record->{MO},$Record->{DY})) {
        $Record->{HR}=12;
        # 12 in ship time - adjust to UTC
       	my $elon=$Record->{LON};
	if ( $elon < 0 ) { $elon += 360; }
        if( $elon<0.1 ) { $elon=0.1; } # Buggy around 0/360
        if( $elon>359.9 ) { $elon=359.9; } 
	my ( $uhr, $udy ) = rxltut(
	    $Record->{HR} * 100,
	    ixdtnd( $Record->{DY}, $Record->{MO}, $Record->{YR} ),
	    $elon * 100
	);
	$Record->{HR} = $uhr / 100;
	( $Record->{DY}, $Record->{MO}, $Record->{YR} ) = rxnddt($udy);
      
    } 
    $Record->write(\*DOUT);  
}
close(DIN);
close(DOUT);


