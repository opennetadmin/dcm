#!/usr/bin/perl -w
##############################################################################
## dcm.pl
## Written by: Brandon Zehm <caspian@dotconf.net>
## Modifications by: Matt Pascoe <matt@opennetadmin.com>
## 
## License:
##  dcm.pl (hereafter referred to as "program") is free software;
##  you can redistribute it and/or modify it under the terms of the GNU General
##  Public License as published by the Free Software Foundation; either version
##  2 of the License, or (at your option) any later version.
##  Note that when redistributing modified versions of this source code, you
##  must ensure that this disclaimer and the above coder's names are included
##  VERBATIM in the modified code.
##  
## Disclaimer:
##  This program is provided with no warranty of any kind, either expressed or
##  implied.  It is the responsibility of the user (you) to fully research and
##  comprehend the usage of this program.  As with any tool, it can be misused,
##  either intentionally (you're a vandal) or unintentionally (you're a moron).
##  THE AUTHOR(S) IS(ARE) NOT RESPONSIBLE FOR ANYTHING YOU DO WITH THIS PROGRAM
##  or anything that happens because of your use (or misuse) of this program,
##  including but not limited to anything you, your lawyers, or anyone else
##  can dream up.  And now, a relevant quote directly from the GPL:
##  
## NO WARRANTY
##  
##  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
##  FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
##  OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
##  PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
##  OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
##  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
##  TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
##  PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
##  REPAIR OR CORRECTION.
##    
## The GNU GPL can be found at http://www.fsf.org/copyleft/gpl.html
##
##############################################################################
## 
## Description
## 
## dcm.pl (Distributed Command Module) is a console utility designed to provide
## a console interface to web-based "modules".  The goal is to build a simple
## framework that will enable a secure method of invoking centrally managed
## modules on a remote web server via an intuitive yet powerful command line
## utility.  The possibilities are endless - we have used dcm.pl to provide
## simple console utilities such as ip mask calculations and checking the load
## of the web server, and for advanced tasks such as using it with cron to 
## schedule database maintenance, archiving config files, checking source code
## in and out of a rcs system, etc.
## 
##############################################################################
##  
##  CODING STANDARDS
##  Synopsis:
##    * Comments are to begin with two pounds: ##
##    * Use an indent of 4 spaces, with NO TABS!
##    * Functions must have a descriptive header with the name, description,
##      input requirements, output, and example usage.
##    * At least one command line argument is REQUIRED before a script does
##      anything!
##    * When no command line arguments are supplied the script should display
##      a human readable usage summary.
##    * The "-h" and "--help" command line options must be supported.
##    * Scripts must exit with an error code of 0 on success, and non-zero
##      on error.
##  
##############################################################################
##  
##  Changelog:
##
##	06/22/2012 - v1.19 - Matt Pascoe
##          - Fix issues with URL parsing of the connector URL.
##	01/25/2011 - v1.19 - Matt Pascoe
##          - Added ability to use username and password set in ENV variables.
##            Just set DCM_LOGIN_USER and/or DCM_LOGIN_PASS
##	04/18/2008 - v1.18 FORK - Matt Pascoe
##	    - I forked due to some minor changes I made, also this version will be included
##	      with the base ONA install with some specific configuration settings
##	    - Removed code that strips trailing newline from STDIN
##      
##      03/07/2007 - v1.17 - Brandon Zehm
##          - First public release!
##          - Renamed several config file options! Old config file won't work!
##          - Check for dcm.conf in ~/, ~/.dcm, /etc, /etc/dcm and other places.
##          - Added basic auth support
##          - Added command line args for overriding the connector url
##          - Added config option to require https
##          - Close $FILE when done with it during command line processing.
##      
##      06/06/2006 - v1.16 - Brandon Zehm
##          - First public release canidate
##          - Integrated functions from inc_standard.pl into dcm.pl
##      
##      05/24/2006 - v1.15 - Brandon Zehm
##          - Allow stand-alone key's on the command line
##      
##      04/18/2006 - v1.14 - Brandon Zehm
##          - Pass unix username to the module being run
##            This will enable unix username based security if desired
##      
##      01/03/2006 - v1.13 - Brandon Zehm
##          - Print "NO SSL" error message to STDERR
##      
##      11/17/2005 - v1.12 - Brandon Zehm
##          - Add option for displaying & switching ipdb contexts
##      
##      11/11/2005 - v1.11 - Brandon Zehm
##          - Add "create symlinks" option
##      
##      11/08/2005 - v1.10 - Brandon Zehm
##          - Fixed a few syntax issues
##      
##      10/26/2005 - v1.09 - Brandon Zehm
##          - Allow value in key=value pairs to be the name of an
##            input file, or - for STDIN.
##      
##      10/25/2005 - v1.08 - Brandon Zehm
##          - Use HTTP POST method for sending "options" to support
##            large data uploads.
##      
##      10/24/2005 - v1.07 - Brandon Zehm
##          - Added support for reading a configuration file
##      
##      10/21/2005 - v1.06 - Brandon Zehm
##          - Added support for HTTP/1.1 chunked transfer encoding
##            for receiving large amounts of data.
##      
##      10/18/2005 - v1.05 - Brandon Zehm
##          - Added SSL support - SSL is now used automatically if
##            the perl IO::Socket::SSL module is available.
##          - Added support to symlink this script to a module's 
##            name and run that module automatically.
##      
##      09/15/2005 - v1.04 - Brandon Zehm
##          - Remove -o option.  Assume everything after the module
##            name are key=value options for that module until a
##            hyphen (-) is the first character of an option.
##          - Added search for inc_standard.pl
##
##      09/08/2005 - v1.03 - Brandon Zehm
##          - Read function exit status from result, and exit with 
##            appropriate error code.
##      
##      08/29/2005 - v1.02 - Brandon Zehm
##          - Fixed a few "use of uninitialized variable" errors.
##      
##      08/22/2005 - v1.01 - Brandon Zehm
##          - Fixed Time::HiRes conditional loading
##          - Moved some more initialization code to functions.pl
##      
##      08/17/2005 - v1.00 - Brandon Zehm
##          - Final v1.00 released
##      
##############################################################################
use strict;
use IO::Socket;


##
## GLOBAL VARIABLES
## These global variables are availble in all scopes and should be
## used in all scripts where approperiate.
## The defaults set here are only used if they are not overridden
## from a configuration file or command line parameter.
##


## General configuration settings
my %conf = (
    
    ## Predefined
    'programName'          => $0,                              ## The name of this program
    'hostname'             => 'localhost',                     ## Used in printmsg() for all output.
    'unix_username'        => getlogin || getpwuid($<),        ## Current user's unix username
    
    ## For printing colors to the console
    'colorBold'            => "\033[1m",
    'colorNoBold'          => "\033[0m",
    'colorWhite'           => "\033[37;1m",
    'colorNormal'          => "\033[m",
    'colorRed'             => "\033[31;1m",
    'colorGreen'           => "\033[32;1m",
    'colorCyan'            => "\033[36;1m",
    
    ## Script specific settings
    'version'              => '1.20-ona',                      ## The version of this program
    'authorName'           => 'Brandon Zehm/Matt Pascoe',      ## Author's Name
    'authorEmail'          => 'caspian@dotconf.net/matt@opennetadmin.com',           ## Author's Email Address
    'configurationFile'    => '',                              ## Configuration file location
    
);


## Logging options
my %logging = (
    
    'stdout'                 => 1,                             ## Print messages to stdout  (0=no, 1=yes)
    'logFile'                => '',                            ## Log messages to specified file
    'logging'                => 0,                             ## Log messages - don't set manually! set logFile option. (0=no, 1=yes)
    'syslog'                 => 0,                             ## Syslog messages  (0=no, 1=yes)
    'facility'               => 1,                             ## Syslog faciltiy (1 == USER)
    'priority'               => 6,                             ## Syslog priority (6 == INFO)

);


## Networking options
my %networking = (
    
    'url'                    => 'http://localhost/ona/dcm.php',## Default DCM connector URL
    'login'                  => '',                            ## HTTP basic auth username
    'passwd'                 => '',                            ## HTTP basic auth password
    'allow-http-fallback'    => 1,                             ## Allow HTTP connections when an HTTPS url is specified
    'timeout'                => 360,                           ## Timeout in seconds for any/all connections
    
    ## INTERNAL USE ONLY
    'URL'                    => '',                            ## hack override url (for command line parsing)
    'host'                   => '',                            ## hostname
    'port'                   => '',                            ## port
    'uri'                    => '/dcm.php',                    ## http uri
    'ssl'                    => 0,                             ## Did the uri specify http or https?
    'sslAvailable'           => 0,                             ## Does this perl installation support SSL?
    'sslWarning'             => 1,                             ## Warn on STDERR when connection is insecure
    'user-agent'             => 'console-module-interface',    ## User agent used in HTTP request

);


## This is a global hash to make life easy.  Info about the 
## state of the program or temporary messages get stored in here.
my %self = (
    'error'                  => '',
);


## Debug/Verbosity level of the script.
## This is it's own scalar (rather than in a hash) to improve speed.
my $debug = 0;


## This hash contains the key=value pairs of data being passed to 
## the module the user chooses to run.
my %opt = ();


## Load Time::HiRes if it's available
eval { require Time::HiRes; };
unless ($@) { Time::HiRes->import qw(time); }


## Load IO::Socket::SSL if it's available
eval { require IO::Socket::SSL; };
unless ($@) { $networking{'sslAvailable'} = 1; }












######################################################################
##                 START OF STD LIBRARY FUNCTIONS                   ##
######################################################################










##
## INITIALIZATION
## Here is a small bit of initialization code that gets run
## before everything else.
##

## Fixup $conf{'programName'}
$conf{'programName'} =~ s/(.)*[\/,\\]//;
$0 = $conf{'programName'} . " " . join(" ", @ARGV);

## Fixup $conf{'hostname'}
if ($conf{'hostname'} eq 'localhost') {
    $conf{'hostname'} = "";
    
    if ($ENV{'HOSTNAME'}) {
        $conf{'hostname'} = lc($ENV{'HOSTNAME'});
    }
    elsif ($ENV{'COMPUTERNAME'}) {
        $conf{'hostname'} = lc($ENV{'COMPUTERNAME'});
    }
    else {
        ## Try the hostname module
        eval { require Sys::Hostname; };
        unless ($@) {
            Sys::Hostname->import qw(hostname);
            $conf{'hostname'} = lc(hostname());
        }
    }
    
    ## Assign a name of "localhost" if it can't find anything else.
    if (!$conf{'hostname'}) {
        $conf{'hostname'} = 'localhost';
    }
    
    $conf{'hostname'} =~ s/\..*$//;  ## Remove domain name if it's present
}











###############################################################################################
##  Function:    printmsg (string $message, [int $level], [*FILEHANDLE])
##
##  Description: Handles all messages - 
##               Depending on the state of the program it will log
##               messages to a log file, print them to STDOUT or both.
##               
##
##  Input:       $message          A message to be printed, logged, etc.
##               $level            The debug level of the message. If not defined 0
##                                 will be assumed.  0 is considered a normal message, 
##                                 1 and higher is considered a debug message.
##               $filehandle       Optional reference to a filehandle to print to rather than
##                                 printing to STDOUT.
##  
##  Output:      Prints to STDOUT, to $logging{'LOGHANDLE'}, both, or none depending 
##               on the state of the program and the debug level specified.
##  
##  Example:     printmsg("ERROR => The file could not be opened!", 0);
###############################################################################################
sub printmsg {
    ## Assign incoming parameters to variables
    my ( $message, $level, $fh ) = @_;
    
    ## Make sure input is sane
    $level = 0 if (!defined($level));
    
    ## Continue only if the debug level of the program is >= message debug level.
    if ($debug >= $level) {
        
        ## Use STDOUT if a filehandle wan't specified
        if (!$fh) {
            $fh = *STDOUT;
        }
        
        ## Change \r\n's to spaces
        $message =~ s/\r?\n/ /go;
        
        ## Get the date in the format: Dec  3 11:14:04
        my ($sec, $min, $hour, $mday, $mon) = localtime();
        $mon = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$mon];
        my $date = sprintf("%s %02d %02d:%02d:%02d", $mon, $mday, $hour, $min, $sec);
        
        ## Syslog the message is needed
        if ($logging{'syslog'}) {
            syslog('/dev/log', $logging{'priority'}, $logging{'facility'}, "$conf{'programName'}\[$$\]: $message");
        }
        
        ## Print to STDOUT always if debugging is enabled, or if the mode is NOT "running".
        if ($logging{'stdout'}) {
            print {$fh} "$date $conf{'hostname'} $conf{'programName'}\[$$\]: $message\n";
        }
        
        ## Print to the log file if $logging{'logging'} is true
        if ($logging{'logging'}) {
            print {$logging{'LOGHANDLE'}} "$date $conf{'hostname'} $conf{'programName'}\[$$\]: $message\n";
        }
        
    }
    
    ## Return 0 errors
    return(0);
}














###############################################################################################
## FUNCTION:    
##   openLogFile ( $filename )
## 
## 
## DESCRIPTION: 
##   Opens the file $filename and attaches it to the filehandle "$logging{'LOGHANDLE'}".
##   Returns 0 on success and non-zero on failure.  Error codes are listed below, and the
##   error message gets set in global variable $!.
##   
##   
## Example: 
##   openFile ("/var/log/scanAlert.log");
##
###############################################################################################
sub openLogFile {
    ## Get the incoming filename
    my $filename = $_[0];
    
    ## Make sure our file exists, and if the file doesn't exist then create it
    if ( ! -f $filename ) {
        printmsg("NOTICE => The file [$filename] does not exist.  Creating it now with mode [0600].", 0);
        open ($logging{'LOGHANDLE'}, ">>$filename");
        close $logging{'LOGHANDLE'};
        chmod (0600, $filename);
    }
    
    ## Now open the file and attach it to a filehandle
    open ($logging{'LOGHANDLE'},">>$filename") or return (1);
    
    ## Put the file into non-buffering mode
    select $logging{'LOGHANDLE'};
    $| = 1;
    select STDOUT;
    
    ## Tell the rest of the program that we can log now
    $logging{'logging'} = 1;
    
    ## Return success
    return(0);
}
















###############################################################################################
## FUNCTION:    
##   syslog (string $socketName, int $priority, int $facility, string $message)
## 
## 
## DESCRIPTION: 
##   Connects to the socket $socketName, and sends it a syslog formatted message.  
##   i.e. it syslog's $message with the priority and facility specified.
##   Returns 0 on success, non-zero on error.  If an error occurs the error message
##   is stored in the global variable $self{'error'}.
##
## Example: 
##   syslog("/dev/log", 6, 1, "Test syslog message");
##
##
## Priorities (on a Linux system)
##   LOG_EMERG       0       system is unusable
##   LOG_ALERT       1       action must be taken immediately
##   LOG_CRIT        2       critical conditions
##   LOG_ERR         3       error conditions
##   LOG_WARNING     4       warning conditions
##   LOG_NOTICE      5       normal but significant condition
##   LOG_INFO        6       informational
##   LOG_DEBUG       7       debug-level messages
##
##
## Facilities (on a Linux system)
##   LOG_KERN        0       kernel messages
##   LOG_USER        1       random user-level messages
##   LOG_MAIL        2       mail system
##   LOG_DAEMON      3       system daemons
##   LOG_AUTH        4       security/authorization messages
##   LOG_SYSLOG      5       messages generated internally by syslogd
##   LOG_LPR         6       line printer subsystem
##   LOG_NEWS        7       network news subsystem
##   LOG_UUCP        8       UUCP subsystem
##   LOG_CRON        9       clock daemon
##   LOG_AUTHPRIV    10      security/authorization messages (private)
##   LOG_FTP         11      ftp daemon
##   LOG_LOCAL0      16      reserved for local use
##   LOG_LOCAL1      17      reserved for local use
##   LOG_LOCAL2      18      reserved for local use
##   LOG_LOCAL3      19      reserved for local use
##   LOG_LOCAL4      20      reserved for local use
##   LOG_LOCAL5      21      reserved for local use
##   LOG_LOCAL6      22      reserved for local use
##   LOG_LOCAL7      23      reserved for local use
##
## v1.1 - 01/16/2004 - Textual changes to error messages
## v1.2 - 03/27/2004 - Remove hashes to improve performance
###############################################################################################
sub syslog {
    
    ## Get incoming variables
    my ($socketName, $priority, $facility, $message) = @_;
    
    ## Set defaults if some variables are not defined
    $socketName  = "/dev/log"         if (!defined($socketName));
    $priority    = 6                  if (!defined($priority));
    $facility    = 1                  if (!defined($facility));
    $message     = "Default Message"  if (!defined($message));
    
    ## Bit-shift the facility (black magic)
    $facility = ($facility << 3);
    
    ## Make sure values are sane (more black magic)
    $priority = $priority & 0x07;
    $facility = $facility & 0x3f8;
    
    ## Generate syslog value for the priority and facility
    my $value = ($priority + $facility);
    
    if (! -S $socketName) {
        $self{'error'} = "ERROR => The specified syslog socket [$socketName] either does not exist or is not a socket.";
        return(1);
    }
    
    ## Open a UNIX socket in dgram mode with udp protocol. 
    socket(SOCKET, PF_UNIX, SOCK_DGRAM, 0) or do { 
        $self{'error'} = "ERROR => syslog(): $!";
        return(2);
    };
    
    ## Connect our socket to SOCKET
    connect(SOCKET, sockaddr_un ($socketName)) or do {
        $self{'error'} = "ERROR => syslog(): $!";
        return(3);
    };
    
    ## Sending the message to the syslog socket
    print SOCKET "<$value>$message" or do {
        $self{'error'} = "ERROR => syslog(): $!";
        return(4);
    };
    
    ## Close the socket
    close SOCKET;
    
    ## Return success
    return(0);
}












###############################################################################################
## FUNCTION:    
##   returnConfigurationFileSections ( string $filename )
## 
## 
## DESCRIPTION: 
##   Reads the file $filename, finds any defined sections, and returns a list of them.  
##   This version of this function reads .ini style files.
##
## Example: 
##   my @list = returnConfigurationFileSections("/etc/configuration.conf");
##
###############################################################################################
sub returnConfigurationFileSections {
    
    ## Get incoming variables
    my ($fileName) = @_;
    
    ## Verify input
    if ( (!$fileName) ) {
        $self{'error'} = "ERROR => returnConfigurationFileSections() One or more incoming parameters were empty";
        return(1);
    }
    
    ## Open the file
    open(CONFFILE, $fileName) or quit("ERROR => Error while opening the configuration file [$fileName].  The error was [$!]",1);
    
    ## Read entire file into a scalar so we can effectivly remove c style /* */ comments
    my $file = "";
    while (<CONFFILE>) {
        $file .= $_;
    }
    close(CONFFILE);
    
    ## Remove comments and whitespace
    $file =~ s/\/\*.*?\*\///ogs;        ## Remove C Style /* */ style comments
    $file =~ s/([^\\])\#.*$/$1/ogm;     ## Remove pound (#) comments - unless backslash escaped
    $file =~ s/\\\#/\#/ogm;             ## Replace '\#' with '#' 
    $file =~ s/\/\/.*$//ogm;            ## Remove slash (//) comments 
    $file =~ s/^\s*(\n|\r\n)//ogm;      ## Remove blank lines
    
    ## Find section names and store them into an array
    my @entries = ();
    foreach my $line (split(/\r?\n/, $file)) {
        if ($line =~ /^\s*\[(.*)\]\s*$/) {
            push(@entries, $1);
        }
    }
    
    ## Check for duplicate entries
    foreach my $entry (@entries) {
        if (scalar(grep(/^$entry$/, @entries)) >= 2) {
            printmsg("WARNING => There are two section definitions in the configuration file [$file] named [$entry]", 0);
        }
    }
    
    ## Return
    return(@entries);
}


















###############################################################################################
## FUNCTION:    
##   readConfigurationFile ( string $filename, string $section, reference $hash_reference )
## 
## 
## DESCRIPTION: 
##   Reads the file $filename, and stores information from the file into the hash 
##   at $hash_reference.  This version of this function reads .ini style files.
##
## Example: 
##   readConfigurationFile("/etc/configuration.conf", "general", \%myHash);
##
###############################################################################################
sub readConfigurationFile {
    
    ## Get incoming variables
    my ($fileName, $section, $hashref) = @_;
    
    
    ## Verify input
    if ( (!$fileName) or (!$section) or (!$hashref) ) {
        printmsg("DEBUG => readConfigurationFile() Incoming parameters are: file: $fileName,  section: $section, hashref: $hashref", 2);
        $self{'error'} = "ERROR => readConfigurationFile() One or more incoming parameters were empty";
        return(1);
    }
    
    ## Open the file
    open(CONFFILE, $fileName) or quit("ERROR => Opening the configuration file [$fileName] returned the error [$!]",1);
    
    ## Read the file into a single scalar variable
    my $file = "";
    while (<CONFFILE>) { $file .= $_; }
    close(CONFFILE);
    
    ## Remove comments and whitespace
    $file =~ s/\/\*.*?\*\///ogs;      ## Remove C Style /* */ style comments
    $file =~ s/([^\\])\#.*$/$1/ogm;   ## Remove pound (#) comments - unless backslash escaped
    $file =~ s/\\\#/\#/ogm;           ## Replace '\#' with '#' 
    $file =~ s/([^:])\/\/.*$/$1/ogm;  ## Remove slash (//) comments (not :// though, that would be a URL)
    $file =~ s/^\s*(\n|\r\n)//ogm;    ## Remove blank lines
    
    
    ## Find the section we want and store the lines of that section in @lines
    my $inSection = 0;
    foreach my $line (split(/\r?\n/, $file)) {
        if ($inSection == 1) {
            if ($line =~ /^\s*\[.*\]\s*$/) {
                ## We're at the end of the section (starting a new section), stop
                $inSection = 0;
                last;
            }
            else {
                ## This is a normal line in the section, parse it and add data to $hashref
                if ($line) {
                    ## Remove whitespace
                    $line =~ s/(^\s+)|(\s+$)//og;
                    ## Don't continue unless the line looks valid
                    next if ( (!$line) or ($line !~ /=>/) );
                    ## Get and store the key/value pair
                    my ($key, $value) = split(/\s*=>\s*/, $line);
                    printmsg("DEBUG => readConfigurationFile() [$section] Found key value pair: $key => $value", 3);
                    ${$hashref}{$key} = $value;
                }
            }
        }
        ## If we found the right section, start recording it's lines to @lines
        if ($line =~ /^\s*\[$section\]\s*$/) {
            $inSection = 1;
        }
    }
    
    ## Return 0 errors
    return(0);
}














######################################################################
##  Function:    quit (string $message, int $errorLevel)
##  
##  Description: Exits the program, optionally printing $message.  It 
##               returns an exit error level of $errorLevel to the 
##               system  (0 means no errors, and is assumed if empty.)
##
##  Example:     quit("Exiting program normally", 0);
######################################################################
sub quit {
    my ( $message, $errorLevel ) = @_;
    $errorLevel = 0 if (!defined($errorLevel));
    
    ## Print exit message
    if ($message) { 
        ## Change the syslog facility to 3/daemon if there is an exit error.
        if ($errorLevel >= 0) {
            $logging{'facility'} = 3;
        }
        printmsg($message, 0);
    }
    
    ## Exit
    exit($errorLevel);
}










######################################################################
##                 END OF STD LIBRARY FUNCTIONS                     ##
######################################################################










#########################################################
## SUB: help
##
## hehe, for all those newbies ;)
#########################################################
sub help {
print <<EOM;

$conf{'colorBold'}$conf{'programName'}-$conf{'version'} by $conf{'authorName'} <$conf{'authorEmail'}>$conf{'colorNoBold'}

Usage:
  $conf{'programName'} <action> [options]
  
$conf{'colorRed'}  Actions: $conf{'colorNormal'}
    --list                  list available modules
    --symlink               create symlinks of each module name to dcm.pl
    -r MODULE [K=V] ...     run specified module with KEY=VALUE options
                              VALUE may also be a filename or - for STDIN
    
$conf{'colorGreen'}  General Options: $conf{'colorNormal'}
    -c FILE                 configuration file [$conf{'configurationFile'}]
    -u URL                  connector url, format: http[s]://server[:port]/url
    -l LOGIN                login for http authentication
    -p PASSWORD             password for http authentication
    -v                      verbosity - use multiple times for greater effect
    
$conf{'colorGreen'}  Logging Options: $conf{'colorNormal'}
    --nostdout              don't print messages to STDOUT
    --syslog                syslog all messages
    --logfile=FILE          log all messages to the specified file

EOM
exit(1);
}















######################################################################
##  Function: initialize ()
##  
##  Does all the script startup jibberish.
##  
######################################################################
sub initialize {
    
    ## Set STDOUT to flush immediatly
    $| = 1;
    
    ## Intercept signals
    $SIG{'QUIT'}  = sub { quit("EXITING: Received SIG$_[0]", 1); };
    $SIG{'INT'}   = sub { quit("EXITING: Received SIG$_[0]", 1); };
    $SIG{'KILL'}  = sub { quit("EXITING: Received SIG$_[0]", 1); };
    $SIG{'TERM'}  = sub { quit("EXITING: Received SIG$_[0]", 1); };
    
    $SIG{'HUP'}   = sub { quit("EXITING: Received SIG$_[0]", 1); };
    $SIG{'ALRM'}  = sub { quit("EXITING: Received SIG$_[0]", 1); };
    
    ## Let children exit on their own so the parent doesn't have to reap them.
    ## $SIG{'CHLD'}  = 'IGNORE';
    
    return(0);
}











######################################################################
##  Function: processCommandLine ()
##  
##  Processes command line storing important data in global var %conf
##  
######################################################################
sub processCommandLine {
    
    
    ############################
    ##  Process command line  ##
    ############################
    
    ## If this is a symlink to dcm.pl, the name of the symlink is used
    ## as the name of the module to run.
    if ($conf{'programName'} ne 'dcm.pl') {
        $self{'module'} = $conf{'programName'};
    }
    
    my @ARGS = @ARGV;
    my $numargv = @ARGS;
    help() unless ($numargv or $self{'module'});
    my $counter = 0;
    for ($counter = 0; $counter < $numargv; $counter++) {
        
        ## ACTION: run specified module (and get options for the module)
        if ( ($ARGS[$counter] eq '-r') or  ($self{'module'} and $ARGS[$counter] !~ /^-/o) ) {
            
            ## Unless a module is already specified, get it
            unless ($self{'module'}) {
                $counter++;
                $self{'module'} = $ARGS[$counter];
                $counter++;
            }
            
            ## Loop through each option passed after the module name
            while ($ARGS[$counter] && $ARGS[$counter] !~ /^-/o) {
                if ($ARGS[$counter] =~ /(\S+)=(\S.*)/) {
                    $opt{$1} = $2;
                    printmsg("DEBUG => Assigned module option key/value: $1 => $2", 3);
                }
                elsif ($ARGS[$counter] =~ /(\S+)=$/) {
                    $opt{$1} = '';
                    printmsg("DEBUG => Assigned module option key/value: $1 => ''", 3);
                }
                elsif ($ARGS[$counter] =~ /(\S+)/) {
                    $opt{$1} = 'Y';
                    printmsg("DEBUG => Assigned module option key/value: $1 => Y", 3);
                }
                else {
                    ## I can't think of why this would ever happen, but whatever... ;)
                    printmsg("WARNING => Key/Value pair [$ARGS[$counter]] is not properly formatted", 0);
                    printmsg("WARNING => Module arguments should be in the form of \"key=value\"", 0);
                }
                $counter++;
            }   $counter--;
        }
        
        ## ACTION: list available modules
        elsif ($ARGS[$counter] eq '--list') {
            $self{'module'} = 'get_module_list';
            $opt{'type'} = 'string';
        }
        
        ## ACTION: create symlinks
        elsif ($ARGS[$counter] eq '--symlink') {
            $self{'module'} = 'get_module_list';
            $opt{'type'} = 'perl';
        }
        
        ## configuration file
        elsif ($ARGS[$counter] eq '-c') {
            $counter++;
            $conf{'configurationFile'} = $ARGS[$counter];
            if (! -e $conf{'configurationFile'}) {
                printmsg("WARNING => Configuration file specified, $conf{'configurationFile'} , doesn't exist!", 0);
            }
        }
        
        ## connector url
        elsif ($ARGS[$counter] eq '-u') {
            $counter++;
            $networking{'URL'} = $ARGS[$counter];
        }
        
        ## basic auth user
        elsif ($ARGS[$counter] eq '-l') {
            $counter++;
            $networking{'login'} = $ARGS[$counter];
        }
        
        ## basic auth password
        elsif ($ARGS[$counter] eq '-p') {
            $counter++;
            $networking{'passwd'} = $ARGS[$counter];
        }
        
        ## verbosity
        elsif ($ARGS[$counter] =~ /^-v+/io) {
            $debug += (length($&) - 1);
        }
        
        ## syslog is enabled
        elsif ($ARGS[$counter] =~ /^--syslog/i) {
            $logging{'syslog'} = 1;
        }
        
        ## nostdout
        elsif ($ARGS[$counter] =~ /^--nostdout/i) {
            $logging{'stdout'} = 0;
        }
        
        ## log file
        elsif ($ARGS[$counter] =~ /^--logfile=(.*)/i) {
            $logging{'logFile'} = $1;
        }
        
        ## help
        elsif ($ARGS[$counter] =~ /^-h$|^--help/) {
            help();
        }
        
        else {
            printmsg("\"$ARGS[$counter]\" is not a recognised option!", 0);
            quit("", 1);
        }
        
    }
    
    
    ## Print help if we're not becoming a daemon.
    if (!$self{'module'}) {
        quit("WARNING => No action was specified, try --help!",1);
    }
    
    ###################################################
    ##  Input validation
    ###################################################
    
    ## Open the log file if we need to
    if ($logging{'logFile'}) {
        if (openLogFile($logging{'logFile'})) {
            printmsg("WARNING => Log file could not be opened!", 0);
        }
    }
    
    ## Return 0 errors
    return(0);
}












######################################################################
##  Function: basicAuth ($login, $pass)
##              $login:  login name
##              $pass:   password
##            
##  Output:   Sets a global variable with the encoded pass-phrase
##            getPage() will use this variable if it is defined
##            when called.
##            
##  Example:  basicAuth ($login, $pass); getPage("/site/secure/index.html");
######################################################################
sub basicAuth {
  my ($login, $pass) = @_;
  
  $conf{'basicAuth'} = "$login:$pass";
  
  ## Base64 encode the login and password
  my $padding = (3 - length($conf{'basicAuth'}) % 3) % 3;                     ## Set flag if binary data isn't divisible by 3
  $conf{'basicAuth'} = substr(pack('u', $conf{'basicAuth'}), 1);              ## Convert the binary to uuencoded text
  chop($conf{'basicAuth'});
  $conf{'basicAuth'} =~ tr|` -_|AA-Za-z0-9+/|;                                ## Translate from uuencode to base64
  $conf{'basicAuth'} =~ s/.{$padding}$/'=' x $padding/e if $padding;          ## Fix the end padding if flag (from above) is set
  
  return(1);
}








###############################################################################################
## FUNCTION:    
##   urlencode ( string $str )
## 
## 
## DESCRIPTION: 
##   Encodes $str for use in an URL call
##
## Example: 
##   $str = urlencode("file=/etc/passwd&debug=3");
##
###############################################################################################
sub urlencode {
    ## Get incoming variables
    my ($str) = @_;
    $str =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/sego;
    return($str);
}












###############################################################################################
## FUNCTION:    
##   urldecode ( string $str )
## 
## 
## DESCRIPTION: 
##   Encodes $str for use in an URL call
##
## Example: 
##   $str = urldecode("file=/etc/passwd&debug=3");
##
###############################################################################################
sub urldecode {
    ## Get incoming variables
    my ($str) = @_;
    $str =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/sego;
    return($str);
}












## getline($socketRef)
sub getline {
    my ($socket) = @_;
    local ($/) = "\r\n";
    return readline *{$$socket};
}










######################################################################
## Function: getPage(string $URI, string $post, bool $return_headers, $socket)
## 
## DESCRIPTION:
##     Generates a web request out of the URI, sends it to the
##     ALREADY setup network connection on $self{webHost}, reads
##     the response, and returns the result.
## 
## INPUT:
##     $URI is a url, it should not contain http:// or www.blah.com, 
##     it shoul look like this: /site/index.html?name=value&blah=test
##     The string should already have been urlencode()'d.
##     
##     $post is pre-formatted http post data to send to the browser.
##     If it's not an empty string an HTTP POST will be done rather
##     than a GET.
##     
##     $return_headers indicates that we should return the http 
##     headers with the result.  1 enables, 0 disables (default).
##     
##     $socket is a reference to the socket which should be already
##     connected to a web server.
##      
## OUTPUT:
##     Returns a string containing the web server's response.
##     
######################################################################
sub getPage {
    
    ## Get incoming variables
    my ($uri, $post, $return_headers, $socket) = @_;
    chomp $uri;
    
    ## Generate Request
    my $request = "";
    my $method = "GET";
    if ($post) { $method = "POST"; }
    
    $request =  "$method $uri HTTP/1.1\r\n" . 
                "Accept: \*\/\*\r\n" . 
                "Host: $networking{'host'}\r\n" .
                "User-Agent: $networking{'user-agent'} $conf{'programName'}-$conf{'version'}\r\n" .
                "Connection: close\r\n";
    $request .= "Authorization: Basic $conf{'basicAuth'}\r\n" if ($conf{'basicAuth'});
    if ($post) {
        $request .= "Content-type: application/x-www-form-urlencoded\r\n" ;
        $request .= "Content-length: " . length($post) . "\r\n";
    }
    $request .= "\r\n";
    if ($post) {
        $request .= $post;
    }
    
    ## Request Page
    if ($debug >= 4) {
        print "Sending HTTP Request:\n", $request;
    }
    print {$$socket} ($request);
    
    ## Read the HTTP response
    my $foundAllHeaders = 0;
    my $headers = '';
    my $data = '';
    my $contentEncoding = 'plain';
    my $contentLength = 0;
    my $contentRemaining = 0;
    
    ## First read the headers and extract some important information
    while ($foundAllHeaders == 0) {
        ## Read a line
        my $line = getline($socket);
        
        ## Quit if the read failed
        if (!$line) { quit("ERROR => HTTP read failed!", 1); }
        
        printmsg("DEBUG => getPage() received line: $line", 4);
        
        ## If it's a blank line we're done with the headers
        if ($line eq "\r\n") {
            $foundAllHeaders = 1;
        }
        
        ## Otherwise postpend the line to $headers
        else {
            $headers .= $line;
            
            ## Extract some important information
            if ($line =~ /Content-Length:\s*(\d+)/io) {
                $contentLength = $1;
                $contentRemaining = $1;
                printmsg("DEBUG => getPage() Content-Length: $contentLength", 1);
            }
            elsif ($line =~ /Transfer-Encoding:\s*(\S+)/io) {
                printmsg("DEBUG => getPage() Transfer-Encoding: $1", 1);
                $contentEncoding = $1;
            }
        }
    }
    
    ## If it's chunked data encoding
    if ($contentEncoding =~ /chunked/io) {
        ## Read lines
        my $cLength = -1;
        my $cRemaining = -1;
        while (my $line = getline($socket)) {
            
            ## Read the chunk header
            if ($cLength == -1) {
                $line =~ /^(\w+)/o;
                $cLength = $cRemaining = hex($1);
                printmsg("DEBUG => Receiving chunked message: $cLength bytes", 2);
            }
            
            ## Receive the body of the chunked message
            elsif ($cRemaining >= 1) {
                printmsg("DEBUG => getPage() read " .  length($line) . " of $cRemaining remaining bytes", 1);
                $cRemaining -= length($line);
                $data .= substr($line, 0, $cRemaining);
            }
            
            ## cRemaining will be -2 when we're done receiving a chunk
            ## so read any remaining chunk footers
            elsif ($cRemaining == -2) {
                ## If we're at the end of footers, set $cRemaining to -1 so it will start reading headers again.
                if ($line eq "\r\n") {
                    $cRemaining = -1;
                }
            }
        }
    }
    
    ## If it's normal data encoding
    else {
        ## Now read the rest of the data
        while ($contentRemaining > 0) {
            my $line = getline($socket);
            my $bytes = length($line);
            $data .= $line;
            $contentRemaining -= $bytes;
            printmsg("DEBUG => getPage() received $bytes of data: $line", 4);
        }
        
        ## Validate our data
        if (length($data) != $contentLength) {
            printmsg("NOTICE => getPage() Content-Length specified ($contentLength) and actual bytes read (" . length($data) . ") don't match!", 0);
        }
    }
    
    ## Return the data
    if ($return_headers == 1) {
        return($headers . "\r\n" . $data);
    }
    return($data);
}















#############################
##
##      MAIN PROGRAM
##
#############################

## Initialize signal handlers and such
initialize();

## Get contents of /etc/onabase, and trim it
my $onabase =  qx(cat /etc/onabase 2>/dev/null);
$onabase =~ s/\s+$//;

## Search for a configuration file
my $homedir = "~";
if ($ENV{'HOME'}) { $homedir = $ENV{'HOME'}; }
if ($ENV{'HOMEDRIVE'} and $ENV{'HOMEPATH'}) { $homedir = $ENV{'HOMEDRIVE'} . $ENV{'HOMEPATH'}; }
my @file_list = (
    $conf{'configurationFile'},
    './.dcm/dcm.conf',
    './dcm.conf',
    $homedir . '/.dcm/dcm.conf',
    $homedir . '/dcm.conf',
    $onabase . '/etc/dcm.conf',
    '/opt/ona/etc/dcm.conf',
    '/etc/dcm.conf',
    '/etc/dcm/dcm.conf',
);
foreach my $file (@file_list) {
    if (-e $file) {
        $conf{'configurationFile'} = $file;
        printmsg("DEBUG => Found configuration file at $file", 1);
        last;
    }
}

## Read the configuration file
readConfigurationFile($conf{'configurationFile'}, "networking", \%networking);
readConfigurationFile($conf{'configurationFile'}, "logging", \%logging);

## If we have an environment user or password, set it
if ($ENV{'DCM_LOGIN_USER'} ) {
    $networking{'login'} = $ENV{'DCM_LOGIN_USER'}
}
if ($ENV{'DCM_LOGIN_PASS'} ) {
    $networking{'passwd'} = $ENV{'DCM_LOGIN_PASS'}
}

## Process Command Line
processCommandLine();

## Setup http basic auth if needed
if ($networking{'login'}) {
    basicAuth($networking{'login'}, $networking{'passwd'});
}

if ($networking{'URL'}) { $networking{'url'} = $networking{'URL'}; }


##
## Parse $networking{'url'} into it's various parts
## url should look like this: http[s]://server[:port]/url
##
if ($networking{'url'} !~ /^((http[s]?):\/)?\/?([^:\/\s]+)(:([^\/]*))?((\/\w+)*\/)([\w\-\.]+[^#?\s]+)/) {
    quit("ERROR => Invalid connector URL: $networking{'url'}", 1);
}
if ($2 eq 'http')     { $networking{'ssl'} = 0; $networking{'port'} = 80; }
elsif ($2 eq 'https') { $networking{'ssl'} = 1; $networking{'port'} = 443; }
else { quit("ERROR => Invalid protocol: $2", 1); }
$networking{'host'} = $3;
$networking{'uri'}  = $6.$8;
if ($5) { $networking{'port'} = $5; }



##
## Prepare to make a query to the web server
##

## Make an "options" string, of the options specified with -o KEY=VALUE KEY=VALUE ....
## that we can pass to the web server.
my $option_string = "";
$opt{'unix_username'} = $conf{'unix_username'};
foreach my $key (keys(%opt)) {
    ## If the value specified is a file, or -, load the file's contents (or STDIN) as the value
    if ( (-e $opt{$key} and -r $opt{$key}) or ($opt{$key} eq '-') ) {
        my $FILE;
        if(!open($FILE, ' ' . $opt{$key})) {
            quit("ERROR => couldn't open input file, $opt{$key}, $!", 1);
        }
        $opt{$key} = '';
        while (<$FILE>) {
            $opt{$key} .= $_;
        }
        close $FILE;
        ## Strip an ending \n (so that `echo test_message | dcm.pl -r test key=-` works properly)
	## MP: removed, causes files to be different in the DB than on filesystems
	## should be done as `echo -n test_message | dcm.pl -r test key=-` or equivilant
        #$opt{$key} =~ s/\r?\n$//os;
    }
    
    ## Quote any "special" characters in the value.
    ## Specifically the '=' and '&' characters need to be escaped.
    $opt{$key} =~ s/[=&]/\\$&/gos;
    
    ## Now add the key=value pair to the $option_string
    $option_string .= "$key=$opt{$key}&";
}
$option_string =~ s/\&$//o;
$option_string = urlencode($option_string);

## Connect to the web server, use a 10 second timeout for initial connect
my $SOCKET;
$SIG{'ALRM'} = sub { $conf{'error'} = "connection timeout exceeded (10 seconds)"; };
alarm(10);
if ($networking{'ssl'} == 1 && $networking{'sslAvailable'} == 0) {
    if ($networking{'allow-http-fallback'} == 0) {
        quit("ERROR => No SSL support available- try installing IO::Socket::SSL", 1);
    }
    printmsg("WARNING => Connection insecure! Install IO::Socket::SSL for https support", 0, *STDERR);
}

if ($networking{'ssl'} == 1 && $networking{'sslAvailable'} == 1) {
    printmsg("DEBUG => Attempting HTTPS connection to: https://$networking{'host'}:$networking{'port'}/", 1);
    $SOCKET = new IO::Socket::SSL->new(PeerAddr  => $networking{'host'},
                                       PeerPort  => $networking{'port'},
                                       Proto     => 'tcp',
                                       Autoflush => 1,
                                       Blocking  => 1,
                                       timeout   => $networking{'timeout'},
    ) or do {
        if ($networking{'allow-http-fallback'} == 0) {
            quit("ERROR => https connection to https://$networking{'host'}:$networking{'port'}/ failed. Error: $!",1);
        }
        printmsg("WARNING => https connection to https://$networking{'host'}:$networking{'port'}/ failed. Error: $!", 0, *STDERR);
        printmsg("NOTICE => Falling back to insecure http mode", 0, *STDERR);
        $networking{'ssl'} = 0;
        $networking{'port'} = 80;
        alarm(10);
    };
}
if ($networking{'ssl'} == 0) {
    printmsg("DEBUG => Attempting HTTP connection to: http://$networking{'host'}:$networking{'port'}/", 1);
    $SOCKET = IO::Socket::INET->new(      PeerAddr  => $networking{'host'},
                                          PeerPort  => $networking{'port'},
                                          Proto     => 'tcp',
                                          Autoflush => 1,
                                          Blocking  => 1,
                                          timeout   => $networking{'timeout'},
    ) or quit("ERROR => Connection to http://$networking{'host'}:$networking{'port'}/ failed. Error was: $!",1);
}
alarm(0);

## Download Page
my $response = getPage(
                   "http://" . $networking{'host'} . $networking{'uri'} . 
                   "?module=" . $self{'module'} . 
                   "&debug=$debug",
                   "options=$option_string",
                   0,
                   \$SOCKET
               );

## Disconnect
$SOCKET->close();

## Get the exit status of the function we ran -- it's the number in the first line of $result
## We default to 1 - so we'll exit with an error unless otherwise instructed.
my $status = 1;
if ($response =~ s/^(\d+)\r\n//so) {
    $status = $1;
}

## INTERRUPTION:  If the "mode" is to create symlinks, do that now.
if ($self{'module'} eq 'get_module_list' and $opt{'type'} and $opt{'type'} eq 'perl') {
    my %modules = ();
    eval $response;
    if (!-f $conf{'programName'}) { quit("ERROR => Can't create symlink - source file $conf{'programName'} doesn't exist!", 1); }
    foreach my $module (keys(%modules)) {
        symlink($conf{'programName'}, $module);
    }
    quit("NOTICE => Symlinks for all modules created in current directory", 0);
}

## Print the result
print $response;

## Quit with no errors
quit("", $status);
