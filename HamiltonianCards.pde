int N_ROWS = 14;
int N_COLS = 10;

int TILE_SIZE,SQ_SIZE;

PImage img_square, img_squareCircle, img_squareTriangle;


void setup(){
//	size(1246,890);
	size(1050,1470);
	background(255);


	img_square = loadImage("img/square.png");
	img_squareTriangle = loadImage("img/square_triangle.png");
	img_squareCircle = loadImage("img/square_circle.png");


	TILE_SIZE = img_squareCircle.width;
	SQ_SIZE = img_square.width;
	println(String.format("Tile size: %d, Square size: %d",TILE_SIZE,SQ_SIZE));

	int x = 0;
	int y = 0;

	char direction = 'R';

	for(int r=0; r<N_ROWS; r++){
		x = 0;
		for(int c=0; c<N_COLS; c++){
			pushMatrix();

			translate(x,y);
			
			switch(direction){
				case 'R':

				break;

				case 'L':
				translate(SQ_SIZE/2,SQ_SIZE/2);
				rotate(radians(180));
				translate(-SQ_SIZE/2,-SQ_SIZE/2);

				break;

			}


			image(img_squareTriangle,0,0);	

			popMatrix();
			x += TILE_SIZE;
		}

		y += TILE_SIZE;
	}


}


void draw(){



}
