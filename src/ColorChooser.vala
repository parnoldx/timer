namespace Timer {
    private class ColorChooser : Gtk.MenuItem {
        private new bool has_focus;
        public signal void color_changed (Color color);
        private int diameter = 16;
        private Color[] colors = Color.all ();

        public ColorChooser () {
            set_size_request (8*diameter+14*6-4, 30);

            button_press_event.connect (button_pressed);
            draw.connect (on_draw);

            select.connect (() => {
                has_focus = true;
            });

            deselect.connect (() => {
                has_focus = false;
            });
        }

        private bool button_pressed (Gdk.EventButton event) {
            int x00 = 10;
            int x0 = diameter + 6;

            for (int i = 0; i < colors.length; i++) {
                if (event.x >= x00+x0 * (i+1) - 3 && event.x <= x00+x0 * (i+1) + diameter + 3) {
                    color_changed (colors[i]);
                    break;
                }
            }
            return true;
        }

        protected bool on_draw (Cairo.Context cr) {
            int x00 = 10;
            int y0 = diameter;
            int x0 = diameter + 6;

            for (int i = 0; i < colors.length; i++) {
                cr.stroke ();
                cr.arc (x00+x0*(i+1) + 6, y0, diameter / 2, 0, 2*Math.PI);
                Gdk.RGBA rgba = Gdk.RGBA ();

                rgba.parse (colors[i].get_secondary_color ());
                Gdk.cairo_set_source_rgba (cr, rgba);
                cr.fill ();
                cr.arc (x00+x0*(i+1) + 6, y0, diameter / 2, 0, 2*Math.PI);
                // cr.set_source_rgba (0,0,0,0.5);
                Gdk.RGBA rgba2 = Gdk.RGBA ();
                rgba2.parse (colors[i].get_primary_color ());
                Gdk.cairo_set_source_rgba (cr, rgba2);
                cr.stroke ();
            }

            return true;
        }
    }
}
