int main(string[] args) { // default
  Gtk.init(ref args); //default

  var header = new Gtk.HeaderBar();
  header.set_show_close_button(true);
  header.set_title("VIDO - Video Downloader");
  
  var window = new Gtk.Window();
  window.set_border_width(15);
  window.set_default_size(550, 270);
  window.set_titlebar(header);
  window.destroy.connect(Gtk.main_quit);
  
  var urlLabel = new Gtk.Label("Enter Url:");

  var infoButton = new Gtk.Button.with_label("Get Video Info");
  infoButton.clicked.connect (() => {
    infoButton.label = "Hello World!";
    infoButton.set_sensitive (false);
  });

  window.add(urlLabel);
  window.show_all();
  
  Gtk.main(); // default
  return 0; // default
}
