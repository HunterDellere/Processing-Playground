class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  PVector prevPos;

  Particle() {
    pos = new PVector(random(0, renderWidth), random(0, renderHeight));
    vel = new PVector(random(-.001, .001), random(-.001, .001));
    acc = new PVector(0, 0);
    prevPos = pos.copy();
  }

  void update() {
    vel.add(acc).limit(.05);
    pos.add(vel);
    acc.mult(0);
  }

  void applyForce(PVector force) {
    acc.add(force).limit(.001);
  }

  void display(PGraphics ren, int x, int y, int rad, float r, float g, float b, float alpha) {
    ren.stroke(r, g, b, alpha);
    ren.strokeWeight(alpha%(scl/2));
    if (dist(x, y, pos.x, pos.y) < rad) {
      ren.line(pos.x, pos.y, prevPos.x, prevPos.y);
    }
    this.updatePrev();
    //circle(pos.x, pos.y, 5);
  }

  void updatePrev() {
    prevPos.x = pos.x;
    prevPos.y = pos.y;
  }

  void edges() {
    if (pos.x > renderWidth) {
      pos.x = 0;
      this.updatePrev();
    }
    if (pos.x < 0) {
      pos.x = renderWidth;
      this.updatePrev();
    }
    if (pos.y > renderHeight) {
      pos.y = 0;
      this.updatePrev();
    }
    if (pos.y < 0) {
      pos.y = renderHeight;
      this.updatePrev();
    }
  }

  void follow(ArrayList<PVector> vectors) {
    int x = floor(pos.x / scl);
    int y = floor(pos.y / scl);
    index = floor(x + y * cols);
    PVector force = vectors.get(index);
    //PVector force = new PVector(0,0);
    force.setMag(.00005);
    this.applyForce(force);
  }
}
