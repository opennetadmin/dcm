DCM.PL
======

dcm.pl is the command line interface tool to the core modules of OpenNetAdmin.
It is intended to provide a batch interface for doing adds, modifies,
deletes etc. 

INSTALL
-------
This tool can be installed on just about any system that has perl installed. It is
simply a command line interface to the modules that ONA uses to do work in 
the core. There are two files that need to be placed in your operating
system somewhere.

dcm.pl: This is the main program file. It needs to be in `/opt/ona/bin`. 
        If you choose to install it elsewhere, like `/usr/local/bin` for instance,
        you should have a symlink that points to it in `/opt/ona/bin` as
        there are several ONA related processes that expect it to be there.
        In the event you have not installed ONA in `/opt/ona`, then put
        it in `$ONABASE/bin`.

dcm.conf: This is the configuration file for dcm.pl. dcm.pl will look for 
          the configuration file in the following locations and it will
          use the first one it finds in this list:

    `'./.dcm/dcm.conf'`,
    `'./dcm.conf'`,
    `$xdg_config_home . '/dcm/dcm.conf'`,
    `$homedir . '/.config/dcm/dcm.conf'`,
    `$homedir . '/.dcm/dcm.conf'`,
    `$homedir . '/dcm.conf'`,
    `$onabase . '/etc/dcm.conf'`,
    `'/opt/ona/etc/dcm.conf'`,
    `'/etc/dcm.conf'`,
    `'/etc/dcm/dcm.conf'`

You can also specify any path using the -c commandline option.

CONFIGURATION
-------------
You will need to adjust the 'url' value in the [networking] section of the 
config file. This is the URL to the dcm.php file. This file is in the same 
directory as the main ONA index.php file would be located. So if you reach 
the ONA website by using http://myserver.example.com/ipam/ then use the same 
url but just tack on dcm.php. Some examples might be:

    url                      => https://localhost/ona/dcm.php
    url                      => http://myserver.example.com/ipam/dcm.php


SECURITY
--------
You should be careful as to how you configure and utilize dcm.pl. By default
it grants very high level access to the ONA system and will allow you to add,
delete or modify just about any record. It will also allow you to use
unencrypted connections to the ONA database.

It is recommended that you configure your web server to utilize https only 
and that you set the `allow-http-fallback` option to 0 to disable the 
downgrade to http style connections. This setting only affects how dcm 
itself operates so having https turned on your web server is good practice 
anyway as it relates to the ONA web interface. For dcm to utilize https you 
will need the following perl modules installed on your system: 
Net::SSleay and IO::Socket::SSL.

I have provided an example .htaccess file in the ONA install that will 
restrict the dcm tool even further. To enable it you can simply rename the 
www/.htaccess.example file to www/.htaccess. By default this example file will 
restrict dcm to work only from the localhost IP address. This means that dcm 
can only be run from the same server that the ONA web interface is on. You 
can adjust the IP address ranges used or if you choose, you can utilize 
basic http auth via .htpasswd. These are a few examples of how one could 
lock it down via .htaccess so I will leave any advanced methods up to the user.

By default dcm will try to connect to ONA as the user 'dcm.pl'. If that user 
does not exist in the ona system then you will get an error. You can specify 
an alternate user to connect as using the -l option for dcm. The commands 
that you are allowed to execute must fall within the privileges that you 
have been granted in the ONA web interface. You will however be able to list 
(--list) all of the available commands.

If you have a system with multiple users and do not want to set username 
and password in the .conf file it would be best to have users set an ENV 
variable in their shell to define the login information specific to them. 
They can also use -l and -p but the ENV option provides a more convenient way 
of dealing with this. You can also use these in cron jobs or other batch 
scripts to control access. The two variables to set are:

    DCM_LOGIN_USER
    DCM_LOGIN_PASS

USAGE
-----
Once you have installed via the steps above, you can test that it is
functioning by issuing the following command:

    dcm.pl --list

This should return a large list of modules and their descriptions. If not,
then you should see an error message explaining the issue.

Here is an example of some of the modules available:

    interface_move            :: Move an interface from one subnet to another
    interface_move_host       :: Moves an interface from one host to another
    interface_share           :: Share an existing interface with another host
    interface_share_del       :: Delete an interface share entry
    location_add              :: Add a location record
    location_del              :: Delete a location
    location_modify           :: Modify a location record
    mangle_ip                 :: Converts between various IP address representations
    nat_add                   :: Add external NAT IP to existing internal IP
    nat_del                   :: Delete external NAT IP from existing internal IP
    ona_sql                   :: Perform basic SQL operations on the database
    report_run                :: Run a report
    subnet_add                :: Add a new subnet
    subnet_del                :: Delete an existing subnet
    subnet_display            :: Display an existing subnet
    subnet_modify             :: Modify an existing subnet
    subnet_nextip             :: Return the next available IP address on a subnet
    vlan_add                  :: Add a VLAN
    vlan_campus_add           :: Add a VLAN campus (VTP Domain)
    vlan_campus_del           :: Delete a VLAN campus
    vlan_campus_modify        :: Modify a VLAN campus record
    vlan_del                  :: Delete a VLAN
    vlan_modify               :: Modify a VLAN

You can also run dcm.pl on its own to get help text. The typical usage is as follows:

    dcm.pl -r <modulename>

This should then display the usage information for the specified module. 
Lets assume you have selected `host_display` as your module. You would run 
dcm.pl with that module name with its required option of `host` and optional 
verbose flag, which would look something like this:

    $ dcm.pl -r host_display host=test.example.com verbose=n
    HOST RECORD (test.example.com)
      id                          23
      primary_dns_id              62
      device_id                   15
      name                        test
      fqdn                        test.example.com
      domain_id                   1                   (example.com)
      domain_fqdn                 example.com


NOTE: One feature of dcm.pl is that it can take files as input. So if I pass dcm.pl 
the option file=myfile.txt it will look in the current path for myfile.txt. This is a 
great feature for passing things into ONA. There is however a drawback at times. 
For example, if you are passing in an option like host=test.example.com and you also 
happen to be in a directory where there is a file or directory named test.example.com 
the dcm.pl script will probably not behave as you expect. Be aware of this behavior, 
it bites me still sometimes.
