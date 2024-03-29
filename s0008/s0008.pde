PGraphics _render;

// Render configuration
boolean renderHighRes = true;
boolean capture = false;
boolean drawFrame = false;

// Paramaters
int rows, cols;
int fidelity;
float maxNoiseAngle;
float noiseFieldRate;
float border, frame;
float innerBorderPercent;

// Print setup
int printWidth = 10; // in inches
int printHeight = 10; // in inches
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
  blendMode(BLEND);
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
  drawFrame = false;

  // set new parameters
  seed = (int)random((float)99999999);
  println("The new seed is: " + seed);
  randomSeed(seed);

  // Load a palette from curated palettes
  color[] palette = myPalettes[floor(random(0, myPalettes.length))];

  // CONFIGURE PARAMETERS

  border = min(renderHeight, renderWidth)/20;
  float packFactor = random(10, 30);
  float scl = min(renderHeight, renderWidth);
  fidelity = 2;//floor(random(3, 9));
  maxNoiseAngle = random(8) * TWO_PI;
  noiseFieldRate = 0.001;

  float space = ((min(renderHeight, renderWidth)) - packFactor*scl) / (packFactor - 1);
  cols = floor((renderWidth - 2*border) / (scl + space));
  rows = floor((renderHeight - 2*border) / (scl + space));
  midX = renderWidth/2;
  midY = renderHeight/2;

  float genes;
  float life; 
  float mass; 
  while (agents.size() < 1) {
    genes = randomGaussian() * 1000;
    life = constrain(100*genes*sin(genes)*sin(genes), 90, 100);// * genes, 0, 100);//*abs(sin(i)*sin(j));
    mass = random(scl/2, scl); //scl*random(genes);
    agents.add(new Agent(random(renderWidth/3, 2*renderWidth/3), random(0, 2*renderHeight/3), life, mass, palette));
  }
  // A 'roughly' centered and even distribution grid to initialize agents
  //for (int i = 0; i < cols + 1; i++) {
  //  for (float j = 0; j < rows +1; j ++) {
  //    //float r = layer * radius;
  //    float offset = 0;

  //    float x = offset + scl * i + (i >= 1 ? space * i : 0); //+ i * scl + (i >= 1 ? space * i : 0);
  //    float y = offset + scl * j + (j >= 1 ? space * j: 0); //+ j * scl + (j >= 1 ? space * j: 0);

  //    genes = randomGaussian() * 100;
  //    life = genes*sin(i)*sin(j);
  //    mass = scl*sin(genes)*sin(genes); //scl*random(genes);

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
    drawFrame = !drawFrame;
    borderColor = myPalettes[4][floor(random(0, myPalettes[4].length))];
    frame = border * 1.05;
    println("Frame: " + (drawFrame ? "Enabled" : "Disabled"));
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
  if (drawFrame) {
    drawFrame(_render);
  }
}

// Set backgound
void setBackground(PGraphics _render) {
  //_render.background(0); // Black BG
  //_render.background(250); // White BG
  _render.background(#E0C9A6); // Old Paper BG
}

void drawFrame(PGraphics _render) {
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

// Curated color palettes
color[][] myPalettes = {
  {#E63946, #f1faee, #a8dadc, #457b9d, #1d3557},
  {#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  {#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  {#001219, #005f73, #0a9396, #94d2bd, #e9d8a6, #ee9b00, #ca6702, #bb3e03, #ae2012, #9b2226},
  {#f8f9fa, #e9ecef, #dee2e6, #ced4da, #adb5bd, #6c757d, #495057, #343a40, #212529, #212529},
  //{#ff0000, #ff8700, #ffd300, #deff0a, #a1ff0a, #0aff99, #0aefff, #147df5, #580aff, #be0aff}, //rainbow
  {#7E60BF, #0487D9, #038C73, #F29F05, #D92B04, #140400}, // simple rainbow
  {#06080D, #1B8EF2, #1A2E40, #22A2F2, #5CB9F2}, // blue & black
  {#110E0E, #0A1214, #BAB3AB, #FE3603, #BFBA93, #ECE8C5, #F33030}, // koi
  {#110E0E, #0B120B, #0A1214, #BAB3AB, #FDC70F, #FDF300, #FE3603, #FF3C1A, #BFBA93, #ECE8C5, #F33030, #40ACF7}, // deep koi
};
