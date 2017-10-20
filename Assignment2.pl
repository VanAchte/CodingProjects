#!/usr/bin/perl

use warnings "all";

my @artists = `find . -mindepth 3 -maxdepth 3 | cut -d '/' -f 3 | sort | uniq`;
my @albums = `find . -mindepth 3 -maxdepth 3`;


chomp(@artists); # Gets rid of all /n line characters at the back of the line

print "<html>\n";
print "<body>\n";
print "<table border =\"1\">\n";
print "  <tr>\n";
print "    <th>Artist</th>\n";
print "    <th>Album</th>\n";
print "  </tr>\n";

my $numAlbums = 0;

for ( my $i = 0; $i < @artists; $i++ ) {
	print "  <tr>\n";
    my @artistAlbums;
    my $curArtist = $artists[$i];
    for( my $j = 0; $j < @albums; $j++) {
        @values = split('/', $albums[$j]);
        my $artist = $values[2];
        my $album = $values[3];
        if($curArtist eq $artist) {
            $numAlbums = $numAlbums + 1;
            push @artistAlbums, $album;
        }
    }

    print "    <td rowspan=\"" . $numAlbums . "\">" . $curArtist . "</td>\n";
    for( my $k = 0; $k < $numAlbums; $k++) {
    	#@sorted_albums = sort { "\L$a" cmp "\L$b" } @artistAlbums;
    	@artistAlbums = sort @artistAlbums;
    	chomp(@artistAlbums);
    	if ($k > 0) {
    		print "  </tr>\n";
    		print "  <tr>\n";
    	}
    	print "    <td>" . $artistAlbums[$k] . "</td>\n";
    }

    print "  </tr>\n";
    $numAlbums = 0;
}
print "</table>\n";
print "</body>\n";