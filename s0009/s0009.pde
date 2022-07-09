import processing.svg.*;

import java.util.Collections;

PGraphics _render;

// Render configuration
boolean renderHighRes = true;
boolean capture = false;
boolean drawBorder = false;

// Paramaters
int rows, cols;
int fidelity;
float maxNoiseAngle;
float noiseFieldRate;
float border, frame;
float innerBorderPercent;

// Print setup
int printWidth = 12; // in inches
int printHeight = 12; // in inches
int printDpi = 350;
int previewDpi = 72;
int renderWidth;
int renderHeight;
float scaleFactor;
int outWidth, outHeight;

// Variable creation
ArrayList <PVector> vectors = new ArrayList();
ArrayList<Agent> agents = new ArrayList();
color colors[] = new color[5];

// Initialization
int seed = 10;
boolean firstFrame = true;
int counter = 0;
float midX = renderWidth/2;
float midY = renderHeight/2;
color borderColor;


// Setup

void setup() {
  size(1024, 1024, P2D);
  //blendMode(BLEND);
  doReset();
}

// Reset

void doReset() {
  agents.clear();
  clear();

  int dpi = renderHighRes ? printDpi : previewDpi;
  scaleFactor = dpi / (float)previewDpi;
  renderWidth = printWidth * dpi;
  renderHeight = printHeight * dpi;

  _render = createGraphics(renderWidth, renderHeight, P2D);

  firstFrame = true;
  drawBorder = false;

  // set new parameters
  seed = (int)random((float)99999999); // or manually set the seed
  println("The new seed is: " + seed);
  randomSeed(seed);

  // Load a palette from curated palettes
  shuffleArray(myPalettes);
  color[] palette = myPalettes[floor(random(0, myPalettes.length))];

  // CONFIGURE PARAMETERS
  border = min(renderHeight, renderWidth)/20;
  float packFactor = random(10, 30);
  float scl = min(renderHeight, renderWidth);
  fidelity = floor(random(2, 25));
  maxNoiseAngle = random(2) * TWO_PI;
  noiseFieldRate = 0.0000001;

  float space = ((min(renderHeight, renderWidth)) - packFactor*scl) / (packFactor - 1);
  cols = floor((renderWidth - 2*border) / packFactor);
  rows = floor((renderHeight - 2*border) / packFactor);
  midX = renderWidth/2;
  midY = renderHeight/2;

  // create a specific number of agents
  float genes;
  float life;
  float mass;

  while (agents.size() < random(5)) {
    genes = randomGaussian() * 1000;
    life = random(80, 100);// * genes, 0, 100);//*abs(sin(i)*sin(j));
    mass = random(scl/2, scl); //scl*random(genes);
    agents.add(new Agent(renderWidth/2, renderHeight/2, life, mass, palette));
  }

  //A 'roughly' centered and even distribution grid to initialize agents
  //  for (int i = 0; i < cols + 1; i++) {
  //  for (float j = 0; j < rows +1; j ++) {
  //    //float r = layer * radius;
  //    float offset = 0;

  //    float x = offset + scl/cols * i; //+ i * scl + (i >= 1 ? space * i : 0);
  //    float y = offset + scl/rows * j; //+ j * scl + (j >= 1 ? space * j: 0);

  //    genes = randomGaussian() * 1000;
  //    life = random(80, 100);// * genes, 0, 100);//*abs(sin(i)*sin(j));
  //    mass = random(packFactor); //scl*random(genes);

  //    agents.add(new Agent(x, y, life, mass, palette));
  //  }
  //}
}

// Render controls

void keyPressed() {
  switch (key) {
  case 's':
    String dateString = String.format("screenshots/%d-%02d-%02d %02d.%02d.%02d", year(), month(), day(), hour(), minute(), second());
    //saveFrame(dateString + ".scr.png");
    _render.save(dateString + ".TIFF");
    println("Screenshot saved");
    break;

  case 'q':

    //println("SVG Recording");
    break;

  case 'w':

    //println("SVG Saved");
    break;

  case 'r':
    seed = (int)System.currentTimeMillis();
    doReset();
    break;

  case 'h':
    renderHighRes = !renderHighRes;
    println(renderHighRes ? "High Resolution" : "Low Resolution");
    doReset();
    break;

  case 'f':
    println(frameRate);
    break;

  case 'c':
    capture = !capture;
    println("Capture: " + (capture ? "Enabled" : "Disabled"));
    break;


  case 'b':
    drawBorder = !drawBorder;
    borderColor = myPalettes[4][floor(random(0, myPalettes[4].length))];
    frame = border * 1.05;
    println("Frame: " + (drawBorder ? "Enabled" : "Disabled"));
    break;
  }
}


// Draw

void draw() {
  _render.beginDraw();

  if (firstFrame) {
    firstFrame = false;
    setBackground(_render);
  }

  magic(_render);
  _render.endDraw();


  float ratio = renderWidth / (float)renderHeight;
  if (ratio > 1) {
    outWidth = 1024;
    outHeight = (int)(outWidth / ratio);
  } else {
    outHeight = 1024;
    outWidth = (int)(outHeight * ratio);
  }

  image(_render, (1024 - outWidth) / 2, (1024 - outHeight) / 2, outWidth, outHeight);

  if (capture) {
    String _id = String.format("captures/%d%02d%02d.%02d.%02d/", year(), month(), day(), hour(), minute());
    saveFrame(_id + "#######" + ".tif");
  }

  counter += noiseFieldRate;
}

// Where the magic happens

void magic(PGraphics r) {
  //setBackground(_render);
  for (Agent agent : agents) {
    agent.run(r);
  }
  if (drawBorder) {
    drawBorder(_render);
  }
}

// Set backgound
void setBackground(PGraphics _render) {
  //_render.background(0); // Black BG
  //_render.background(250); // White BG
  _render.background(#E0C9A6); // Old Paper BG
}

void drawBorder(PGraphics _render) {
  _render.noStroke();
  _render.fill(borderColor);
  //innerBorderPercent = innerBorderPercent / 100;

  //outer
  _render.rect(0, 0, renderWidth, frame);
  _render.rect(renderWidth - frame, 0, frame, renderHeight);
  _render.rect(0, 0, frame, renderHeight);
  _render.rect(0, renderHeight - frame, renderWidth, frame);

  ////inner
  ////_render.fill(0, 255);
  //_render.rect(border, border, renderWidth - 2*border, border*.05);
  //_render.rect(border, border, border * innerBorderPercent, renderHeight - 2*border);
  //_render.rect(border, renderHeight - border*(1+innerBorderPercent), renderWidth - 2*border, border * innerBorderPercent);
  //_render.rect(renderWidth - border*(1+innerBorderPercent), border, border * innerBorderPercent, renderHeight - 2*border);
}

void shuffleArray(int[][] a) {
  int nbrCols = a.length;
  int nbrRows = a[0].length;
  for (int c = 0; c < nbrCols; c++) {
    for (int r = 0; r < nbrRows; r++) {
      int nc = (int)random(nbrCols);
      int nr = (int)random(nbrRows);
      int temp = a[c][r];
      a[c][r] = a[nc][nr];
      a[nc][nr] = temp;
    }
  }
}

// Curated color palettes
color[][] myPalettes = {
  {#E63946, #f1faee, #a8dadc, #457b9d, #1d3557},
  {#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  {#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  {#001219, #005f73, #0a9396, #94d2bd, #e9d8a6, #ee9b00, #ca6702, #bb3e03, #ae2012, #9b2226},
  {#f8f9fa, #e9ecef, #dee2e6, #ced4da, #adb5bd, #6c757d, #495057, #343a40, #212529, #212529},
  {#ff0000, #ff8700, #ffd300, #deff0a, #a1ff0a, #0aff99, #0aefff, #147df5, #580aff, #be0aff}, //rainbow
  {#7E60BF, #0487D9, #038C73, #F29F05, #D92B04, #140400}, // simple rainbow
  {#06080D, #1B8EF2, #1A2E40, #22A2F2, #5CB9F2}, // blue & black
  {#110E0E, #0A1214, #BAB3AB, #FE3603, #BFBA93, #ECE8C5, #F33030}, // koi
  {#110E0E, #0B120B, #0A1214, #BAB3AB, #FDC70F, #FDF300, #FE3603, #FF3C1A, #BFBA93, #ECE8C5, #F33030, #40ACF7}, // deep koi
  {#03071e, #370617, #6a040f, #9d0208, #d00000, #dc2f02, #e85d04, #f48c06, #faa307, #ffba08},
  {#007f5f, #2b9348, #55a630, #80b918, #aacc00, #bfd200, #d4d700, #dddf00, #eeef20, #ffff3f}, // lime
  {#0b090a, #161a1d, #660708, #a4161a, #ba181b, #e5383b, #b1a7a6, #d3d3d3, #f5f3f4, #ffffff}, // Black, Red, Grey, White
  {#582f0e, #7f4f24, #936639, #a68a64, #b6ad90, #c2c5aa, #a4ac86, #656d4a, #414833, #333d29}, // Brown, Tan, Green
  {#fec5bb, #fcd5ce, #fae1dd, #f8edeb, #e8e8e4, #d8e2dc, #ece4db, #ffe5d9, #ffd7ba, #fec89a}, // muted red, green, orange
};
