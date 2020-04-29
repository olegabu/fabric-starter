#!/usr/bin/perl

open IN,$ARGV[0];

$i=1; while (<IN>) { 
if ((/runStep/)&&!(/^\s*\#/)) { print "\#$i\n$_"; $i++ } 
else { print }}