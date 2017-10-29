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

    public class MainWindow : Gtk.Window {
    	// private TimerSettings settings;

		public MainWindow (Gtk.Application application) {
			Object (application: application,
                icon_name: "com.github.parnold-x.timer",
                title: _("Timer"),
                resizable: false,
                height_request: 280,
                width_request: 520);
        }

        construct {
            var window_index = (int) application.get_windows ().length ();
            ColorManager.startup (Color.GRAPE,window_index);
            get_style_context ().add_class ("mainwindow-%d".printf(window_index));

            var header_bar = new Gtk.HeaderBar ();
            header_bar.get_style_context ().add_class ("background");
            header_bar.show_close_button = true;
            var settings_button = create_settings_menu ();
            header_bar.pack_end (settings_button);

            var title = new TitleLabel ();

            header_bar.set_custom_title (title);
            set_titlebar (header_bar);

            this.delete_event.connect (on_window_closing);

            var timer_manager = new TimerManager ();
            var time_entry = new TimerEntry (timer_manager);

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.can_focus = true;
            button_press_event.connect ((e) => {
                focus (Gtk.DirectionType.UP);
                return false;
            });

            box.pack_start (time_entry);
            add (box);
            show_all ();
            time_entry.focus (Gtk.DirectionType.UP);

            title.unfocus.connect (() => {
                time_entry.focus (Gtk.DirectionType.UP);
            });

            timer_manager.new_timer_set.connect ((t) => {
                focus (Gtk.DirectionType.UP);
                t.start ();
            });
            timer_manager.tick.connect ((t) => {
                time_entry.set_progress_fraction (t.time_elapsed_percentage);
                time_entry.text = t.time_left.to_string ();
            });
            timer_manager.timer_finished.connect ((t) => {
                time_entry.set_progress_fraction (t.time_elapsed_percentage);
                time_entry.text = "Timer finished";
                title.text = title.text +" finished";
                play_beep ();
                ColorManager.beep ();
            });

        }

        private Gtk.MenuButton create_settings_menu () {
            Gtk.Menu settings_menu = new Gtk.Menu();
            foreach (Color c in Color.all ()) {
                var label = new Gtk.Label(c.get_label ());

                var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
                var color_image = new Gtk.Image.from_pixbuf (ColorManager.get_icon (c));
                box.add (color_image);
                box.add(label);

                var menu_item = new Gtk.MenuItem();
                menu_item.activate.connect(() => {
                    ColorManager.change_color (c, 0);
                });
                menu_item.add(box);
                menu_item.name = c.get_label ();
                settings_menu.add(menu_item);
            }

            settings_menu.show_all();

            var settings_button = new Gtk.MenuButton();
            settings_button.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            settings_button.set_popup(settings_menu);

            return settings_button;
        }

        private bool on_window_closing () {
            return false;
        }

        private void play_beep () {
            dynamic Gst.Element playbin = Gst.ElementFactory.make ("playbin", "play");
            var temp_file = File.new_for_path (Environment.get_tmp_dir ()+"/parnold-x.teatimer.beep.wav");
            if (!temp_file.query_exists ()) {
                var file = File.new_for_uri ("resource:///com/github/parnold-x/teatimer/beep.wav");
                try {
                file.copy (temp_file, 0);
                } catch (GLib.Error e) {
                    GLib.warning ("Failed to extract beep: %s", e.message);
                }
            }
            playbin.uri = temp_file.get_uri ();
            playbin.set_state (Gst.State.PLAYING);
        }
}
}