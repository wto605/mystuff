# TODO: portable shebang. Getoptions notes

# Enforce checks for bad perl
use warnings;
use strict;

# Automatically die on errors of system calls (e.g. file operations).
use autodie;

# To make main scope explicit and separate from global

# Any global variables used by all functions without passing
%globaloptions; # This hash contains options specified by user and global config

exit main (@ARGV);

sub main {
  #the actual script goes here
}

# regex for semicolons (not perfect): (^[^\n#]+[^\{;,\n} ] *([^\$]#|$))
# regex to guard hash keys: HASH_NAME_HERE{([^']\w+)}

# Debugprint sub
sub vprint ($) {
  print "DEBUG: $_[0]\n" if $verbose;
};

# Teeprint (used a global hash "options" for different levels)
sub teeprint {
  my $msg_level = shift;
  print {$options{'logfh'}} @_ if ( $msg_level <= $options{'verbose'} );
  print {$options{'stdout'}} @_ if ( $msg_level <= $options{'tee'} );
}

# qw() is "quote word" puts hard quotes around all words inside it. e.g. when only using some of a module
use List::Util qw (first last);

# qx() is same as backtick (quotes lines as a string). NOTE: will still include line breaks in each string, use chomp.
# This example gits a list of all SHA
chomp (my @git_log_output = qx{git log -1 --format="%H" $repo_path});

# qq is for block quotes, can use ANY character
  my $body = qq~
This is a sample block quote for an email body.

It still supports $variables, so remember to escape an\@email.address.
Note that indentation is included in the block quote.
~;
  my $body2 = qq#
Other characters are supported too!
but picking something like hash may confuse syntax highlighting.
#; # That first hash is NOT a comment!


# Emailing files - condensed example.
# NOTE: never seen a case where mutt didn't work but sendmail did, that may be paranoid.
# Explored using Email::MIME (supported for perl 5.14.x at work) to send mail from within perl, but this was
# more complex than the needs of this message. mutt is universal at work and supports easy MIME attachments and
# should be configured on all work systems for username sending.
sub email_log_file {
  my ($status, $runtime, $recipients) = @_;
  my $body = qq~
This message is sent for debug & development purposes. For info contact me.

Overall Result: $status
Run Time: $runtime
~;
  system("gzip -c $options{'logdir'}/example.log > /tmp/$$.example.log.gz");
  my @muttresult = qx { echo '$body' | mutt -s "example logfile for $ENV{'USER'}" -a "/tmp/$$.example.log.gz" -- $recipients };
  # Print to shell (log is closed) and use sendmail to report any mutt failures.
  if (($? >> 8) != 0) {
    system("echo \'mutt failed to send log $options{'logdir'}/example.log from $ENV{'HOST'} for $ENV{'USER'}\' | sendmail $recipients");
    print "-W- Failed to email log file via mutt:\n-W-     " . join ("\n-W-     ", @muttresult) . "\n";
  }
}
