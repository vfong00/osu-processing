class Slider extends Circle implements Displayable{
  float x, y, x1, y1, r, in, score, len, startTime, initScore, timeDispScore, tickDist, angle;
  String num;
  boolean dead, wasClicked, lastTicked, onTick, notChecked, moving, forward, atEnd;
  int firstNotTicked, numTicked, tickScore, shape, numReverses, timesGone, totalTicks;
  ApproachCircle c;
  SliderTick[] ticksForward, ticksBackward;
  PVector start, end, dir;

  public Slider(float x, float y, float x1, float y1, float r, float startTime, int num, int numReverses) {
    super(x, y, r, startTime, num);

    this.x = x;
    this.y = y;
    start = new PVector(x,y);

    this.x1 = x1;
    this.y1 = y1;
    end = new PVector(x1,y1);

    len = dist(start.x, start.y, end.x, end.y);
    dir = new PVector(x1 - x, y1 - y);

    this.r = r;
    this.numReverses = numReverses;
    this.num =  "" + num;
    
    firstNotTicked = 1;
    numTicked = 0;
    timesGone = 0;
    initScore = 2.5;
    score = 2.5;
    timeDispScore = 255;
    
    PVector n = new PVector(10, 0);
    this.angle = PVector.angleBetween(n,dir);
    if (y1 > y) angle *= -1;

    c = new ApproachCircle(x, y, 2.5 * r);
    this.len = dist(start.x, start.y, x1, y1);

    dead = false;
    wasClicked = false;
    lastTicked = false;
    onTick = false;
    atEnd = false;
    notChecked = true;
    moving = false;
    forward = true;
    
    initializeTicks();
  }

  void initializeTicks() {
    int numTicks = ((int) len / 100) + 2;
    ticksForward = new SliderTick[numTicks];
    ticksBackward = new SliderTick[numTicks];
    
    if (numTicks > 2) tickDist = len / (numTicks - 1);
    else tickDist = len;
    
    for(int i = 0; i < numTicks; i++) {
      boolean last = i == numTicks - 1;
      ticksForward[i] = new SliderTick(start.x + (dir.normalize().x * tickDist * i), start.y + (dir.normalize().y * tickDist * i), last);
      if (i == 0) ticksForward[i].setAlive(false);
      ticksBackward[i] = new SliderTick(start.x + (dir.normalize().x * tickDist * i), start.y + (dir.normalize().y * tickDist * i), last);
      ticksBackward[i].setAlive(false);
    }
  }

  void displayClicky(boolean number){
    stroke(255);
    strokeWeight(4);
    fill(20);
    ellipse(x,y,r-7,r-7);
 //<>//
    drawLinearGradientDisc(x, y, (r / 2) - 5, (r / 2) - 5, color(204, 44, 113), color(20,20,20));
    if (number){
      fill(255);
      text(num, x-12, y+5);
    }
  }

  void displayTicks(boolean forward) {
    if (forward) {
      for (int i = 0; i < ticksForward.length; i++) {
        ticksForward[i].display();
      }
    } else {
      for (int i = 0; i < ticksBackward.length; i++) {
        ticksBackward[i].display();
      }
    }
  }

  void checkTicked(SliderTick[] g) {
    SliderTick tick = g[firstNotTicked];
    if (dist(x,y, tick.getX(), tick.getY()) < 1) {
      if (isClicked() && (forward || (firstNotTicked != ticksForward.length - 1))) {
        tickScore = 10;
        numTicked++;
        totalTicks++;
        tick.setTicked(true);
      } else {
        tickScore = 0;
        if (forward || (firstNotTicked != ticksForward.length - 1)) totalTicks++;
        tick.setAlive(false);
      }
      if (forward) firstNotTicked++;
      else firstNotTicked--;
      lastTicked = tick.isEnd();
      onTick = true;
    } else {
      onTick = false;
    }
  }

  void drawSlider(){
    fill(0,0,0,0);
    stroke(255, 255);
    strokeWeight(4);
    // lines that make up sides of slider
    line(start.x + (r / 2) * cos((PI / 2) - angle), start.y + (r / 2) * sin((PI / 2) - angle), end.x + (r / 2) * cos((PI / 2) - angle), end.y + (r / 2) * sin((PI / 2) - angle)); // top
    line(start.x + (r / 2) * cos((PI / 2) + angle), start.y - (r / 2) * sin((PI / 2) + angle), end.x + (r / 2) * cos((PI / 2) + angle), end.y - (r / 2) * sin((PI / 2) + angle)); // bottom
    // arcs at end of sliders
    arc(start.x, start.y, r, r, (PI / 2) - angle, (3 * PI / 2) - angle);
    arc(end.x, end.y, r, r, (3 * PI / 2) - angle , (2 * PI) + (PI / 2) - angle);
    noStroke();
    fill(20);
  }
  
  void moveSlider(int reverse) {
    x += ((int) Math.pow(-1, reverse)) * dir.normalize().x * 2;
    y += ((int) Math.pow(-1, reverse)) * dir.normalize().y * 2;
  }
  
  void updateTicks(boolean forward) {
    boolean end;
    if (!forward) {
      for (int i = 1; i < ticksForward.length; i++) {
        end = i == ticksForward.length - 1;
        ticksForward[i].setTicked(false);
        ticksForward[i].setAlive(true);
        ticksForward[i].setEnd(end);
      }
    } else {
      for (int i = 0; i < ticksBackward.length - 1; i++) {
        end = i == 0;
        ticksBackward[i].setTicked(false);
        ticksBackward[i].setAlive(true);
        ticksBackward[i].setEnd(end);
      }
    }
  }
  
  void funcSlider() {
    if (c.getRadius() < r) {
        moving = true;
        fill(255);
        // if it is at the end of a slider
        if ( ( forward && ( (Math.abs(end.x - x) < 1) && (Math.abs(end.y - y) < 1) ) ) || 
             ( !forward && ( (Math.abs(start.x - x) < 1) && (Math.abs(start.y - y) < 1) ) )
           ) {
          atEnd = true;
          moveSlider(timesGone);
          if (!forward) firstNotTicked = 1;
          else firstNotTicked = ticksForward.length - 1;
        } else {
           if (numReverses != timesGone) {
             if (atEnd) {
               forward = !forward;
               timesGone++;
             }
             updateTicks(forward);
             moveSlider(timesGone);
             atEnd = false;
             lastTicked = false;
           } else {
             dead = true;
           }
        }
        if (forward) checkTicked(ticksForward);
        else checkTicked(ticksBackward);
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
    
    // final calculation of ticks ticked to total number of tick
    if (((float) numTicked / totalTicks) == 1.0) score += 3;
    else if (((float) numTicked / totalTicks) >= 0.5) score += 2;
    else if (((float) numTicked / totalTicks) > 0) score++;

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
  
  void display() {
    if (!isDead()) {
      drawSlider();
      displayTicks(forward);
      funcSlider();
    } else {
      if (timeDispScore > 0) {
        if (numReverses % 2 == 1) displayScore(x + 5, y + 5);
        else displayScore(x1 + 5, y1 + 5);
      }
    }
  }
}
