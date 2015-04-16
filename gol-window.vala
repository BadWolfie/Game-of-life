using Gtk;

public class GOLWindow : ApplicationWindow {
	private HeaderBar headerbar;
	private Scale chance_entry;
	private Lattice lattice;
	private bool running;
	private bool init;

	private Image play_img;
	private Image pause_img;
	private Button clean_button;
	private Button play_pause_button;

	public GOLWindow(Gtk.Application app) {
		Object(application: app);

		window_position = WindowPosition.CENTER;
		set_default_size(600,600);
		border_width = 0;
		running = false;
		init = false;

		create_widgets();
	}

	private void create_widgets() {
		headerbar = new HeaderBar();
		headerbar.show();

		headerbar.set_show_close_button(true);
		headerbar.set_title("Game of Life");
		set_titlebar(headerbar);

		chance_entry = new Scale.with_range(Orientation.HORIZONTAL,0,100,1);
		chance_entry.width_request = 100;
		chance_entry.show();

		var chance_label = new Label("Probabilidad (%): ");
		chance_label.show();

		var hbox = new Box(Orientation.HORIZONTAL,0);
		hbox.pack_start(chance_label,false,true,7);
		hbox.pack_start(chance_entry,true,true,0);
		hbox.show();

		// clean_button = new Button.from_icon_name(
		// 								"media-playback-stop-symbolic",
		// 								IconSize.LARGE_TOOLBAR);
		clean_button = new Button.with_mnemonic("_Limpiar");
		clean_button.clicked.connect(on_clean_clicked);
		clean_button.sensitive = false;
		clean_button.show();

		pause_img = new Image.from_icon_name("media-playback-pause-symbolic",
										   IconSize.LARGE_TOOLBAR);
		pause_img.show();

		play_img = new Image.from_icon_name("media-playback-start-symbolic",
										   IconSize.LARGE_TOOLBAR);
		play_img.show();

		play_pause_button = new Button();
		play_pause_button.clicked.connect(on_play_pause_clicked);
		play_pause_button.add(play_img);
		play_pause_button.show();

		headerbar.pack_end(play_pause_button);
		headerbar.pack_end(clean_button);
		headerbar.pack_start(hbox);
	}

	private void init_lattice() {
		int chance = (int) chance_entry.get_value();
		lattice = new Lattice(chance);
		lattice.show();
		add(lattice);
	}

	private void on_clean_clicked() {
		if (lattice != null) {
			this.remove(lattice);
			lattice.destroy();
		}

		clean_button.sensitive = false;
		chance_entry.sensitive = true;
		init = false;
	}

	private void on_play_pause_clicked() {
		if (running) {
			if (!clean_button.sensitive)
				clean_button.sensitive = true;

			play_pause_button.remove(pause_img);
			play_pause_button.add(play_img);
			running = false;
		} else {
			if (!init) {
				chance_entry.sensitive = false;
				init_lattice();
				init = true;
			}

			play_pause_button.remove(play_img);
			play_pause_button.add(pause_img);
			
			clean_button.sensitive = false;
			running = true;
			run();
		}
	}

	private void run() {
		GLib.Timeout.add(2000,() => {
			lattice.do_iteration();

			lattice.hide();
			lattice.show();

			return running;
		});
	}
}