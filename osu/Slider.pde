class Slider extends Circle implements Displayable{
  float x, y, r, in, score, len, startTime, initScore, x1, y1;
  String num;
  boolean dead, wasClicked, lastTicked, onTick, notChecked, moving, reverse, complete;
  int firstNotTicked, numTicked;
  ApproachCircle c;
  float time;
  int tickScore;
  SliderTick[] ticks;
  SliderTick[] reverseTicks;
  int shape;
  float[] start = new float[2];
  float[] end = new float[2];
  PVector dir;
  
  
  public Slider(float x, float y, float r, float startTime, int num, float x1, float y1, boolean reverse) {
    super(x,y,r,startTime,num);
    
    this.x = x;
    this.y = y;
    start[0] = x;
    start[1] = y;
    
    this.x1 = x1;
    this.y1 = y1;
    end[0] = x1;
    end[1] = y1; 
    
    dir = new PVector(x1- x,y1-y);
    
    this.r = r;
    this.reverse = reverse;
    this.num =  "" + num;
    firstNotTicked = 0;
    numTicked = 0;
    initScore = 2.5;
    
    c = new ApproachCircle(x, y, 2.5 * r);
    this.len = dist(start[0],start[1],x1,y1);
    print(len);
    
 
    print(start[0]);
    print(end[0]);
    if(reverse){
      ticks = new SliderTick[6];
      ticks[0] = new SliderTick(625, 600, false);
      /*for(int i = 1; i < ticks.length/2; i++){
        ticks[i] = new SliderTick(start[0] + 75 + i*100, start[1], false);
      }
      for(int i = ticks.length/2; i < ticks.length -1; i++){
        ticks[i] = new SliderTick((end-75)-(i-3)*100, 600, false);
      }*/
      ticks[1] = new SliderTick(725, 600, false);
      ticks[2] = new SliderTick(825, 600, false);
      ticks[3] = new SliderTick(825, 600, false);
      ticks[4] = new SliderTick(725, 600, false);
      ticks[5] = new SliderTick(625, 600, true);
    }else{
      ticks = new SliderTick[3];
      for(int i = 1; i < ticks.length; i++){
        ticks[i] = new SliderTick(start[0] + 75 + i*100, start[1], false);
      }
    }
    
    dead = false;
    wasClicked = false;

    lastTicked = false;
    onTick = false;
    notChecked = true;
    complete = false;
    moving = false;

    score = 2.5;
    this.reverse = reverse;
    if (reverse) this.time = 950;
    else this.time = 515;
  }
  
  void displayClicky(boolean number) {
    noStroke();
    fill(255);
    ellipse(x, y, r, r);
    drawLinearGradientDisc(x, y, (r/2) - 5, (r/2) - 5, color(204, 44, 113), color(20,20,20));
    if (number){
      fill(255);
      text(num, x-12, y+5);
    }
  }
  
  void displayTicks(SliderTick[] g) {
    if (complete){
      for (int i = 0; i < g.length; i++) {
        g[i].display();
      }
    }else{
      for (int i = 0; i < g.length/2; i++) {
        g[i].display();
      }
    }
  }
  
  void checkTicked(SliderTick[] g) {
    SliderTick tick = g[firstNotTicked];
    if (x == tick.getX() && y == tick.getY()) {
      onTick = true;
      if (isClicked()) {
        tickScore = 10;
        numTicked++;
        tick.setTicked(true);
      } else {
        tickScore = 0;
        tick.setAlive(false);
      }
      firstNotTicked++;
      lastTicked = tick.isEnd();
    } else {
      onTick = false;
    }
  }
  
  int t = 0;
  void display() {
    if (t > time) dead = true;
    if (!isDead()) {
      horizontalSlider();
      displayTicks(ticks);
      
      if (c.getRadius() < r) {
        moving = true;
        fill(255);
        if (!complete && x < end[0] ){
          x += dir.normalize().x ;;
        }else{
           if (!reverse){
             dead = true;
           }else{
             
             complete = true;
             if (x > start[0]) x -= dir.normalize().x ;; 
           }
        }
        if (!lastTicked) checkTicked(ticks);
        else onTick = false;
        /*if(complete && reverse){
          displayTicks(reverseTicks);
          if (!lastTicked) checkTicked(reverseTicks);
          else onTick = false;
        }*/
        displayClicky(false);
      } else {
        if (wasClicked || isClicked()) {
          if (!wasClicked) initScore = c.getRadius() / r;
          c.updateRadius();
          wasClicked = true;
        } else {
          c.display();
          displayClicky(true);
        }
      }
      text(firstNotTicked + "", 50, 160);
      t++;
    }
  }
  
  void horizontalSlider(){
    fill(0,0,0,0);
    stroke(255, 255);
    strokeWeight(4);
    line(start[0], start[1]-r/2, end[0], end[1]-r/2);
    line(start[0], start[1]+r/2, end[0], end[1]+r/2);
    arc(start[0], start[1], r, r, PI / 2, 3 * PI / 2);
    arc(end[0], end[1], r, r, 3 * PI / 2, 2*PI);
    arc(end[0], end[1], r, r, 0, PI / 2);
  }
  
  void verticalSlider(){
    fill(0,0,0,0);
    stroke(255, 255);
    strokeWeight(4);
    line(start[0], y-r/2, end[0], y-r/2);
    line(start[0], y+r/2, end[0], y+r/2);
    arc(start[0], y, r, r, PI / 2, 3 * PI / 2);
    arc(end[0], y, r, r, 3 * PI / 2, 2*PI);
    arc(end[0], y, r, r, 0, PI / 2);
  }
  
  boolean isClicked() {
    return (mousePressed && dist(mouseX, mouseY, this.x, this.y) < r);
  }
  
  boolean wasClicked() {
    return wasClicked;
  }
  
  boolean isDead() {
    return dead;
  }
  
  boolean lastTicked() {
    return lastTicked;
  }
  
  boolean onTick() {
    return onTick;
  }
  
  boolean notChecked() {
    return notChecked;
  }
  
  boolean moving() {
    return moving;
  }
  
  void resetTicks(){
    for( SliderTick a: ticks){
      a.setAlive(true);
    }
  }
  
  void setNotChecked(boolean b) {
    notChecked = b;
  }
  
  float initScore() {
    return initScore;
  }
  
  int getScore() {
    // initial hit score; -1 and 0 are used for later tiering
    if (initScore() > 1.6) score = -1;
    else score = 0;
    
    // final calculation of ticks ticked to total number of ticks
    if (((float) numTicked / ticks.length) == 1.0) score += 3;
    else if (((float) numTicked / ticks.length) >= 0.5) score += 2;
    else if (((float) numTicked / ticks.length) > 0) score++;
    
    // conversion to 300/100/50/X system
    if (score == 3) score = 300;
    else if (score == 2) score = 100;
    else if (score == 1) score = 50;
    else score = 0;
    
    return (int) score;
  }
  
  int tickScore() {
    return tickScore;
  }
}
