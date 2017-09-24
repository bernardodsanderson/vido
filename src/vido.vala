int main(string[] args) {
  Gtk.init(ref args);

  // Header
  var header = new Gtk.HeaderBar();
  header.set_show_close_button(true);
  header.set_title("VIDO - Video Downloader");
  
  // Window
  var window = new Gtk.Window();
  window.set_border_width(15);
  window.set_default_size(600, 600);
  window.set_titlebar(header);
  window.destroy.connect(Gtk.main_quit);

  // Grid
  var grid = new Gtk.Grid();
  // grid.orientation = Gtk.Orientation.VERTICAL;
  grid.row_spacing = 6;
  grid.column_spacing = 6;
  
  // URL label
  var url_label = new Gtk.Label("Enter Url: ");
  grid.attach(url_label, 0, 0, 1, 1);
  // layout.attach_next_to (hello_label, hello_button, Gtk.PositionType.RIGHT, 1, 1);

  // Get info button
  var info_button = new Gtk.Button.with_label("Get Video Info");
  info_button.clicked.connect (() => {
    info_button.label = "Hello World!";
    info_button.set_sensitive (false);
    // var notification = new Notification (_("Hello World"));
    // notification.set_body (_("This is my first notification!"));
    // this.send_notification ("notify.app", notification);
    // var image = new Gtk.Image.from_icon_name ("dialog-warning", Gtk.IconSize.DIALOG);
    // notification.set_icon (image.gicon);
  });
  grid.attach (info_button, 2, 0, 1, 1);

  // Add to window
  window.add(grid);
  window.show_all();
  
  Gtk.main();
  return 0;
}
