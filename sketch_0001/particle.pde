class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  PVector prevPos;

  Particle() {
    pos = new PVector(random(0, width), random(0, height));
    vel = new PVector(random(-.001, .001), random(-.001, .001));
    acc = new PVector(0, 0);
    prevPos = pos.copy();
  }

  void update() {
    vel.add(acc).limit(.2);
    pos.add(vel);
    acc.mult(0);
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void display() {
    stroke(230, 202, 125, 3);
    strokeWeight(1);
    line(pos.x, pos.y, prevPos.x, prevPos.y);
    this.updatePrev();
    //circle(pos.x, pos.y, 5);
  }

  void updatePrev() {
    prevPos.x = pos.x;
    prevPos.y = pos.y;
  }

  void edges() {
    if (pos.x > width) {
      pos.x = 0;
      this.updatePrev();
    }
    if (pos.x < 0) {
      pos.x = width;
      this.updatePrev();
    }
    if (pos.y > height) {
      pos.y = 0;
      this.updatePrev();
    }
    if (pos.y < 0) {
      pos.y = height;
      this.updatePrev();
    }
  }

  void follow(ArrayList<PVector> vectors) {
    int x = floor(pos.x / scl);
    int y = floor(pos.y / scl);
    index = floor(x + y * cols);
    PVector force = vectors.get(index);
    //PVector force = new PVector(0,0);
    force.setMag(.0005);
    this.applyForce(force);
  }
}
