PImage grass;
PImage water;
PImage dirt;
PImage rock;

int gridWidth=50;
float grid[][];
boolean isRock[][];
float nscale = .1;
float nheight = 10;
PVector clickStart = new PVector();
PVector offset = new PVector();
PVector pOffset = new PVector();
boolean held = false;

public void setup() {
  fullScreen(P2D);
  grid = new float[gridWidth][gridWidth];
  isRock = new boolean[gridWidth][gridWidth];
  grass = loadImage("platformerTile_48.png");
  water = loadImage("platformerTile_26.png");
  dirt = loadImage("platformerTile_01.png");
  rock = loadImage("voxelTile_29.png");
  drawLandscape();
}

public void drawLandscape() {
  pushMatrix();
  translate(width/2, height/2);
  float fxoff = offset.x % 1;
  int ixoff = (int) offset.x;
  float fyoff = offset.y % 1;
  int iyoff = (int) offset.y;
  
  int pixoff = (int) pOffset.x;
  int piyoff = (int) pOffset.y;
  
  if (ixoff != pixoff || iyoff != piyoff) {
    for (int x = 0; x < gridWidth; x++) {
      for (int y = 0; y < gridWidth; y++) {
        grid[x][y] = noise((x + ixoff) * nscale, (y+iyoff) * nscale)*nheight;
        isRock[x][y] = noise((x + ixoff) * nscale, (y+iyoff) * nscale, 1000) > 0.6;
      }
    }
  }
  
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridWidth; y++) {
      float z = grid[x][y];
      if (z > 3) {
        PVector sc = block2screen(x- fxoff-gridWidth/2,y-fyoff-gridWidth/2,z);
        if (sc.x > -width/2-100 && sc.x < width/2+100
            && sc.y > -height/2-100 && sc.y < height/2 +100) { 
          if(isRock[x][y]) {
            image(rock, sc.x, sc.y + 63);
            image(rock, sc.x, sc.y);
          } else {
            image(dirt, sc.x, sc.y + 63);
            image(grass, sc.x, sc.y);
          }
        }
      } else {
        PVector sc = block2screen(x- fxoff-gridWidth/2,y-fyoff-gridWidth/2,3);
        if (sc.x > -width/2-100 && sc.x < width/2+100
            && sc.y > -height/2-100 && sc.y < height/2 +100) { 
          image(water, sc.x, sc.y);
        }
      }
    }
  }
  popMatrix();
  textSize(100);
  fill(255);
  text("FPS: " + frameRate, 0,100);
}

public void draw() {
  if (offset.x != pOffset.x &&
      offset.y != pOffset.y) {
    drawLandscape();
  }
  if (held) {
    pOffset.x = offset.x;
    pOffset.y = offset.y;
    float dMouseX = (mouseX - clickStart.x) / (width/32);
    float dMouseY = (mouseY - clickStart.y) / (width/32);
    PVector blockDiff = screen2block(dMouseX, dMouseY);
    offset = offset.add(blockDiff);
  }
}

public void mousePressed() {
  held = true;
  clickStart.x = mouseX;
  clickStart.y = mouseY;
}

public void mouseReleased() {
  held = false;
  pOffset.x = offset.x;
  pOffset.y = offset.y;
}

public PVector block2screen(float x,
                         float y,
                         float z) {
  return new PVector((x-y)*55,
                     (x+y)*32-z*63);
}

public PVector screen2block(float x, float y) {
  float xpy = y / 32.0;
  float xmy = x / 55.0;
  float by = (xpy - xmy) / 2;
  float bx = xpy - by;
  return new PVector(bx, by, 0);
}