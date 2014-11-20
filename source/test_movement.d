import movement;
import std.math;

void main() {
	//942 54 609 367
	Position target = { x: 609, y: 367 };
	Position new_position = { x : 102, y: 54 };
	while ( abs(new_position.x) < abs(target.x) ) {
		new_position = move_one_unit(1,new_position.x, new_position.y, target.x, target.y);
		debug std.stdio.writeln(new_position);
	}	
}
