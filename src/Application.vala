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
        public const string STANDARD_TIMER_NAME = "Timer";

        private static string? title = null;

        public TimerApp () {
            Object (application_id: "com.github.parnold-x.timer",
            flags: ApplicationFlags.HANDLES_COMMAND_LINE);
        }

        public override void activate () {

        }


        public override int command_line (ApplicationCommandLine command_line) {
            this.hold ();
            int res = _command_line (command_line);
            this.release ();
            return res;
        }

        public int _command_line (ApplicationCommandLine command_line) {
            OptionEntry[] options = new OptionEntry[1];
            options[0] = { "title", 0, 0, OptionArg.STRING, ref title, "Set the title of the Timer", "<title>" };
            string[] args = command_line.get_arguments ();

            string timer = "";
            string*[] _args = new string[args.length];
            for (int i = 0; i < args.length; i++) {
                if (!args[i].has_prefix ("-")){
                    timer += args[i] + " ";
                } else if (args[i] == "--help" || args[i] == "-help" || args[i] == "-h") {
                    help ();
                    return 0;
                }
                _args[i] = args[i];
            }
            try {
                var opt_context = new OptionContext ("[<input>]");
                opt_context.add_main_entries (options, null);
                unowned string[] tmp = _args;
                opt_context.parse (ref tmp);
            } catch (OptionError e) {
                command_line.print ("error: %s\n", e.message);
                help ();
                return 0;
            }
            new MainWindow (this, (int) get_windows ().length (), title, timer);
            title = null;
            return 0;
        }

        private void help () {
            print ("Usage: %s [OPTION] [<input>]\n",application_id);
            print ("The ultimate tea timer.\n\n");
            print ("\t<input>\n");
            print ("\t\tInput to start the timer.\n\n");
            print ("\t\tFor example:\n");
            print ("\t\t5\t\t\ttimer for 5 minutes\n");
            print ("\t\t5 minutes\t\ttimer for 5 minutes\n");
            print ("\t\t5 minutes 15 seconds\ttimer for 5 minutes 15 seconds\n");
            print ("\t\t2 hours 15 minutes\ttimer for 2 hours 15 minutes\n");
            print ("\t\t2m15s\t\t\ttimer for 2 minutes 15 seconds\n");
            print ("\n\n");
            print ("Options:\n");
            print ("  --title=<title>\n");
            print ("\t\tSet the title of the Timer.\n\n");
        }

        public static void main (string[] args) {
            // Initializing GStreamer
            Gst.init (ref args);
            var app = new Timer.TimerApp ();
            app.run (args);
        }
    }
}