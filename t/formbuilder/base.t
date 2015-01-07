use strict;
use warnings;

use Test::More;
use Test::Exception;

package TestModule;
use parent qw(HTML::FormBuilder::Base);

sub new{
	my $class = shift;
	my $self = shift || {};
	bless $self, $class;
}

1;

package main;

my $obj;
lives_ok(sub {$obj = TestModule->new({})}, 'create obj ok');
is($obj->_localize('test'), 'test', 'test localilze');
lives_ok(sub {$obj = TestModule->new({option => {localize => sub {return "hello"}}})}, 'create obj ok');
is($obj->_localize('test'), 'hello', 'test localilze');
lives_ok(sub {$obj = TestModule->new({classes => {required_asterisk => 'required_asterisk'}})}, 'create obj ok');
my $result = $obj->_build_element_and_attributes('div', {class => 'adiv'}, "div content",{required_mark => 1});
is($result, '<div class="adiv"><em class="required_asterisk">**</em>div content</div>');
done_testing;
