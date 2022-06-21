import nice.palettes.*;

PGraphics _render;

// Render configuration
boolean renderHighRes = true;
boolean capture = false;

// Paramaters
float maxAngle;
int segments;
int layers;


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
ArrayList<Node> nodes = new ArrayList();
color colors[] = new color[5];

// Initialization
int seed = 10;
boolean firstFrame = true;


// Setup

void setup() {
  size(1024, 1024, P2D);
  colorMode(HSB, 360, 100, 100, 100);
  blendMode(BLEND);
  doReset();
}

// Reset

void doReset() {
  nodes.clear();
  clear();

  int dpi = renderHighRes ? printDpi : previewDpi;
  scaleFactor = dpi / (float)previewDpi;
  renderWidth = printWidth * dpi;
  renderHeight = printHeight * dpi;

  _render = createGraphics(renderWidth, renderHeight, P2D);
  firstFrame = true;

  // set new parameters
  println("The new seed is: " + seed);
  randomSeed(seed);
  
  float maxAngle = random(4, 100) * TWO_PI;
  float radius = 150;  
  layers = (int)(min(renderWidth, renderHeight) / (radius));
  float depth = random(1,5);
  segments = (int)(random(500, 2500));
  Palette();

  color[] palette = myPalettes[floor(random(0, myPalettes.length))];
  // Pre-load
  for (int i = 0; i < depth; i++) {
    float midX = renderWidth/2;
    float midY = renderHeight/2;
    float layer = 0;
    for (float a = 0; a < maxAngle; a += maxAngle/segments) {

      layer = floor(a/(maxAngle/TWO_PI)); //(floor((segments/layers)));
      float r = layer * radius;

      float x = midX + r * cos(a);
      float y = midY + r * sin(a);
      float life = 100*abs(sin(i)*sin(i));
      float mass = 5*radius*abs(cos(i)*sin(i));
      nodes.add(new Node(x, y, life, mass, palette[(int)(i*layer)%palette.length]));
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
}

// Where the magic happens

void magic(PGraphics r) {
  r.background(0, 50);
  push();
  for (Node node : nodes) {
    node.run(r);
  }
  pop();
}

// Set backgound
void setBackground(PGraphics _render) {
  _render.background(random(1, 10));
}

// Create a random palette
void Palette() {
  int hue = round(random(360));
  int r1  = round(random(180));
  colors[0] = color(hue - (r1*2), round(random(100)), round(random(100)));
  colors[1] = color(hue - r1, round(random(100)), round(random(100)));
  colors[2] = color(hue, round(random(100)), round(random(100)));
  colors[3] = color(hue + r1, round(random(100)), round(random(100)));
  colors[4] = color(hue + (r1*2), round(random(100)), round(random(100)));
}

// Curated color palettes
color[][] myPalettes = {
  {#E63946, #f1faee, #a8dadc, #457b9d, #1d3557},
  {#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  {#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  {#001219, #005f73, #0a9396, #94d2bd, #e9d8a6, #ee9b00, #ca6702, #bb3e03, #ae2012, #9b2226},
  {#f8f9fa, #e9ecef, #dee2e6, #ced4da, #adb5bd, #6c757d, #495057, #343a40, #212529, #212529},
  {#ff0000, #ff8700, #ffd300, #deff0a, #a1ff0a, #0aff99, #0aefff, #147df5, #580aff, #be0aff} //rainbow
};
