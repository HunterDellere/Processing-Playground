import peasy.*;

PeasyCam cam;

long seed;
float r;
int total;
int outHeight, outWidth;

Node[][] cloud;

boolean firstFrame = true;
boolean renderHighRes = true;
boolean capture = false;

void setup() {
  size(1000, 1000, P3D);
  cam = new PeasyCam(this, 1500);
  surface.setResizable(true);
  surface.setLocation(100, 100);
  doReset();
}

// Reset

void doReset() {
  clear();

  seed = (long)random(999);
  total = 25;
  firstFrame = true;
  r = 500;
  color[] palette = myPalettes[floor(random(0, myPalettes.length))]; // some subset of the selected palette


  // set new parameters
  println("The new seed is: " + seed);
  randomSeed(seed);

  cloud = new Node[total+1][total+1];

  //pre-load
  for (int i = 0; i < total + 1; i++) {
    float lat = map(i, 0, total, 0, PI);
    //float r2 = pow(pow(abs(cos(m2 * lat / 4) / a),
    for (int j = 0; j < total + 1; j++) {
      float lon = map(j, 0, total, 0, TWO_PI);
      float x = r * sin(lat) * cos(lon);
      float y = r * sin(lat) * sin(lon);
      float z = r * cos(lat);
      cloud[i][j] = new Node(x, y, z, 100, 1, palette[(int)(i)%palette.length]);
    }
  }
}
// Render controls

void keyPressed() {
  switch (key) {
  case 's':
    String dateString = String.format("screenshots/%d-%02d-%02d %02d.%02d.%02d", year(), month(), day(), hour(), minute(), second());
    //saveFrame(dateString + ".scr.png");
    save(dateString + ".TIFF");
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
  //_render.beginDraw();

  if (firstFrame) {
    firstFrame = false;
    setBackground();
  }

  background(0);
  lights();
  
  stroke(255);
  
  
  for (int i = 0; i < total; i++) {
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < total + 1; j++) {
      PVector v1 = cloud[i][j].pos;
      PVector v2 = cloud[i+1][j].pos;
      vertex(v1.x, v1.y, v1.z);
      vertex(v2.x, v2.y, v2.z);
    }
    endShape();
  }
  //magic();
  //_render.endDraw();


  float ratio = width / (float)height;
  if (ratio > 1) {
    outWidth = 750;
    outHeight = (int)(outWidth / ratio);
  } else {
    outHeight = 750;
    outWidth = (int)(outHeight * ratio);
  }

  //image(_render, (750 - outWidth) / 2, (750 - outHeight) / 2, outWidth, outHeight);

  if (capture) {
    String _id = String.format("captures/%d%02d%02d.%02d.%02d/", year(), month(), day(), hour(), minute());
    saveFrame(_id + "#######" + ".tif");
  }
}

// Set backgound
void setBackground() {
  background(0);
}

//// Create a random palette
//void Palette() {
//  int hue = round(random(360));
//  int r1  = round(random(180));
//  colors[0] = color(hue - (r1*2), round(random(100)), round(random(100)));
//  colors[1] = color(hue - r1, round(random(100)), round(random(100)));
//  colors[2] = color(hue, round(random(100)), round(random(100)));
//  colors[3] = color(hue + r1, round(random(100)), round(random(100)));
//  colors[4] = color(hue + (r1*2), round(random(100)), round(random(100)));
//}

// Curated color palettes
color[][] myPalettes = {
  {#E63946, #f1faee, #a8dadc, #457b9d, #1d3557},
  {#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  {#264653, #2a9d8f, #e9c46a, #f4a261, #e76f51},
  {#001219, #005f73, #0a9396, #94d2bd, #e9d8a6, #ee9b00, #ca6702, #bb3e03, #ae2012, #9b2226},
  {#f8f9fa, #e9ecef, #dee2e6, #ced4da, #adb5bd, #6c757d, #495057, #343a40, #212529, #212529},
  {#ff0000, #ff8700, #ffd300, #deff0a, #a1ff0a, #0aff99, #0aefff, #147df5, #580aff, #be0aff} //rainbow
};
