#!/usr/bin/perl

use DBI;
use Time::localtime;
use Time::Local;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);
use CGI;

my $PASSWORD = 'PASSWORD';
my $CATEGORY = 83;
my $LOG_FILE = '/usr/local/nodeny/module/platon.log';

$c=new CGI;

sub debug
{
  my ($time);
  open LOG, ">>$LOG_FILE";
  $time = CORE::localtime;
  print LOG "$time: $_[0]\n";
  $c->save(\*LOG);
  close LOG;
}

sub return_ok
{
  debug "OK";
  print "Content-type: text/html; charset=utf-8;\n\n";
  print "OK\n";
  exit;
}

sub return_fail
{
  debug $_[0];
  print "Content-type: text/html; charset=utf-8;\n";
  print "Status: 400 Bad Request\n\n";
  print "FAIL:$_[0]\n";
  exit;
}

require '/usr/local/nodeny/nodeny.cfg.pl';
$dbh=DBI->connect("DBI:mysql:database=$db_name;host=$db_server;mysql_connect_timeout=$mysql_connect_timeout;",$user,$pw,{PrintError=>1});
die "Connection to database failed" unless $dbh;
require '/usr/local/nodeny/web/calls.pl';

$sign = md5_hex(uc(
  reverse($c->param('email')).
  $PASSWORD.
  $c->param('order').
  reverse(substr($c->param('card'),0,6).substr($c->param('card'),-4))
));

return_fail 'sign' unless $sign eq $c->param('sign');
$order = &sql_select_line($dbh, "SELECT * FROM s_platon WHERE id='".$c->param('order')."'");
return_fail 'order' unless $order;
return_ok if $order->{performed} eq '1';

&sql_do($dbh,
  "INSERT INTO pays SET
    mid='".$order->{mid}."',
    cash='".$order->{amount}."',
    time=UNIX_TIMESTAMP(NOW()),
    admin_id=0,
    admin_ip=0,
    office=0,
    bonus='y',
    reason='Platon ".$c->param('id')." (ID ".$order->{id}.")',
    coment='Platon ".$c->param('id')." (ID ".$order->{id}.")',
    type=10,
    category='".$CATEGORY."'");

&sql_do($dbh, "UPDATE users SET state='on', balance=balance+".$order->{amount}." WHERE id='".$order->{mid}."'");
&sql_do($dbh, "UPDATE s_platon SET performed=1 WHERE id='".$order->{id}."'");

return_ok;
