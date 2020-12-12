#!/usr/bin/perl

# Set these for your situation
my $MTDIR = "/home/mtowner/minetest";
my $BACKUPDIR = "/home/mtowner/backups";
my $TARCMD = "/bin/tar czf";
my $BACKUP_DELAY = 5;
my $IRC_CHAN = "#changeme";
my $IRC_SERVER = "irc.freenode.net";
my $IRC_NICK = "BackupScript";
my $IRC_PORT = "6667";
my $IRC_LOGINNAME = "Minetest Backup Script";
my $DOING_DELAY = "false";

use strict;
use IO::Socket;

#-------------------
# No changes below here...
#-------------------
my $VERSION = "1.5";

sub DoWarn
{
	print "Doing a delay of $BACKUP_DELAY minutes\n";

	# Connect to the IRC server.
	my $sock = new IO::Socket::INET(PeerAddr => $IRC_SERVER,
					PeerPort => $IRC_PORT,
					Proto => 'tcp') or die "Can't connect to IRC server '$IRC_SERVER' on port '$IRC_PORT'\n";

	# Log on to the server.
	print $sock "NICK $IRC_NICK\r\n";
	#print $sock "USER $IRC_LOGINNAME 8 * :Perl IRC Hacks Robot\r\n";
	print $sock "USER $IRC_LOGINNAME 8 * :$IRC_LOGINNAME\r\n";

	# Read lines from the server until it tells us we have connected.
	while (my $input = <$sock>)
	{
		# Check the numerical responses from the server.
		if ($input =~ /004/)
		{
			# We are now logged in.
			last;
		}
		elsif ($input =~ /433/)
		{
			die "Nickname '$IRC_NICK' is already in use.";
		}
	}

	# Join the channel.
	print $sock "JOIN $IRC_CHAN\r\n";

	# Keep reading lines from the server.
	while (my $input = <$sock>)
	{
		chop $input;
		if ($input =~ /^PING(.*)$/i)
		{
			# We must respond to PINGs to avoid being disconnected.
			print $sock "PONG $1\r\n";
		}
		else
		{
			# Print the raw line received by the bot.
			print "$input\n";
		}
		print $sock "Warning - the minetest game is about to run a backup. You have $BACKUP_DELAY minutes to finish saving your changes.\r\n";
	}
	sleep($BACKUP_DELAY * 60);
}

if ($ARGV[0] eq "warn")
{
	$DOING_DELAY = "true";
}

print "MineBackup.pl version $VERSION\n";
print "=========================\n";

if ($DOING_DELAY eq "true")
{
	DoWarn();
}

exit 0;

if (! -d $BACKUPDIR)
{
	print "Backup dir $BACKUPDIR not found, creating...\n";
	system("mkdir -p $BACKUPDIR");
}
print "Moving existing backups: ";

if (-f "$BACKUPDIR/minebackup-5.tgz")
{
	unlink("$BACKUPDIR/minebackup-5.tgz")  or warn "Could not unlink $BACKUPDIR/minebackup-5.tgz: $!";
}
if (-f "$BACKUPDIR/minebackup-4.tgz")
{
	rename("$BACKUPDIR/minebackup-4.tgz", "$BACKUPDIR/minebackup-5.tgz");
}
if (-f "$BACKUPDIR/minebackup-3.tgz")
{
	rename("$BACKUPDIR/minebackup-3.tgz", "$BACKUPDIR/minebackup-4.tgz");
}
if (-f "$BACKUPDIR/minebackup-2.tgz")
{
	rename("$BACKUPDIR/minebackup-2.tgz", "$BACKUPDIR/minebackup-3.tgz");
}
if (-f "$BACKUPDIR/minebackup-1.tgz")
{
	rename("$BACKUPDIR/minebackup-1.tgz", "$BACKUPDIR/minebackup-2.tgz");
}
print "Done\nCreating New Backup: ";
# set no respawn
system("touch '$MTDIR/nostart'");

my $running=`ps ax|grep minetestserver|grep -v grep`;

if ($running ne "")
{
	# Process is running, kill it
	system("killall minetestserver");
	#system("killall /home/mtowner/minetest/bin/startminetest");
	sleep(20);
}
system("$TARCMD $BACKUPDIR/minebackup-1.tgz $MTDIR");
print("Done!\n");
# Remove respawn flag
if (-f "$MTDIR/nostart")
{
	print "Removing $MTDIR/nostart\n";
	# Remove the lock file if it exists
	unlink("$MTDIR/nostart");
}
print("Server should restart within 60 seconds!\n");
sleep(5);
exit 0;
