// Explorable Mandelbrot Set
 import controlP5.*;
 ControlP5 cp5;
boolean cpLoaded = true;

PFont f;
boolean ShipMode = false;

// Interations
double downX, downY, prevMouseX, prevMouseY, startX, startY, startWH;
boolean shift=false;
boolean zoom = false;
boolean pause = true;
boolean isLoaded = false;

// Modifiers
double sensitivity = 0.1;
double deltaX = 0.04;

// Control rendering
int defaultMaxiterations = 100;
  int maxiterations = 0;
double defaultResolution = 4.0;
  double resolution = defaultResolution;
  double minResolution = 1;

// Control zoom & scale
double defaultXmin = -2.5;
  double xmin = defaultXmin;
double defaultYmin = -2;
  double ymin = defaultYmin;
double defaultWH = 4;
  double wh = defaultWH;

// Lightning: [356,0,0], [200,20,0], [65,85,100]
color c1;
  int c1h = 330;
  int c1s = 35;
  int c1b = 15;
color c2;
  int c2h = 270;
  int c2s = 80;
  int c2b = 70;
color c3;
  int c3h = 165;
  int c3s = 45;
  int c3b = 100;
  
int ctrlX = 25;
int ctrlY = 25;
int ctrlW = 165;
int ctrlH = 285;

// Launch
void setup() {
  size(1000, 1000);
  f = createFont("Arial",12,true);
  
  cp5 = new ControlP5(this);
    
  frameRate(30);
  colorMode(HSB, 360, 100, 100);
  loadPixels();
  loadSliders();
}

void draw() {
  c1 = color(c1h, c1s, c1b, HSB);
  c2 = color(c2h, c2s, c2b, HSB);
  c3 = color(c3h, c3s, c3b, HSB);
  
  double moveX = (mouseX-(width/2.0))/(width/2.0) * sensitivity;
  double moveY = (mouseY-(height/2.0))/(height/2.0) * sensitivity;

  // Cool loading options
  if(!isLoaded && resolution < defaultResolution) {
    //resolution+=0.5;
    //if(resolution == defaultResolution) isLoaded = true;
  }
  if(!isLoaded && maxiterations < defaultMaxiterations) {
    maxiterations += 1;
    if(maxiterations == defaultMaxiterations) isLoaded = true;
  }
  
  if(!pause) {
    if(moveX > 0.7) moveX = 0.7;  
    if(moveY > 0.7) moveY = 0.7;
    
//      resolution = resolution + (resolution*0.001);
    
    if (wh>10) wh=10;
    if (deltaX>1) deltaX=1;
    wh = wh - deltaX*wh;
    xmin = xmin + deltaX*wh/2 + moveX*wh/2;
    ymin = ymin + deltaX*wh/2 + moveY*wh/2;
  }

  mandelbrot();
  
  // Draw control background
  fill(360,0,0,95);
  noStroke();
  rect(ctrlX,ctrlY,ctrlW,ctrlH);
}

void loadSliders() {
  if(cpLoaded) {
    colorMode(HSB, 360, 100, 100);  
    int cFore = color(c3h, 30, 90);
    int cBack = color(c3h, 30, 40);
    int cActive = color(c3h, 30, 100);
    int cVal = color(c3h, 10, 0);
    int h = 17;
    int indent = 50;
    
    cp5.setControlFont(f);
    cp5.setColorForeground(cFore).setColorActive(cActive).setColorBackground(cBack).setColorValueLabel(cVal);  
  
    cp5.addSlider("c1h").setPosition(indent,50).setRange(0,360).setHeight(h);
    cp5.addSlider("c2h").setPosition(indent,70).setRange(0,360).setHeight(h);
    cp5.addSlider("c3h").setPosition(indent,90).setRange(0,360).setHeight(h);

    cp5.addSlider("c1s").setPosition(indent,140).setRange(0,100).setHeight(h);
    cp5.addSlider("c2s").setPosition(indent,160).setRange(0,100).setHeight(h);
    cp5.addSlider("c3s").setPosition(indent,180).setRange(0,100).setHeight(h);

    cp5.addSlider("c1b").setPosition(indent,230).setRange(0,100).setHeight(h);
    cp5.addSlider("c2b").setPosition(indent,250).setRange(0,100).setHeight(h);
    cp5.addSlider("c3b").setPosition(indent,270).setRange(0,100).setHeight(h);

    cp5.addButton("resetSize").setCaptionLabel("Reset Size").setPosition(indent,320).setSize(120,(int)((float)h*1.5));
  }
}

public void resetSize(){
  // Modifiers
  sensitivity = 0.1;
  deltaX = 0.04;
  
  // Control rendering
  maxiterations = 0;
  resolution = defaultResolution;
  
  // Control zoom & scale
  xmin = defaultXmin;
  ymin = defaultYmin;
  wh = defaultWH;
}

void mandelbrot() {
  double xmax = xmin + wh;
  double ymax = ymin + wh;
 
  // Calculate amount we increment x,y for each pixel
  double dx = (xmax-xmin) / width;
  double dy = (ymax-ymin) / height;
 
  double y = ymin;
  for (int j = 0; j < height; j++) {
    double x = xmin;
    for (int i = 0; i < width; i++) {
      double a = x;
      double b = y;
      int n = 0;
      while (n < maxiterations) { 
        double aa = a * a; 
        double bb = b * b; 
        if(ShipMode)  b = 2.0 * abs((float)a) * abs((float)b) + y; 
        else          b = 2.0 * (float)a * (float)b + y; 
        a = aa - bb + x; 
        if (aa + bb > resolution) break;
        n++;
      }
 
      color pixelColor = complexGradient(c1, c2, c3, (n * (float)resolution % 100)/100); //lerpColor(startColor, endColor, (n * (float)resolution % 100)/100);
//      if(i%100 == 0) println((n * (double)resolution % 100)/100);
      pixels[i+j*width] = (n==maxiterations) ? color(0) : pixelColor;
 
      x += dx;
    }
    y += dy;
  }
  
  updatePixels();
  cout("Spacebar: start/pause","center1");
  if(pause) {
    cout("Paused – Drag to move.","center2");
  }

}

color complexGradient(color c1, color c2, color c3, float p){
  color lc;
  float mp = 0.5;
  float newP = 0.0;
  
  if(p <= mp){
    newP = p/mp;
    lc = lerpColor(c1, c2, newP);
  }
  else {
    newP = (p-mp)/mp;
    lc = lerpColor(c2, c3, newP);
  }
  return lc;
}

void cout(String text, String position) {
  float pos;
  textFont(f,16);
  colorMode(HSB, 360, 100, 100);
  fill(360,0,100);
  
  if(position == "left"){
    textAlign(LEFT);
    text(text, 50, height-50);
  }
  if(position == "right"){
    textAlign(RIGHT);
    text(text, width-50, height-50);
  }
  if(position == "center1"){
    textAlign(CENTER);
    text(text, width/2, 50);
  }
  if(position == "center2"){
    textAlign(CENTER);
    text(text, width/2, 75);
  }
}

void mousePressed() {
    downX=mouseX;
    downY=mouseY;
    startX=xmin;
    startY=ymin;
    startWH=wh;
}
void mouseReleased() {}

void mouseDragged() {
  boolean disable = false;
  if(mouseX > ctrlX && mouseX < ctrlX+ctrlW) {
    if(mouseY > ctrlY && mouseY < ctrlY+ctrlH) {
      disable = true;
    }
  }
  
  if(!disable) {
    double deltaX=(mouseX-downX)/width;
    double deltaY=(mouseY-downY)/height;
   
    if (!shift) {
      xmin = startX-deltaX*wh;
      ymin = startY-deltaY*wh;
    } 
    else {
      if (wh>10) wh=10;
      if (deltaX>1) deltaX=1;
      wh = startWH-deltaX*wh;
      xmin = startX+deltaX*wh/2;
      ymin = startY+deltaX*wh/2;
    }
  }
}

void keyPressed() {
  if(keyCode == ' '){
    pause = pause?false:true;
  }
  else if(keyCode == DOWN) {
    if(resolution > minResolution) resolution-=0.1;
  }
  else if(keyCode == UP) {
    resolution+=0.1;
  }
  else if(keyCode == LEFT) {
    maxiterations-=10;
  }
  else if(keyCode == RIGHT) {
    maxiterations+=10;
  }
}
