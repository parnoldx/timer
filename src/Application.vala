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
    public class TimerApp : Gtk.Application {


        public TimerApp () {
            Object (application_id: "com.github.parnold-x.timer",
            flags: ApplicationFlags.FLAGS_NONE);
        }

        public override void activate () {
            var window = new MainWindow (this, (int)get_windows ().length ());
            var quit_action = new SimpleAction ("quit", null);

            add_action (quit_action);
            add_accelerator ("<Control>q", "app.quit", null);


            quit_action.activate.connect (() => {
                if (window != null) {
                    window.destroy ();
                }
            });
        }

        public static void main (string[] args) {
            // Initializing GStreamer
            Gst.init (ref args);
            var app = new Timer.TimerApp ();
            app.run (args);
        }
    }
}