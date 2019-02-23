int TILESHEET_OFFSET = 1;
int TILESHEET_WIDTH = 32;

int SPRITE_SIZE = 32;
int SPRITE_SPACING = 1;

int TILE_WIDTH = 16;
int TILE_HEIGHT = 8;
int TILE_Z_HEIGHT = 8;

PImage tileSheet;
PImage spriteSheet;

PImage grass;
PImage grassShadows[];
PImage water;
PImage dirt;
PImage rock;
PImage rockShadows[];
PImage cursor;

int gridWidth=40;
float grid[][];
boolean isRock[][];
float nscale = 0.1;
float nheight = 10;
PVector clickStart = new PVector();
PVector offset = new PVector();
PVector pOffset = new PVector();
boolean held = false;
int direction = 0;
PVector blockDiff = new PVector();

Sprite idleForward;
Sprite idleBackward;
Sprite walkingForward;
Sprite walkingBackward;

PGraphics buffer;

public void setup() {
  fullScreen(P2D);
  //size(1280,720, P2D);
  
  spriteSheet = loadImage("GenericCharacter.png");
  PImage[] idleForwardImages = new PImage[4];
  PImage[] idleBackwardImages = new PImage[4];
  PImage[] walkingForwardImages = new PImage[4];
  PImage[] walkingBackwardImages = new PImage[4];
  for (int i = 0; i < 4; i ++) {
    idleForwardImages[i] = spriteSheet.get((SPRITE_SIZE + SPRITE_SPACING) * i, (SPRITE_SIZE + SPRITE_SPACING) * 0, SPRITE_SIZE, SPRITE_SIZE);
    idleBackwardImages[i] = spriteSheet.get((SPRITE_SIZE + SPRITE_SPACING) * i, (SPRITE_SIZE + SPRITE_SPACING) * 3, SPRITE_SIZE, SPRITE_SIZE);
    walkingForwardImages[i] = spriteSheet.get((SPRITE_SIZE + SPRITE_SPACING) * i, (SPRITE_SIZE + SPRITE_SPACING) * 1, SPRITE_SIZE, SPRITE_SIZE);
    walkingBackwardImages[i] = spriteSheet.get((SPRITE_SIZE + SPRITE_SPACING) * i, (SPRITE_SIZE + SPRITE_SPACING) * 4, SPRITE_SIZE, SPRITE_SIZE);
  }
  
  idleForward = new Sprite(idleForwardImages, 10);
  idleBackward = new Sprite(idleBackwardImages, 10);
  walkingForward = new Sprite(walkingForwardImages, 10);
  walkingBackward = new Sprite(walkingBackwardImages, 10);
  
  grid = new float[gridWidth][gridWidth];
  isRock = new boolean[gridWidth][gridWidth];
  buffer = createGraphics(width / 4, height / 4, P2D);
  tileSheet = loadImage("tiles_taller_shadow.png");
  grass = tileSheet.get(TILESHEET_OFFSET, TILESHEET_OFFSET, TILESHEET_WIDTH, TILESHEET_WIDTH);
  water = tileSheet.get(TILESHEET_OFFSET, TILESHEET_OFFSET + (TILESHEET_WIDTH + TILESHEET_OFFSET) * 7, TILESHEET_WIDTH, TILESHEET_WIDTH);
  dirt = tileSheet.get(TILESHEET_OFFSET, TILESHEET_OFFSET + (TILESHEET_WIDTH + TILESHEET_OFFSET) * 6, TILESHEET_WIDTH, TILESHEET_WIDTH);
  rock = tileSheet.get(TILESHEET_OFFSET, TILESHEET_OFFSET + (TILESHEET_WIDTH + TILESHEET_OFFSET) * 6, TILESHEET_WIDTH, TILESHEET_WIDTH);
  
  grassShadows = new PImage[5];
  rockShadows = new PImage[5];
  
  for(int i = 0; i < 5; i++) {
    grassShadows[i] = tileSheet.get(TILESHEET_OFFSET + (i+1) * (TILESHEET_OFFSET + TILESHEET_WIDTH), TILESHEET_OFFSET, TILESHEET_WIDTH, TILESHEET_WIDTH);
    rockShadows[i] = tileSheet.get(TILESHEET_OFFSET + (i+1) * (TILESHEET_OFFSET + TILESHEET_WIDTH), TILESHEET_OFFSET + (TILESHEET_WIDTH + TILESHEET_OFFSET) * 6, TILESHEET_WIDTH, TILESHEET_WIDTH);
  }
  
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
}

public void drawLandscape(PGraphics graphics, int minX, int minY, int maxX, int maxY) {
  graphics.beginDraw();
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
      if (sc.x > -graphics.width/2-100 && sc.x < graphics.width/2+100
          && sc.y > -graphics.height/2-100 && sc.y < graphics.height/2 +100) { 
        if (z == 3) {
          graphics.image(water, sc.x, sc.y);
        } else if(isRock[x][y]) {
          if (isTooTall(x, y)) {
            graphics.image(rock, sc.x, sc.y + TILE_Z_HEIGHT);
          }
          graphics.image(rock, sc.x, sc.y);
          if (x < gridWidth - 1 && grid[x+1][y] > z) {
            graphics.image(rockShadows[0], sc.x, sc.y);
          }
          if (y > 0 && grid[x][y-1] > z) {
            graphics.image(rockShadows[1], sc.x, sc.y);
          }
          if (y < gridWidth - 1 && grid[x][y+1] > z) {
            graphics.image(rockShadows[2], sc.x, sc.y);
          }
          if (y < gridWidth - 1 && x < gridWidth - 1 && grid[x+1][y+1] > z) {
            graphics.image(rockShadows[3], sc.x, sc.y);
          }
          if (x < gridWidth - 1 && y > 0 && grid[x+1][y-1] > z) {
            graphics.image(rockShadows[4], sc.x, sc.y);
          }
        } else {
          if (isTooTall(x, y)) {
            graphics.image(dirt, sc.x, sc.y + TILE_Z_HEIGHT);
          }
          graphics.image(grass, sc.x, sc.y);
          if (x < gridWidth - 1 && grid[x+1][y] > z) {
            graphics.image(grassShadows[0], sc.x, sc.y);
          }
          if (y > 0 && grid[x][y-1] > z) {
            graphics.image(grassShadows[1], sc.x, sc.y);
          }
          if (y < gridWidth - 1 && grid[x][y+1] > z) {
            graphics.image(grassShadows[2], sc.x, sc.y);
          }
          if (y < gridWidth - 1 && x < gridWidth - 1 && grid[x+1][y+1] > z) {
            graphics.image(grassShadows[3], sc.x, sc.y);
          }
          if (x < gridWidth - 1 && y > 0 && grid[x+1][y-1] > z) {
            graphics.image(grassShadows[4], sc.x, sc.y);
          }
        }
      }
    }
  }
  graphics.popMatrix();
  graphics.endDraw();
}

public void draw() {
  drawLandscape(buffer,0,0, gridWidth/2+1, gridWidth/2+1);
  PVector playerCoords = block2screen(0, 0, grid[gridWidth/2][gridWidth/2]-1);
  buffer.beginDraw();
  buffer.pushMatrix();
  buffer.translate(buffer.width/2, buffer.height/2);
  Sprite curSprite = walkingForward;
  if (held) {
    if (direction == 0) {
      curSprite = walkingForward;
    } else if (direction == 1) {
      curSprite = walkingBackward;
    } else if (direction == 2) {
      buffer.scale(-1, 1);
      buffer.translate(-32,0);
      curSprite = walkingBackward;
    } else if (direction == 3) {
      buffer.scale(-1, 1);
      buffer.translate(-32,0);
      curSprite = walkingForward;
    }
    float inverseDist = 1/max(blockDiff.mag(), 0.01);
    curSprite.ticksPerFrame = (int) map(inverseDist, 0 , 100, 1, 50);
    //buffer.text(curSprite.ticksPerFrame, 0,-100);
  } else {
    if (direction == 0) {
      curSprite = idleForward;
    } else if (direction == 1) {
      curSprite = idleBackward;
    } else if (direction == 2) {
      buffer.scale(-1, 1);
      buffer.translate(-32,0);
      curSprite = idleBackward;
    } else if (direction == 3) {
      buffer.scale(-1, 1);
      buffer.translate(-32,0);
      curSprite = idleForward;
    }
  }
  curSprite.tick();
  curSprite.draw(buffer, playerCoords.x, playerCoords.y -32,32,32);
  buffer.popMatrix();
  buffer.text(frameRate, 0, 20);
  buffer.endDraw();
  drawLandscape(buffer,0, gridWidth/2+1, gridWidth/2+1, gridWidth);
  drawLandscape(buffer,gridWidth/2+1, 0, gridWidth, gridWidth/2+1);
  drawLandscape(buffer,gridWidth/2+1, gridWidth/2+1, gridWidth, gridWidth);
  pushMatrix();
  scale(4);
  image(buffer, 0, 0);
  popMatrix();

  if (held) {
    pOffset.x = offset.x;
    pOffset.y = offset.y;
    float dMouseX = (mouseX - clickStart.x) / (width);
    float dMouseY = (mouseY - clickStart.y) / (width);
    blockDiff = screen2block(dMouseX, dMouseY);
    if (blockDiff.x > 0 && blockDiff.x > abs(blockDiff.y)) {
      direction = 0; // down right
    } else if (blockDiff.y < 0 && abs(blockDiff.y) > abs(blockDiff.x)) {
      direction = 1; // up right
    } else if (blockDiff.x < 0 && abs(blockDiff.x) > abs(blockDiff.y)) {
      direction = 2; // up left
    } else if (blockDiff.y > 0 && blockDiff.y > abs(blockDiff.x)) {
      direction = 3; // down left
    }
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
