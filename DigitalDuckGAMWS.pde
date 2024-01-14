import processing.sound.*;

PImage duckidle1, duckidle2, duckwalk1, duckwalk2, duckeat, duckswim1, duckswim2, duckheld1, duckheld2, ducksprite;
PImage lake, grass, button, bag, crumbs;
ArrayList<Duck> ducks;
ArrayList<Crumbs> crumbslist;
SoundFile quack;

void setup() {
  fullScreen();
  noStroke();
  imageMode(CENTER);
  ducks       = new ArrayList<Duck>();
  ducks.add(new Duck(width/2,height/2));
  crumbslist  = new ArrayList<Crumbs>();
  duckidle1   = loadImage("duckidle1.png");
  duckidle2   = loadImage("duckidle2.png");
  duckwalk1   = loadImage("duckwalk1.png");
  duckwalk2   = loadImage("duckwalk2.png");
  duckeat     = loadImage("duckeat.png");
  duckswim1   = loadImage("duckswim.png");
  duckswim2   = loadImage("duckswim2.png");
  duckheld1   = loadImage("duckheld1.png");
  duckheld2   = loadImage("duckheld2.png");
  lake        = loadImage("newlake.png");
  grass       = loadImage("grass.png");
  button      = loadImage("moreducks.png");
  bag         = loadImage("bread.png");
  crumbs      = loadImage("crumbs.png");
  quack       = new SoundFile(this, "quack.wav");
}

void draw() {
  background(255);
  fill(#D1EAFF);
  rect(0,0,width,225);
  stroke(0);
  strokeWeight(5);
  line(0,225,width,225);
  noStroke();
  
  
  //clear ducks
  fill(0);
  rect(18,10,102,30);
  fill(255);
  textSize(20);
  text("Clear Ducks",20,30);
  
  //lake
  image(lake,width-350,450,lake.width*1.5,lake.height*1.5);

  //grass
  image(grass,350,height-250,grass.width*2,grass.height*2);
  
  for(int i = 0; i < crumbslist.size(); i++) {
    Crumbs crumb = crumbslist.get(i);
    crumb.update();
    crumb.display();   
  }
  
  for(int i = 0; i < ducks.size(); i++) {
    Duck duck = ducks.get(i);
    duck.movement();
    duck.display();    
  }
  
 
  //button
  tint(255,127);
  if(dist(mouseX,mouseY,width-400,height-150)<100){ tint(220,127); } 
  image(button,width-400,height-150);
  tint(200,127);
  image(bag,width-150,height-150);
  tint(255,127);
  if(dist(mouseX,mouseY,width-150,height-150)<80){ tint(220,127); } 
  image(bag,width-150,height-150);
  noTint();
}

void mousePressed() {
  if(mouseX >= 20 && mouseX <= 120 && mouseY >= 10 && mouseY <= 40){ 
    for(int i = ducks.size()-1; i >= 1; i--){ ducks.remove(i); }
  } 
  if(dist(mouseX,mouseY,width-400,height-150)<100){ducks.add(new Duck(random(100,width-100),random(300,height-300)));}
  if(dist(mouseX,mouseY,width-150,height-150)<80) {crumbslist.add(new Crumbs(mouseX,mouseY));}
}

class Duck {
  float xpos, ypos, targetx, targety, movex, movey, xpre;
  float spd = 0.02;
  int timer, animtimer, ducktimer, crumbtimer, quacktimer;
  boolean locked = false;
  boolean left = false, right = true, flip = false;
  boolean idle = true, walking = false, eating = false, swimming = false, held = false, crumbeating = false;
  
  Duck(float x,float y) {
    xpos = x;
    ypos = y;
    movex = x;
    movey = y;
    targetx = x;
    targety = y;
  }
    
  boolean hover() {
    if(mouseX > xpos-((ducksprite.width/1.25)/2) && mouseX < xpos+((ducksprite.width/1.25)/2) && 
      mouseY > ypos-((ducksprite.height/1.25)/2) && mouseY < ypos+((ducksprite.height/1.25)/2)) {
      return true; } else { return false; }
  }
  
  void movement() {
    if(mousePressed && hover() && crumbslist.size() == 0) {locked = true;}
    if(!mousePressed) { locked = false;}
    
    if(locked) {
      held = true;
      xpos  = mouseX;
      ypos  = mouseY;
      xpos = constrain(xpos,35,width-35);
      ypos = constrain(ypos,200,height-50);
      timer = 0;
    } else { held = false; }
    
    
    //lake collision
    color c1 = get(int(xpos),int(ypos));
    color c2 = get(width-350,350);
    color c3 = get(1398,435);
    if( c1 == c2 || c1 == c3) { swimming = true; } else { swimming = false; }
    
    //grass collision
    color c4 = get(360,754);
    color c5 = get(422,826);
    color c6 = get(249,715);
    color c7 = get(268,781);
    color c8 = get(162,884);
    color c9 = get(538,940);
    if( c1 == c4 || c1 == c5 || c1 == c6 || c1 == c7 || c1 == c8 || c1 == c9) { eating = true; } else { eating = false; }
    
    if( crumbslist.size() > 0){
      Crumbs crumb = crumbslist.get(0);
      if(crumb.alreadylocked == true) {
        targetx = crumb.x-10;
        targety = crumb.y;
        xpre = xpos;
        movex = targetx - xpos;
        movey = targety - ypos;
        
        if(dist(xpos,ypos,crumb.x,crumb.y)<30){
          crumbslist.remove(0);
          crumbtimer = 15;
          crumbeating = true;
        }
      }
    }
    
    //random movement calculator
    if((timer > random(5,10) * frameRate) && !locked && crumbslist.size() == 0) {
      xpre = xpos;
      targetx = random(50,width-50);
      targety = random(250,height-200); 
      movex = targetx - xpos;
      movey = targety - ypos;
      timer = 0;
    }
    
    if (dist(xpos,ypos,targetx,targety) > 5 && !locked && ducksprite != duckeat) {
      walking = true; idle = false;
      xpos += movex * spd;
      ypos += movey * spd;
    } else {
      walking = false; idle = true;
      targetx = xpos;
      targety = ypos;
    }  
    timer++;
  }
  

  
  void display() {
    if(animtimer <= 20) { 
      if(swimming == true) { ducksprite = duckswim1; }
      else if(idle == true) { ducksprite = duckidle1; }
      else if(walking == true) { ducksprite = duckwalk1; }
    } else { 
      if(swimming == true) { ducksprite = duckswim2; }
      else if(idle == true) { ducksprite = duckidle2; }
      else if(walking == true) { ducksprite = duckwalk2; }
    }
       
    if(eating == true) {
      int rnd = int(random(1,1000));
      if ( rnd < 10 && ducktimer == 0) {
        ducktimer = 60;
      }
      
      if (ducktimer > 0) {
        ducksprite = duckeat;
        ducktimer--;
      }
    }
       
    if(crumbeating == true && crumbtimer > 0) {
      ducksprite = duckeat;
      crumbtimer--;
    }
       
    if(held == true) {
      if(animtimer <= 20) {
        ducksprite = duckheld1;
      } else { ducksprite = duckheld2; }
    }
       
    if(quacktimer > random(10,60) * frameRate) {
      quack.play();
      quacktimer = 0;
    }
       
    pushMatrix();
    translate(xpos,ypos);
    if(xpre > targetx) scale(-1,1);
    image(ducksprite,0,0,ducksprite.width/1.25,ducksprite.height/1.25);
    popMatrix();
    if(animtimer > 40) { animtimer = 0; }
    animtimer++;
    quacktimer++;
  }
}

class Crumbs {
  boolean locked,hover;
  boolean alreadylocked = false;
  float x,y;
  
  Crumbs(float xx, float yy){
    x = xx;
    y = yy;
  }
  
  void update() {
    if(hover()) {hover = true;} else {hover = false;}
    color c1 = get(mouseX,mouseY);
    color c2 = get(width-350,350);
    color c3 = get(1398,435);
    if(mousePressed && hover && alreadylocked == false) {locked = true;}
    if(!mousePressed && c1 != c2 && c1 != c3 ) { locked = false; alreadylocked = true;}
    if(locked){
      x = mouseX;
      y = mouseY; 
    }  
  }
  
  boolean hover() {
    if(mouseX > x-(crumbs.width/5)/2 && mouseX < x+(crumbs.width/5)/2 && 
      mouseY > y-(crumbs.height/5)/2 && mouseY < y+(crumbs.height/5)/2) {
      return true;
    } else { return false; }
  }
  
  void display() { image(crumbs,x,y,crumbs.width/5,crumbs.height/5); }
}
