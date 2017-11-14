using Gtk;
Window window;
string folder_location;

int main(string[] args) {
  init(ref args);

  // Global Vars
  var css_provider = new Gtk.CssProvider();
  var download_button = new Button.with_label("Download");
  var header = new HeaderBar();
  var window = new Window();
  var url_input = new Entry();
  bool has_input = false;
  bool has_location = false;
  var location_button = new Button.with_label("Select Folder to Save");
  var video_label = new Label("");
  var info_button = new Button.with_label("Get Video Info");
  var audio_only = new CheckButton.with_label ("Audio Only");
  var with_subtitles = new CheckButton.with_label ("Add Subtitles");
  bool audio = false;
  bool subtitles = false;
  // Grid
  var grid = new Grid();

  // Add CSS file
  try {
    css_provider.load_from_path("style.css");
  } catch (GLib.Error e) {
    warning ("%s", e.message);
  }
  Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

  // Header
  header.set_show_close_button(true);
  header.set_title("VIDO - Video Downloader");
  
  // Window
  window.set_border_width(15);
  // window.set_default_size(600, 800);
  window.resizable = false;
  window.set_titlebar(header);
  window.destroy.connect(Gtk.main_quit);

  // grid.orientation = Gtk.Orientation.VERTICAL;
  grid.row_spacing = 6;
  grid.column_spacing = 6;

  // URL input
  url_input.get_style_context().add_class("input");
  url_input.set_placeholder_text("Enter url...");
  stdout.printf("url_input_text");
  url_input.changed.connect (() => {
    string url_input_text = url_input.text;
    if (url_input_text.length > 1) {
      if (has_location) {
        download_button.set_sensitive (true);
      }
      has_input = true;
    }
  });
  // Add a delete-button:
  url_input.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear");
  url_input.set_input_purpose(Gtk.InputPurpose.URL);
  url_input.icon_press.connect ((pos, event) => {
    if (pos == Gtk.EntryIconPosition.SECONDARY) {
      info_button.label = "Get Video Info";
      video_label.label = "";
      url_input.set_text ("");
      download_button.label = "Download";
      with_subtitles.active = false;
      download_button.set_sensitive (false);
      audio_only.active = false;
    }
  });
  // url_input.set_text("https://youtube.com/ID");
  grid.attach (url_input, 0, 0, 75, 1);

  // Save location button
  location_button.clicked.connect (() => {
    on_open_clicked();
    location_button.label = folder_location;
    if (folder_location.length > 0) { //&& url_input.get_text() != ""
      has_location = true;
      if (has_input) {
        download_button.set_sensitive (true);
      }
    }
  });
  grid.attach (location_button, 0, 1, 75, 1);

  // Audio Only
  audio_only.toggled.connect (() => {
    // Emitted when the audio_only has been clicked:
    if (audio_only.active) {
      with_subtitles.active = false;
      audio = true;
    } else {
      audio = false;
    }
  });
  grid.attach (audio_only, 0, 7, 20, 1);

  // With Subtitles
  with_subtitles.toggled.connect (() => {
    // Emitted when the with_subtitles has been clicked:
    if (with_subtitles.active) {
      audio_only.active = false;
      subtitles = true;
    } else {
      subtitles = false;
    }
  });
  grid.attach_next_to (with_subtitles, audio_only, Gtk.PositionType.RIGHT, 2, 1);

  // Video Label
  video_label.get_style_context().add_class("videolabel");
  video_label.margin_top = 10;
  grid.attach (video_label, 0, 3, 75, 1);

  // Get info button
  info_button.clicked.connect (() => {
    string str = "Info Loaded...";
    info_button.label = str;
    try {
      string standard_output, standard_error;
      int exit_status;
      Process.spawn_command_line_sync("youtube-dl -e --get-duration --get-format " + url_input.get_text(), out standard_output, out standard_error, out exit_status);
      video_label.label = standard_output;
      stderr.printf("%s\n", standard_output);
    } catch (SpawnError e) {
      stderr.printf("%s\n", e.message);
    }
    // info_button.set_sensitive (false);
  });
  grid.attach (info_button, 0, 2, 75, 1);

  // download_button button
  download_button.get_style_context().add_class(Gtk.STYLE_CLASS_SUGGESTED_ACTION);
  download_button.get_style_context().add_class("downloadbutton");
  download_button.set_sensitive (false);
  download_button.clicked.connect (() => {
    download_button.label = "Downloading...";
    download_button.set_sensitive (false);
    // var notification = new Notification (_("Hello World"));
    // notification.set_body (_("This is my first notification!"));
    // this.send_notification ("notify.app", notification);
    // var image = new Gtk.Image.from_icon_name ("dialog-warning", Gtk.IconSize.DIALOG);
    // notification.set_icon (image.gicon);
    string[] spawn_args;
    if (audio) { // --extract-audio
      spawn_args = {"youtube-dl", "--no-warnings", "--extract-audio", url_input.get_text()};
    } else if (subtitles) {
      spawn_args = {"youtube-dl", "--no-warnings", "--all-subs", url_input.get_text()};
    } else {
      spawn_args = {"youtube-dl", "--no-warnings", url_input.get_text()};
    }
    MainLoop loop = new MainLoop ();
    try {
      string[] spawn_env = Environ.get ();
      Pid child_pid;

      Process.spawn_async (folder_location,
        spawn_args,
        spawn_env,
        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
        null,
        out child_pid);

      ChildWatch.add (child_pid, (pid, status) => {
        // Triggered when the child indicated by child_pid exits
        download_button.label = "Finished!";
        download_button.set_sensitive (true);
        Process.close_pid (pid);
        loop.quit ();
      });

      loop.run ();
    } catch (SpawnError e) {
      stdout.printf ("Error: %s\n", e.message);
    }
  });
  download_button.margin_top = 10;
  grid.attach (download_button, 0, 8, 75, 12);

  // Add to window
  location_button.grab_focus();
  window.add(grid);
  window.show_all();
  
  Gtk.main();
  return 0;
}

void on_open_clicked () {
  var file_chooser = new FileChooserDialog (
    "Open Folder",
    window,
    FileChooserAction.SELECT_FOLDER,
    "_Cancel", ResponseType.CANCEL,
    "_Open", ResponseType.ACCEPT);
  if (file_chooser.run () == ResponseType.ACCEPT) {
    folder_location = file_chooser.get_filename ();
    stderr.printf ("Folder Selected: %s\n", file_chooser.get_filename ());
  }
  file_chooser.destroy ();
}
