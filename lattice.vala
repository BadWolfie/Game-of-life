using Gtk;

struct LatticeThread {
	Cell[,] cells;
	int begin_x;
	int begin_y;

	LatticeThread(Cell[,] cells,int begin_x, int begin_y) {
		this.begin_x = begin_x;
		this.begin_y = begin_y;
		this.cells = cells;
	}

	// Cell[,] run() {
	// 	 return null;
	// }
}

public class Lattice : DrawingArea {
	public const int LATTICE_SIZE = 20;
	// private LatticeThread[4] threads;
	private int chance;

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

		// for (int i = 0; i < 4; i++) {
		// 	threads[i] = LatticeThread(_cells,0,0);
		// }
	}

	private bool paint_grid(Cairo.Context context) {
		for (int i = 0; i < LATTICE_SIZE; i++) {
			for (int j = 0; j < LATTICE_SIZE; j++) {
				if (_cells[i,j].state == CellState.ALIVE)
					context.set_source_rgba(255,255,255,1);
				else
					context.set_source_rgba(0,0,0,1);
				context.rectangle(j*30,i*30,30,30);
				context.fill();
			}
		}

		return true;
	}

	public void do_iteration() {
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

		// try {
		// 	Thread<Cell[,]>[4] t;
		// 	for (int i = 0; i < 4; i++)
		// 		t[i] = new Thread<Cell[,]>.try("",threads[i].run);
		// 	Cell[,] aux = t.join();
		// } catch (Error e) {
		// 	stdout.printf("Error: %s\n",e.message);
		// }
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
				if (alive != 3)
					val = CellState.DEAD;
				break;
			case CellState.ALIVE:
				if ((alive > 3) || (alive < 2))
					val = CellState.DEAD;
				break;
		}

		return val;
	}
}