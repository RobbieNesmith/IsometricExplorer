class PlayerCharacter {
  Sprite walkingForward, walkingBackward, idleForward, idleBackward, curSprite;
  int direction;
  boolean isWalking;
  
  public PlayerCharacter(PImage spriteSheet, int spriteSize, int spriteSpacing) {
    PImage[] idleForwardImages = new PImage[4];
    PImage[] idleBackwardImages = new PImage[4];
    PImage[] walkingForwardImages = new PImage[4];
    PImage[] walkingBackwardImages = new PImage[4];
    for (int i = 0; i < 4; i ++) {
      idleForwardImages[i] = spriteSheet.get((spriteSize + spriteSpacing) * i, (spriteSize + spriteSpacing) * 0, spriteSize, spriteSize);
      idleBackwardImages[i] = spriteSheet.get((spriteSize + spriteSpacing) * i, (spriteSize + spriteSpacing) * 3, spriteSize, spriteSize);
      walkingForwardImages[i] = spriteSheet.get((spriteSize + spriteSpacing) * i, (spriteSize + spriteSpacing) * 1, spriteSize, spriteSize);
      walkingBackwardImages[i] = spriteSheet.get((spriteSize + spriteSpacing) * i, (spriteSize + spriteSpacing) * 4, spriteSize, spriteSize);
    }
    
    this.idleForward = new Sprite(idleForwardImages, 10);
    this.idleBackward = new Sprite(idleBackwardImages, 10);
    this.walkingForward = new Sprite(walkingForwardImages, 10);
    this.walkingBackward = new Sprite(walkingBackwardImages, 10);
    this.curSprite = walkingForward;
  }
  
  public void setDirection(int direction) {
    this.direction = direction;
    this.updateSprite();
  }
  
  public void setIsWalking(boolean isWalking) {
    this.isWalking = isWalking;
    this.updateSprite();
  }
  
  public void setTicksPerFrame(int ticksPerFrame) {
    if (this.isWalking) {
      this.curSprite.ticksPerFrame = ticksPerFrame;
    }
  }
  
  private void updateSprite() {
    if (this.isWalking) {
      if (direction == 0 || direction == 3) {
        this.curSprite = this.walkingForward;
      } else {
        this.curSprite = this.walkingBackward;
      }
    } else {
      if (direction == 0 || direction == 3) {
        this.curSprite = this.idleForward;
      } else {
        this.curSprite = this.idleBackward;
      }
    }
  }
  
  public void tick() {
    this.curSprite.tick();
  }
  
  public void draw(PGraphics graphics, float x, float y) {
    if (this.direction > 1) {
      graphics.scale(-1, 1);
    }
    this.curSprite.draw(graphics, x, y);
  }
}