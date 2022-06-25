PGraphics _render;

// Render configuration
boolean renderHighRes = true;
boolean capture = false;
boolean drawFrame = false;

// Paramaters
int rows, cols;
float size, space;
int fidelity;
float maxNoiseAngle;
float noiseFieldRate;
float border, frame;
float innerBorderPercent;

// Print setup
int printWidth = 10;
int printHeight = 10;
int printDpi = 300;
int previewDpi = 72;
int renderWidth;
int renderHeight;
float scaleFactor = 1;
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
  color[] palettes = myPalettes[floor(random(0, myPalettes.length))];

  // Pre-load
  border = min(renderHeight, renderWidth)/20;
  size = random(5, 200);
  float packFactor = 1 / random(20, 50);
  space = (min(renderHeight, renderWidth) - 2*border) * packFactor -size;
  cols = floor((renderWidth - 2*border) / (size + space));
  rows = floor((renderHeight - 2*border) / (size + space));
  fidelity = floor(random(3, 10));
  maxNoiseAngle = random(2) * TWO_PI;
  noiseFieldRate = 1 / random(999, 999999);
  midX = renderWidth/2;
  midY = renderHeight/2;

  for (int i = 0; i < cols + 1; i++) {


    for (float j = 0; j < rows +1; j ++) {

      //float r = layer * radius;
      float offset = border;

      float x = offset + i * size + (i > 1 ? space * i : 0);
      float y = offset + j * size + (j > 1 ? space * j: 0);

      float life = 100*abs(sin(i)*sin(j));
      float mass = size;
      color c = palettes[(int)(abs(cos(i+seed)*sin(j)*seed))%palettes.length];

      agents.add(new Agent(x, y, life, mass, c));
    }
  }
  redraw();
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
  push();
  for (Agent agent : agents) {
    r.pushMatrix();
    agent.run(r);
    r.popMatrix();
  }
  pop();
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
};
