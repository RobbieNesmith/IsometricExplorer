PImage tileSheet;

PImage grass;
PImage water;
PImage dirt;
PImage rock;
PImage cursor;

int TILESHEET_OFFSET = 1;
int TILESHEET_WIDTH = 32;

int TILE_WIDTH = 16;
int TILE_HEIGHT = 8;
int TILE_Z_HEIGHT = 7;

int gridWidth=40;
float grid[][];
boolean isRock[][];
float nscale = 0.1;
float nheight = 10;
PVector clickStart = new PVector();
PVector offset = new PVector();
PVector pOffset = new PVector();
boolean held = false;

PGraphics buffer;

public void setup() {
  fullScreen(P2D);
  //size(1280,720, P2D);
  grid = new float[gridWidth][gridWidth];
  isRock = new boolean[gridWidth][gridWidth];
  buffer = createGraphics(width / 4, height / 4, P2D);
  tileSheet = loadImage("tiles.png");
  grass = tileSheet.get(TILESHEET_OFFSET, TILESHEET_OFFSET, TILESHEET_WIDTH, TILESHEET_WIDTH);
  water = tileSheet.get(TILESHEET_OFFSET, TILESHEET_OFFSET + (TILESHEET_WIDTH + TILESHEET_OFFSET) * 7, TILESHEET_WIDTH, TILESHEET_WIDTH);
  dirt = tileSheet.get(TILESHEET_OFFSET, TILESHEET_OFFSET + (TILESHEET_WIDTH + TILESHEET_OFFSET) * 6, TILESHEET_WIDTH, TILESHEET_WIDTH);
  rock = tileSheet.get(TILESHEET_OFFSET, TILESHEET_OFFSET + (TILESHEET_WIDTH + TILESHEET_OFFSET) * 6, TILESHEET_WIDTH, TILESHEET_WIDTH);
  cursor = loadImage("cursor.png");
  loadLandscape(0,0);
  drawLandscape(buffer);
}

public boolean isTooTall(int x, int y) {
  return x < gridWidth - 1 && y < gridWidth - 1
         && (grid[x][y] - 1 > grid[x + 1][y]
         || grid[x][y] - 1 > grid[x][y + 1]);
}

public void loadLandscape(int xoff, int yoff) {
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridWidth; y++) {
      grid[x][y] = noise((x + xoff) * nscale, (y+yoff) * nscale)*nheight;
      isRock[x][y] = noise((x + xoff) * nscale, (y+yoff) * nscale, 1000) > 0.6;
    }
  }
}

public void drawLandscape(PGraphics graphics) {
  graphics.beginDraw();
  graphics.noStroke();
  graphics.fill(200);
  graphics.rect(0,0,graphics.width,graphics.height);
  graphics.pushMatrix();
  graphics.translate(graphics.width/2, graphics.height/2);
  float fxoff = betterMod(offset.x, 1);
  int ixoff = floor(offset.x);
  float fyoff = betterMod(offset.y, 1);
  int iyoff = floor(offset.y);
  
  int pixoff = floor(pOffset.x);
  int piyoff = floor(pOffset.y);
  
  if (ixoff != pixoff || iyoff != piyoff) {
    loadLandscape(ixoff, iyoff);
  }
  
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridWidth; y++) {
      float z = grid[x][y];
      if (z < 3) {
        z = 3;
      }
      PVector sc = block2screen(x- fxoff-gridWidth/2,y-fyoff-gridWidth/2,z);
      if (sc.x > -graphics.width/2-100 && sc.x < graphics.width/2+100
          && sc.y > -graphics.height/2-100 && sc.y < graphics.height/2 +100) { 
        if (z == 3) {
          graphics.image(water, sc.x, sc.y);
        } else if(isRock[x][y]) {
          if (isTooTall(x, y)) {
            graphics.image(rock, sc.x, sc.y + TILE_Z_HEIGHT);
          }
          graphics.image(rock, sc.x, sc.y);
        } else {
          if (isTooTall(x, y)) {
            graphics.image(dirt, sc.x, sc.y + TILE_Z_HEIGHT);
          }
          graphics.image(grass, sc.x, sc.y);
        }
      }
    }
  }
  graphics.popMatrix();
  graphics.endDraw();
  //graphics.textSize(10);
  //graphics.fill(255);
  //graphics.text("FPS: " + frameRate, 0,10);
}

public void draw() {
  pushMatrix();
  scale(4);
  image(buffer, 0, 0);
  popMatrix();
  if (held) {
    drawLandscape(buffer);
    pOffset.x = offset.x;
    pOffset.y = offset.y;
    float dMouseX = (mouseX - clickStart.x) / (width/32);
    float dMouseY = (mouseY - clickStart.y) / (width/32);
    PVector blockDiff = screen2block(dMouseX, dMouseY);
    offset = offset.add(blockDiff);
    image(cursor, clickStart.x-64, clickStart.y-64, 128, 128);
  }
}

public void mousePressed() {
  held = true;
  clickStart.x = mouseX;
  clickStart.y = mouseY;
}

public void mouseReleased() {
  held = false;
  drawLandscape(buffer);
}

public PVector block2screen(float x,
                         float y,
                         float z) {
  return new PVector((x-y)*TILE_WIDTH,
                     (x+y)*TILE_HEIGHT-z*TILE_Z_HEIGHT);
}

public PVector screen2block(float x, float y) {
  float xpy = y / TILE_HEIGHT;
  float xmy = x / TILE_WIDTH;
  float by = (xpy - xmy) / 2;
  float bx = xpy - by;
  return new PVector(bx, by, 0);
}

float betterMod(float a, float b) {
  if (a >= 0) {
    return a%b;
  } else {
    return a%b+b;
  }
}
