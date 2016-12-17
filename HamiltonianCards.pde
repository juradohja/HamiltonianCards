int N_ROWS = 14;
int N_COLS = 10;

int TILE_SIZE, SQ_SIZE;

PImage img_square, img_squareCircle, img_squareTriangle;
PImage texture1, texture2;
PImage img_page;

import processing.pdf.*;

int state_current, state_next;

int [][] design;

char[][] path;


String pathDesign;
String pathPath;

boolean debug = false;

boolean save = false;

boolean doPage = false;


void setup() {
//  size(1066, 1486);
//  size(1980, 1530);
  size(1980, 1530,PDF,"results/result.pdf"); //Print PDF at 41% scale
  background(255);

  // CLI usage:
  /*
  	In processing path:
	./processing-java --sketch=SKETCH_PATH --run 
	Options:
	--design DESIGN_FILENAME 	Choose the design file to process
	--path PATH_FILENAME		Choose a predefined path file
	--debug				See the design overlaid to the grid
	--save				Save the resulting image
	--page				Generate the whole page to be printed

  */
  if(args.length!=0){
    println(args[0]);

    if(argExists("--debug")){
        debug = true;
    }

    if(argExists("--save")){
        save = true;
    }

    if(argExists("--page")){
        doPage = true;
    }

    int argDesign = argIndex("--design");
    if(argDesign>=0){
        pathDesign = args[argDesign+1];        
    }
    else{
        pathDesign = "2017.txt";
    }

    int argPath = argIndex("--path");
    if(argPath>=0){
        pathPath = args[argPath+1];        
    }
    else{
        pathPath = "01.txt";
    }

  }

  /*
  if(save){
  size(1980, 1530,PDF,"results/result.pdf");
  }
  else{
  size(1980, 1530);
  }
  background(255);
  */


  img_square = loadImage("img/square.png");
  img_squareTriangle = loadImage("img/square_triangle.png");
  img_squareCircle = loadImage("img/square_circle.png");


  img_page = loadImage("img/page_template_270.png");

  texture1 = loadImage("img/texture_example_01.png");
  texture2 = loadImage("img/texture_example_02.png");


  generatePath(10, 10);


  design = new int[N_ROWS][N_COLS];
  loadDesign(pathDesign);

  path = new char[N_ROWS][N_COLS];
  loadPath(pathPath);


  TILE_SIZE = img_squareCircle.width;
  SQ_SIZE = img_square.width;
  println(String.format("Tile size: %d, Square size: %d", TILE_SIZE, SQ_SIZE));


  if(doPage){
	image(img_page,0,0,width,height);
  }

  int x = 0;
  int y = 0;

  char direction = 'R';

  state_next = 1;
  state_current = 1;

  //  translate(TILE_SIZE-SQ_SIZE,TILE_SIZE-SQ_SIZE);
  if(doPage){
	translate(width/2+SQ_SIZE*0.9,SQ_SIZE*2);
	scale(0.8);
  }
  else{
  	translate(16, 16);
  }

//  scale(0.5);

  for (int r=0; r<N_ROWS; r++) {
    x = 0;
    for (int c=0; c<N_COLS; c++) {
      pushMatrix();

      translate(x, y);

      state_current = design[r][c];
      direction = path[r][c];

      pushMatrix();
      switch(direction) {
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
      if (direction == 'E') {
        image(img_square, 0, 0);
      } else {
        if (state_current == state_next) {
          image(img_squareTriangle, 0, 0);
        } else {
          image(img_squareCircle, 0, 0);
        }
      }

      popMatrix();


      if (debug) {
        //        translate(SQ_SIZE/2,SQ_SIZE/2);
        //  ellipse(0,0,70,70);

        fill( state_current==1 ? 0 : 255);
        noStroke();
	int offset = 2;
        if (state_current == 1) {
          image(texture1, offset, offset,SQ_SIZE-2*offset,SQ_SIZE-2*offset);
        } else {
          image(texture2, offset, offset,SQ_SIZE-2*offset,SQ_SIZE-2*offset);
        }
        //        rect(0,0,80,80);
      }

      popMatrix();
      x += TILE_SIZE;
    }

    y += TILE_SIZE;
  }


  if (save) {
    save(filename("png"));
  }

    exit();
}

String filename(String ext){
	return String.format("results/%04d%02d%02d%02d%02d%02d.%s", year(), month(), day(), hour(), minute(), second(),ext);
}

// Return the index of the argument in the list. -1 if it's not in the list
int argIndex(String arg){
	for(int i=0; i<args.length; i++){
		if(arg.equals(args[i])){
			return i;
		}
	}
	return -1;
}

boolean argExists(String arg){
	return argIndex(arg)>=0;
}

void rotateSquare(int degrees) {
  translate(SQ_SIZE/2, SQ_SIZE/2);
  rotate(radians(degrees));
  translate(-SQ_SIZE/2, -SQ_SIZE/2);
}

void loadDesign(String filename) {
  String [] lines = loadStrings("designs/"+filename);

  for (int i=0; i<lines.length; i++) {
    String [] chars = split(lines[i], "\t");

    for (int j=0; j<chars.length; j++) {
      design[i][j] = chars[j].equals("x") ? 1 : 2;
      //      print(chars[j]);
      //      print(design[i][j]);
    }
    //    println();
  }

}

void loadPath(String filename) {
  String [] lines = loadStrings("paths/"+filename);

  for (int i=0; i<lines.length; i++) {
    String [] chars = split(lines[i], "\t");

    for (int j=0; j<chars.length; j++) {
      path[i][j] = chars[j].charAt(0);
      print(path[i][j]);
    }
    println();
  }
}

void generatePath(int n, int m) {
  boolean successfulPath = false;
  while (!successfulPath) {
    try {
      char[][] hP = new char[m][n]; // Hamiltonian Path
      boolean[][] vC = new boolean[m][n]; // visited cells
      int[][] pT = new int[m][n];
      for (int i=0; i<m; i++) {
        for (int j=0; j<n; j++) {
          vC[i][j] = false; // declares every cell in the grid as non-visited
        }
      }
      Cell currentCell = new Cell(0, 0);
      switch(int(random(4))) { // sets a corner as start
      case 0:
        vC[0][0] = true;
        pT[0][0] = 1;
        break;
      case 1:
        vC[0][n-1] = true;
        currentCell.col = n-1;
        pT[0][n-1] = 1;
        break;
      case 2:
        vC[m-1][0] = true;
        currentCell.row = m-1;
        pT[m-1][0] = 1;
        break;
      case 3:
        vC[m-1][n-1] = true;
        currentCell.row = m-1;
        currentCell.col = n-1;
        pT[m-1][n-1] = 1;
        break;
      }
      int steps = 1;
      while (steps < ((m*n)-1)) {
        ArrayList<Cell> neighbors = new ArrayList<Cell>();
        for (int i = 0; i<4; i++) {
          switch(i) { // searches all neighbors
          case 0:
            if (currentCell.row-1>=0) {
              if (!vC[currentCell.row-1][currentCell.col]) {
                neighbors.add(new Cell(currentCell.row-1, currentCell.col));
              }
            }
            break;
          case 1:
            if (currentCell.col+1<n) {
              if (!vC[currentCell.row][currentCell.col+1]) {
                neighbors.add(new Cell(currentCell.row, currentCell.col+1));
              }
            }
            break;
          case 2:
            if (currentCell.row+1<m) {
              if (!vC[currentCell.row+1][currentCell.col]) {
                neighbors.add(new Cell(currentCell.row+1, currentCell.col));
              }
            }
            break;
          case 3:
            if (currentCell.col-1>=0) {
              if (!vC[currentCell.row][currentCell.col-1]) {
                neighbors.add(new Cell(currentCell.row, currentCell.col-1));
              }
            }
            break;
          }
        }
        for (int i = 0; i<neighbors.size(); i++) {
          try {
            Cell currentNeighbor = neighbors.get(i);
            if (!vC[currentNeighbor.row][currentNeighbor.col-1] && !vC[currentNeighbor.row][currentNeighbor.col+1]) {
              neighbors.remove(i);
//              System.out.println("removed");
              i--;
            }
          } 
          catch(ArrayIndexOutOfBoundsException ex) {
          }
        }
        currentCell = neighbors.get(int(random(neighbors.size())));
        vC[currentCell.row][currentCell.col] = true;
        steps++;
        pT[currentCell.row][currentCell.col] = steps;
      }
      successfulPath = true;

      for (int i=0; i<m; i++) {
        for (int j=0; j<m; j++) { 
          System.out.print(pT[i][j]+" ");
        }
        System.out.println("");
      }
    } 
    catch (IndexOutOfBoundsException e) {
    }
  }
}

void draw(){


}
