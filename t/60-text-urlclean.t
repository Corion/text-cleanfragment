#!perl -w
use strict;
use Test::More;
use Data::Dumper;

use Text::CleanFragment;
use utf8;
binmode DATA, ':utf8';
my @tests = map { s!\s+$!!g; [split /\|/] } grep {!/^\s*#/ && /\S/} <DATA>;

push @tests, ["String\nWith\n\nNewlines\r\nEmbedded","String_With_Newlines_Embedded"];
push @tests, ["String\tWith \t Tabs \tEmbedded","String_With_Tabs_Embedded"];
push @tests, ["","",'Empty String'];
push @tests, ["\x{5317}\x{4EB0}\n",  # those are the Chinese characters for Beijing, according to Sean M. Burke
              'Bei_Jing', '(Some) Chinese characters also work'];
push @tests, ["Do p\x{00FC}t <this> into URL's?","Do_put_this_into_URLs",'Synopsis'];

plan tests => 1+@tests*3;

for (@tests) {
    my $name= $_->[2] || $_->[1];
    my $res = clean_fragment($_->[0]);
    is $res, $_->[1], $name;
    like $res, qr/^([-.A-Za-z0-9]([-._A-Za-z0-9]*[-.A-Za-z0-9])?)?$/ , "Result matches qr/^([-.A-Za-z0-9]([-._A-Za-z0-9]*[-.A-Za-z0-9])?)?\$/";
    is clean_fragment($_->[1]), $_->[1], "'$_->[1]' is idempotent";
};

is_deeply [clean_fragment(
    'Lenny', 'Motörhead'
)], ['Lenny','Motorhead'], "Multiple arguments also work";
__DATA__
Grégory|Gregory
   Leading Spaces|Leading_Spaces
   Trailing Space     |Trailing_Space
Don't Think|Dont_Think|Apostrophes get eliminated
Don´t Think|Dont_Think|Left-quote-Apostrophes get eliminated
He said "happy", not "sad"|He_said_happy_not_sad|Quotes get eliminated
Ævar Arnfjörð Bjarmason|AEvar_Arnfjord_Bjarmason
forward/slash|forward_slash
back\slash|back_slash
Ümloud feat. ß|Umloud_feat._ss
/foo/bar/index.html|foo_bar_index.html|filename with path
<script>alert();</script>|script_alert_script|Tag injection
javascript:alert();|javascript_alert|Immediate JS URL attempt
&lt;script&gt;|lt_script_gt|Amp-encoded tag injection
C++|C|Plus signs get eliminated
Justice - Cross|Justice-Cross|Space-dash-space to dash
Justice - - Across the Universe|Justice-Across_the_Universe|Repeated dashes also get squashed
What Is This?|What_Is_This|Question marks get eliminated
Do püt <this> into URL's?|Do_put_this_into_URLs|Synopsis
This is plenking ...|This_is_plenking...|No underscore before \W