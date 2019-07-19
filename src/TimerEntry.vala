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
            valign: Gtk.Align.CENTER,
            uid: window_id);
        this.manager = manager;
    }

    construct {
        get_style_context ().add_class ("entry-%d".printf(uid));
        try {
            minute_only_pattern = new GLib.Regex ("""^\s*(?<minutes>\d*[.,]?\d+)\s*$""", RegexCompileFlags.JAVASCRIPT_COMPAT);
            long_form_pattern = new GLib.Regex ("""^\s*((?<days>\d*[.,]?\d+)\s*(d|dys?|days?))?\s*((?<hours>\d*[.,]?\d+)\s*(h|hrs?|hours?))?\s*((?<minutes>\d*[.,]?\d+)\s*(m|mins?|minutes?))?\s*((?<seconds>\d*[.,]?\d+)\s*(s|secs?|seconds|))?\s*$""", RegexCompileFlags.JAVASCRIPT_COMPAT);
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

    private static double parse_num(string num) {
      return double.parse (num.replace (",", "."));
    }

    private void timer_set (string timer_str) {
        try {
            GLib.MatchInfo mi;
            if (minute_only_pattern.match_full (timer_str, -1, 0, 0, out mi)) {
                var time = parse_num (mi.fetch_named ("minutes")) * GLib.TimeSpan.MINUTE + 0.5;
                manager.new_timer (new Timer.TimeSpan (time));
                return;
            }
            if (!long_form_pattern.match_full (timer_str, -1, 0, 0, out mi)) {
                return;
            }
            var days = mi.fetch_named ("days");
            var hours = mi.fetch_named ("hours");
            var minutes = mi.fetch_named ("minutes");
            var seconds = mi.fetch_named ("seconds");
            if (days == null && hours == null && minutes == null && seconds == null) {
                return;
            }
            var time = 0.5;  // Rounding
            if (days != null) {
                time += parse_num (days) * GLib.TimeSpan.DAY;
            }
            if (hours != null) {
                time += parse_num (hours) * GLib.TimeSpan.HOUR;
            }
            if (minutes != null) {
                time += parse_num (minutes) * GLib.TimeSpan.MINUTE;
            }
            if (seconds != null) {
                time += parse_num (seconds) * GLib.TimeSpan.SECOND;
            }
            manager.new_timer (new Timer.TimeSpan (time));
        } catch (GLib.Error e) {
            GLib.warning ("Regex parse error: %s", e.message);
        }
    }

    public bool validate_timer (string timer_str) {
        try {
            GLib.MatchInfo mi;
            if (minute_only_pattern.match_full (timer_str, -1, 0, 0, out mi)) {
               return true;
            }
            if (!long_form_pattern.match_full (timer_str, -1, 0, 0, out mi)) {
                return false;
            }
            return mi.fetch_named ("days") != null || mi.fetch_named ("hours") != null || mi.fetch_named ("minutes") != null || mi.fetch_named ("seconds") != null;
        } catch (GLib.Error e) {
            GLib.warning ("Regex parse error: %s", e.message);
            return false;
        }
    }

}

}
