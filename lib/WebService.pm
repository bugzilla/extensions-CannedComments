# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::CannedComments::WebService;

use strict;
use warnings;

use base qw(Bugzilla::WebService);

use Bugzilla::Extension::CannedComments::Comment;

use Bugzilla::Error;

sub get {
    my ($self, $params) = @_;

    $params->{'id'} 
        || ThrowCodeError('param_required', 
                          { function => 'CannedComments.get', param => 'id' });

    my $comment = Bugzilla::Extension::CannedComments::Comment->new({
        id      => $params->{'id'}, 
        user_id => Bugzilla->user->id
    });

    $comment || return {};

    return {
        id      => $comment->id, 
        summary => $comment->summary, 
        comment => $comment->comment
    };
}

1;
