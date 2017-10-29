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
public class TimerEntry : Gtk.Entry {
    GLib.Regex minute_only_pattern;
    GLib.Regex long_form_pattern;
    TimerManager manager;


    public TimerEntry (TimerManager manager) {
        Object (xalign: 0.5f);
        this.manager = manager;
    }

    construct {
        try {
            minute_only_pattern = new GLib.Regex ("""^\s*(?<minutes>\d+)\s*$""",RegexCompileFlags.JAVASCRIPT_COMPAT);
            long_form_pattern = new GLib.Regex ("""^((?<days>\d+)\s*(d|dys?|days?))|((?<hours>\d+)\s*(h|hrs?|hours?))|((?<minutes>\d+)\s*(m|mins?|minutes?))|((?<seconds>\d+)\s*(s|secs?|seconds|))$""",RegexCompileFlags.JAVASCRIPT_COMPAT);
        } catch (GLib.Error e) {
            GLib.error ("Regex construction: %s", e.message);
        }
        activate.connect(() => {
            string str = get_text ();
            timer_set (str);
        });
        notify["scroll-offset"].connect((e,m)=> {
           if (scroll_offset > 0) {
            //TODO font shrinking
           }
        });
    }

    private void timer_set (string timer_str) {
        try {
        GLib.MatchInfo mi;
        if (minute_only_pattern.match (timer_str, 0, out mi)) {
           var time = new Timer.TimeSpan ();
           time.minutes = int.parse (mi.fetch_named ("minutes"));
           manager.new_timer (time);
           return;
        }
        if (!long_form_pattern.match (timer_str, 0, out mi)) {
            return;
        }
        var time = new Timer.TimeSpan ();
        var days = mi.fetch_named ("days");
        if (days != null) {
            time.days = int.parse (days);
        }
        var d_index = timer_str.index_of ("d");
        long_form_pattern.match_full (timer_str, -1, d_index < 0 ? 0 : d_index, 0, out mi);
        var hours = mi.fetch_named ("hours");
        if (hours != null) {
            time.hours = int.parse (hours);
        }
        var h_index = timer_str.index_of ("h");
        long_form_pattern.match_full (timer_str, -1, h_index < 0 ? 0 : h_index, 0, out mi);
        var minutes = mi.fetch_named ("minutes");
        if (minutes != null) {
            time.minutes = int.parse (minutes);
        }
        var m_index = timer_str.index_of ("m");
        long_form_pattern.match_full (timer_str, -1, m_index < 0 ? 0 : m_index, 0, out mi);
        var seconds = mi.fetch_named ("seconds");
        if (seconds != null) {
            time.seconds = int.parse (seconds);
        }
        manager.new_timer (time);
        } catch (GLib.Error e) {
            GLib.warning ("Regex parse error: %s", e.message);
        }
    }

}

}