#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';



sub MetaSploit {
    system("sudo -u ", HackerArch::FuncHeaders::GetUsername(), " pacaur -S metasploit-git");
}

