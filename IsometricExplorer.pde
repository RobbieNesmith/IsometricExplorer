int TILESHEET_OFFSET = 1;
int TILESHEET_WIDTH = 32;

int SPRITE_SIZE = 32;
int SPRITE_SPACING = 1;

int TILE_WIDTH = 16;
int TILE_HEIGHT = 8;
int TILE_Z_HEIGHT = 8;

String renderMode = P2D;

PImage tileSheet;
PImage spriteSheet;

PImage water;
PImage cursor;
PImage landTypes[][];

String[] playerSpriteSheets = {"GenericCharacter", "Knight", "MusketGuy", "Ninja", "Pirate", "Roman", "Viking"};
PlayerCharacter player;

int gridWidth=40;
float grid[][];
boolean isRock[][];
int shadowVariants[][];
int landType;
float nscale = 0.1;
float nheight = 10;
PVector clickStart = new PVector();
PVector offset = new PVector();
PVector pOffset = new PVector();
boolean held = false;
PVector blockDiff = new PVector();

PGraphics buffer;

public void setup() {
  fullScreen(renderMode);
  //size(1280,720, renderMode);
  landType = (int) random(7);
  //landType = 0;
  
  int spriteSheetIndex = (int) random(playerSpriteSheets.length);
  spriteSheet = loadImage(playerSpriteSheets[spriteSheetIndex] + ".png");
  player = new PlayerCharacter(spriteSheet, SPRITE_SIZE, SPRITE_SPACING);
  
  grid = new float[gridWidth][gridWidth];
  isRock = new boolean[gridWidth][gridWidth];
  shadowVariants = new int[gridWidth][gridWidth];
  buffer = createGraphics(width / 4, height / 4, renderMode);
  tileSheet = loadImage("tiles_taller_calculated_shadows.png");
  landTypes = new PImage[7][32];
  
  for (int shadowVariant = 0; shadowVariant < 32; shadowVariant++) {
    for (int landVariant = 0; landVariant < 7; landVariant++) {
      landTypes[landVariant][shadowVariant] = tileSheet.get(shadowVariant * TILESHEET_WIDTH, landVariant * TILESHEET_WIDTH, TILESHEET_WIDTH, TILESHEET_WIDTH);
    }
  }
  water = tileSheet.get(0, TILESHEET_WIDTH * 7, TILESHEET_WIDTH, TILESHEET_WIDTH);
  
  cursor = loadImage("cursor.png");
  loadLandscape(0,0);
  drawLandscape(buffer,0,0,gridWidth/2, gridWidth/2);
}

public boolean isTooTall(int x, int y) {
  return x < gridWidth - 1 && y < gridWidth - 1
         && (grid[x][y] - 1 > grid[x + 1][y]
         || grid[x][y] - 1 > grid[x][y + 1]);
}

public void loadLandscape(int xoff, int yoff) {
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridWidth; y++) {
      grid[x][y] = (int) (noise((x + xoff) * nscale, (y+yoff) * nscale)*2*nheight) /2.0;
      if(grid[x][y] < 3) {
        grid[x][y] = 3;
      }
      isRock[x][y] = noise((x + xoff) * nscale, (y+yoff) * nscale, 1000) > 0.6;
    }
  }
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridWidth; y++) {
      shadowVariants[x][y] = 0;
      if (y < gridWidth - 1 && grid[x][y + 1] > grid[x][y]) {
        shadowVariants[x][y] += 1;
      }
      if (x < gridWidth - 1 && y < gridWidth - 1 && grid[x + 1][y + 1] > grid[x][y]) {
        shadowVariants[x][y] += 2;
      }
      if (x < gridWidth - 1 && grid[x + 1][y] > grid[x][y]) {
        shadowVariants[x][y] += 4;
      }
      if (x < gridWidth - 1 && y > 0 && grid[x + 1][y - 1] > grid[x][y]) {
        shadowVariants[x][y] += 8;
      }
      if (y > 0 && grid[x][y - 1] > grid[x][y]) {
         shadowVariants[x][y] += 16;
      }
    }
  }
}

public void drawLandscape(PGraphics graphics, int minX, int minY, int maxX, int maxY) {
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
  
  for (int x = minX; x < maxX; x++) {
    for (int y = minY; y < maxY; y++) {
      float z = grid[x][y];
      if (z < 3) {
        z = 3;
      }
      PVector sc = block2screen(x- fxoff-gridWidth/2,y-fyoff-gridWidth/2,z);
      if (sc.x > -graphics.width/2 - TILESHEET_WIDTH && sc.x < graphics.width/2
          && sc.y > -graphics.height/2 - TILESHEET_WIDTH && sc.y < graphics.height/2) { 
        if (z == 3) {
          graphics.image(water, sc.x, sc.y);
        } else {
          if (isTooTall(x, y)) {
            graphics.image(landTypes[6][0], sc.x, sc.y + TILE_Z_HEIGHT);
          }
          if(isRock[x][y]) {
            graphics.image(landTypes[6][shadowVariants[x][y]], sc.x, sc.y);
          } else {
            graphics.image(landTypes[landType][shadowVariants[x][y]], sc.x, sc.y);
          }
        }
      }
    }
  }
  graphics.popMatrix();
}

public void draw() {
  buffer.beginDraw();
  drawLandscape(buffer,0,0, gridWidth/2+1, gridWidth/2+1);
  PVector playerCoords = block2screen(0, 0, grid[gridWidth/2][gridWidth/2]-1);
  buffer.pushMatrix();
  buffer.translate(buffer.width/2, buffer.height/2);
  if (held) {
    float inverseDist = 1/max(blockDiff.mag(), 0.01);
    player.setTicksPerFrame((int) map(inverseDist, 5 , 100, 1, 50));
  }
  player.tick();
  player.draw(buffer, playerCoords.x, playerCoords.y - SPRITE_SIZE);
  buffer.popMatrix();
  drawLandscape(buffer,0, gridWidth/2+1, gridWidth/2+1, gridWidth);
  drawLandscape(buffer,gridWidth/2+1, 0, gridWidth, gridWidth/2+1);
  drawLandscape(buffer,gridWidth/2+1, gridWidth/2+1, gridWidth, gridWidth);
  buffer.endDraw();
  pushMatrix();
  scale(4);
  image(buffer, 0, 0);
  popMatrix();

  if (held) {
    player.setIsWalking(true);
    pOffset.x = offset.x;
    pOffset.y = offset.y;
    float dMouseX = (mouseX - clickStart.x) / (width);
    float dMouseY = (mouseY - clickStart.y) / (width);
    blockDiff = screen2block(dMouseX, dMouseY);
    if (blockDiff.x > 0 && blockDiff.x > abs(blockDiff.y)) {
      player.setDirection(0); //down right
    } else if (blockDiff.y < 0 && abs(blockDiff.y) > abs(blockDiff.x)) {
      player.setDirection(1); // up right
    } else if (blockDiff.x < 0 && abs(blockDiff.x) > abs(blockDiff.y)) {
      player.setDirection(2); // up left
    } else if (blockDiff.y > 0 && blockDiff.y > abs(blockDiff.x)) {
      player.setDirection(3); // down left
    }
    offset = offset.add(blockDiff);
    
    image(cursor, clickStart.x-64, clickStart.y-64, 128, 128);
  } else {
    player.setIsWalking(false);
  }
  text(frameRate, 0,20);
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
  return new PVector((x-y-1)*TILE_WIDTH,
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