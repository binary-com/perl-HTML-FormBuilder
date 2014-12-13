#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::FailWarnings;
use Test::Exception;
use HTML::FormBuilder;
use HTML::FormBuilder::Select;

my ($form_obj, $result, $expect_result);

$form_obj = HTML::FormBuilder->new({id => 'testid'});
my $fieldset_index = $form_obj->add_fieldset({});

my $input_field_amount = {
													'label' => {
																			'text'     => 'Amount',
																			'for'      => 'amount',
																			'optional' => '0',
																			'call_customer_support' => 1,
																			'tooltip'  => {
																										 desc => "this is a tool tip",
																										 img_url => "test.png"
																										},
																		 },
													'input' => {
																			'type'      => 'text',
																			'id'        => 'amount',
																			'name'      => 'amount',
																			'maxlength' => 40,
																			'value'     => '',
																		 },
												 };

$form_obj->add_field($fieldset_index, $input_field_amount);

lives_ok(sub{$result = $form_obj->build}, 'build tooltip ok');
$expect_result = <<EOF;
<form id="testid" method="get"><div class="rbox form">
    <div class="rbox-wrap">
        
        <fieldset><div class="grd-row-padding row clear"><div class="extra_tooltip_container"><label for="amount"><em class="required_asterisk">**</em>Amount</label> <a href='#' title='this is a tool tip' rel='tooltip'><img src="test.png" /></a></div><div class="grd-grid-8"><input class=" text" id="amount" maxlength="40" name="amount" type="text"></div></div></fieldset>
        <span class="tl">&nbsp;</span><span class="tr">&nbsp;</span><span class="bl">&nbsp;</span><span class="br">&nbsp;</span>
        
        
    </div>
</div></form><p class="required"><em class="required_asterisk">**</em> - 1</p>
EOF
chomp $expect_result;
is($result, $expect_result, 'tooltip and call_customer_support');

done_testing();


