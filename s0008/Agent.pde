class Agent {
  PVector pos, vel, acc;
  PVector prevPos;
  float mass, life;
  float prevMass, initialMass;
  color _color;
  boolean active; // is the agent being drawn

  float h, s, b; // colors

  Agent(float x, float y, float l, float m, color c) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    prevPos = pos.copy();
    life = l;
    mass = m;
    initialMass = mass;
    _color = c;
    active = false;
  }

  void run(PGraphics r) {
    this.follow();
    this.update();
    this.edges();
    this.display(r);
  }

  void update() {
    this.age();
    prevPos = pos.copy();
    pos.add(vel);
    vel.add(acc);
    vel.limit(1.5);
    acc.mult(0);
  }

  void display(PGraphics r) {
    float rad = mass/2; // radius

    r.stroke(0);
    r.strokeWeight(.01);
    //r.strokeJoin(MITER);

    //r.circle(pos.x, pos.y, rad);
    //r.rect(pos.x, pos.y, vel.x, vel.y);
    //r.line(pos.x, pos.y, pos.x + vel.x, pos.y + vel.y);

    float offset = life/10; //vel.heading();

    // Create a shape by iterating over 2pi based on the fidelity parameter.
    // 3 - 10 can be used for most shapes
    // 10+ will increase the fidelity of the circle
    r.beginShape();
    r.fill(_color);
    r.noStroke();
    for (int i = 0; i <= fidelity; i++) {
      if (life > 20 && life < 45 || life > 60 && life < 95) {
        if (!active) {
          active = !active;
          this.drawEndCap(r);
        }
        float step = TWO_PI/fidelity;
        r.vertex(pos.x + rad * cos(step * i + offset ), pos.y + rad * sin(step * i + offset));
      }
    }
    r.endShape(CLOSE);

    // Create a stoke at each point of the shape
    r.beginShape();
    r.stroke(0);
    r.strokeWeight(constrain(mass*5, 0, 5));
    for (int i = 0; i < fidelity; i++) {
      if (life > 20 && life < 45 || life > 60 && life < 95) {
        float step = TWO_PI/fidelity;
        r.point(pos.x + rad * cos(step * i + offset ), pos.y + rad * sin(step * i + offset));
        //prevPos = pos.copy();
      }
    }

    // Check for end of draw & draw a cap
    if (life <=20 && life >= 19 || life <=60 && life >= 59) {
      this.drawEndCap(r);
    }
    r.endShape();
  }

  void drawEndCap(PGraphics r) {
    float capRad = prevMass/2; // radius for the start & end cap
    float offset = life/10;

    r.stroke(0);
    r.strokeWeight(constrain(mass/5, 1, 5));

    // Add an end cap to the segment
    beginShape();
    float step = TWO_PI/fidelity;
    for (int i = 0; i < fidelity; i++) {
      r.vertex(pos.x + capRad * cos(step * i + offset ), pos.y + capRad * sin(step * i + offset));
    }
    endShape(CLOSE);
  }



  void age() {
    if (life > 0) {
      prevMass = mass;
      mass = initialMass * life/150;
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
    force.setMag(.11);
    this.applyForce(force);
  }
}
