using Gtk;

/**
 * @brief Enumeración que contiene los tipos de operaciones que son mostradas en
 * la Statusbar de la ventana. */
private enum OperationType {
	RUNNING,
	PAUSED,
	CLEANED,
	GENERATED,
	IDLE
}

/**
 *
 * @brief Ventana principal de la aplicación.
 *
 * @author Ian Hernández <ihernandezs@openmailbox.org>
 */
public class GOLWindow : ApplicationWindow {
	/**
	 * HeaderBar que contiene los controles de la ventana. */
	private HeaderBar headerbar;
	/**
	 * MenuButton que contiene un Popover con controles. */
	private MenuButton param_button;

	/**
	 * Conjunto de imagenes a ser mostradas en el botón de animación. */
	private Image play_img;				/** Imagen "play". */
	private Image pause_img;			/** Imagen "pausa". */
	/**
	 * Conjunto de botones que controlan las acciones de la ventana. */
	private Button play_pause_button;	/** Botón de animación. */
	private Button clean_button;		/** Botón de limpieza. */
	private Button generate_button;		/** Botón de generado. */

	/**
	 * Popover que contiene los controles para los parámetros del autómata. */
	private Popover popover;
	/**
	 * Conjunto de widgets Scale que controlan los parámetros del autómata. */
	private Scale chance_entry;			/** Probabilidad de ser célula viva. */
	private Scale b_min_entry;			/** Número mínimo para nacer. */
	private Scale s_min_entry;			/** Número mínimo para sobrevivir. */
	private Scale b_max_entry;			/** Número máximo para nacer. */
	private Scale s_max_entry;			/** Número máximo para sobrevivir. */

	/**
	 * Box que contiene los componentes de la ventana. */
	private Box content;

	/**
	 * Statusbar que muestra información en la ventana. */
	private Statusbar statusbar;
	/**
	 * Entero utilizado para mostrar información en la Statusbar. */
	private uint context_id;

	/**
	 * Elemento Lattice que representa el estado del autómata. */
	private Lattice lattice;
	
	/**
	 * GraphicDialog donde se muestra la gráfica de densidades. */
	public GraphicDialog dialog;

	/**
	 * Conjunto de variables de control de la ventana. */
	private int running_time;	/** Número de turnos transcurridos. */
	private bool running;		/** Indica si está corriendo la simulación. */
	private bool init;			/** Indica si lattice ha sido inicializada. */

	/**
	 * @brief Constructor principal de la ventana.
	 *
	 * @param app Gtk.Application a la que pertenece la ventana.
	 */
	public GOLWindow(Gtk.Application app) {
		Object(application: app);

		window_position = WindowPosition.CENTER_ALWAYS;
		set_default_size(500,600);

		border_width = 0;
		running = false;
		init = false;

		create_widgets();
	}

	/**
	 * @brief Crea e inicializa los widgets que contine la ventana.
	 */
	private void create_widgets() {
		headerbar = new HeaderBar();
		headerbar.show();

		headerbar.set_show_close_button(true);
		headerbar.set_title("Game of Life");
		set_titlebar(headerbar);

		statusbar = new Statusbar();
		context_id = statusbar.get_context_id("statusbar");
		refresh_status(OperationType.IDLE);
		statusbar.show();

		chance_entry = new Scale.with_range(Orientation.HORIZONTAL,0,100,1);
		chance_entry.width_request = 100;
		chance_entry.set_value((double) 50);
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
		b_min_entry.set_value((double) 3);
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
		b_max_entry.set_value((double) 3);
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
		s_min_entry.set_value((double) 2);
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
		s_max_entry.set_value((double) 3);
		s_max_entry.show();

		var s_max_label = new Label("Máximo para sobrevivir: ");
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

		generate_button = new Button.with_mnemonic("_Generar");
		generate_button.clicked.connect(init_lattice);
		generate_button.set_tooltip_text("Generar tablero");
		generate_button.show();

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

		var menu_img = new Image.from_icon_name("open-menu-symbolic",
												IconSize.MENU);
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

		content = new Box(Orientation.VERTICAL,0);
		content.pack_end(statusbar,false,true,0);
		content.show();
		add(content);
		
		dialog = new GraphicDialog(this);
	}

	/**
	 * @brief Crea e inicializa la Lattice a utilizarse.
	 */
	private void init_lattice() {
		if (!init) {
			play_pause_button.sensitive = true;
			clean_button.sensitive = true;
			
			int chance = (int) chance_entry.get_value();

			lattice = new Lattice(chance);
			generate_button.sensitive = false;
			
			//if (!init) dialog.show_all();
			content.add(lattice);
			lattice.show();
			
			refresh_status(OperationType.GENERATED);
			set_resizable(false);
			init = true;
		}
	}

	/**
	 * @brief Destruye la Lattice actual para dar espacio a una nueva.
	 */
	private void on_clean_clicked() {
		if (lattice != null) {
			content.remove(lattice);
			set_resizable(true);
			lattice.destroy();
			dialog.graphic.reset();
		}

		play_pause_button.sensitive = false;
		generate_button.sensitive = true;
		clean_button.sensitive = false;

		refresh_status(OperationType.CLEANED);
		init = false;
	}

	/**
	 * @brief Inicia/Pausa la simulación.
	 */
	private void on_play_pause_clicked() {
		if (running) {
			param_button.sensitive = true;
			play_pause_button.remove(pause_img);
			play_pause_button.add(play_img);

			refresh_status(OperationType.PAUSED);
			clean_button.sensitive = true;
			running = false;
		} else {
			param_button.sensitive = false;
			play_pause_button.remove(play_img);
			play_pause_button.add(pause_img);
			
			clean_button.sensitive = false;
			running = true;
			run();
		}
	}

	/**
	 * @brief Refresca la Statusbar para mostrar información sobre la operación
	 * en progreso.
	 *
	 * @param operation Tipo de operación que está siendo realizada.
	 */
	private void refresh_status(OperationType operation) {
		int chance = (int) chance_entry.get_value();
		int b_min = (int) b_min_entry.get_value();
		int b_max = (int) b_max_entry.get_value();
		int s_min = (int) s_min_entry.get_value();
		int s_max = (int) s_max_entry.get_value();
		double density = 0;

		if (lattice != null)
			density = lattice.density;

		string status = "P: %d%c. ".printf(chance,'%');
		status += "R: B%d%d/S%d%d. ".printf(b_min,b_max,s_min,s_max);
		switch (operation) {
			default:
			case OperationType.IDLE:
			case OperationType.CLEANED:
				running_time = 0;
				statusbar.push(context_id,"Esperando... ");
				break;
			case OperationType.GENERATED:
				running_time = 0;
				status += "D: %.2f%c, %d iteraciones. ".printf(density,'%',
															   running_time);
				statusbar.push(context_id,status);
				//dialog.graphic.add_density(density);
				break;
			case OperationType.RUNNING:
				status += "D: %.2f%c, %d iteraciones. ".printf(density,'%',
															   running_time);
				statusbar.push(context_id,status + "(Corriendo)");
				dialog.graphic.add_density(density);
				break;
			case OperationType.PAUSED:
				status += "D: %.2f%c, %d iteraciones. ".printf(density,'%',
															  running_time);
				statusbar.push(context_id,status + "(Pausado)");
				break;
		}
	}

	/**
	 * @brief Función ejecutada mientras corre la simulación.
	 */
	private void run() {
		int born_min = (int) b_min_entry.get_value();
		int born_max = (int) b_max_entry.get_value();
		int surv_min = (int) s_min_entry.get_value();
		int surv_max = (int) s_max_entry.get_value();
			
		GLib.Timeout.add(500,() => {
			if (running_time == 2000)
				on_play_pause_clicked();
			
			if (running) {
				lattice.do_iteration(born_min, born_max,surv_min, surv_max);
				running_time++;

				lattice.hide();
				lattice.show();

				refresh_status(OperationType.RUNNING);
			}

			return running;
		});
	}
}
