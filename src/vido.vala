using Gtk;
Window window;
string folder_location;

int main(string[] args) {
  init(ref args);

  // Header
  var header = new HeaderBar();
  header.set_show_close_button(true);
  header.set_title("VIDO - Video Downloader");
  
  // Window
  var window = new Window();
  window.set_border_width(15);
  // window.set_default_size(600, 800);
  window.resizable = false;
  window.set_titlebar(header);
  window.destroy.connect(Gtk.main_quit);

  // Grid
  var grid = new Grid();
  // grid.orientation = Gtk.Orientation.VERTICAL;
  grid.row_spacing = 6;
  grid.column_spacing = 6;
  
  // URL label
  var url_label = new Label("Enter Url: ");
  grid.attach(url_label, 0, 0, 1, 1);
  // layout.attach_next_to (hello_label, hello_button, Gtk.PositionType.RIGHT, 1, 1);

  // URL input
  var url_input = new Entry();
  // url_input.set_text("https://youtube.com/ID");
  grid.attach_next_to(url_input, url_label, PositionType.RIGHT, 2, 1);

  // Save location button
  var location_button = new Button.with_label("Select Folder to Save");
  location_button.clicked.connect (() => {
    on_open_clicked();
    location_button.label = folder_location;
  });
  grid.attach (location_button, 0, 1, 35, 1);

  // Get info button
  var info_button = new Button.with_label("Get Video Info");
  info_button.clicked.connect (() => {
    string str = url_input.get_text();
    info_button.label = str;
    info_button.set_sensitive (false);
  });
  grid.attach (info_button, 0, 2, 35, 1);

  // download_button button
  var download_button = new Button.with_label("Download");
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
  });
  download_button.margin_top = 10;
  grid.attach (download_button, 0, 3, 35, 10);

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
