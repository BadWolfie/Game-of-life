using Gtk;

public class GOLWindow : ApplicationWindow {
	private HeaderBar headerbar;
	private Popover popover;

	private MenuButton param_button;
	private Scale chance_entry;
	private Scale b_min_entry;
	private Scale s_min_entry;
	private Scale b_max_entry;
	private Scale s_max_entry;

	private Image play_img;
	private Image pause_img;
	private Button clean_button;
	private Button play_pause_button;
	private Button generate_button;

	private Lattice lattice;
	private bool running;
	private bool init;

	public GOLWindow(Gtk.Application app) {
		Object(application: app);

		window_position = WindowPosition.CENTER;
		set_default_size(600,600);
		// set_resizable(false);
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

		var hbox1 = new Box(Orientation.HORIZONTAL,0);
		hbox1.pack_start(chance_label,false,true,7);
		hbox1.pack_start(chance_entry,true,true,0);
		hbox1.homogeneous = true;
		hbox1.show();

		b_min_entry = new Scale.with_range(Orientation.HORIZONTAL,0,8,1);
		b_min_entry.width_request = 100;
		b_min_entry.show();

		var b_min_label = new Label("Mínimo para nacer: ");
		b_min_label.show();

		var hbox2 = new Box(Orientation.HORIZONTAL,0);
		hbox2.pack_start(b_min_label,false,true,7);
		hbox2.pack_start(b_min_entry,true,true,0);
		hbox2.homogeneous = true;
		hbox2.show();

		b_max_entry = new Scale.with_range(Orientation.HORIZONTAL,0,8,1);
		b_max_entry.width_request = 100;
		b_max_entry.show();

		var b_max_label = new Label("Máximo para nacer: ");
		b_max_label.show();

		var hbox3 = new Box(Orientation.HORIZONTAL,0);
		hbox3.pack_start(b_max_label,false,true,7);
		hbox3.pack_start(b_max_entry,true,true,0);
		hbox3.homogeneous = true;
		hbox3.show();

		s_min_entry = new Scale.with_range(Orientation.HORIZONTAL,0,8,1);
		s_min_entry.width_request = 100;
		s_min_entry.show();

		var s_min_label = new Label("Mínimo para sobrevivir: ");
		s_min_label.show();

		var hbox4 = new Box(Orientation.HORIZONTAL,0);
		hbox4.pack_start(s_min_label,false,true,7);
		hbox4.pack_start(s_min_entry,true,true,0);
		hbox4.homogeneous = true;
		hbox4.show();

		s_max_entry = new Scale.with_range(Orientation.HORIZONTAL,0,8,1);
		s_max_entry.width_request = 100;
		s_max_entry.show();

		var s_max_label = new Label("Máximo para nacer: ");
		s_max_label.show();

		var hbox5 = new Box(Orientation.HORIZONTAL,0);
		hbox5.pack_start(s_max_label,false,true,7);
		hbox5.pack_start(s_max_entry,true,true,0);
		hbox5.homogeneous = true;
		hbox5.show();

		var vbox = new Box(Orientation.VERTICAL,0);
		vbox.pack_start(hbox1,true,true,0);
		vbox.pack_start(hbox2,true,true,0);
		vbox.pack_start(hbox3,true,true,0);
		vbox.pack_start(hbox4,true,true,0);
		vbox.pack_start(hbox5,true,true,0);
		vbox.show();

		// generate_button = new Button.from_icon_name(
		// 							"list-add-symbolic",
		// 							IconSize.LARGE_TOOLBAR);
		generate_button = new Button.with_mnemonic("_Generar");
		generate_button.clicked.connect(init_lattice);
		generate_button.set_tooltip_text("Generar tablero");
		generate_button.show();

		// clean_button = new Button.from_icon_name(
		// 								"media-playback-stop-symbolic",
		// 								IconSize.LARGE_TOOLBAR);
		clean_button = new Button.with_mnemonic("_Limpiar");
		clean_button.set_tooltip_text("Limpiar tablero");
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
		play_pause_button.set_tooltip_text("Correr/Pausar");
		play_pause_button.sensitive = false;
		play_pause_button.add(play_img);
		play_pause_button.show();

		param_button = new MenuButton();
		param_button.set_direction(ArrowType.NONE);
		param_button.relief = Gtk.ReliefStyle.NONE;

		var menu_img = new Image.from_icon_name("open-menu-symbolic",IconSize.MENU);
		menu_img.show();

		var param_label = new Label("Parámetros");
		param_label.show();

		var hbox = new Box(Orientation.HORIZONTAL,5);
		hbox.pack_start(menu_img,true,true,0);
		hbox.pack_start(param_label,true,true,0);
		hbox.show();

		param_button.add(hbox);

		param_button.set_tooltip_text("Establecer parámetros");
		popover = new Popover(param_button);
		param_button.show();

		param_button.set_popover(popover);
		popover.border_width = 5;
		popover.add(vbox);
		
		headerbar.pack_end(play_pause_button);
		headerbar.pack_end(clean_button);
		headerbar.pack_start(param_button);
		headerbar.pack_start(generate_button);
	}

	private void init_lattice() {
		if (!init) {
			param_button.sensitive = false;
			play_pause_button.sensitive = true;
			clean_button.sensitive = true;
			
			int chance = (int) chance_entry.get_value();
			int born_min = (int) b_min_entry.get_value();
			int born_max = (int) b_max_entry.get_value();
			int surv_min = (int) s_min_entry.get_value();
			int surv_max = (int) s_max_entry.get_value();

			lattice = new Lattice(born_min, born_max, 
								  surv_min, surv_max, 
								  chance);
			generate_button.sensitive = false;
			lattice.show();
			add(lattice);

			init = true;
		}
	}

	private void on_clean_clicked() {
		if (lattice != null) {
			this.remove(lattice);
			lattice.destroy();
		}

		play_pause_button.sensitive = false;
		generate_button.sensitive = true;
		clean_button.sensitive = false;
		param_button.sensitive = true;
		init = false;
	}

	private void on_play_pause_clicked() {
		if (running) {
			play_pause_button.remove(pause_img);
			play_pause_button.add(play_img);

			clean_button.sensitive = true;
			running = false;
		} else {
			play_pause_button.remove(play_img);
			play_pause_button.add(pause_img);
			
			clean_button.sensitive = false;
			running = true;
			run();
		}
	}

	private void run() {
		GLib.Timeout.add(1000,() => {
			lattice.do_iteration();

			lattice.hide();
			lattice.show();

			return running;
		});
	}
}