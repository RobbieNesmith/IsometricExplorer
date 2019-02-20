class Sprite {
  PImage[] images;
  int curFrame;
  int ticksPerFrame;
  int curTick;
  public Sprite(PImage[] images, int ticksPerFrame) {
    this.images = images;
    this.ticksPerFrame = ticksPerFrame;
  }
  
  public void tick() {
    this.curTick++;
    if (this.curTick >= this.ticksPerFrame) {
      this.curFrame ++;
      this.curTick = 0;
      if (this.curFrame >= this.images.length) {
        this.curFrame = 0;
      }
    }
  }
  
  public void draw(float x, float y, float xSize, float ySize) {
    image(this.images[this.curFrame], x, y, xSize, ySize);
  }
  
  public void draw(PGraphics gr, float x, float y, float xSize, float ySize) {
    gr.image(this.images[this.curFrame], x, y, xSize, ySize);
  }
}