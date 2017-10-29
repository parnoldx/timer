/*
 * Copyright (c) 2017 Peter Arnold
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */
 
namespace Timer {
public class TitleLabel : Gtk.Entry {
	string last_title = "Timer";

	public signal void unfocus ();
	public TitleLabel() {
		Object (text: "Timer", xalign: 0.5f);
	}

	construct {
		var title_context = get_style_context ();
		title_context.remove_class ("entry");
        title_context.add_class ("label");
        title_context.add_class ("title");
        activate.connect (() => {
            if (text.length == 0) {
                last_title = "Timer";
            } else {
                last_title = text;
            }
            unfocus ();
        });
        key_press_event.connect ((e) => {
            if (65307 == e.keyval) {
            	unfocus ();
            }
            return false;
        });
        focus_in_event.connect ((e) => {
            text = "";
        });
        focus_out_event.connect ((e) => {
            if (text.length != 0) {
                last_title = text;
            }
            text = last_title;
        });
	}

}
}