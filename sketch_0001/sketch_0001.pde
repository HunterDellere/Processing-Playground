PGraphics render;

int printWidth = 5;
int printHeight = 5;
int printDpi = 300;
int previewDpi = 72;

boolean renderHighRes = true;
boolean firstFrame = true;

int renderWidth;
int renderHeight;

float scaleFactor = 1;

int seed = 0;

int detail = floor(random(500, 1000)); // number of particles
int quantity = floor(random(3, 7)); // number of drawn areas

float rate = 0.00002;
float inc = 0.005; //increments of the perlin noise field. More movement with higher increments.
float zoff = 0;
int scl = 50;
int cols, rows, index;
ArrayList<PVector> flowfield = new ArrayList<PVector>();
PVector v;
ArrayList<Particle> particles = new ArrayList<Particle>();

ArrayList <Integer> colorList = new ArrayList();
ArrayList <Integer> xCoords = new ArrayList();
ArrayList <Integer> yCoords = new ArrayList();
ArrayList <Integer> rads = new ArrayList();

void setup() {
  size(1024, 1024, P2D);
  doReset();
  cols = floor(renderWidth / scl);
  rows = floor(renderHeight / scl);

  // initialize the flowfield with 0 vectors
  for (int i = 0; i < 2 * renderWidth * renderHeight / scl / scl; i++) {
    flowfield.add(i, new PVector(0, 0, 0));
    println(i);
  }
  
}

void doReset() {
  int dpi = renderHighRes ? printDpi : previewDpi;
  scaleFactor = dpi / (float)previewDpi;
  renderWidth = printWidth * dpi;
  renderHeight = printHeight * dpi;

  render = createGraphics(renderWidth, renderHeight, P2D);
  firstFrame = true;
  
  // create particles
  for (int i = 0; i < detail; i++) {
    particles.add(new Particle());
  }

  // generate random rgb values for color mapping
  for (int i = 0; i < detail*4; i++) {
    colorList.add(i, floor(random(255)));
  }
  
    // generate random radius for each shape
  for (int i = 0; i < quantity; i++) {
    rads.add(i, floor(random(renderHeight/scl, renderHeight/2)));
  }
  
    // generate random x coordinates for each shape
  for (int i = 0; i < quantity; i++) {
    xCoords.add(i, floor(random(rads.get(i), renderWidth-rads.get(i))));
  }
  
    // generate random y coordinates for each shape
  for (int i = 0; i < quantity; i++) {
    yCoords.add(i, floor(random(rads.get(i), renderHeight-rads.get(i))));
  }
  
  //maxRadius = 50;
  
  //randomSeed(seed);
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
      doReset();
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
  
  //println(frameRate);
}

void magic(PGraphics ren) {
    
  float yoff = 0;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x=0; x < cols; x++) {
      noiseDetail(2); // # of octaves for the Perlin noise which correlate to character & detail.
      v = PVector.fromAngle(noise(xoff, yoff, zoff) * TWO_PI);
      index = floor(x + y * cols);
      flowfield.set(index, v);
      xoff += inc;
      //push();
      //stroke(0, 50);
      //translate(x * scl, y * scl);
      //rotate(v.heading());
      //line(0, 0, scl/2, 0);
      ////circle(x * scl, y * scl, 4.0);
      //pop();
    }

    yoff += inc;
    zoff += rate;
    
    for (int i = 0; i < quantity; i++) {
      for (int j = 0; j < detail / quantity; j++) {
        int rad = rads.get(i); // floor(height/(j+2));
        int xCoord = xCoords.get(i); //floor(width / (i + 2));
        int yCoord = yCoords.get(i); // floor(height / (i + 2));
        float r = colorList.get(i*4);
        float g = colorList.get(i*4+1);
        float b = colorList.get(i*4+2);
        float alpha = colorList.get(i*4+3) % 10;
        particles.get(i*j).follow(flowfield);
        particles.get(i*j).update();
        particles.get(i*j).edges();
        particles.get(i*j).display(ren, xCoord, yCoord, rad, r, g, b, alpha);
      }
    }
  }
}
