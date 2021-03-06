import processing.opengl.*;
import processing.opengl.*;
import processing.sound.*;
import java.util.*;

int timer = 0;
int streak = 0;
int score = 0;
int rawScore = 0;
int rawMaxScore = 0;
int temp = 0;
int counter = 0;
int noFail = 1;
float accuracy = 0;

int three = 0; //300s
int one = 0; //100s
int fifty = 0; //50s
int miss = 0; //misses

StartScreen screen;
HealthBar xd;
PImage pointer;
PImage marisa;
SoundFile file;

Circle a, b, c, d, e;
Slider sl, sl1;
Spinner sp, sp1;
Cursor p;


Circle tCircle;
Slider tSlider, tSliderRev;
Spinner tSpinner;

ArrayList<Object> clickies;
ArrayList<Circle> circles;
ArrayList<Slider> sliders;
ArrayList<Spinner> spinners;
ArrayList<Object> dead;

boolean ran, end, pause, first, song, over, tutorial;

void setup() {
  size(1000, 800);
  screen = new StartScreen(1000,800);
  first = true;
  play();
}

void varReset() {
  pause = false;
  song = false;
  end = false;
  ran = false;
  over = false;
  tutorial = false;
  timer = 0;
  score = 0;
  streak = 0;
  rawScore = 0;
  rawMaxScore = 0;
  accuracy = 0;
  three = 0;
  one = 0;
  fifty = 0;
  miss = 0;
}

void play() {
  varReset();
  screen.setStart(false);
  pointer = loadImage("Images/pointer.png");
  marisa = loadImage("Images/marisa1.png");

  file = new SoundFile(this, "marisa.mp3");

  clickies = new ArrayList<Object>();
  circles = new ArrayList<Circle>();
  sliders = new ArrayList<Slider>();
  spinners = new ArrayList<Spinner>();
  dead = new ArrayList<Object>();

  a = new Circle(345, 620, 80, 0, 1);
  clickies.add(a);
  circles.add(a);

  b = new Circle(495, 175, 80, 50, 2);
  clickies.add(b);
  circles.add(b);

  c = new Circle(645, 620, 80, 100, 3);
  clickies.add(c);
  circles.add(c);

  d = new Circle(260, 350, 80, 150, 4);
  clickies.add(d);
  circles.add(d);

  e = new Circle(730, 350, 80, 200, 5);
  clickies.add(e);
  circles.add(e);

  sp = new Spinner(250, 450, 10);
  clickies.add(sp);
  spinners.add(sp);
  
  sl = new Slider(350, 200, 600, 300, 80, 500, 6, 1);
  clickies.add(sl);
  sliders.add(sl);
  
  sl1 = new Slider(600, 450, 350, 550, 80, 700, 7, 1);
  clickies.add(sl1);
  sliders.add(sl1);
  
  sp1 = new Spinner(950, 1150, 10);
  clickies.add(sp1);
  spinners.add(sp1);

  p = new Cursor(width / 2, height / 2);
  xd = new HealthBar(500, 0.75);

  tCircle = new Circle(500, 400, 100, 50, 1);
  tSlider = new Slider(300, 400, 700, 400, 80, 790, 2, 1);
  tSliderRev = new Slider(300, 400, 700, 400, 80, 790, 3, 2);
  tSpinner = new Spinner(500, 650, 10);

}

void scoreCircle(Circle circle) {
  int cScore = circle.getScore();
  // adding to health
  if (cScore == 300) xd.changeHealth(noFail * 85);
  else if (cScore == 100) xd.changeHealth(noFail * 45);
  else if (cScore == 50) xd.changeHealth(noFail * 25);
  else xd.changeHealth(noFail * -10);

  // actually scoring the circle
  if (cScore < 100) streak = 0;
  else streak++;
  int sMult = streak;
  if (sMult > 0) sMult--;
  score += cScore + (cScore * sMult);
  rawScore += cScore;
  rawMaxScore += 300;
}

void scoreSlider(Slider slider) {
  // if slider hasn't been clicked or if the approach circle hasn't elapsed it yet
  if (slider.notChecked()) {
    // check for when elapsed
    if (slider.moving()) {
      slider.setNotChecked(false);
      streak = 0;
    }
    // check for when clicked first time. Update scores
    else if (slider.wasClicked()) {
      slider.setNotChecked(false);
      if (slider.initScore() > 1.6) streak = 0;
      else streak++;
    }
  }
  // check if on tick, and score appropiately
  if (!slider.isDead() && slider.onTick()) {
    if (slider.tickScore() == 10) {
      xd.changeHealth(40);
      score += 10;
      streak++;
    }
    else if (slider.tickScore() == 0 && !slider.lastTicked()) streak = 0;
  }
  // when slider ends, calculate the end score based on the amount of ticks ticked and add it.
  if (slider.isDead() && !dead.contains(slider)) {
    int sScore = slider.getScore();

    if (sScore == 300) xd.changeHealth(noFail * 65);
    else if (sScore == 100) xd.changeHealth(noFail * 15);
    else if (sScore == 50) xd.changeHealth(noFail * 1);
    else xd.changeHealth(noFail * -50);

    int sMult = streak;
    if (sMult > 0) sMult--;
    score += sScore + (sScore * sMult);
    rawScore += sScore;
    rawMaxScore += 300;
  }
}

void scoreSpinner(Spinner spinner) {
  if (!spinner.isDead()) {
    score += spinner.getScore();
  }
  else if (!spinner.checked()) {
    spinner.updateScore();
    int sScore = spinner.getScore();

    if (sScore == 300) xd.changeHealth(noFail * 65);
    else if (sScore == 100) xd.changeHealth(noFail * 15);
    else if (sScore == 50) xd.changeHealth(noFail * 1);
    else xd.changeHealth(noFail * -50);

    if (sScore == 0) streak = 0;
    else streak++;
    int sMult = streak;
    if (sMult > 0) sMult--;
    score += sScore + (sScore * sMult);
    rawScore += sScore;
    rawMaxScore += 300;
    spinner.setChecked();
  }
}

void countClickyScores() {
  for (Circle c : circles){
    if (c.getScore() == 300) three++;
    if (c.getScore() == 100) one++;
    if (c.getScore() == 50) fifty++;
    if (c.getScore() == 0) miss++;
  }

  for (Slider s : sliders){
    if (s.getScore() == 300) three++;
    if (s.getScore() == 100) one++;
    if (s.getScore() == 50) fifty++;
    if (s.getScore() == 0) miss++;
  }

  for (Spinner s : spinners) {
    if (s.getScore() == 300) three++;
    if (s.getScore() == 100) one++;
    if (s.getScore() == 50) fifty++;
    if (s.getScore() == 0) miss++;
  }
}

void displayGrade() {
  String grade = "";

  // enclosing circle
  pushStyle();
  stroke(204, 44, 113);
  strokeWeight(20);
  ellipse(770,300,350,350);

  // determining letter
  if (accuracy == 100) grade = "S";
  else if (accuracy > 90) grade = "A";
  else if (accuracy > 80) grade = "B";
  else if (accuracy > 70) grade = "C";
  else if (accuracy > 60) grade = "D";
  else grade = "F";

  fill(204, 44, 113);
  textSize(300);
  if (grade.equals("A") || grade.equals("C") || grade.equals("D")) text(grade, 665, 405);
  else text(grade, 695, 405);
  popStyle();
}


void endScreen() {
  if (!ran) {
    countClickyScores();
    ran = true;
  }
  if (file.isPlaying()) file.stop();
  
  fill(204, 44, 113);
  rect(40,200,500,70,10);
  rect(40,300,500,300,10);

  pushStyle();
  stroke(204, 44, 113);
  fill(255);
  strokeWeight(5);
  rect(575,510,180,80,5); //restart
  rect(775,510,180,80,5); //exit

  fill(204, 44, 113);
  textSize(40);
  text("Replay", 605,565);
  text("Exit", 825,565);
  popStyle();

  if (mousePressed && (580 < mouseX && mouseX < 755) && (515 < mouseY && mouseY < 585)){
    play();
    screen.setMode(2);
  }
  if (mousePressed && (785 < mouseX && mouseX < 950) && 515 < mouseY && mouseY < 585){
    screen.setMode(0);
    clickies.clear();
    dead.clear();
  }
  fill(255);
  textSize(50);
  text("Score           " + score, 50, 255);

  textSize(27);
  text("300x", 60, 360);
  text("100x", 60, 440);
  text("50x", 320, 360);
  text("X", 320, 440);

  textSize(40);
  text(streak + "x                "+ (int) (accuracy * 100) / 100.0  + "%", 70, 560);
  text(three, 150, 360);
  text(one, 150, 440);
  text(fifty, 390, 360);
  text(miss, 390, 440);


  textSize(44);
  text("Streak        Accuracy" , 60, 510);

  displayGrade();
  p.display();
}

void displayClickies() {
  // display all circles. When dead, score them.
  textSize(32);
  for(Circle c : circles) {
    if (timer > c.getStartTime()) c.display();
    if ((c.isDead() || c.isClicked()) && !dead.contains(c)) {
      scoreCircle(c);
      dead.add(c);
    }
  }
  // display all sliders. Score them (for each tick) until they die)
  for(Slider s : sliders){
    if (timer > s.getStartTime()) s.display();
    scoreSlider(s);
    if (s.isDead() && !dead.contains(s)) dead.add(s);
  }
  // display all spinners while in their active period
  for(Spinner spi : spinners) {
    if (timer > spi.getStartTime() && timer < spi.getEndTime()) {
      scoreSpinner(spi);
      spi.display();
    } else if (timer > spi.getEndTime())  {
      spi.display();
      spi.setDead();
      if (!dead.contains(spi)) dead.add(spi);
      if (!sp.checked()) scoreSpinner(spi);
    }
  } 
}


void keyPressed() {
  final int k = keyCode;

  if ((k == 'P' && screen.getMode() == 2) || tutorial && k == 'P' ){
    pause = !pause;
  }
  
  if (k == 'M') {
    noFail = 0;
    xd.changeDegenRate(0);
  }
  
  if (k == 'N') {
    noFail = 1;
    xd.changeDegenRate(0.75);
  }

  if (k == 'R'){
   play();
   screen.setMode(1);
  }
  if (k == ENTER || k == RETURN) {
    play();
    screen.setMode(1);
  }
  if (k == ESC) exit();
}

void displayPauseMenu(boolean dead) {
  if (!dead) {
    fill(166, 255, 43);
    rect(300,200,400,100);
  }
  fill(255, 130, 28);
  rect(300,350,400,100);
  fill(255, 33, 73);
  rect(300,500,400,100);

  fill(10);
  noStroke();
  if (!dead) {
    triangle(300,200,320,200,300,220);
    triangle(700,300,700,280,680,300);
  }

  triangle(300,350,320,350,300,370);
  triangle(700,450,700,430,680,450);

  triangle(300,500,320,500,300,520);
  triangle(700,600,700,580,680,600);

  textSize(50);
  fill(255);
  if (!dead) text("Continue",390,265);
  text("Retry", 440,415);
  text("Back to Menu", 340,565);
  if (file.isPlaying()) file.pause();
  song = false;
  p.display();

  if (!dead && mousePressed && 300 < mouseX && mouseX < 700 && 200 < mouseY && mouseY < 300) pause = false;
  if (mousePressed && 300 < mouseX && mouseX < 700 && 350 < mouseY && mouseY < 450){
    play();
    screen.setMode(1);
  }
  if (mousePressed && 300 < mouseX && mouseX < 700 && 500 < mouseY && mouseY < 600){
    pause = false;
    screen.setMode(0);
    play();
  }
}

void pause(boolean dead) {
    if (pause || over) {
      displayPauseMenu(dead);
    }
}


void tutorial() {
  background(10);
  timer++;
  if (!tCircle.isDead()) {
    fill(255);
    text("Introducting the hit circle.", 375,250);
    text("Click on the circle as the approach circle closes in!", 275,300);
    tCircle.display();
  }else if (!tSlider.isDead()) {
    text("Introducting the slider.", 425,250);
    text("Click and hold on the head of the slider as the approach circle closes in!", 200,300);
    tSlider.display();
  }else if (!tSliderRev.isDead()) {
    text("Now, let's reverse the direction", 350,250);
    text("When the circle reaches the other side, change direction.", 225,300);
    tSliderRev.display();
  } else if (!tSpinner.isComplete()) {
    text("Introducing the spinner", 400,250);
    text("You hold and drag your cursor rapidly!", 325,300);
    tSpinner.display();
  }else{
    screen.setMode(1);
    tutorial = false;
    counter = 0;
  }
  p.display();
}

void drawSongs(){
  textSize(37);
  noStroke();
    if (570 < mouseX && 200< mouseY && mouseY < 300){

      //drawing osu logo
      fill(255,255,255,100);
      ellipse(300,400,500,500);
      fill(20);
      ellipse(300,400,460,460);
      fill(255,255,255,100);
      ellipse(300,400,430,430);
      fill(10);
      textSize(200);
      text("osu!", 90,450);

      noStroke();
      textSize(30);
      fill(255,255,255);

      noStroke();

      pushStyle();



      fill(204, 44, 113);
      rect(570,200,450,100,10);
      fill(255);
      textSize(40);
      text("Tutorial", 700,260);


      //draws upper bar
      fill(204, 44, 113,100);
      noStroke();
      rect(0,0,1000,100);
      strokeWeight(5);
      stroke(255);
      line(0,100,1000,100);

      fill(255);
      text("osu! Tutorial", 30,90);
      popStyle();

      if(mousePressed && counter > 10){
        tutorial= true;
      }
    }

    if (570 < mouseX && 350< mouseY && mouseY < 450){
      marisa.resize(1000,800);
      background(marisa);
      //text("Silver Forest - Marisa Spark", 30,50);



      fill(204, 44, 113);
      rect(570,320,450,100,10);
      fill(255);
      text("Silver Forest", 670,365);
      text("Marisa Spark", 670,395);

      pushStyle();
      fill(204, 44, 113,100);
      noStroke();
      rect(0,0,1000,100);
      strokeWeight(5);
      stroke(255);
      line(0,100,1000,100);

      noStroke();
      textSize(30);
      fill(255,255,255);
      text("Silver Forest - Marisa Spark", 30,90);

      if(mousePressed && counter > 10 && !tutorial){
         screen.setMode(2);
         screen.setStart(true);
      }

      popStyle();


      /*/if(mousePressed &&counter > 10){
         screen.setMode(2);
         screen.setStart(true);
      }*/
    }


      fill(204, 44, 113);
      rect(590,200,450,100,10);
      fill(255);
      text("Tutorial", 730,260);

      fill(204, 44, 113);
      rect(590,320,450,100,10);
      fill(255);

      text("Silver Forest", 700,365);
      text("Marisa Spark", 700,395);

      fill(204, 44, 113,100);
      noStroke();
      rect(0,0,1000,100);
      strokeWeight(5);
      stroke(255);
      line(0,100,1000,100);


}

void draw() {
  background(10);
  noCursor();
  p.display();

  if (screen.getMode() == 0) {
     screen.display();
     p.display();
     file.stop();
     counter = 0;
  } if (screen.getMode() == 1){
    counter ++;
    file.stop();

    drawSongs();
    p.display();
    if (tutorial) {
      tutorial();
      timer = 0;
    }
  } else if (screen.getMode() == 2 && !pause) {
    background(marisa);

    if (first && screen.getStart()) screen.setStart(false);
    if (!end) {
      if (!song){
        file.play();
        song = true;
      }
      first = false;
      timer++;
      displayClickies();
      accuracy = (float) (rawScore * 100) / rawMaxScore;
      if (dead.size() == 0) accuracy = 100;
      fill(255);
      p.display();
      xd.display();

      if (xd.getHealth() == 0) {
        mousePressed = false;
        if (!over) temp = millis();
        over = true;
        // i was lazy so i just reformated the pause code
        // in osu!, dying is the exact same screen anyway
        if (millis() - temp > 2000) {
          pause = true;
        }
        else {
          delay(50); // because the rest of the game looks slow in comparison lol.
          // Also, I guess it adds to the osu! game... the game slows down when you die
          displayClickies();
        }
      }

      // text(timer + "", 50, 160);
      fill(255);
      textSize(32);
      text("Streak: " + streak + "x", 15, 790);
      text("Score: " + score, 770, 35);
      text("Accuracy: " + (int) (accuracy * 100) / 100.0  + "%", 725, 65);
    } else {
      if (screen.getStart()) play();
    }
  }
  if (pause) pause(over);
  if (screen.getMode() == 3) {
    screen.helpMenu();
    p.display();
    file.stop();

    if (mousePressed && 470 < mouseX && mouseX < 540 && 530 < mouseY && mouseY < 570) screen.setMode(0);
  }
  if (screen.getMode() == 4) exit();

  if (clickies.size() == dead.size() && clickies.size() != 0) {
    if (!end) temp = millis();
    end = true;
    if (millis() - temp > 2200) endScreen();
    else displayClickies();
  }

  //file.stop();

 /* timer++;
      text("timer: " + timer + "x", 100, 100);
      displayClickies();
      accuracy = (float) rawScore * 100 / rawMaxScore;
      if (dead.size() == 0) accuracy = 0;
      fill(255);
      p.display();

      // text(timer + "", 50, 160);
      textSize(32);
      text("Streak: " + streak + "x", 15, 790);
      text("Score: " + score, 770, 35);
      text("Accuracy: " + (int) (accuracy * 100) / 100.0  + "%", 725, 65);*/

}
