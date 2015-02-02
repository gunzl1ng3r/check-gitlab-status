#!/usr/bin/perl

# GitLab comes with a built-in script to check the state of its services
# we execute said command and store the output in an array
my @output = `/usr/bin/sudo /usr/bin/gitlab-ctl status`;

my $ok = 0;
my $warning = 0;
my $critical = 0;
my $unknown = 0;

my @service_states;

# iterate through the array containing gitlab-ctl output
foreach ( @output ) {

	# explode the first part of each line ( the second part, after the ";" is non-neccessary information
	( $original_string, $state, $service, $additional ) = ($_ =~ /((.+):\s(.+):\s(.+));/);

	# self-explanatory
	if ( $state == "run" ) {
		$ok++;
	} elsif ( $state == "down" ) {
		$critical++;
	} else {
		$unknown++;
	}

	# push service and state in a new array with separator
	push(@service_states,"$service: $state");

}

# determine exit code based counts
if ( $critical > 0 ) {
	print "CRITICAL - $critical services are down - " . join("; ", @service_states);
	exit 2;
} elsif ( $warning > 0 ) {
	# only here for for sake completeness, I have not yet found a reason for a warning in here
	exit 1;
} elsif ( $ok > 0 ) {
	print "OK - All services are runnung - " . join("; ", @service_states);
	exit 0;
} else {
	print "UNKNOWN - I have no idea how you got here, new state?";
	exit 3;
}
