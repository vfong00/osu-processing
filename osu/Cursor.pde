class Cursor extends Thing implements Displayable {
  float x, y;
  PImage cursorPhoto, cursorTrailPhoto;
  ArrayDeque<CursorTrail> trailImgs;
  
  public Cursor(float x, float y, PImage cursorPhoto, PImage cursorTrailPhoto) {
      super(x,y);
      this.cursorPhoto = cursorPhoto;
      this.cursorTrailPhoto = cursorTrailPhoto;
      trailImgs = new ArrayDeque<CursorTrail>(100);
  }
  
  void display() {
    imageMode(CENTER);
    x = mouseX;
    y = mouseY;
    
    if (trailImgs.size() >= 100) {
      trailImgs.removeFirst();
    }
    CursorTrail t = new CursorTrail(x, y, cursorTrailPhoto);
    trailImgs.add(t);
    
    Iterator<CursorTrail> iter = trailImgs.descendingIterator();
    while (iter.hasNext()) {
      iter.next().display();
    }
    
    tint(255, 255);
    image(cursorPhoto, x, y);
    fill(255);
    
    text(x+"", 50, 70);
    text(y+"", 50, 100);
    text(mousePressed+"", 50, 130);
    // text(trailImgs.size() + "", 50, 160);
  }
}
