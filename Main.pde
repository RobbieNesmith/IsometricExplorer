PImage grass;
PImage water;
PImage dirt;
PImage rock;

int gridWidth=20;
float nscale = .1;
float nheight = 10;
PVector clickStart = new PVector();
PVector offset = new PVector();
boolean held = false;

public void setup() {
  fullScreen(P2D);
  grass = loadImage("platformerTile_48.png");
  water = loadImage("platformerTile_26.png");
  dirt = loadImage("platformerTile_01.png");
  rock = loadImage("voxelTile_29.png");
  textSize(100);
}

public void draw() {
  background(150, 226, 255);
  pushMatrix();
  translate(width/2, 3*height/4);
  float fxoff = offset.x % 1;
  float ixoff = (int) offset.x;
  float fyoff = offset.y % 1;
  float iyoff = (int) offset.y;
  for (int x = -gridWidth/2; x < gridWidth / 2; x++) {
    for (int y = -gridWidth/2; y < gridWidth / 2; y++) {
      float z = noise((x + ixoff) * nscale, (y+iyoff) * nscale)*nheight;
      boolean isRock = noise((x + ixoff) * nscale, (y+iyoff) * nscale, 1000) > 0.6;
      if (z > 3) {
        PVector sc = block2screen(x- fxoff,y-fyoff,z);
        if(isRock) {
          //image(rock, sc.x, sc.y + 64);
          image(rock, sc.x, sc.y);
        } else {
          //image(dirt, sc.x, sc.y + 64);
          image(grass, sc.x, sc.y);
        }
      } else {
        PVector sc = block2screen(x- fxoff,y-fyoff,3);
        image(water, sc.x, sc.y);
      }
    }
  }
  popMatrix();
  if (held) {
    float dMouseX = (mouseX - clickStart.x) / (width/32);
    float dMouseY = (mouseY - clickStart.y) / (width/32);
    PVector blockDiff = screen2block(dMouseX, dMouseY);
    offset = offset.add(blockDiff);
  }
  text("FPS: " + frameRate, 0,100);
}

public void mousePressed() {
  held = true;
  clickStart.x = mouseX;
  clickStart.y = mouseY;
}

public void mouseReleased() {
  held = false;
}

public PVector block2screen(float x,
                         float y,
                         float z) {
  return new PVector((x-y)*55,
                     (x+y)*32-z*64);
}

public PVector screen2block(float x, float y) {
  float xpy = y / 32.0;
  float xmy = x / 55.0;
  float by = (xpy - xmy) / 2;
  float bx = xpy - by;
  return new PVector(bx, by, 0);
}