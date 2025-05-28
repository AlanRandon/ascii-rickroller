#!/usr/bin/env perl

use Time::HiRes;

system("[ ! -e frames.dat ] && xz ./frames.dat.xz -dk");

my $pid = fork();
if ($pid == 0) {
	system("ffplay -nodisp -loglevel quiet ./never-gonna-give-you-up.opus");
	die;
};

open(fh, '<', "./frames.dat") or die;
local $/ = "\0";
while (<fh>) {
	print "\e[H$_";
	Time::HiRes::sleep(0.04 * 2);
};
close(fh);

wait();
