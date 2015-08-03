#!perl

if ( !require Test::Perl::Critic ) {
    Test::More::plan(
        skip_all => "Test::Perl::Critic required for testing PBP compliance" );
}

Test::Perl::Critic->import( -profile => 't/.perlcriticrc' );
Test::Perl::Critic::all_critic_ok();
