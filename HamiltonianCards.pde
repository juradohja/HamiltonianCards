int N_ROWS = 14;
int N_COLS = 10;

int TILE_SIZE,SQ_SIZE;

PImage img_square, img_squareCircle, img_squareTriangle;

int state_current, state_next;

int [][] design;

char[][] path;


boolean debug = false;

boolean save = false;


void setup(){
	size(1066,1486);
	background(255);


	img_square = loadImage("img/square.png");
	img_squareTriangle = loadImage("img/square_triangle.png");
	img_squareCircle = loadImage("img/square_circle.png");


	design = new int[N_ROWS][N_COLS];
	loadDesign("2017.txt");

	path = new char[N_ROWS][N_COLS];
	loadPath("01.txt");


	TILE_SIZE = img_squareCircle.width;
	SQ_SIZE = img_square.width;
	println(String.format("Tile size: %d, Square size: %d",TILE_SIZE,SQ_SIZE));

	int x = 0;
	int y = 0;

	char direction = 'R';

	state_next = 1;
	state_current = 1;

//	translate(TILE_SIZE-SQ_SIZE,TILE_SIZE-SQ_SIZE);
	translate(16,16);

	for(int r=0; r<N_ROWS; r++){
		x = 0;
		for(int c=0; c<N_COLS; c++){
			pushMatrix();

			translate(x,y);

			state_current = design[r][c];
			direction = path[r][c];
			
			switch(direction){
				case 'R':
					state_next = design[r][(c+1)];
				break;

				case 'L':
					state_next = design[r][c-1];
					rotateSquare(180);
				break;

				case 'U':
					state_next = design[r-1][c];
					rotateSquare(-90);	
				break;

				case 'D':
					state_next = design[r+1][c];
					rotateSquare(90);	
				break;

			}

			// If it is last cell
			if(direction == 'E'){
				image(img_square,0,0);
			}
			else{
				if(state_current == state_next){
					image(img_squareTriangle,0,0);	
				}
				else{
					image(img_squareCircle,0,0);	
				}
			}

			if(debug){
				translate(SQ_SIZE/2,SQ_SIZE/2);
				fill( state_current==1 ? 0 : 255);
				ellipse(0,0,70,70);
			}

			popMatrix();
			x += TILE_SIZE;
		}

		y += TILE_SIZE;
	}


	if(save){
		save(String.format("results/%04d%02d%02d%02d%02d%02d.png",year(),month(),day(),hour(),minute(),second()));
		exit();
	}


}

void rotateSquare(int degrees){
	translate(SQ_SIZE/2,SQ_SIZE/2);
	rotate(radians(degrees));
	translate(-SQ_SIZE/2,-SQ_SIZE/2);
}

void loadDesign(String filename){
	String [] lines = loadStrings("designs/"+filename);

	for(int i=0; i<lines.length; i++){
		String [] chars = split(lines[i],"\t");

		for(int j=0; j<chars.length; j++){
			design[i][j] = chars[j].equals("x") ? 1 : 2;
//			print(chars[j]);
//			print(design[i][j]);
		}
//		println();
	}


}

void loadPath(String filename){
	String [] lines = loadStrings("paths/"+filename);

	for(int i=0; i<lines.length; i++){
		String [] chars = split(lines[i],"\t");

		for(int j=0; j<chars.length; j++){
			path[i][j] = chars[j].charAt(0);
			print(path[i][j]);
		}
		println();
	}


}

void draw(){


}
