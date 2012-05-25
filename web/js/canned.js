/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 * This Source Code Form is "Incompatible With Secondary Licenses", as
 * defined by the Mozilla Public License, v. 2.0.
 */

var canned_cache        = [];
var canned_counter      = 0;
var canned_hidden_class = 'bz_default_hidden';

function newCanned (checkbox) {
    var summary_container = YAHOO.util.Dom.get('new_canned_summary_container');
    if (checkbox.checked == true) {
        YAHOO.util.Dom.removeClass(summary_container, canned_hidden_class);
    }
    else {
        YAHOO.util.Dom.addClass(summary_container, canned_hidden_class);
    }
}

function oldCanned (select) {
    var id = select.options[select.selectedIndex].value;
    var remove_container = YAHOO.util.Dom.get('remove_old_canned_container');
    if (id) {
        YAHOO.util.Dom.removeClass(remove_container, canned_hidden_class);
        updateComment(id);
    }
    else {
        YAHOO.util.Dom.addClass(remove_container, canned_hidden_class);
    }
}

function updateComment (id) {
    var textarea = YAHOO.util.Dom.get('comment');
    if (canned_cache[id]) {
        textarea.value += canned_cache[id] + "\n\n";
        return true;
    }
    var callback = {
        success : function (o) {
            var data = YAHOO.lang.JSON.parse(o.responseText);
            if (!data.error) {
                canned_cache[data.result.id] = data.result.comment;
                textarea.value += canned_cache[data.result.id] + "\n\n";
            }
            else {
                console.log("ERROR: " + data.error);
            }
        }, 
        failure : function (o) {
            console.log("ERROR: " + o.id + " " + o.status + " " + o.statusText);
        }
    };
    var json_object = {
          method : "CannedComments.get",
          id : canned_counter++,
          params : [ { id : id } ]
    };
    var post_data =  YAHOO.lang.JSON.stringify(json_object);
    YAHOO.util.Connect.setDefaultPostHeader('application/json', true);
    var request = YAHOO.util.Connect.asyncRequest('POST', 'jsonrpc.cgi', callback, post_data);
}
