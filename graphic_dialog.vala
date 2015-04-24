using Gtk;

public class GraphicDialog : Dialog {
	/**
	 * Elemento ScrolledWindow donde se muestra el elemento DensityGraphic. */
	private ScrolledWindow scroll;

	/**
	 * Elemento DensityGraphic donde se genera el histograma de densidades. */
	private DensityGraphic _graphic;
	public DensityGraphic graphic {
		get { return _graphic; }
	}
	
	/**
	 * Statusbar que muestra información en la ventana. */
	private Statusbar statusbar;
	/**
	 * Entero utilizado para mostrar información en la Statusbar. */
	private uint context_id;

	public GraphicDialog(GOLWindow window) {
		title = "Gráfica de densidades";
		set_transient_for(window);
		set_size_request(650,300);
		border_width = 0;
		create_widgets();
	}

	void create_widgets() {
		scroll = new ScrolledWindow(null,null);
		scroll.set_policy(PolicyType.AUTOMATIC,PolicyType.NEVER);
	
		statusbar = new Statusbar();
		context_id = statusbar.get_context_id("statusbar");
		statusbar.push(context_id,"Esperando... ");
		
		var button = new Button.with_mnemonic("_Ocultar");
		button.clicked.connect(() => { this.hide(); });
		
		_graphic = new DensityGraphic();
		scroll.add(_graphic);
		
		var hbox = new Box(Orientation.HORIZONTAL,300);
		hbox.pack_start(statusbar,true,true,0);
		hbox.pack_start(button,true,true,10);
			
		var content = get_content_area() as Box;
		content.pack_start(scroll,true,true,0);
		content.pack_start(hbox,true,true,0);
		
		_graphic.list_updated.connect(() => {
			double avg = 0;
			_graphic.density_list.foreach((entry) => {
				avg += entry;
			});
			
			avg /= (double) _graphic.density_list.length();
			statusbar.push(context_id,
						   "Promedio de densidad: %.2f%c.".printf(avg,'%'));
		});
		
		_graphic.list_reseted.connect(() => {
			statusbar.push(context_id,"Esperando... ");		
		});
	}
}
