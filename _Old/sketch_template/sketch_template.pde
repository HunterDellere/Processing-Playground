PGraphics render;

int printWidth = 36;
int printHeight = 36;
int printDpi = 300;
int previewDpi = 72;

boolean renderHighRes = false;
boolean firstFrame = true;

int renderWidth;
int renderHeight;

float scaleFactor = 1;

int seed = (int)random(99999999);

ArrayList <Integer> colorList = new ArrayList();
ArrayList <Integer> xCoords = new ArrayList();
ArrayList <Integer> yCoords = new ArrayList();
ArrayList <Integer> rads = new ArrayList();

void setup() {
  size(1024, 1024, P2D);
  doReset();
}

void doReset() {
  int dpi = renderHighRes ? printDpi : previewDpi;
  scaleFactor = dpi / (float)previewDpi;
  renderWidth = printWidth * dpi;
  renderHeight = printHeight * dpi;

  render = createGraphics(renderWidth, renderHeight, P2D);
  firstFrame = true;
  
  randomSeed(seed);
}

void keyPressed() {
  switch (key) {
    case 's':
      String dateString = String.format("outputs/%d-%02d-%02d %02d.%02d.%02d", year(), month(), day(), hour(), minute(), second());
      render.background(0);
      //saveFrame(dateString + ".scr.png");
      render.save(dateString + ".TIFF");
      break;
      
    case 'r':
      seed = (int)System.currentTimeMillis();
      println(seed);
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
  }
}

void draw() {
  render.beginDraw();
  
  if (firstFrame) {
    firstFrame = false;
    render.background(0);
  }
  
  magic(render);
  render.endDraw();
  
  int outWidth, outHeight;
  
  float ratio = renderWidth / (float)renderHeight;
  if (ratio > 1) {
    outWidth = 1024;
    outHeight = (int)(outWidth / ratio);
  } else {
    outHeight = 1024;
    outWidth = (int)(outHeight * ratio);
  }
  
  image(render, (1024 - outWidth) / 2, (1024 - outHeight) / 2, outWidth, outHeight);
  
}

void magic(PGraphics r) {
    
  
}
