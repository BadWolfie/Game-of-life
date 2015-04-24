using Gtk;

/**
 *
 * @brief [brief description]
 *
 * @author Ian Hernández <ihernandezs@openmailbox.org>
 */
public class Lattice : DrawingArea {
	public const int LATTICE_SIZE = 550;
	private int total_size = LATTICE_SIZE * LATTICE_SIZE;
	
	private int born_min;
	private int born_max;
	private int surv_min;
	private int surv_max;

	private int chance;
	private double _density;
	public double density {
		get { return _density; }
		set { _density = value; }
	}

	private Cell[,] _cells;
	public Cell[,] cells {
		get { return _cells; }
	}

	private Cell[,] _cells_new;
	public Cell[,] cells_new {
		get { return _cells_new; }
	}

	public Lattice(int chance) {
		Object();
		set_size_request(LATTICE_SIZE,LATTICE_SIZE);
		draw.connect(paint_grid);

		this.chance = chance;

		create_components();
	}

	private void create_components() {
		_cells_new = new Cell[LATTICE_SIZE,LATTICE_SIZE];
		_cells = new Cell[LATTICE_SIZE,LATTICE_SIZE];

		for (int i = 0; i < LATTICE_SIZE; i++) {
			for (int j = 0; j < LATTICE_SIZE; j++) {
				_cells[i,j] = new Cell(chance);
				_cells_new[i,j] = new Cell.from_Cell(_cells[i,j]);
			}
		}
	}

	private bool paint_grid(Cairo.Context context) {
		int alive = 0;

		for (int i = 0; i < LATTICE_SIZE; i++) {
			for (int j = 0; j < LATTICE_SIZE; j++) {
				if (_cells[i,j].state == CellState.ALIVE) {
					context.set_source_rgba(1,1,1,1);
					alive++;
				} else {
					context.set_source_rgba(0.08,0.08,0.08,1);
				}

				context.rectangle(j,i,1,1);
				context.fill();
			}
		}

		_density = ((double) alive / (double) total_size) * 100;
		return true;
	}

	public void do_iteration(int born_min, int born_max, 
							 int surv_min, int surv_max) {
		this.born_min = born_min;
		this.born_max = born_max;
		this.surv_min = surv_min;
		this.surv_max = surv_max;
		
		for (int i = 0; i < LATTICE_SIZE; i++) {
			for (int j = 0; j < LATTICE_SIZE; j++) {
				int alive = count_alive(i,j);
				_cells_new[i,j].state = eval(_cells[i,j].state,alive);
			}
		}

		for (int i = 0; i < LATTICE_SIZE; i++) {
			for (int j = 0; j < LATTICE_SIZE; j++) {
				_cells[i,j].state = _cells_new[i,j].state;
			}
		}
	}

	private int count_alive(int x, int y) {
		int x_prev = (x + (LATTICE_SIZE - 1)) % LATTICE_SIZE;
		int x_next = (x + 1) % LATTICE_SIZE;

		int y_prev = (y + (LATTICE_SIZE - 1)) % LATTICE_SIZE;
		int y_next = (y + 1) % LATTICE_SIZE;

		int alive = 0;

		if (_cells[x_prev,y_prev].state == CellState.ALIVE) alive++;
		if (_cells[x_prev,y].state == CellState.ALIVE) alive++;
		if (_cells[x_prev,y_next].state == CellState.ALIVE) alive++;
		if (_cells[x,y_prev].state == CellState.ALIVE) alive++;
		if (_cells[x,y_next].state == CellState.ALIVE) alive++;
		if (_cells[x_next,y_prev].state == CellState.ALIVE) alive++;
		if (_cells[x_next,y].state == CellState.ALIVE) alive++;
		if (_cells[x_next,y_next].state == CellState.ALIVE) alive++;

		return alive;
	}

	private CellState eval(CellState current, int alive) {
		CellState val = CellState.ALIVE;

		switch (current) {
			case CellState.DEAD:
				if ((alive > born_max) || (alive < born_min))
					val = CellState.DEAD;
				break;
			case CellState.ALIVE:
				if ((alive > surv_max) || (alive < surv_min))
					val = CellState.DEAD;
				break;
		}

		return val;
	}
}
