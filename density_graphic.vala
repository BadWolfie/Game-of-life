using Gtk;

/**
 *
 */
public class DensityGraphic : DrawingArea {
	public signal void list_updated();
	public signal void list_reseted();

	private const int AREA_WIDTH = 2020;
	private const int AREA_HEIGHT = 320;

	private List<double?> _density_list;
	public List<double?> density_list {
		get { return _density_list; }
	}

	/**
	 *
	 */
	public DensityGraphic() {
		Object();
		set_size_request(AREA_WIDTH,AREA_HEIGHT);
		draw.connect(paint_graphic);
		create_components();
	}

	private void create_components() {
		_density_list = new List<double?>();
	}
	
	public void add_density(double entry) {
		_density_list.append(entry);
		
		this.hide();
		this.show();
		
		list_updated();
	}
	
	public void reset() {
		_density_list.foreach((entry) => {
			_density_list.remove(entry);
		});
		
		this.hide();
		this.show();
		
		list_reseted();
	}

	private bool paint_graphic(Cairo.Context context) {
		context.set_source_rgba(0,0,0,0.3);
		context.set_line_width(0.5);
		for (int x = 0; x <= 2000; x+= 10) {
			context.move_to((x * 3) + 10,10);
			context.line_to((x * 3) + 10,AREA_HEIGHT - 10);
		}
		
		for (int x = 0; x <= 100; x+= 10) {
			context.move_to(10,(x * 3) + 10);
			context.line_to(AREA_WIDTH - 10,(x * 3) + 10);
		}
		
		context.stroke();
		context.set_source_rgba(0,0,0,1);
		context.set_line_width(1);

		context.move_to(10,10);
		context.line_to(10,AREA_HEIGHT - 10);
		context.line_to(AREA_WIDTH - 10,AREA_HEIGHT - 10);
		
		context.stroke();
		int i = 0;
		
		context.set_source_rgba(1,0,0,1);
		_density_list.foreach((entry) => {
			int y = (AREA_HEIGHT - 5) - (((int) entry * 3) + 10);
			int x = (i * 3) + 10;
			
			context.arc(x,y,2,0,2 * Math.PI);
			context.fill();
			i++;
		});

		return true;
	}
}
