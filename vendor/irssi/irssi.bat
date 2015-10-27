@ECHO OFF
IF NOT EXIST bin\irssi.exe EXIT
SET PERL5LIB=lib/perl5/5.8
SET PERLLIB=lib/perl5/5.8
SET TERMINFO_DIRS=terminfo
bin\irssi.exe --home="~/.irssi
