PImage sketch;
PVector v;
ArrayList<Particle> particles = new ArrayList<Particle>();

float zoff = 0;

int detail = 500;
float rate = 0.0003;
float inc = 0.05; //increments of the perlin noise field. More movement with higher increments.
int scl = 40;
int cols, rows, index;
ArrayList<PVector> flowfield = new ArrayList<PVector>();

void setup() {
  size(1000, 1000);
  cols = floor(width / scl);
  rows = floor(height / scl);

  for (int i = 0; i < 2 * cols * rows; i++) {
    flowfield.add(i, new PVector(0, 0, 0));
    println(i);
  }

  for (int i = 0; i < detail; i++) {
    particles.add(new Particle());
  }
}

void draw() {
  background(255);
  float yoff = 0;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x=0; x < cols; x++) {
      stroke(0, 50);
      noiseDetail(2); // # of octaves for the Perlin noise which correlate to character & detail.
      v = PVector.fromAngle(noise(xoff, yoff, zoff) * TWO_PI);
      index = floor(x + y * cols);
      flowfield.set(index, v);
      xoff += inc;
      //push();
      //translate(x * scl, y * scl);
      //rotate(v.heading());
      //line(0, 0, scl/2, 0);
      ////circle(x * scl, y * scl, 4.0);
      //pop();
    }

    yoff += inc;
    zoff += rate;
    for (int i = 0; i < particles.size(); i++) {
      particles.get(i).follow(flowfield);//PVector.fromAngle(noise(xoff, yoff, zoff) * TWO_PI * 8));
      particles.get(i).update();
      particles.get(i).edges();
      particles.get(i).display();
    }
  }
  println(frameRate);
}
