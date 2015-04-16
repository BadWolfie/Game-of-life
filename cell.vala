public enum CellState {
	DEAD,
	ALIVE
}

public class Cell {
	private CellState _state;
	public CellState state {
		get { return _state; }
		set { _state = value; }
	}

	public Cell(int chance) {
		_state = CellState.DEAD;

		int rand = Random.int_range(0,100);
		for (int i = 0; i < chance; i++) {
			if (rand == i) {
				_state = CellState.ALIVE;
				break;
			}
		}
	}

	public Cell.from_Cell(Cell cell) {
		this._state = cell.state;
	}
}