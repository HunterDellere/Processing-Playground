PGraphics _render;

// Render configuration
boolean renderHighRes = true;
boolean capture = false;

// Paramaters
int scl;
float maxNoiseAngle;

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


// Setup

void setup() {
  size(750, 750, P2D);
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

  // set new parameters
  seed = (int)random((float)99999999);
  println("The new seed is: " + seed);
  randomSeed(seed);

  color[] palettes = myPalettes[floor(random(0, myPalettes.length))];
  // Pre-load
  scl = floor(random(10,50));
  maxNoiseAngle = random(2) * TWO_PI;
  
  for (int i = -1*scl; i < renderWidth/scl; i++) {
    float midX = renderWidth/2;
    float midY = renderHeight/2;
    for (float j = -1*scl; j < renderHeight/scl; j ++) {

      //float r = layer * radius;

      float x = i*random(.5,1) * scl;
      float y = j*scl;
      float life = 100*abs(sin(i)*sin(i));
      float mass = scl/2*abs((sin(i)*sin(j)));
      agents.add(new Agent(x, y, life, mass, palettes[(int)(abs(i+j))%palettes.length]));
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
    println("Capture: " + capture);
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
    outWidth = 750;
    outHeight = (int)(outWidth / ratio);
  } else {
    outHeight = 750;
    outWidth = (int)(outHeight * ratio);
  }

  image(_render, (750 - outWidth) / 2, (750 - outHeight) / 2, outWidth, outHeight);

  if (capture) {
    String _id = String.format("captures/%d%02d%02d.%02d.%02d/", year(), month(), day(), hour(), minute());
    saveFrame(_id + "#######" + ".tif");
  }

  counter += .00001;
}

// Where the magic happens

void magic(PGraphics r) {
  setBackground(_render);
  push();
  for (Agent agent : agents) {
    agent.run(r);
  }
  pop();
}

// Set backgound
void setBackground(PGraphics _render) {
  //_render.background(0);
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
};
