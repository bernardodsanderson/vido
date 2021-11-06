/*
* Copyright 2017-2019 Bernardo Anderson
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

public class Application : Gtk.Application {
    private MainWindow window;
    public static Settings settings;

    public Application () {
        Object (
            application_id: "com.github.bernardodsanderson.vido",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        settings = new Settings ("com.github.bernardodsanderson.vido");
    }

    protected override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        var open_action = new SimpleAction ("open", null);
        open_action.activate.connect (() => {
            try {
                File destination = File.new_for_path (Application.settings.get_string ("destination"));
                AppInfo.launch_default_for_uri (destination.get_uri (), null);
            } catch (Error e) {
                warning (e.message);
            }
        });
        add_action (open_action);

        int window_x, window_y;
        settings.get ("window-position", "(ii)", out window_x, out window_y);

        window = new MainWindow (this);

        if (window_x != -1 || window_y != -1) { // Not a first time launch
            window.move (window_x, window_y);
        } else { // First time launch
            window.window_position = Gtk.WindowPosition.CENTER;
        }

        window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run (args);
    }
}
