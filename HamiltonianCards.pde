import java.util.*;

int N_ROWS = 7;
int N_COLS = 27;

int TILE_SIZE, SQ_SIZE;

PImage img_square, img_squareCircle, img_squareTriangle, img_squareStart;
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

boolean doGeneratePath = true;


void setup() {
//  size(1066, 1486);
  size(4000, 1530);
//  size(1980, 1530,PDF,"results/result.pdf"); //Print PDF at 41% scale
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
	--page				Generate the whole page to be printed (with instructions)

  */

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
	doGeneratePath = false;
    }
    else{
        pathPath = "01.txt";
    }


  //TEST
  /*
  int mrows = 14;
  int ncols = 10;
  char[][] hG = generatePath(ncols, mrows);
  for (int i=0; i<mrows; i++) {
    for (int j=0; j<ncols; j++) { 
      System.out.print(hG[i][j]+" ");
    }
    System.out.println("");
  }
  */



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
  img_squareStart = loadImage("img/square_start.png");


  img_page = loadImage("img/page_template_270.png");

  texture1 = loadImage("img/texture_example_01.png");
  texture2 = loadImage("img/texture_example_02.png");




  design = new int[N_ROWS][N_COLS];
  loadDesign(pathDesign);

  if(doGeneratePath){
    path = generatePath(N_COLS,N_ROWS);
  }
  else{
    path = new char[N_ROWS][N_COLS];
    loadPath(pathPath);
  }
  



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

  boolean isStart;

  for (int r=0; r<N_ROWS; r++) {
    x = 0;
    for (int c=0; c<N_COLS; c++) {
      pushMatrix();

      translate(x, y);

      state_current = design[r][c];
      direction = path[r][c];

      if(direction>'U'){ // if direction char is lowercase
     	isStart = true; 
	direction -= 32; // Make it uppercase
      }
      else{
	isStart = false;
      }

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


      if(isStart){
	image(img_squareStart,0,0);
      }


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
	if(args!=null){
	for(int i=0; i<args.length; i++){
		if(arg.equals(args[i])){
			return i;
		}
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

char[][] generatePath(int n, int m) {  // By José Alberto Jurado https://github.com/juradohja
  boolean successfulPath = false;
  char[][] hG = new char[m][n]; // Hamiltonian Grid
  while (!successfulPath) {
    try {
      boolean[][] vC = new boolean[m][n]; // visited cells
      int[][] pT = new int[m][n]; // path travelled
      LinkedList<Cell> hP = new LinkedList<Cell>();
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
      hP.addLast(currentCell);
      int steps = 1;
      while (steps < ((m*n)-1)) {
        ArrayList<Cell> neighbors = new ArrayList<Cell>();
        for (int i = 0; i<4; i++) {
          switch(i) { // searches all non-visited neighbors
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
        for (int i = 0; i<neighbors.size(); i++) { // removes neighbors that don't meet enough criteria
          try {
            Cell currentNeighbor = neighbors.get(i);
            if (!vC[currentNeighbor.row][currentNeighbor.col-1] && !vC[currentNeighbor.row][currentNeighbor.col+1]) {
              neighbors.remove(i);
              i--;
            }
          } 
          catch(ArrayIndexOutOfBoundsException ex) {
          }
        }
        currentCell = neighbors.get(int(random(neighbors.size()))); // chooses randomly a neighbor, travels it and starts again
        vC[currentCell.row][currentCell.col] = true;
        steps++;
        pT[currentCell.row][currentCell.col] = steps;
        hP.addLast(currentCell);
      }
      successfulPath = true;
      for (int i=0; i<m; i++) {
        for (int j=0; j<n; j++) { 
          if (pT[i][j] == 0) {
            pT[i][j] = m*n; 
            hP.addLast(new Cell(i, j));
          }
//          System.out.print(pT[i][j]+" ");
        }
//        System.out.println("");
      }
/*      for (int i=0; i<hP.size(); i++) {
        System.out.println("["+hP.get(i).row+","+hP.get(i).col+"]");
      }
*/
      // relocate start and end
      int relocateStartAndEnd = 0;
      while (relocateStartAndEnd < 1000) { // CHANGE RANDOMNESS more iterations -> greater randomness
        int startOrEnd = int(random(2)); // choose start or end
        switch(startOrEnd) {
        case 0:
          currentCell = hP.get(0);
          break;
        case 1:
          currentCell = hP.get(hP.size()-1);
          break;
        }
        ArrayList<Cell> neighbors = new ArrayList<Cell>();
        for (int i = 0; i<4; i++) { // locates all non-connected neighbors
          try {
            switch(i) {
            case 0:
              if (abs(pT[currentCell.row][currentCell.col]-pT[currentCell.row-1][currentCell.col]) > 1) {
                neighbors.add(new Cell(currentCell.row-1, currentCell.col));
              }
              break;
            case 1:
              if (abs(pT[currentCell.row][currentCell.col]-pT[currentCell.row][currentCell.col+1]) > 1) {
                neighbors.add(new Cell(currentCell.row, currentCell.col+1));
              }
              break;
            case 2:
              if (abs(pT[currentCell.row][currentCell.col]-pT[currentCell.row+1][currentCell.col]) > 1) {
                neighbors.add(new Cell(currentCell.row+1, currentCell.col));
              }
              break;
            case 3:
              if (abs(pT[currentCell.row][currentCell.col]-pT[currentCell.row][currentCell.col-1]) > 1) {
                neighbors.add(new Cell(currentCell.row, currentCell.col-1));
              }
              break;
            }
          } 
          catch(ArrayIndexOutOfBoundsException ex) {
          }
        }
        Cell chosenNeighbor = neighbors.get(int(random(neighbors.size()))); // choose a neighbor
        int indexChosenNeighbor = pT[chosenNeighbor.row][chosenNeighbor.col]-1;
        LinkedList<Cell> tempHP = new LinkedList<Cell>();
        if (indexChosenNeighbor > pT[currentCell.row][currentCell.col]) { // change path
          for (int i = indexChosenNeighbor-1; i>=0; i--) {
            tempHP.add(hP.get(i));
          }
          for (int i = indexChosenNeighbor; i<hP.size(); i++) {
            tempHP.add(hP.get(i));
          }
        } else {
          for (int i = 0; i<=indexChosenNeighbor; i++) {
            tempHP.add(hP.get(i));
          }
          for (int i = hP.size()-1; i>indexChosenNeighbor; i--) {
            tempHP.add(hP.get(i));
          }
        }
        hP = tempHP;
        for (int i = 0; i<hP.size(); i++) {
          pT[hP.get(i).row][hP.get(i).col] = i+1;
        }
        relocateStartAndEnd++;
      }
/*
      for (int i=0; i<m; i++) {
        for (int j=0; j<n; j++) { 
          System.out.print(pT[i][j]+" ");
        }
        System.out.println("");
      }
*/
      for (int i = 0; i<hP.size()-1; i++) {
        Cell thisCell = hP.get(i);
        Cell nextCell = hP.get(i+1);
        int row = nextCell.row - thisCell.row;
        int col = nextCell.col - thisCell.col;
        if (i==0) {
          if (row == 1) {
            hG[thisCell.row][thisCell.col] = 'd';
          }
          if (row == -1) {
            hG[thisCell.row][thisCell.col] = 'u';
          }
          if (col == 1) {
            hG[thisCell.row][thisCell.col] = 'r';
          }
          if (col == -1) {
            hG[thisCell.row][thisCell.col] = 'l';
          }
        } else {
          if (row == 1) {
            hG[thisCell.row][thisCell.col] = 'D';
          }
          if (row == -1) {
            hG[thisCell.row][thisCell.col] = 'U';
          }
          if (col == 1) {
            hG[thisCell.row][thisCell.col] = 'R';
          }
          if (col == -1) {
            hG[thisCell.row][thisCell.col] = 'L';
          }
        }
        if (i==hP.size()-2) {
          hG[nextCell.row][nextCell.col] = 'E';
        }
      }
/*      for (int i=0; i<m; i++) {
        for (int j=0; j<n; j++) { 
          System.out.print(pT[i][j]+""+hG[i][j]+" ");
        }
        System.out.println("");
      }
*/
    } 
    catch (IndexOutOfBoundsException e) {
    }
  }
  return hG;
}

void draw(){


}
