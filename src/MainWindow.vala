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
    	private Settings settings;
        public int uid { get; construct set; }
        public string? timer_name { get; construct set; }
        public string timer { get; construct set; }
        TimerManager timer_manager;
        private bool is_finished;

		public MainWindow (Gtk.Application application, int window_id, string? name, string? t_set) {
			Object (application: application,
                icon_name: "com.github.parnold-x.timer",
                title: _("Timer"),
                resizable: false,
                height_request: 280,
                width_request: 520,
                uid: window_id,
                timer_name: name,
                timer: t_set);
        }

        construct {
            settings = new Settings ("com.github.parnold-x.timer");
            ColorManager.startup (Color.get (settings.get_string ("color")), uid);
            get_style_context ().add_class ("w-%d".printf(uid));

            var window_x = settings.get_int ("window-x");
            var window_y = settings.get_int ("window-y");

            if (window_x != -1 ||  window_y != -1) {
                move (window_x + 25*uid, window_y+25*uid);
            }

            var header_bar = new Gtk.HeaderBar ();
            header_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            header_bar.show_close_button = true;
            var settings_button = create_settings_menu ();
            header_bar.pack_end (settings_button);

            var title = new TitleLabel (timer_name);

            header_bar.set_custom_title (title);
            set_titlebar (header_bar);

            this.delete_event.connect (on_window_closing);

            timer_manager = new TimerManager ();
            var time_entry = new TimerEntry (timer_manager, uid);

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
            // set_keep_above (settings.get_boolean ("always-on-top"));
            time_entry.unfocus.connect (() => {
                focus (Gtk.DirectionType.UP);
            });

            title.unfocus.connect (() => {
                time_entry.focus (Gtk.DirectionType.UP);
            });

            var launcher = Unity.LauncherEntry.get_for_desktop_id ("com.github.parnold-x.timer.desktop");

            timer_manager.new_timer_set.connect ((t) => {
                focus (Gtk.DirectionType.UP);
                if (is_finished) {
                    title.text = title.last_title;
                    is_finished = false;
                }
                t.start ();
                if (uid == 0)
                    launcher.progress_visible = true;
            });
            timer_manager.tick.connect ((t) => {
                time_entry.set_progress_fraction (t.time_elapsed_percentage);
                if (uid == 0)
                    launcher.progress = t.time_elapsed_percentage;
                if (!timer_manager.stop_notify)
                    time_entry.text = t.time_left.to_string ();
            });
            timer_manager.timer_finished.connect ((t) => {
                time_entry.set_progress_fraction (t.time_elapsed_percentage);
                if (!is_finished) {
                    title.text = _("%s finished").printf (title.text);
                    is_finished = true;
                }
                if (!timer_manager.stop_notify)
                    time_entry.text = title.text;
                set_keep_above (true);
                ColorManager.beep (settings, uid);
                set_keep_above (settings.get_boolean ("always-on-top"));
                if (uid == 0)
                    launcher.progress_visible = false;
            });

            if (time_entry.validate_timer (timer)) {
                time_entry.text = timer;
                time_entry.activate ();
            }
        }

        private Gtk.MenuButton create_settings_menu () {
            Gtk.Menu settings_menu = new Gtk.Menu();
            var new_timer = new Gtk.MenuItem.with_label (_("New Timer"));
            new_timer.activate.connect (() => {
                new MainWindow (get_application (), (int) get_application ().get_windows ().length (), null, "");
            });
            settings_menu.add(new_timer);
            var color_item = new ColorChooser ();
            color_item.color_changed.connect ((c) => {
                ColorManager.change_color (c, uid);
                settings.set_string ("color", c.get_label ());
            });
            settings_menu.add(color_item);
            settings_menu.add (new Gtk.SeparatorMenuItem ());
            var always_on_top = new Gtk.CheckMenuItem.with_label (_("Always on top"));
            always_on_top.active = settings.get_boolean ("always-on-top");
            always_on_top.toggled.connect (() => {
                var state = settings.get_boolean ("always-on-top");
                set_keep_above (!state);
                settings.set_boolean ("always-on-top",!state);
                always_on_top.active = !state;
            });
            settings_menu.add (always_on_top);

            var beep_sound = new Gtk.CheckMenuItem.with_label (_("Beep sound"));
            beep_sound.active = settings.get_boolean ("sound-beep");
            beep_sound.toggled.connect (() => {
                var state = settings.get_boolean ("sound-beep");
                settings.set_boolean ("sound-beep",!state);
                beep_sound.active = !state;
            });
            settings_menu.add (beep_sound);
            settings_menu.show_all();

            var settings_button = new Gtk.MenuButton();
            settings_button.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            settings_button.set_popup(settings_menu);

            return settings_button;
        }

        private bool on_window_closing () {
            timer_manager.actual_timer.stop ();
            int root_x, root_y;
            get_position (out root_x, out root_y);
            settings.set_int ("window-x", root_x);
            settings.set_int ("window-y", root_y);
            return false;
        }
}
}
