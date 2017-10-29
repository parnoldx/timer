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
					return "#ffe16b";
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
					return "#fff394";
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
		@define-color colorPrimary %s;
		@define-color colorAccent %s;
		@define-color bg_highlight_color shade (@colorPrimary, 1.4);

		.titlebar,
		.background {
		    border: none;
		    background-image: none;
		    background-color: @colorPrimary;
		    padding: 1px 3px;
		    box-shadow:
		        inset 1px 0 0 0 alpha (@colorPrimary, 0.2),
		        inset -1px 0 0 0 alpha (@colorPrimary, 0.2),
		        inset 0 1px 0 0 @colorPrimary;
		}
		.entry {
		    font-size: 18px;
		}
		""";

		private const string CHANGE_COLOR = """
		@define-color colorPrimary %s;
		@define-color colorAccent %s;
        .background,
        .titlebar {
            transition: all 600ms ease-in-out;
        }
    	""";

		public static void startup (Timer.Color color, int uid) {
			try {
            	var provider = new Gtk.CssProvider ();
            	provider.load_from_data (ColorManager.STARTUP_CSS.printf (color.get_primary_color (), color.get_secondary_color ()));
            	Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
             } catch (GLib.Error e) {
            	GLib.error ("Failed to load css: %s", e.message);
        	}
		}

		public static void change_color (Timer.Color color, int uid) {
			try {
            	var provider = new Gtk.CssProvider ();
            	provider.load_from_data (ColorManager.CHANGE_COLOR.printf (color.get_primary_color (), color.get_secondary_color ()));
            	Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
            	GLib.error ("Failed to load css: %s", e.message);
        	}
		}

		public static void beep () {
			highlight_red ();
			unhighlight_red ();
			Timeout.add (210, ()=> {
				highlight_red ();
				unhighlight_red ();
				return false;
			});
			Timeout.add (410, ()=> {
				highlight_red ();
				unhighlight_red ();
				return false;
			});

		}

		private static void highlight_red () {
			try {
            	var provider = new Gtk.CssProvider ();
            	provider.load_from_data ("""
				.background {
					background-color:red;
        		}""");
            	Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
            	GLib.error ("Failed to load css: %s", e.message);
        	}
		}

		private static void  unhighlight_red () {
			Timeout.add (90, ()=> {
				try {
            		var provider = new Gtk.CssProvider ();
            		provider.load_from_data ("""
					.background {
						background-color:@colorPrimary;
        			}""");
            		Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            	} catch (GLib.Error e) {
            		GLib.error ("Failed to load css: %s", e.message);
        		}
        		return false;
        	});
		}

		public static Gdk.Pixbuf get_icon (Timer.Color color) {
			try {
				var replace_svg = icon_svg_data.printf (color.get_primary_color ());//, color.get_secondary_color ());
 				return new Gdk.Pixbuf.from_stream (new GLib.MemoryInputStream.from_data (replace_svg.data, GLib.g_free));
 			} catch (GLib.Error e) {
            	GLib.error ("Failed to create icon: %s", e.message);
        	}
		}

		public const string icon_svg_data = """<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   width="16"
   height="16"
   viewBox="0 0 16 16"
   id="svg2"
   version="1.1"
   >
  <defs
     id="defs4" />
  <metadata
     id="metadata7">
    </metadata>
  <g
     id="layer1"
     transform="translate(0,-1036.3622)">
    <circle
       style="fill:%s;fill-opacity:1;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none"
       id="path4136"
       cx="8"
       cy="1044.3622"
       r="7" />
    <path
       style="fill:#ed5353;fill-opacity:0;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none"
       d="M 6.7774711,14.862042 C 3.8486262,14.308707 1.5829103,11.991637 1.1150244,9.0712513 0.99308876,8.3101708 1.0675418,6.9269622 1.2698269,6.1952886 1.8070215,4.252233 3.1361535,2.6422977 4.9293109,1.7626719 8.4479552,0.03661582 12.650906,1.5177896 14.315806,5.070593 c 0.402698,0.859334 0.568827,1.5708648 0.609785,2.6116985 0.04057,1.0309396 -0.02894,1.5921602 -0.303015,2.4466845 -0.436105,1.35969 -1.296176,2.568407 -2.45368,3.448325 -0.585792,0.445311 -1.682485,0.970914 -2.4339048,1.166478 -0.8023604,0.208822 -2.1854461,0.264127 -2.9575201,0.118263 z"
       id="path4138"
       transform="translate(0,1036.3622)" />
    <path
       style="fill:#ed5353;fill-opacity:0;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none"
       d="M 6.7774711,14.862042 C 3.8486262,14.308707 1.5829103,11.991637 1.1150244,9.0712513 0.99308876,8.3101708 1.0675418,6.9269622 1.2698269,6.1952886 1.8070215,4.252233 3.1361535,2.6422977 4.9293109,1.7626719 8.4479552,0.03661582 12.650906,1.5177896 14.315806,5.070593 c 0.402698,0.859334 0.568827,1.5708648 0.609785,2.6116985 0.04057,1.0309396 -0.02894,1.5921602 -0.303015,2.4466845 -0.436105,1.35969 -1.296176,2.568407 -2.45368,3.448325 -0.585792,0.445311 -1.682485,0.970914 -2.4339048,1.166478 -0.8023604,0.208822 -2.1854461,0.264127 -2.9575201,0.118263 z"
       id="path4140"
       transform="translate(0,1036.3622)" />
    <path
       style="fill:#ed5353;fill-opacity:0;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none"
       d="M 6.7774711,14.862042 C 3.8486262,14.308707 1.5829103,11.991637 1.1150244,9.0712513 0.99308876,8.3101708 1.0675418,6.9269622 1.2698269,6.1952886 1.8070215,4.252233 3.1361535,2.6422977 4.9293109,1.7626719 8.4479552,0.03661582 12.650906,1.5177896 14.315806,5.070593 c 0.402698,0.859334 0.568827,1.5708648 0.609785,2.6116985 0.04057,1.0309396 -0.02894,1.5921602 -0.303015,2.4466845 -0.436105,1.35969 -1.296176,2.568407 -2.45368,3.448325 -0.585792,0.445311 -1.682485,0.970914 -2.4339048,1.166478 -0.8023604,0.208822 -2.1854461,0.264127 -2.9575201,0.118263 z"
       id="path4142"
       transform="translate(0,1036.3622)" />
    <path
       style="fill:#ed5353;fill-opacity:0;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none"
       d="M 6.7774711,14.862042 C 3.8486262,14.308707 1.5829103,11.991637 1.1150244,9.0712513 0.99308876,8.3101708 1.0675418,6.9269622 1.2698269,6.1952886 1.8070215,4.252233 3.1361535,2.6422977 4.9293109,1.7626719 8.4479552,0.03661582 12.650906,1.5177896 14.315806,5.070593 c 0.402698,0.859334 0.568827,1.5708648 0.609785,2.6116985 0.04057,1.0309396 -0.02894,1.5921602 -0.303015,2.4466845 -0.436105,1.35969 -1.296176,2.568407 -2.45368,3.448325 -0.585792,0.445311 -1.682485,0.970914 -2.4339048,1.166478 -0.8023604,0.208822 -2.1854461,0.264127 -2.9575201,0.118263 z"
       id="path4144"
       transform="translate(0,1036.3622)" />
  </g>
</svg>""";

}
}