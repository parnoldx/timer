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
    public int uid { get; construct set; }

    public TimerEntry (TimerManager manager, int window_id) {
        Object (xalign: 0.5f,
            uid: window_id);
        this.manager = manager;
    }

    construct {
        get_style_context ().add_class ("entry-%d".printf(uid));
        try {
            minute_only_pattern = new GLib.Regex ("""^\s*(?<minutes>\d+)\s*$""",RegexCompileFlags.JAVASCRIPT_COMPAT);
            long_form_pattern = new GLib.Regex ("""^((?<days>\d+)\s*(d|dys?|days?))|((?<hours>\d+)\s*(h|hrs?|hours?))|((?<minutes>\d+)\s*(m|mins?|minutes?))|((?<seconds>\d+)\s*(s|secs?|seconds|))\s*$""",RegexCompileFlags.JAVASCRIPT_COMPAT);
        } catch (GLib.Error e) {
            GLib.error ("Regex construction: %s", e.message);
        }
        activate.connect(() => {
            string str = get_text ();
            timer_set (str);
        });
        notify["text"].connect((e,m) => {
            var len = text.length;
            if (len < 26) {
                if (ColorManager.font_size < 18) {
                    ColorManager.change_font (18, uid);
                }
            } else if (len < 30){
                if (ColorManager.font_size != 17) {
                    ColorManager.change_font (17, uid);
                }
            } else if (len < 33){
                if (ColorManager.font_size != 16) {
                    ColorManager.change_font (16, uid);
                }
            } else if (len < 36){
                if (ColorManager.font_size != 15) {
                    ColorManager.change_font (15, uid);
                }
            } else if (len < 39){
                if (ColorManager.font_size != 14) {
                    ColorManager.change_font (14, uid);
                }
            } else if (len < 42){
                if (ColorManager.font_size != 13) {
                    ColorManager.change_font (13, uid);
                }
            } else if (len < 45){
                if (ColorManager.font_size != 12) {
                    ColorManager.change_font (12, uid);
                }
            }
        });
        focus_in_event.connect ((e) => {
            if (manager.is_timer_set ()) {
                var timer = manager.actual_timer;
                if (timer.time_left.is_expired ()) {
                    timer.stop ();
                } else {
                    manager.stop_notify = true;
                }
                text = timer.timer_start_span.to_string ().strip ();
                Timeout.add (1, () => {
                    select_region (0, -1);
                    return false;
                });
            }
            return false;
        });
        focus_out_event.connect ((e) => {
             manager.stop_notify = false;
             return false;
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

    public bool validate_timer (string timer_str) {
        try {
            GLib.MatchInfo mi;
            if (minute_only_pattern.match (timer_str, 0, out mi)) {
               return true;
            }
            return long_form_pattern.match (timer_str, 0, out mi);
        } catch (GLib.Error e) {
            GLib.warning ("Regex parse error: %s", e.message);
        }
    }

}

}