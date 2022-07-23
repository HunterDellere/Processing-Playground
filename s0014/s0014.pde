import processing.pdf.*;

PGraphics _render;

// Render configuration
int numRenders = 25;
int renderCount = 0;
boolean highQuality = true;
boolean watch = true;
boolean capture = false;
boolean svg = false;
boolean drawBorder = false;
boolean draw = true;

// Print setup
int printWidth = 12; // in inches
int printHeight = 12; // in inches
int printDpi = 350;
int previewDpi = 70;
int renderWidth, renderHeight;
float mW, mH;
float scaleFactor;
int outWidth, outHeight;
float border;
color borderColor;
String dateString;

// Initialization
int seed;
boolean firstFrame;
int counter = 0;
float incRate = pow(0.1, 6);


// Variable creation
ArrayList<Agent> agents;
int maxAgents;
color [] palette;

// Paramaters
int rows, cols;
int fidelity;
float maxNoiseAngle;
float scl;

  // Setup

  void setup() {
  size(750, 750, P2D);
  colorMode(HSB);

  //noLoop();
  doReset();
}

// Reset

void doReset() {
  clear();
  loop();

  agents = new ArrayList<Agent>();

  // setup render dimensions
  int dpi = highQuality ? printDpi : previewDpi;
  scaleFactor = dpi / (float)previewDpi;
  renderWidth = printWidth * dpi;
  renderHeight = printHeight * dpi;
  mW = renderWidth / 2;
  mH = renderHeight / 2;
  border = min(mW, mH) * 0.05;


  _render = createGraphics(renderWidth, renderHeight, P2D);
  _render.colorMode(HSB);


  dateString = String.format("%d%02d%02d_%02d%02d%02d", year(), month(), day(), hour(), minute(), second());
  firstFrame = true;
  drawBorder = false;


  // set new random seed
  seed =  (int)random((float)999999999); // or manually set the seed
  println("The current seed is: " + seed);
  randomSeed(seed);
  noiseSeed(seed);

  /* Load a palette from curated palettes
   The myPalettes variable doesn't reset when using doReset() and will only
   reproduce the seeded result with a fresh run of the sketch.
   This can be changed by managing a copy of myPalettes.
   */
  //shuffleArray(myPalettes, seed);
  palette = myPalettes[floor(random(myPalettes.length))];

  // CONFIGURE PARAMETERS
  fidelity = floor(random(3, 10)); // <2 not currently implemented
  float packFactor = random(1, 20);
  scl = min(renderHeight, renderWidth)/packFactor;
  maxAgents = floor((mW * mH)/ (2*scl));

  maxNoiseAngle = ceil(random(5)) * TWO_PI;
  incRate = pow(0.01, 20);

  // create a specific number of agents
  float initLife;
  float initMass;

  println("Spawning " + maxAgents + " agents...");
  while (agents.size() < maxAgents) {
    int agentCount = 0;

    // Periodic updates on spawning
    if (millis() % 1000.0 == 0.0) {
      if (agents.size() > agentCount) {
        agentCount = agents.size();
        println(agents.size() + " of " + maxAgents + " agents spawned...");
      }
    }

    //palette = myPalettes[floor(random(myPalettes.length))];

    initLife = 100;
    initMass = 20 + abs(randomGaussian() * scl);
    float x = random(initMass, mW * 2 - initMass);
    float y = random(initMass, mH * 2 - initMass);
    agents.add(new Agent(x, y, initLife, initMass, palette));

    // remove dead agents
    for (int i = 0; i < agents.size(); i++) {
      Agent agent = agents.get(i);
      if (agent.isDead()) {
        agents.remove(i);
      }
    }
  }
  println("All " + agents.size() + " agents spawned.");
}

// Render controls

void keyPressed() {
  switch (key) {
    /*
     Spacebar - Reset sketch
     Q        - Change quality
     W        -
     E        -
     R        - Report
     A        - Save a screenshot of the display as PNG
     S        - Save high quality TIFF file from offscreen buffer
     D        - Save a PDF version of the sketch
     F        - Toggle GIF animation capture of the display (High disk usage)
     B        - Toggle drawing a border around the sketch
     */

  case ' ':
    println("Resetting...");
    println("  ");
    println("--====--====--====--====--====--====--====--");
    println("  ");
    doReset();
    break;

  case 'q':
    highQuality = !highQuality;
    //println(highQuality ? "High quality" : "Low quality");
    println("  ");
    println("--====--====--====--====--====--====--====--");
    println("  ");
    println("Rendering with " + (highQuality ? "high quality..." : "low quality..."));
    doReset();
    break;

  case 'w':
    watch = !watch;
    println(watch ? "Watching." : "Hiding.");
    break;

  case 'e':
    //draw = false;
    println("Exiting...");
    exit();
    break;

  case 'r':
    println(floor(frameRate) + " fps");
    break;

  case 'a':
    //dateString = String.format("screenshots/%d%02d%02d_%02d%02d%02d", year(), month(), day(), hour(), minute(), second());
    saveFrame("screenshots/" + dateString + "_" + seed + "_png.png");
    println("PNG screenshot saved.");
    break;

  case 's':
    println("Saving TIFF image...");
    PImage img = _render.get();
    img.save("screenshots/" + dateString + "_" + seed + "_tif.tif");
    println("TIFF image saved.");
    break;

  case 'd':
    svg = true;
    println("SVG saving...");
    // Start and stop recording managed in Draw
    break;

  case 'f':
    capture = !capture;
    println("Capture " + (capture ? "enabled." : "disabled."));
    break;

  case 'b':
    drawBorder = !drawBorder;
    borderColor = myBackgrounds[(int)random(myBackgrounds.length)];
    println("Border: " + (drawBorder ? "enabled." : "disabled."));
    break;
  }
}


// Draw

void draw() {
  _render.beginDraw();


  // Setup, display, and capture
  float ratio = renderWidth / (float)renderHeight;
  if (ratio > 1) {
    outWidth = 750;
    outHeight = (int)(outWidth / ratio);
  } else {
    outHeight = 750;
    outWidth = (int)(outHeight * ratio);
  }

  if (svg) {
    beginRecord(PDF, "screenshots/" + dateString + "_" + seed + "_pdf.pdf");
    image(_render, (750 - outWidth) / 2, (750 - outHeight) / 2, outWidth, outHeight);
  }

  if (firstFrame) {
    setBackground(_render);
    firstFrame = false;
  }

  if (drawBorder) {
    drawBorder(_render);
  }

  for (int i = 0; i < agents.size(); i++) {
    Agent agent = agents.get(i);
    agent.run(_render);

    if (agent.isDead()) {
      agents.remove(i);
      //if (agents.size()%100 == 0) {
      //  println(agents.size() + " agents remaining.");
      //}
    }
  }


  if (capture) {
    PImage img = _render.get();
    img.save("captures/" + dateString + "/" + dateString + "_" + seed + frameCount + ".tif");
    //save(_id + "#######" + ".tif");
  }

  if (svg) {
    endRecord();
    println("SVG Saved.");
    svg = false;
  }

  _render.endDraw();

  if (watch) {
    image(_render, (750 - outWidth) / 2, (750 - outHeight) / 2, outWidth, outHeight);
  }

  // if no agents remain, save the render and start again until numRenders
  if (agents.size() < 1) {
    println("Done rendering.");

    println("Saving render " + (renderCount + 1) + " of " + numRenders + "...");
    beginRecord(PDF, "screenshots/" + dateString + "_" + seed + "_pdf.pdf");
    image(_render, (750 - outWidth) / 2, (750 - outHeight) / 2, outWidth, outHeight);
    endRecord();
    svg = false;
    println("Render saved.");
    if (renderCount < numRenders - 1) {
      println("Resetting...");
      println("  ");
      println("--====--====--====--====--====--====--====--");
      println("  ");

      renderCount++;
      doReset();
    } else {
      println("All renders complete.");
      noLoop();
    }
  }

  counter += incRate;
}

// Where the magic happens

//void magic(PGraphics r) {
//}

// Set backgound
void setBackground(PGraphics _render) {
  //_render.background(myBackgrounds[(int)random(0, myBackgrounds.length)]);
  color bgColor = color(myBackgrounds[(int)(random(myBackgrounds.length))]);
  _render.fill(bgColor);
  _render.noStroke();
  _render.rectMode(CENTER);
  _render.rect(mW, mH, mW * 2, mH * 2);
}

// Draw a border around the sketch
void drawBorder(PGraphics _render) {
  _render.noStroke();
  _render.rectMode(CENTER);

  //inner
  _render.fill(255);
  _render.rect(mW, border * 0.6, mW*2, border);
  _render.rect(renderWidth - border * 0.6, mH, border, renderHeight);
  _render.rect(border * 0.6, mH, border, renderHeight);
  _render.rect(mW, renderHeight - border * 0.6, renderWidth, border);

  //outer
  _render.fill(borderColor);
  _render.rect(mW, border * 0.5, mW*2, border);
  _render.rect(renderWidth-border/2, mH, border, renderHeight);
  _render.rect(border/2, mH, border, renderHeight);
  _render.rect(mW, renderHeight - border/2, renderWidth, border);
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
  //{#E63946, #f1faee, #a8dadc, #457b9d, #1d3557},
  //{#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  //{#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  //{#001219, #005f73, #0a9396, #94d2bd, #e9d8a6, #ee9b00, #ca6702, #bb3e03, #ae2012, #9b2226},
  //{#f8f9fa, #e9ecef, #dee2e6, #ced4da, #adb5bd, #6c757d, #495057, #343a40, #212529, #212529},
  {#ff0000, #ff8700, #ffd300, #deff0a, #a1ff0a, #0aff99, #0aefff, #147df5, #580aff, #be0aff}, //rainbow
  {#7E60BF, #0487D9, #038C73, #F29F05, #D92B04, #140400}, // simple rainbow
  {#06080D, #1B8EF2, #1A2E40, #22A2F2, #5CB9F2}, // blue & black
  {#110E0E, #0A1214, #BAB3AB, #FE3603, #BFBA93, #ECE8C5, #F33030}, // koi
  {#110E0E, #0B120B, #0A1214, #BAB3AB, #FDC70F, #FDF300, #FE3603, #FF3C1A, #BFBA93, #ECE8C5, #F33030, #40ACF7}, // deep koi
  {#03071e, #370617, #6a040f, #9d0208, #d00000, #dc2f02, #e85d04, #f48c06, #faa307, #ffba08},
  //{#007f5f, #2b9348, #55a630, #80b918, #aacc00, #bfd200, #d4d700, #dddf00, #eeef20, #ffff3f}, // lime
  {#0b090a, #161a1d, #660708, #a4161a, #ba181b, #e5383b, #b1a7a6, #d3d3d3, #f5f3f4, #ffffff}, // Black, Red, Grey, White
  {#582f0e, #7f4f24, #936639, #a68a64, #b6ad90, #c2c5aa, #a4ac86, #656d4a, #414833, #333d29}, // Brown, Tan, Green
  {#fec5bb, #fcd5ce, #fae1dd, #f8edeb, #e8e8e4, #d8e2dc, #ece4db, #ffe5d9, #ffd7ba, #fec89a}, // muted red, green, orange
  {#fca17d, #f9dbbd, #70d6ff, #064789, #114b5f}, // sunset
  {#c53d07, #fb9a74, #f9dbbd, #70d6ff, #064789, #114b5f}, // deep sunset
};

// Curated background colors
color[] myBackgrounds = {
  #E0C9A6, // Old Paper
  #000005, // Black
  #FFFFF5, // White
};
