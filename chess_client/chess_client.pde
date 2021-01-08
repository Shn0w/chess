import processing.net.*;

Client myClient;
boolean myTurn;
color light = #D3EBC7;
color dark = #AABFAA;
PImage wrook, wbishop, wknight, wqueen, wking, wpawn;
PImage brook, bbishop, bknight, bqueen, bking, bpawn;
boolean firstClick;
int row1, col1, row2, col2;
int pr1, pc1, pr2, pc2;
char prev1;
char prev2;
boolean z;
boolean pressed;
boolean acceptPress;
char promote;


char[][] grid = { 
  {'R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'}, 
  {'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'}, 
  {'r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'}
};

void setup() {
  size(800, 800);
  firstClick = true;
  myClient = new Client(this, "127.0.0.1", 1234);
  myTurn = false;

  brook = loadImage("blackRook.png");
  bbishop = loadImage("blackBishop.png");
  bknight = loadImage("blackKnight.png");
  bqueen = loadImage("blackQueen.png");
  bking = loadImage("blackKing.png");
  bpawn = loadImage("blackPawn.png");

  wrook = loadImage("whiteRook.png");
  wbishop = loadImage("whiteBishop.png");
  wknight = loadImage("whiteKnight.png");
  wqueen = loadImage("whiteQueen.png");
  wking = loadImage("whiteKing.png");
  wpawn = loadImage("whitePawn.png");
}

void draw() {
  drawBoard();
  drawPieces();

  if (z && !myTurn) {
    grid[pr1][pc1] = prev1;
    grid[pr2][pc2] = prev2;
    myClient.write("z" + pr1 + pc1 + pr2 + pc2 + prev1 + prev2);
    z = false;
    myTurn = true;
  }
  for (int c = 0; c<8; c++) {
    if (grid[7][c]=='P') {
      acceptPress = true;
      rectMode(CENTER);
      textSize(20);
      textAlign(CENTER);
      fill(255);
      rect(width/2, height/2, 400, 60);
      fill(0);
      text("Q: queen, B: bishop, K: knight, R: rook", width/2, height/2+5);
      rectMode(CORNER);
      if (pressed && (promote=='B' || promote=='Q' || promote == 'R' || promote=='K')) {
        if (promote=='k') promote = 'N';
        grid[7][c] = promote;
        acceptPress = false;
        pressed = false;
        myClient.write("p" + 7 + c + promote);
      }
    }
  }
  if (myClient.available()>0) {
    String incoming = myClient.readString();
    String command = incoming.substring(0, 1);
    if (command.equals("m")) {
      int r2 = int(incoming.substring(1, 2));
      int c2 = int(incoming.substring(2, 3));
      int r1 = int(incoming.substring(3, 4));
      int c1 = int(incoming.substring(4, 5));
      grid[r2][c2] = grid[r1][c1];
      grid[r1][c1] = ' ';
      if (r2==0 && grid[r2][c2]=='p') {
      } else {
        myTurn = true;
      }
    } else if (command.equals("z")) {
      int r1 = int(incoming.substring(1, 2));
      int c1 = int(incoming.substring(2, 3));
      int r2 = int(incoming.substring(3, 4));
      int c2 = int(incoming.substring(4, 5));
      char p1 = incoming.charAt(5);
      char p2 = incoming.charAt(6);
      grid[r1][c1] = p1;
      grid[r2][c2] = p2;
    } else if (command.equals("p")) {
      int r1 = int(incoming.substring(1, 2));
      int c1 = int(incoming.substring(2, 3));
      char p = incoming.charAt(3);
      grid[r1][c1] = p;
      myTurn = true;
    }
  }
}

void drawPieces() {
  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) {
      if (grid[r][c] == 'r') image (wrook, c*100, r*100, 100, 100);
      if (grid[r][c] == 'R') image (brook, c*100, r*100, 100, 100);
      if (grid[r][c] == 'b') image (wbishop, c*100, r*100, 100, 100);
      if (grid[r][c] == 'B') image (bbishop, c*100, r*100, 100, 100);
      if (grid[r][c] == 'n') image (wknight, c*100, r*100, 100, 100);
      if (grid[r][c] == 'N') image (bknight, c*100, r*100, 100, 100);
      if (grid[r][c] == 'q') image (wqueen, c*100, r*100, 100, 100);
      if (grid[r][c] == 'Q') image (bqueen, c*100, r*100, 100, 100);
      if (grid[r][c] == 'k') image (wking, c*100, r*100, 100, 100);
      if (grid[r][c] == 'K') image (bking, c*100, r*100, 100, 100);
      if (grid[r][c] == 'p') image (wpawn, c*100, r*100, 100, 100);
      if (grid[r][c] == 'P') image (bpawn, c*100, r*100, 100, 100);
    }
  }
}

void drawBoard() {
  for (int r = 0; r<grid.length; r++) {
    for (int c = 0; c<grid[0].length; c++) {
      if (r%2==c%2) {
        fill(light);
      } else {
        fill(dark);
      }
      rect(c*100, r*100, 100, 100);
    }
  }
}

void mouseReleased() {
  if (firstClick || Character.isUpperCase(grid[mouseY/100][mouseX/100])) {
    row1 = mouseY/100;
    col1 = mouseX/100;
    firstClick = false;
  } else {
    row2 = mouseY/100;
    col2 = mouseX/100;
    if (myTurn && !(row2 == row1 && col2 == col1)) {
      prev1 = grid[row1][col1];
      prev2 = grid[row2][col2];
      pr2 = row2;
      pc2 = col2;
      pr1 = row1;
      pc1 = col1;  
      grid[row2][col2] = grid[row1][col1];
      grid[row1][col1] = ' ';
      myTurn =false;
      firstClick = true;
      myClient.write("m" + row2 + col2 + row1 + col1);
    }
  }
}

void keyPressed() {
  if ((key=='z' || key=='Z') && !myTurn) { 
    z = true;
  } else if (acceptPress) {
    pressed= true;
    promote = Character.toUpperCase(key);
  }
}
