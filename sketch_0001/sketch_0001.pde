PImage sketch;

float inc = 0.1;
float scl = 20;
int cols, rows;


void setup() {
  size(1000, 1000);
  background(255);
  cols = floor(width / scl);
  rows = floor(height / scl);
}

void draw() {
  int yoff = 0;
  int xoff = 0;
  
  for (int y = 0; y < rows; y++) {
    for (int x=0; x < cols; x++) {
      float n = noise(xoff, yoff) * 255; //perlin noise at x,y
      xoff += inc;
      fill(n);
      circle(x * scl, y * scl, 4.0);
    }
   yoff += inc;
  }
  println(frameRate);
}
