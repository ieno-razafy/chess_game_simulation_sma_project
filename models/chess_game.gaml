/**
* Name: chessgame
* Based on the internal skeleton template. 
* Author: ienoavtr
* Tags: 
*/

model chessgame


global {
	/** Insert the global definitions, variables and actions here */
	bool tour <- true;

		
	init {
		// constructeur pour les pieces blanche
		create Tour number: 2;
		create Chevalier number: 2;
		create Fou number: 2;
		create Roi number: 1;
		create Reine number: 1;
		create Pion number: 8;
		ask Tour[0] {
			couleur <- true;
			do moving(Case[0, 7]);
		}

		ask Tour[1] {
			couleur <- true;
			do moving(Case[7, 7]);
		}

		ask Chevalier[0] {
			couleur <- true;
			do moving(Case[1, 7]);
		}

		ask Chevalier[1] {
			couleur <- true;
			do moving(Case[6, 7]);
		}

		ask Fou[0] {
			couleur <- true;
			do moving(Case[2, 7]);
		}

		ask Fou[1] {
			couleur <- true;
			do moving(Case[5, 7]);
		}

		ask Reine[0] {
			couleur <- true;
			do moving(Case[3, 7]);
		}

		ask Roi[0] {
			couleur <- true;
			do moving(Case[4, 7]);
		}

		//  constructeur pour les pieces noir
		create Tour number: 2;
		create Chevalier number: 2;
		create Fou number: 2;
		create Roi number: 1;
		create Reine number: 1;
		create Pion number: 8;
		ask Tour[2] {
			couleur <- false;
			do moving(Case[0, 0]);
		}

		ask Tour[3] {
			couleur <- false;
			do moving(Case[7, 0]);
		}

		ask Chevalier[2] {
			couleur <- false;
			do moving(Case[1, 0]);
		}

		ask Chevalier[3] {
			couleur <- false;
			do moving(Case[6, 0]);
		}

		ask Fou[2] {
			couleur <- false;
			do moving(Case[2, 0]);
		}

		ask Fou[3] {
			couleur <- false;
			do moving(Case[5, 0]);
		}

		ask Reine[1] {
			couleur <- false;
			do moving(Case[3, 0]);
		}

		ask Roi[1] {
			couleur <- false;
			do moving(Case[4, 0]);
		}

		loop i from: 0 to: 7 {
			ask Pion[i] {
				do moving(Case[i, 6]);
				couleur <- true;
			}

			ask Pion[i + 8] {
				do moving(Case[i, 1]);
				couleur <- false;
			}

		}

	}

	// Selection des pieces disponible a se deplacer	
	Piece selectAvalaiblePiece {
		list<Case> mouvement <- [];
		Piece pi <- one_of(agents of_generic_species Piece where (each.couleur = tour));
		ask pi {
			mouvement <- mouvements();
		}

		if (mouvement = []) {
			do selectAvalaiblePiece();
		} else {
			return pi;
		}

	}

	//	reflexe que les pieces doivent avoir
	reflex updateMouvement {
		Piece ReineCheck <- one_of(agents of_generic_species Reine where (each.couleur = tour));
		if (ReineCheck = nil) {
			do pause;
		}

		Piece pi <- selectAvalaiblePiece();
		ask pi {
			list<Case> mouvement <- mouvements();
			Case move <- one_of(mouvement);
			if (!empty(move)) {
				ask (agents of_generic_species Piece inside (move)) {
					do die;
				}

				do moving(move);
				if (tour = true) {
					tour <- false;
				} else {
					tour <- true;
				}

			}

		}

	}

}

//  Class Piece (Abstract)
species Piece {
	bool couleur;
	Case current_cell;
	list<Case> mouvements {
		return nil;
	}

	action moving (Case case) {
		current_cell <- case;
		location <- case.location;
	}

}

//  Heritage pour le deplacement des Tour, Fou, Reine
species TourReineFouMouvement parent: Piece {
	list<Case> vecteur (list<list<int>> data) {
		list<Case> movesReturn <- [];
		loop i over: data {
			int a <- i[0];
			int b <- i[1];
			loop while: true {
				if (Case[current_cell.grid_x + i[0], current_cell.grid_y + i[1]] = nil) {
					break;
				} else {
					if (agents of_generic_species Piece where (each.couleur != self.couleur and each.current_cell = Case[current_cell.grid_x + i[0], current_cell.grid_y + i[1]]) != []) {
						add Case[current_cell.grid_x + i[0], current_cell.grid_y + i[1]] to: movesReturn;
						break;
					}

					if (agents of_generic_species Piece where (each.couleur = self.couleur and each.current_cell = Case[current_cell.grid_x + i[0], current_cell.grid_y + i[1]]) = []) {
						add Case[current_cell.grid_x + i[0], current_cell.grid_y + i[1]] to: movesReturn;
					} else {
						break;
					}

				}

				i[0] <- a + i[0];
				i[1] <- b + i[1];
			}

		}

		return movesReturn;
	}

}

// Heritage et chargement de Piece-Tour
species Tour parent: TourReineFouMouvement {

	aspect default {
		if (couleur = false) {
			draw image_file("../includes/img_pieces/tourNoir.png") size: 8;
		} else {
			draw image_file("../includes/img_pieces/tourBlanche.png") size: 8;
		}

	}

	list<Case> mouvements {
		list<Case> mouvement <- [];
		loop i over: vecteur([[0, -1], [0, 1], [1, 0], [-1, 0]]) {
			add i to: mouvement;
		}

		return mouvement;
	}

}
// Heritage et chargement de Piece-Chevalier
species Chevalier parent: Piece {

	aspect default {
		if (couleur = false) {
			draw image_file("../includes/img_pieces/chevalierNoir.png") size: 8;
		} else {
			draw image_file("../includes/img_pieces/chevalierBlanc.png") size: 8;
		}

	}

}

// Heritage et chargement de Piece-Fou
species Fou parent: TourReineFouMouvement {

	aspect default {
		if (couleur = false) {
			draw image_file("../includes/img_pieces/fouNoir.png") size: 8;
		} else {
			draw image_file("../includes/img_pieces/fouBlanc.png") size: 8;
		}

	}

	list<Case> mouvements {
		list<Case> mouvement <- [];
		loop i over: vecteur([[-1, -1], [-1, 1], [1, -1], [1, 1]]) {
			add i to: mouvement;
		}

		return mouvement;
	}

}

// Heritage et chargement de Piece-Roi
species Roi parent: Piece {

	aspect default {
		if (couleur = false) {
			draw image_file("../includes/img_pieces/roiNoir.png") size: 8;
		} else {
			draw image_file("../includes/img_pieces/roiBlanc.png") size: 8;
		}

	}

}

// Heritage et chargement de Piece-Reine
species Reine parent: TourReineFouMouvement {

	aspect default {
		if (couleur = false) {
			draw image_file("../includes/img_pieces/reineNoir.png") size: 8;
		} else {
			draw image_file("../includes/img_pieces/reineBlanche.png") size: 8;
		}

	}

	list<Case> mouvements {
		list<Case> mouvement <- [];
		loop i over: vecteur([[0, -1], [0, 1], [1, 0], [-1, 0], [-1, -1], [-1, 1], [1, -1], [1, 1]]) {
			add i to: mouvement;
		}

		return mouvement;
	}

}

// Heritage et chargement de Piece-Pion
species Pion parent: Piece {

	aspect default {
		if (couleur = false) {
			draw image_file("../includes/img_pieces/pionNoir.png") size: 8;
		} else {
			draw image_file("../includes/img_pieces/pionBlanche.png") size: 8;
		}

	}

	list<Case> mouvements {
		list<Case> mouvement <- [];
		if (couleur = true) {
			if (!empty(agents of_generic_species Piece where (each.couleur = false and each.current_cell = Case[current_cell.grid_x + 1, current_cell.grid_y - 1]))) {
				add Case[current_cell.grid_x + 1, current_cell.grid_y - 1] to: mouvement;
			}

			if (!empty(agents of_generic_species Piece where (each.couleur = false and each.current_cell = Case[current_cell.grid_x - 1, current_cell.grid_y - 1]))) {
				add Case[current_cell.grid_x - 1, current_cell.grid_y - 1] to: mouvement;
			}

			if (empty(agents of_generic_species Piece where (each.current_cell = Case[current_cell.grid_x, current_cell.grid_y - 1]))) {
				add Case[current_cell.grid_x, current_cell.grid_y - 1] to: mouvement;
			}

		} else {
			if (!empty(agents of_generic_species Piece where (each.couleur = true and each.current_cell = Case[current_cell.grid_x + 1, current_cell.grid_y + 1]))) {
				add Case[current_cell.grid_x + 1, current_cell.grid_y + 1] to: mouvement;
			}

			if (!empty(agents of_generic_species Piece where (each.couleur = true and each.current_cell = Case[current_cell.grid_x - 1, current_cell.grid_y + 1]))) {
				add Case[current_cell.grid_x - 1, current_cell.grid_y + 1] to: mouvement;
			}

			if (agents of_generic_species Piece where (each.current_cell = Case[current_cell.grid_x, current_cell.grid_y + 1]) = []) {
				add Case[current_cell.grid_x, current_cell.grid_y + 1] to: mouvement;
			}

		}

		return mouvement;
	}

}

grid Case width: 8 height: 8 neighbors: 4 {

	init {
		if (((grid_x + grid_y) mod 2) = 0) {
			color <- #green;
		} else {
			color <- #yellow;
		}

	}

}

experiment chessgame type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display Jeu {
			grid Case lines: #black;
			species Tour aspect: default;
			species Chevalier aspect: default;
			species Fou aspect: default;
			species Roi aspect: default;
			species Reine aspect: default;
			species Pion aspect: default;
		}
	}
}
