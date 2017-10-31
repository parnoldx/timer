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
public class TimerObject : GLib.Object {
    public TimeSpan timer_start_span { get; private set; }
  	public DateTime timer_start { get; private set; }
    public DateTime timer_end { get; private set; }
    public Timer.TimeSpan time_left { get; private set; }
    public double time_elapsed_percentage { get; private set; }

    //private members
    private double time_span_ms;
    private uint tick_timer = 0;

    //signals
    public signal void tick (TimerObject timer);
    public signal void match (TimerObject timer);

    public TimerObject (Timer.TimeSpan time_span) {
        timer_start_span = time_span;
        timer_end = time_span.get_end_time (new DateTime.now_local ());
    }

    public void start () {
        timer_start = new DateTime.now_local ();
        time_span_ms = (double) timer_end.difference (timer_start);
        update ();
        tick_timer = Timeout.add (1000, () => {
            update ();
            return true;
        });
    }

    public void stop () {
        if (tick_timer != 0) {
            Source.remove (tick_timer);
            tick_timer = 0;
        }
    }

    public void update () {
        var time_left_glib = timer_end.difference (new DateTime.now_local ());
        time_left = new Timer.TimeSpan.from_glib (time_left_glib);
        if (time_left.match ()) {
            // exact time match ring and stuff
            time_elapsed_percentage = 1.0;
            match (this);
            return;
        }
        time_elapsed_percentage = 1.0 - ((double)time_left_glib / time_span_ms);
        tick (this);
    }
}
}