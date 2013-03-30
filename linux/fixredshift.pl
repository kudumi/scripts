use strict;
use warnings;
use Proc::Daemon;
 
$daemon = Proc::Daemon->new(
    work_dir => '/home/eric',
    .....
);
 
$Kid_1_PID = $daemon->Init;
 
unless ( $Kid_1_PID ) {
    # code executed only by the child ...
}
 
$Kid_2_PID = $daemon->Init( { 
                work_dir     => '/home/eric',
                exec_command => 'if [ ps -e | grep totem || ps -e | grep xlock ]; then redshift -x; fi',
             } );
 
$pid = $daemon->Status( ... );
 
$stopped = $daemon->Kill_Daemon( ... );
