//PImage sketch;
//PVector v;
//ArrayList<Particle> particles = new ArrayList<Particle>();

//float zoff = 0; // z is used as the time domain for the Perlin noise field.

//int detail = 100; // number of particles
//float rate = 0.0003;
//float inc = 0.1; // increments of the perlin noise field. More movement with higher increments.
//int scl = 15;
//int cols = floor(width / scl);
//int rows = floor(height / scl);
////PVector flowfield[] = new PVector[cols*rows];

//void setup() {
//  size(1000, 1000);
//  //cols = floor(width / scl);
//  //rows = floor(height / scl);
//  //PVector flowfield[] = new PVector[cols*rows];

//  for (int i = 0; i < detail; i++){
//    particles.add(new Particle());
//  }
//}

//void draw() {
//  background(255);
//  float yoff = 0;
//  for (int y = 0; y < rows; y++) {
//    float xoff = 0;
//    for (int x=0; x < cols; x++) {
//      xoff += inc;
//      stroke(0, 50);
//      noiseDetail(4); // # of octaves for the Perlin noise which correlate to character & detail.
//      v = PVector.fromAngle(noise(xoff, yoff, zoff) * TWO_PI);
//      //flowfield[x + y * cols] = v;
//      push();
//      translate(x * scl, y * scl);
//      rotate(v.heading());
//      line(0, 0, scl/2, 0);
//      //circle(x * scl, y * scl, 4.0);
//      pop();
//    }
    
//  yoff += inc;
//  zoff += rate;
  
//    for (int i = 0; i < particles.size(); i++) {
//      //particles.get(i).applyForce(v);
//      particles.get(i).update();
//      particles.get(i).edges();
//      particles.get(i).display();
//    }
//  }
//  println(frameRate);
//}
