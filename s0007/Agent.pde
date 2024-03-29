class Agent {
  PVector pos;
  PVector vel;
  PVector acc;
  PVector prevPos;
  float mass, life, m1;
  color _color;

  float h, s, b; // colors

  Agent(float x, float y, float l, float m, color c) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    prevPos = pos.copy();
    life = l;
    mass = m;
    m1 = mass;
    _color = c;
  }

  void run(PGraphics r) {
    this.follow();
    this.update();
    //this.edges();
    this.display(r);
  }

  void update() {
    this.age();
    pos.add(vel);
    vel.add(acc);
    vel.limit(2);
    acc.mult(0);
  }

  void display(PGraphics r) {
    float distanceFromMid = dist(pos.x, pos.y, renderWidth/2, renderHeight/2);
    if (distanceFromMid <renderHeight/2) {
      r.fill(_color);
      //r.noStroke();
      r.stroke(_color);
      r.strokeWeight(mass);
      r.strokeJoin(MITER);

      //r.circle(pos.x, pos.y, mass);
      //r.rect(pos.x, pos.y, vel.x, vel.y);
      //r.line(pos.x, pos.y, pos.x + vel.x, pos.y + vel.y);

      r.pushMatrix();
      r.beginShape();


      // Box
      r.vertex(pos.x, pos.y);
      r.vertex(pos.x + mass, pos.y);
      r.vertex(pos.x + mass, pos.y + mass);
      r.vertex(pos.x, pos.y + mass);
      //r.vertex(pos.x, pos.y);
      
      r.endShape(CLOSE);
      r.popMatrix();
    }
  }

  void age() {
    if (life > 0) {
      mass = m1 * (life/100);
      life -= 0.3;
    } else {
      mass = 0;
    }
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void updatePrev() {
    prevPos.x = pos.x;
    prevPos.y = pos.y;
  }

  void edges() {
    if (pos.x > renderWidth + mass) {
      pos.x = 0 - mass / 2;
      this.updatePrev();
    }
    if (pos.x < 0 - mass) {
      pos.x = renderWidth + mass / 2;
      this.updatePrev();
    }
    if (pos.y > renderHeight + mass) {
      pos.y = 0 - mass /2;
      this.updatePrev();
    }
    if (pos.y < 0 - mass) {
      pos.y = renderHeight + mass / 2;
      this.updatePrev();
    }
  }

  void follow() {
    noiseDetail(1); // # of octaves for the Perlin noise which correlate to character & detail.
    float midX = renderWidth / 2;
    float midY = renderHeight / 2;
    PVector centerForce = new PVector(pos.x-midX, pos.y-midY);
    float dampen = pow(2, 7);
    PVector force = PVector.fromAngle(noise(pos.x/dampen, pos.y/dampen, counter/dampen) * maxNoiseAngle);
    //PVector force = new PVector(0,0);
    force.setMag(.15);
    this.applyForce(force);
  }
}
