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
	public enum Color {
		STRAWBERRY,
		ORANGE,
		BANANA,
		LIME,
		BLUEBERRY,
		GRAPE,
		SILVER,
		SLATE,
		BLACK;

		public static Color get (string label) {
			foreach (Color c in Color.all ()) {
				if (c.get_label () == label) {
					return c;
				}
			}
			assert_not_reached();
		}

		public string get_label () {
			switch (this) {
				case STRAWBERRY:
					return "Strawberry";
				case ORANGE:
					return "Orange";
				case BANANA:
					return "Banana";
				case LIME:
					return "Lime";
				case BLUEBERRY:
					return "Blueberry";
				case GRAPE:
					return "Grape";
				case SILVER:
					return "Silver";
				case SLATE:
					return "Slate";
				case BLACK:
					return "Black";
				default:
                	assert_not_reached();
			}
		}

		public string get_primary_color () {
			switch (this) {
				case STRAWBERRY:
					return "#ed5353";
				case ORANGE:
					return "#ffa154";
				case BANANA:
					return "#f9c440";
				case LIME:
					return "#9bdb4d";
				case BLUEBERRY:
					return "#64baff";
				case GRAPE:
					return "#ad65d6";
				case SILVER:
					return "#abacae";
				case SLATE:
					return "#485a6c";
				case BLACK:
					return "#4d4d4d";
				default:
                	assert_not_reached();
			}
		}

		public string get_secondary_color () {
			switch (this) {
				case STRAWBERRY:
					return "#ff8c82";
				case ORANGE:
					return "#ffc27d";
				case BANANA:
					return "#ffe16b";
				case LIME:
					return "#d1ff82";
				case BLUEBERRY:
					return "#8cd5ff";
				case GRAPE:
					return "#e29ffc";
				case SILVER:
					return "#d4d4d4";
				case SLATE:
					return "#667885";
				case BLACK:
					return "#666666";
				default:
                	assert_not_reached();
			}
		}

		public static Color[] all() {
       		return { STRAWBERRY,
		ORANGE,
		BANANA,
		LIME,
		BLUEBERRY,
		GRAPE,
		SILVER,
		SLATE,
		BLACK};
   		}
	}
public class ColorManager : GLib.Object {
		public const string STARTUP_CSS = """
		@define-color colorPrimary%d %s;
		@define-color colorAccent%d %s;
		@define-color textColorPrimary #1a1a1a;

		.w-%d {
		    background-color: @colorPrimary%d;
		}
		.w-%d .titlebar {
		    background-color: @colorPrimary%d;
		    padding: 1px 3px;
			box-shadow: none;
		}
		.w-%d .titlebar entry {
			background: none;
			border: none;
			box-shadow: none;
		}
		.w-%d .titlebar entry:focus {
			border-bottom: 1px solid @base_color;
		}
		.entry-%d {
		    font-size: 18px;
		}

.entry-%d:focus {
    border-color: alpha (@colorAccent%d, 0.8);
    box-shadow:
        inset 0 0 0 1px alpha (@colorAccent%d, 0.23),
        0 1px 0 0 alpha (@bg_highlight_color, 0.3);
    transition: all 200ms ease-in;
}
.entry-%d progress,
.entry-%d progress:focus,
.entry-%d.progressbar,
.entry-%d.progressbar:focus {
    background-image:
        linear-gradient(
            to bottom,
            mix(
                @colorAccent%d,
                @base_color,
                0.4
            ),
            mix(
                @colorAccent%d,
                @base_color,
                0.5
            )
        );
    border: 1px solid @colorAccent%d;
    border-right: 0;
    border-top-right-radius: 0;
    border-bottom-right-radius: 0;
    box-shadow:
        inset 0 1px 0 0 alpha (@inset_dark_color, 0.7),
        inset 0 0 0 1px alpha (@inset_dark_color, 0.3);
}
.entry-%d:selected {
    background-color: shade (@colorAccent%d, 0.8);
    color: @text_color;
}

.entry-%d:selected:focus {
    background-color: alpha (@colorAccent%d, 0.9);
    color: @text_color;
    text-shadow: none;
}
		""";

		private const string CHANGE_COLOR = """
		@define-color colorPrimary%d %s;
		@define-color colorAccent%d %s;

        .w-%d,
		.w-%d .titlebar,
		.entry-%d progress {
            transition: all 600ms ease-in-out;
        }
    	""";

    	public static int font_size = 18;
    	private const string FONT_CHANGE = """
    	.entry-%d {
		    font-size: %dpx;
		}
    	""";

		public static void startup (Timer.Color color, int uid) {
			if (uid > 0) {
				var colorarray = Color.all ();
				for (int i = 0; i < colorarray.length; i++) {
					if (colorarray[i] == color) {
						color = colorarray[(i+uid)%colorarray.length];
						break;
					}
				}
			}
			try {
            	var provider = new Gtk.CssProvider ();
            	provider.load_from_data (ColorManager.STARTUP_CSS.printf (uid, color.get_primary_color (),
            		uid, color.get_secondary_color (), uid, uid, uid, uid, uid, uid, uid, uid, uid, uid, uid, uid,
            		uid, uid, uid, uid, uid, uid, uid, uid, uid));
            	Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
             } catch (GLib.Error e) {
            	GLib.error ("Failed to load css: %s", e.message);
        	}
		}

		public static void change_color (Timer.Color color, int uid) {
			try {
            	var provider = new Gtk.CssProvider ();
            	provider.load_from_data (ColorManager.CHANGE_COLOR.printf (uid, color.get_primary_color (), uid, color.get_secondary_color (), uid, uid, uid));
            	Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
            	GLib.error ("Failed to load css: %s", e.message);
        	}
		}

		public static void change_font (int size, int uid) {
			font_size = size;
			try {
            	var provider = new Gtk.CssProvider ();
            	provider.load_from_data (ColorManager.FONT_CHANGE.printf (uid, font_size));
            	Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
            	GLib.error ("Failed to load css: %s", e.message);
        	}
		}

		public static void beep (Settings setting, int uid) {
			if (setting.get_boolean ("sound-beep"))
				play_beep_sound ();
			if (!setting.get_boolean ("flash-beep"))
				return;
			// flash red to the sound
			highlight_red (uid);
			unhighlight_red (uid);
			Timeout.add (210, ()=> {
				highlight_red (uid);
				unhighlight_red (uid);
				return false;
			});
			Timeout.add (410, ()=> {
				highlight_red (uid);
				unhighlight_red (uid);
				return false;
			});
		}

		private static void play_beep_sound () {
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

		private static void highlight_red (int uid) {
			try {
            	var provider = new Gtk.CssProvider ();
            	provider.load_from_data ("""
				.w-%d {
					background-color:red;
        		}""".printf (uid));
            	Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
            	GLib.error ("Failed to load css: %s", e.message);
        	}
		}

		private static void  unhighlight_red (int uid) {
			Timeout.add (90, ()=> {
				try {
            		var provider = new Gtk.CssProvider ();
            		provider.load_from_data ("""
					.w-%d {
						background-color:@colorPrimary%d;
        			}""".printf (uid, uid));
            		Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            	} catch (GLib.Error e) {
            		GLib.error ("Failed to load css: %s", e.message);
        		}
        		return false;
        	});
		}

}
}