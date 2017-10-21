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
  var location_button = new Button.with_label("Select Folder to Save");
  var video_label = new Label("");
  var info_button = new Button.with_label("Get Video Info");
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
  // url_input.set_text("https://youtube.com/ID");
  grid.attach (url_input, 0, 0, 75, 1);

  // Save location button
  location_button.clicked.connect (() => {
    on_open_clicked();
    location_button.label = folder_location;
  });
  grid.attach (location_button, 0, 1, 75, 1);

  // Video Label
  url_input.get_style_context().add_class("videolabel");
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
  download_button.clicked.connect (() => {
    string str = url_input.get_text();
    download_button.label = str;
    download_button.set_sensitive (false);
    // var notification = new Notification (_("Hello World"));
    // notification.set_body (_("This is my first notification!"));
    // this.send_notification ("notify.app", notification);
    // var image = new Gtk.Image.from_icon_name ("dialog-warning", Gtk.IconSize.DIALOG);
    // notification.set_icon (image.gicon);
    try {
      string standard_output, standard_error;
      int exit_status;
      Process.spawn_command_line_sync("youtube-dl --get-title " + url_input.get_text(), out standard_output, out standard_error, out exit_status);
      Process.spawn_command_line_sync("youtube-dl -o '" + folder_location + "/" + standard_output + "' '" + url_input.get_text() + "'");
    } catch (SpawnError e) {
      stderr.printf("%s\n", e.message);
    }
    download_button.label = "Done!";
  });
  download_button.margin_top = 20;
  grid.attach (download_button, 0, 8, 75, 12);

  // Add to window
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
