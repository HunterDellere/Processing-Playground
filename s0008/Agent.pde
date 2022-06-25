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
    vel.limit(1.5);
    acc.mult(0);
  }

  void display(PGraphics r) {
    float rad = mass/2;
    r.stroke(0);
    r.strokeWeight(.01);
    //r.strokeJoin(MITER);

    //r.circle(pos.x, pos.y, rad);
    //r.rect(pos.x, pos.y, vel.x, vel.y);
    //r.line(pos.x, pos.y, pos.x + vel.x, pos.y + vel.y);

    float offset = vel.heading();

    r.beginShape();
    r.fill(_color);
    r.noStroke();
    for (int i = 0; i < fidelity; i++) {
      if (life > 30 && life < 75) {
        float step = TWO_PI/fidelity;
        r.vertex(pos.x + rad * cos(step * i + offset ), pos.y + rad * sin(step * i + offset));
      }
    }
    r.endShape(CLOSE);

//    r.beginShape();
//    for (int i = 0; i < fidelity / 3; i++) {
//      if (life > 40 && life < 60) {
//        float step = TWO_PI/fidelity;
//        r.circle(pos.x + rad * cos(step * i + offset ), pos.y + rad * sin(step * i + offset), 1);
//        prevPos = pos.copy();
//      }
//    }
//    r.endShape();

    //// Box
    //r.vertex(pos.x - rad, pos.y - rad);
    //r.vertex(pos.x + rad, pos.y - rad);
    //r.vertex(pos.x + rad, pos.y + rad);
    //r.vertex(pos.x - rad, pos.y + rad);
    ////r.vertex(pos.x, pos.y);
  }


  void age() {
    if (life > 0) {
      mass = m1 * life/100;
      life -= 0.05;
    } else {
      mass = 0;
    }
  }

  void applyForce(PVector force) {
    force.div(mass);
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
    float dampen = pow(2, 8);
    PVector force = PVector.fromAngle(noise(pos.x/dampen, pos.y/dampen, counter/dampen) * maxNoiseAngle);
    //PVector force = new PVector(0,0);
    force.setMag(1);
    this.applyForce(force);
  }
}
