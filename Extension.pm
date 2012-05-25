# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::CannedComments;
use strict;
use base qw(Bugzilla::Extension);

use Bugzilla::Extension::CannedComments::Comment;

use Data::Dumper;

our $VERSION = '0.01';

sub db_schema_abstract_schema {
    my ($self, $args) = @_;
    $args->{'schema'}->{'canned_comments'} = {
        FIELDS => [
            id => {
                TYPE       => 'MEDIUMSERIAL',
                NOTNULL    => 1,
                PRIMARYKEY => 1,
            },
            user_id => {
                TYPE        => 'INT3',
                NOTNULL     => 1,
                REFERENCES  => { TABLE  =>  'profiles',
                                 COLUMN =>  'userid',
                                 DELETE => 'CASCADE' }
            },
            summary => {
                TYPE    => 'VARCHAR(255)',
                NOTNULL => 1
            },
            comment => {
                TYPE    => 'LONGTEXT',
                NOTNULL => 1,
            },
        ],
        INDEXES => [
            canned_comments_who_idx => { FIELDS => [qw(user_id summary)],
                                         TYPE   => 'UNIQUE'},
        ],
    };
}

sub template_before_process {
    my ($self, $args) = @_;
    my $file = $args->{'file'};
    my $vars = $args->{'vars'};

    if ($file eq 'bug/show-header.html.tmpl') {
        $vars->{'canned_comments'} = 1;
    }

    if ($file eq 'bug/create/create.html.tmpl'
        || $file eq 'bug/edit.html.tmpl') 
    {
        $vars->{'canned_comments'} 
            = Bugzilla::Extension::CannedComments::Comment->match({ 
                user_id => Bugzilla->user->id 
            });
    }
}

sub page_before_template {
    my ($self, $args) = @_;
    my ($vars, $page) = @$args{qw(vars page_id)};

    if ($page eq 'canned_comments.html') {
        $vars->{'canned_comments'} 
            = Bugzilla::Extension::CannedComments::Comment->match({ 
                user_id => Bugzilla->user->id 
            });
    }
}

sub object_end_of_set_all {
    my ($self, $args) = @_;
    my $object         = $args->{'object'};
    my $params         = Bugzilla->input_params;

    if ($object->isa('Bugzilla::Bug')
        && $params->{'old_canned'}
        && !$params->{'new_canned'})
    {   
        # Do not do anything esle if:
        # 1. They entered something in the comment field either manually 
        #    or via canned comment javascript
        # 2. They are not removing any previous canned comments    
        return if $params->{'comment'}
                  && !$params->{'remove_old_canned'};

        my $old_canned = Bugzilla::Extension::CannedComments::Comment->check({
            id => $params->{'old_canned'}
        });
        if ($params->{'remove_old_canned'}) {
            $old_canned->remove_from_db();
        }
        else {
            $object->add_comment($old_canned->comment, { 
                isprivate => $params->{'comment_is_private'} 
            }); 
        }
    }
}

sub bug_end_of_update {
    my ($self, $args) = @_;
    my $params = Bugzilla->input_params;

    if ($params->{'new_canned'} && $params->{'comment'}) {
        Bugzilla::Extension::CannedComments::Comment->create({
            user_id => Bugzilla->user->id, 
            summary => $params->{'new_canned_summary'}, 
            comment => $params->{'comment'}
        });
    }
}

sub webservice {
    my ($self,  $args) = @_;
    my $dispatch = $args->{dispatch};
    $dispatch->{CannedComments} = "Bugzilla::Extension::CannedComments::WebService";
}

__PACKAGE__->NAME;
