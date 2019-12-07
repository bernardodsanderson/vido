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

public class MainWindow : Gtk.ApplicationWindow {
    private string folder_location;
    private string video_info;
    private uint configure_id;

    public MainWindow (Gtk.Application app) {
        Object (
            application: app,
            border_width: 15,
            resizable: false
        );
    }

    construct {
        // Add CSS file
        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("/com/github/bernardodsanderson/vido/style.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // Header
        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.title = _("VIDO - Video Downloader");
        set_titlebar (header);

        // URL input
        var url_input = new Gtk.Entry ();
        url_input.get_style_context ().add_class ("inputurl");
        url_input.placeholder_text = _("Enter URL…");

        // Add a clear icon
        url_input.secondary_icon_name = "edit-clear";
        url_input.input_purpose = Gtk.InputPurpose.URL;

        // Save location button
        var location_label = new Gtk.Label (_("Folder to Save:"));
        location_label.halign = Gtk.Align.END;
        var location_button = new Gtk.FileChooserButton (_("Select Folder to Save"), Gtk.FileChooserAction.SELECT_FOLDER);
        location_button.halign = Gtk.Align.START;
        location_button.set_filename (get_destination ());

        // Audio Only
        var audio_only = new Gtk.CheckButton.with_label (_("Audio Only"));

        // With Subtitles
        var with_subtitles = new Gtk.CheckButton.with_label (_("Add Subtitles"));

        // Video Label
        var video_label = new Gtk.Label ("");
        video_label.get_style_context ().add_class ("videolabel");
        video_label.margin_top = 10;

        // Get info button
        var info_button = new Gtk.Button.with_label (_("Get Video Info"));
        info_button.sensitive = false;

        // download_button button
        var download_button = new Gtk.Button.with_label (_("Download"));
        download_button.margin_top = 10;
        download_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        download_button.get_style_context ().add_class ("downloadbutton");
        download_button.sensitive = false;

        var grid = new Gtk.Grid ();
        grid.row_spacing = 6;
        grid.column_spacing = 6;
        grid.attach (url_input, 0, 0, 7, 1);
        grid.attach (location_label, 0, 1, 1, 1);
        grid.attach (location_button, 1, 1, 1, 1);
        grid.attach (audio_only, 2, 1, 2, 1);
        grid.attach (with_subtitles, 4, 1, 2, 1);
        grid.attach (info_button, 0, 2, 7, 1);
        grid.attach (video_label, 0, 3, 7, 1);
        grid.attach (download_button, 0, 4, 7, 1);
        add (grid);

        url_input.changed.connect (() => {
            if (url_input.text != "") {
                info_button.sensitive = true;

                if (folder_location != "") {
                    download_button.sensitive = true;
                }
            } else {
                info_button.sensitive = false;
                download_button.sensitive = false;
            }
        });

        url_input.icon_press.connect ((pos, event) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY) {
                info_button.label = _("Get Video Info");
                video_label.label = "";
                url_input.text = "";
                download_button.label = _("Download");
                with_subtitles.active = false;
                download_button.sensitive = false;
                audio_only.active = false;
            }
        });

        location_button.file_set.connect (() => {
            Application.settings.set_string ("destination", location_button.get_filename ());

            if (folder_location != "") {
                if (url_input.text != "") {
                    download_button.sensitive = true;
                }
            }
        });

        audio_only.toggled.connect (() => {
            // Emitted when the audio_only has been clicked:
            if (audio_only.active) {
                with_subtitles.active = false;
            }
        });

        with_subtitles.toggled.connect (() => {
            // Emitted when the with_subtitles has been clicked:
            if (with_subtitles.active) {
                audio_only.active = false;
            }
        });

        Application.settings.bind ("audio-only", audio_only, "active", SettingsBindFlags.DEFAULT);
        Application.settings.bind ("with-subtitles", with_subtitles, "active", SettingsBindFlags.DEFAULT);

        info_button.clicked.connect (() => {
            string str = _("Loading info…");
            info_button.label = str;
            MainLoop loop = new MainLoop ();
            try {
                string[] spawn_args = { "youtube-dl", "-e", "--get-duration", "--get-format", url_input.text };
                string[] spawn_env = Environ.get ();
                Pid child_pid;

                int standard_input;
                int standard_output;
                int standard_error;

                Process.spawn_async_with_pipes ("/",
                    spawn_args,
                    spawn_env,
                    SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                    null,
                    out child_pid,
                    out standard_input,
                    out standard_output,
                    out standard_error);

                // stdout:
                IOChannel output = new IOChannel.unix_new (standard_output);
                output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stdout");
                });

                // stderr:
                IOChannel error = new IOChannel.unix_new (standard_error);
                error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stderr");
                });

                ChildWatch.add (child_pid, (pid, status) => {
                    // Triggered when the child indicated by child_pid exits
                    if (status == 0) {
                        video_label.label = video_info;
                    } else {
                        video_label.label = "";

                        var error_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                            _("Unable to fetch the video info"),
                            _("The following error message may be helpful:"),
                            "dialog-error");
                        error_dialog.transient_for = this;
                        error_dialog.show_error_details (video_info);
                        error_dialog.run ();
                        error_dialog.destroy ();
                    }

                    video_info = ""; // Clear the video info (or the error message)
                    info_button.label = _("Get Video Info");
                    Process.close_pid (pid);
                    loop.quit ();
                });

                loop.run ();
            } catch (SpawnError e) {
                stdout.printf ("Error: %s\n", e.message);
            }
        });

        download_button.clicked.connect (() => {
            download_button.label = _("Downloading…");
            download_button.sensitive = false;
            // var notification = new Notification (_("Hello World"));
            // notification.set_body (_("This is my first notification!"));
            // this.send_notification ("notify.app", notification);
            // var image = new Gtk.Image.from_icon_name ("dialog-warning", Gtk.IconSize.DIALOG);
            // notification.set_icon (image.gicon);
            string[] spawn_args;
            if (audio_only.active) { // --extract-audio
                spawn_args = { "youtube-dl", "--no-warnings", "--extract-audio", url_input.text };
            } else if (with_subtitles.active) {
                spawn_args = { "youtube-dl", "--no-warnings", "--all-subs", url_input.text };
            } else {
                spawn_args = { "youtube-dl", "--no-warnings", url_input.text };
            }

            MainLoop loop = new MainLoop ();
            try {
                string[] spawn_env = Environ.get ();
                Pid child_pid;

                int standard_input;
                int standard_output;
                int standard_error;

                Process.spawn_async_with_pipes (folder_location,
                    spawn_args,
                    spawn_env,
                    SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                    null,
                    out child_pid,
                    out standard_input,
                    out standard_output,
                    out standard_error);

                // stdout:
                IOChannel output = new IOChannel.unix_new (standard_output);
                output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stdout");
                });

                // stderr:
                IOChannel error = new IOChannel.unix_new (standard_error);
                error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stderr");
                });

                ChildWatch.add (child_pid, (pid, status) => {
                    // Triggered when the child indicated by child_pid exits
                    if (status == 0) {
                        download_button.label = _("Finished!");
                        download_button.sensitive = true;
                    } else {
                        download_button.label = _("Download");

                        var error_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                            _("Unable to download the video"),
                            _("The following error message may be helpful:"),
                            "dialog-error");
                        error_dialog.transient_for = this;
                        error_dialog.show_error_details (video_info);
                        error_dialog.run ();
                        error_dialog.destroy ();
                    }

                    video_info = ""; // Clear the video info (or the error message)
                    Process.close_pid (pid);
                    loop.quit ();
                });

                loop.run ();
            } catch (SpawnError e) {
                stdout.printf ("Error: %s\n", e.message);
            }
        });
    }

    private string get_destination () {
        string destination = Application.settings.get_string ("destination");

        if (destination != null) {
            DirUtils.create_with_parents (destination, 0775);
        }

        return destination;
    }

    private bool process_line (IOChannel channel, IOCondition condition, string stream_name) {
        if (condition == IOCondition.HUP) {
            stdout.printf ("%s: The fd has been closed.\n", stream_name);
            return false;
        }

        try {
            string line;
            channel.read_line (out line, null, null);
            video_info = line + video_info;
            stdout.printf ("%s: %s", stream_name, line);
        } catch (IOChannelError e) {
            stdout.printf ("%s: IOChannelError: %s\n", stream_name, e.message);
            return false;
        } catch (ConvertError e) {
            stdout.printf ("%s: ConvertError: %s\n", stream_name, e.message);
            return false;
        }

        return true;
    }

    protected override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;
            int x, y;
            get_position (out x, out y);
            Application.settings.set ("window-position", "(ii)", x, y);

            return false;
        });

        return base.configure_event (event);
    }
}
