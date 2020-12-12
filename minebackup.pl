#!/usr/bin/perl

#use strict;
use IO::Socket;
#use warnings;
#use AnyEvent;
#use AnyEvent::IRC::Client;
use Mojo::IRC;

# Set these for your situation
my $MTDIR = "/home/mtowner/minetest";
my $BACKUPDIR = "/home/mtowner/backups";
my $TARCMD = "/bin/tar czf";
my $BACKUP_DELAY = 5;
my $IRC_CHAN = "##changeme";
my $IRC_SERVER = "irc.freenode.net";
my $IRC_NICK = "BackupScript";
my $IRC_PORT = "6667";
my $IRC_LOGINNAME = "Minetest Backup Script";
my $DOING_DELAY = "false";
my $SHOW_SERVER_OUTPUT = "true";
my $BACKUP_CONFIG = "/home/mtowner/MineBackup/backups.rc";
my $DEBUG_MODE = "false";	# Set to "true" to enable debug output

#-------------------
# No changes below here...
#-------------------
my $VERSION = "1.5";

sub debugPrint
{
	if ($DEBUG_MODE eq "true")
	{
		print "$_[0]";
	}
}

sub testIRC
{
my $irc = Mojo::IRC->new(
            nick => 'BackupBot',
            user => 'A Backup is about to be done',
            server => 'irc.freenode.net:6667',
          );
 
$irc->on(irc_join => sub {
  my($self, $message) = @_;
  warn "yay! i joined $message->{params}[0]";
});
 
$irc->on(irc_privmsg => sub {
  my($self, $message) = @_;
  say $message->{prefix}, " said: ", $message->{params}[1];
});
 
$irc->connect(sub {
  my($irc, $err) = @_;
  return warn $err if $err;
  $irc->write(join => '##changeme');
});
 
Mojo::IOLoop->start;
}

if (-f $BACKUP_CONFIG)
{
	if (open(my $fh, '<:encoding(UTF-8)', $BACKUP_CONFIG))
	{
		while (my $row = <$fh>)
		{
			chomp $row;
			my $CommentChar = substr($row, 0, 1);
			if ($CommentChar eq "#")
			{
				next;
			}
			(my $command, my $setting) = split(/=/, $row);
			if ($command eq "BACKUP_DELAY")
			{
				debugPrint("Saw command $command\n");
				$BACKUP_DELAY = $setting;
			}
			elsif ($command eq "IRC_CHAN")
			{
				debugPrint("Saw command $command\n");
				$IRC_CHAN = $setting;
			}
			elsif ($command eq "IRC_SERVER")
			{
				debugPrint("Saw command $command\n");
				$IRC_SERVER = $setting;
			}
			elsif ($command eq "IRC_NICK")
			{
				debugPrint("Saw command $command\n");
				$IRC_NICK = $setting;
			}
			elsif ($command eq "IRC_PORT")
			{
				debugPrint("Saw command $command\n");
				$IRC_PORT = $setting;
			}
			elsif ($command eq "IRC_LOGINNAME")
			{
				debugPrint("Saw command $command\n");
				$IRC_LOGINNAME = $setting;
			}
			elsif ($command eq "SHOW_SERVER_OUTPUT")
			{
				debugPrint("Saw command $command\n");
				$SHOW_SERVER_OUTPUT = $setting;
			}
			elsif ($command eq "BACKUP_CONFIG")
			{
				debugPrint("Saw command $command\n");
				$BACKUP_CONFIG = $setting;
			}
			else
			{
				die ("Unknown command: $command\n");
			}
		}
		close($fh);
	}
	else
	{
		warn "Could not open file '$BACKUP_CONFIG' $!";
	}
}

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
		my $SawIt = chop($sock);
		debugPrint("$SawIt\n");

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
	print($sock "JOIN $IRC_CHAN\r\n");
	print ("joined channel: 'JOIN $IRC_CHAN'\n");
print $sock "Warning - the minetest game is about to run a backup. You have $BACKUP_DELAY minutes to finish saving your changes.\r\n";
	# Keep reading lines from the server.
	while (my $input = <$sock>)
	{
		debugPrint("SawLine\n");
		chop $input;
		if ($input =~ /^PING(.*)$/i)
		{
			# We must respond to PINGs to avoid being disconnected.
			print $sock "PONG $1\r\n";
		}
		else
		{
			if ($SHOW_SERVER_OUTPUT eq "true")
			{
				# Print the raw line received by the bot.
				print "$input\n";
			}
		}
		print $sock "Warning - the minetest game is about to run a backup. You have $BACKUP_DELAY minutes to finish saving your changes.\r\n";
		last;
	}
	debugPrint"About to sleep\n";
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
	testIRC();
	#DoWarn();
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
