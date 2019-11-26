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
public class TimerManager : GLib.Object {
    public TimerObject? actual_timer { get; private set; }
    public bool stop_notify { get; set; }

    public signal void new_timer_set (TimerObject timer);
    public signal void tick (TimerObject timer);
    public signal void timer_finished (TimerObject timer);

    public bool is_timer_set () {
        return actual_timer != null;
    }

    public void new_timer (Timer.TimeSpan timespan) {
        if (actual_timer != null) {
            actual_timer.stop ();
        }
        actual_timer = new TimerObject (timespan);
        actual_timer.tick.connect ((t) => {
            tick (t);
        });
        actual_timer.match.connect ((t) => {
            timer_finished (t);
        });
        new_timer_set (actual_timer);
    }
}
}