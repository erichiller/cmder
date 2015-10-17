#!/usr/local/bin/perl
#
#	euc_jp.pm : EUC Japanese Character Support Functions
#		This modules is experimental.  API may be changed.
#
#	$Id: euc_jp.pm,v 1.2 2001-04-22 22:35:41+09 hayashi Exp $
#
#	Copyright (c) 2001 Hiroo Hayashi.  All rights reserved.
#
#	This program is free software; you can redistribute it and/or
#	modify it under the same terms as Perl itself.
#

package Term::ReadLine::Gnu::XS;

use Carp;
use strict;

# make aliases
use vars qw(%Attribs);
*Attribs = \%Term::ReadLine::Gnu::Attribs;

# enable Meta
rl_prep_terminal(1);

rl_add_defun('euc-jp-forward', \&ej_forward);
rl_add_defun('euc-jp-backward', \&ej_backward);
rl_add_defun('euc-jp-backward-delete-char', \&ej_rubout);
rl_add_defun('euc-jp-delete-char', \&ej_delete);
rl_add_defun('euc-jp-forward-backward-delete-char', \&ej_rubout_or_delete);
rl_add_defun('euc-jp-transpose-chars', \&ej_transpose_chars);

rl_bind_key(ord "\cf", 'euc-jp-forward');
rl_bind_key(ord "\cb", 'euc-jp-backward');
rl_bind_key(ord "\ch", 'euc-jp-backward-delete-char');
#rl_bind_key(ord "\cd", 'euc-jp-delete-char');
rl_bind_key(ord "\cd", 'euc-jp-forward-backward-delete-char');
rl_bind_key(ord "\ct", 'euc-jp-transpose-chars');

1;

#	An EUC Japanese character consists of two 8 bit characters.
#	And the MSBs (most significant bit) of both bytes are set.

#	To support Shift-JIS charactor set the following two functions
#	must be extended.
sub ej_first_byte_p {
    my ($p) = @_;
    my $l = $Attribs{line_buffer};
    return substr($l, $p, 1) =~ /[\x80-\xff]/
	&& substr($l, 0, $p) =~ /^([\x00-x7f]|([\x80-\xff][\x80-\xff]))*$/;
}

sub ej_second_byte_p {
    my ($p) = @_;
    my $l = $Attribs{line_buffer};
    return $p > 0 && substr($l, $p, 1) =~ /[\x80-\xff]/
	&& substr($l, 0, $p) !~ /^([\x00-x7f]|([\x80-\xff][\x80-\xff]))*$/;
}

#forward-char
sub ej_forward {
    my($count, $key) = @_;
    if ($count < 0) {
	ej_backward(-$count, $key);
    } else  {
	while ($count--) {
	    if (ej_first_byte_p($Attribs{point})) {
		rl_call_function('forward-char', 2, $key);
	    } else {
		rl_call_function('forward-char', 1, $key);
	    }
	}
    }
    return 0;
}

#backward-char
sub ej_backward {
    my($count, $key) = @_;
    if ($count < 0) {
	ej_forward(-$count, $key);
    } else  {
	while ($count--) {
	    if (ej_second_byte_p($Attribs{point})) {
		rl_call_function('backward-char', 1, $key);
	    }
	    if (ej_second_byte_p($Attribs{point} - 1)) {
		rl_call_function('backward-char', 2, $key);
	    } else {
		rl_call_function('backward-char', 1, $key);
	    }
	}
    }
    return 0;
}

#backward-delete-char
sub ej_rubout {
    my($count, $key) = @_;
    if ($count < 0) {
	ej_delete(-$count, $key);
    } else  {
	if ($Attribs{point} <= 0) {
	    rl_ding();
	    return 1;
	}
	while ($count--) {
	    if (ej_second_byte_p($Attribs{point})) {
		$Attribs{point}--;
	    }
	    if (ej_second_byte_p($Attribs{point} - 1)) {
		rl_call_function('backward-delete-char', 2, $key);
	    } else {
		rl_call_function('backward-delete-char', 1, $key);
	    }
	}
    }
    return 0;
}

#delete-char
sub ej_delete {
    my($count, $key) = @_;
    if ($count < 0) {
	ej_rubout(-$count, $key);
    } else  {
	while ($count--) {
	    if (ej_first_byte_p($Attribs{point})) {
		rl_call_function('delete-char', 2, $key);
	    } elsif (ej_second_byte_p($Attribs{point})) {
		rl_call_function('backward-delete-char', 1, $key);
		rl_call_function('delete-char', 1, $key);
	    } else {
		rl_call_function('delete-char', 1, $key);
	    }
	}
    }
    return 0;
}

#forward-backward-delete-char
sub ej_rubout_or_delete {
    my($count, $key) = @_;
    if ($Attribs{end} != 0 && $Attribs{point} == $Attribs{end}) {
	return ej_rubout($count, $key);
    } else  {
	return ej_delete($count, $key);
    }
}

#transpose-chars
sub ej_transpose_chars {
    my($count, $key) = @_;

    return 0 unless $count;

    if (ej_second_byte_p($Attribs{point})) {
	$Attribs{point}--;
    }
    if ($Attribs{point}	== 0	# the beginning of the line
	|| ($Attribs{end} < 2)	# only one ascii char
	# only one EUC char
	|| ($Attribs{end} == 2 && ej_first_byte_p(0))) {
	rl_ding();
	return -1;
    }
    rl_begin_undo_group();
    if ($Attribs{point} == $Attribs{end}) {
	# If point is at the end of the line
	ej_backward(1, $key);
	$count = 1;
    }
    ej_backward(1, $key);
    my $dummy;
    if (ej_first_byte_p($Attribs{point})) {
	$dummy = substr($Attribs{line_buffer}, $Attribs{point}, 2);
	rl_delete_text($Attribs{point}, $Attribs{point} + 2);
    } else {
	$dummy = substr($Attribs{line_buffer}, $Attribs{point}, 1);
	rl_delete_text($Attribs{point}, $Attribs{point} + 1);
    }
    ej_forward($count, $key);
    rl_insert_text($dummy);
    rl_end_undo_group();
    return 0;
}
