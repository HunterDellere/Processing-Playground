class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  
  Particle() {
    pos = new PVector(random(0, width), random(0, height));
    vel = new PVector(0,0);
    acc = new PVector(0,0);
  }
  
  void update() {
    vel.add(acc).limit(.1);
    pos.add(vel);
    acc.mult(0);
  }
  
  void applyForce(PVector force) {
    acc.add(force);
  }
  
  void display() {
    stroke(0);
    fill(0);
    circle(pos.x, pos.y, 5);
  }
  
  void edges() {
    if (pos.x > width) pos.x = 0;
    if (pos.x < 0) pos.x = width;
    if (pos.y > height) pos.y = 0;
    if (pos.y < 0) pos.y = height;
  }

  void follow(ArrayList<PVector> vectors) {
    int x = floor(pos.x / scl);
    int y = floor(pos.y / scl);
    index = floor(x + y * cols);
    PVector force = vectors.get(index);
    //PVector force = new PVector(0,0);
    force.setMag(.0001);
    this.applyForce(force);
  }
    
}
