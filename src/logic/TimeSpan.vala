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
    public class TimeSpan : GLib.Object {
        public int days { get; set; }

        public int hours { get; set; }

        public int minutes { get; set; }

        public int seconds { get; set; }

        bool expired = false;

        public TimeSpan (double time_in_ms = 0.0) {
          days = (int) (time_in_ms / GLib.TimeSpan.DAY);
          time_in_ms -= days * GLib.TimeSpan.DAY;
          hours = (int) (time_in_ms / GLib.TimeSpan.HOUR);
          time_in_ms -= hours * GLib.TimeSpan.HOUR;
          minutes = (int) (time_in_ms / GLib.TimeSpan.MINUTE);
          time_in_ms -= minutes * GLib.TimeSpan.MINUTE;
          seconds = (int) (time_in_ms / GLib.TimeSpan.SECOND);
        }

        public TimeSpan.from_glib (GLib.TimeSpan glib_time_span) {
            expired = glib_time_span < -120; // some processing time
            var time_seconds = (int) GLib.Math.ceil (((double)glib_time_span) / GLib.TimeSpan.SECOND);
            var time_minutes = (int) (glib_time_span / GLib.TimeSpan.MINUTE);
            if (time_seconds != 0 && time_seconds % 60 == 0) {
                time_minutes += 1;
            }
            var time_hours = (int) (glib_time_span / GLib.TimeSpan.HOUR);
            if ((time_seconds != 0 || time_minutes != 0) && time_seconds % 60 == 0 && time_minutes % 60 == 0) {
                time_hours += 1;
            }
            var time_days = (int) (glib_time_span / GLib.TimeSpan.DAY);
            if ((time_seconds != 0 || time_minutes != 0 || time_hours != 0) && time_seconds % 60 == 0 && time_minutes % 60 == 0 && time_hours % 24 == 0) {
                time_days += 1;
            }
            seconds = (time_seconds % 60).abs ();
            minutes = (time_minutes % 60).abs ();
            hours = (time_hours % 24).abs ();
            days = (time_days).abs ();
        }

        public DateTime get_end_time (DateTime start_time) {
            DateTime end_time = start_time;
            end_time = end_time.add_seconds (seconds);
            end_time = end_time.add_minutes (minutes);
            end_time = end_time.add_hours (hours);
            end_time = end_time.add_days (days);
            return end_time;
        }

        public bool match () {
            return days == 0 && hours == 0 && minutes == 0 && seconds == 0;
        }

        public bool is_expired () {
            return expired;
        }

        public string to_string () {
            string time = "";
            if (days != 0) {
                time+="%d days ".printf(days);
            }
            if (hours != 0) {
                time+="%d hours ".printf(hours);
            }
            if (minutes == 1) {
                time+="%d minute ".printf(minutes);
            }
            if (minutes != 0 && minutes != 1) {
                time+="%d minutes ".printf(minutes);
            }
            if (seconds != 0) {
                time+="%d seconds ".printf(seconds);
            }
            if (expired && time.length > 0) {
                time+="ago";
            }
            return time;
        }
    }
}
