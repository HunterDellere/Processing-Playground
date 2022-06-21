import nice.palettes.*;

PGraphics _render;

int printWidth = 10;
int printHeight = 10;
int printDpi = 300;
int previewDpi = 72;

boolean renderHighRes = true;
boolean firstFrame = true;

int renderWidth;
int renderHeight;

float scaleFactor = 1;

int seed = (int)random(99999999);

ArrayList <PVector> vectors = new ArrayList();
ArrayList<Particle> particles = new ArrayList<Particle>();
color colors[] = new color[5];

////Params
float angle = TWO_PI;
int segments = (int)random(1000, 10000);
//int count = floor(random(3, 5));
float life;

////Palette

void setup() {
  size(1024, 1024, P2D);
  colorMode(HSB, 360, 100, 100);
  doReset();
}

void createPalette() {
  int hue = round(random(360));
  int r1  = round(random(180));
  colors[0] = color(hue - (r1*2), round(random(100)), round(random(100)));
  colors[1] = color(hue - r1, round(random(100)), round(random(100)));
  colors[2] = color(hue, round(random(100)), round(random(100)));
  colors[3] = color(hue + r1, round(random(100)), round(random(100)));
  colors[4] = color(hue + (r1*2), round(random(100)), round(random(100)));
}

void doReset() {
  particles.clear();
  clear();
  int dpi = renderHighRes ? printDpi : previewDpi;
  scaleFactor = dpi / (float)previewDpi;
  renderWidth = printWidth * dpi;
  renderHeight = printHeight * dpi;

  _render = createGraphics(renderWidth, renderHeight, P2D);
  createPalette();
  firstFrame = true;

  randomSeed(seed);
  for (float a = 0; a < angle; a += angle / segments) {
    float deltaX = renderWidth/4; //renderWidth / 1.1*random(0, random(0, 1));
    float deltaY = renderHeight/4; //renderWidth / 1.1*random(0, random(0, 1));
    float x = renderWidth/2 + renderWidth/5*cos(a) * abs(noise(cos(a), sin(a)) % 1);
    float y = renderHeight/2 + renderHeight/5*sin(a) * abs(noise(cos(a), sin(a)) % 1);
    float mass = random(renderWidth/20, renderWidth/15);
    float life = random(70, 100);
    particles.add(new Particle(x, y, mass, life, colors[floor(random(colors.length))]));
  }

  redraw();
}

void keyPressed() {
  switch (key) {
  case 's':
    String dateString = String.format("outputs/%d-%02d-%02d %02d.%02d.%02d", year(), month(), day(), hour(), minute(), second());
    //saveFrame(dateString + ".scr.png");
    _render.save(dateString + ".TIFF");
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
  _render.beginDraw();

  if (firstFrame) {
    firstFrame = false;
    _render.background(random(200,250));
  }

  magic(_render);
  _render.endDraw();

  int outWidth, outHeight;

  float ratio = renderWidth / (float)renderHeight;
  if (ratio > 1) {
    outWidth = 1024;
    outHeight = (int)(outWidth / ratio);
  } else {
    outHeight = 1024;
    outWidth = (int)(outHeight * ratio);
  }

  image(_render, (1024 - outWidth) / 2, (1024 - outHeight) / 2, outWidth, outHeight);
}

void magic(PGraphics r) {
  //background(0,.001);
  push();
  for (Particle particle : particles) {
    particle.run(r);
  }
  pop();
}
