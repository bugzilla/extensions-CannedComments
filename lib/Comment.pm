# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::CannedComments::Comment;

use base qw(Bugzilla::Object);

use strict;
use warnings;

use Bugzilla::Error;
use Bugzilla::Util qw(trim);

use Scalar::Util qw(blessed);
use Data::Dumper;

###############################
####    Initialization     ####
###############################

use constant DB_TABLE => 'canned_comments';

use constant LIST_ORDER => 'id';

use constant DB_COLUMNS => qw(
    id
    user_id
    summary 
    comment
);

use constant VALIDATORS => {
    user_id => \&_check_user,
    summary => \&_check_summary,
    comment => \&_check_comment,
};

###############################
####      Validators       ####
###############################

sub _check_user {
    my ($invocant, $user) = @_;
    if (blessed $user) {
        return $user->id;
    }
    return $user;
}

sub _check_summary {
    my ($invocant, $summary) = @_;
    $summary = trim($summary);
    $summary || ThrowCodeError('param_required', { param => 'summary' });
    my $matches = Bugzilla::Extension::CannedComments::Comment->match({
        user_id => Bugzilla->user->id, 
        summary => $summary
    });
    @$matches
        && ThrowUserError('canned_comments_dupe_summary', { summary => $summary });
    return $summary;
}

sub _check_comment {
    my ($invocant, $comment) = @_;
    $comment = trim($comment);
    $comment || ThrowCodeError( 'param_required', { param => 'comment' } );
    return $comment;
}

###############################
####      Accessors        ####
###############################

sub user_id { return $_[0]->{'user_id'}; }
sub summary { return $_[0]->{'summary'}; }
sub comment { return $_[0]->{'comment'}; }

sub user {
    my ($self) = @_;
    $self->{'user'} ||= Bugzilla::User->new($self->user_id);
    return $self->{'user'};
}

1;
