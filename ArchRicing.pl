#!/usr/bin/perl
use strict;
use warnings 'FATAL' => 'all';
use Cwd;
use IO::File;

require ConsolePrintTemplates;
use lib sprintf( "%s/lib" , getcwd());
use HackerArch::Ricing qw( :ALL );

sub Start {
	HackerArch::Ricing::AddMouseStyling();
	HackerArch::Ricing::BumblebeeStatusStyling()
}

sub SetupZshVim {
	system( "zsh " . getcwd() . "/install/ZimZsh.zsh" );
	system( "sudo -u " . ConsolePrintTemplates::GetUsername() . " zsh " . getcwd() . "/install/ZimZsh.zsh" );

	system( "cat " . getcwd() . "/ricing/zshrc > /root/.zshrc" );
	system( "cat " . getcwd() . "/ricing/zshrc > /home/" . ConsolePrintTemplates::GetUsername() . "/.zshrc" );

	system( "cat " . getcwd() . "/ricing/zimrc > /root/.zimrc" );
	system( "cat " . getcwd() . "/ricing/zimrc > /home/" . ConsolePrintTemplates::GetUsername() . "/.zimrc" );

	system( "vim +PluginInstall +qall" );
	system( "sudo -u " . ConsolePrintTemplates::GetUsername() . " vim +PluginInstall +qall" );
	system( "cat " . getcwd() . "/ricing/vimrc > /root/.vimrc" );
	system( "cat " . getcwd() . "/ricing/vimrc > /home/" . ConsolePrintTemplates::GetUsername() . "/.vimrc" );
}

BEGIN {
	Start();
}
