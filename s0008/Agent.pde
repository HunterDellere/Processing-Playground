class Agent {
  PVector pos, vel, acc;
  PVector prevPos;
  float mass, life;
  float prevMass, initialMass;
  color[] colors;
  boolean active; // is the agent being drawn

  float h, s, b; // colors

  Agent(float x, float y, float l, float m, color[] c) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    prevPos = pos.copy();
    colors = c;
    life = l;
    mass = m;
    initialMass = mass;

    active = true;
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
    vel.limit(1);
    acc.mult(0);
  }

  void display(PGraphics r) {
    float rad = mass; // radius
    PVector noiseV = PVector.fromAngle(noise(vel.x, vel.y, counter/mass) * maxNoiseAngle).setMag(2);

    float offset = vel.heading() + life/100;

    // Create the body of a shape by iterating over 2pi based on the fidelity parameter.
    // 3 - 10 can be used for most shapes
    // 10+ will increase the fidelity of the circle
    r.noStroke();
    r.fill(colors[(int)map(mass, 0, initialMass, 0, colors.length)%colors.length]);
    r.beginShape();
    for (int i = 0; i <= fidelity; i++) {
      if (life > 5 && life < 95 && life % 30 < 10) {
        float step = TWO_PI/fidelity;
        r.vertex(pos.x + mass * cos(step*i) + offset, pos.y + mass * sin(step*i) + offset);
      }
    }
    r.endShape(CLOSE);

    // Draw end caps
    r.beginShape();
    if (!active && life < 95 || !active && life == 0) {
      active = !active;
      this.drawEndCap(r);
    }
    r.endShape(CLOSE);

    // Create a stoke at each point of the shape
    r.stroke(colors[(int)map(mass, 0, initialMass, 0, colors.length*2+1)%colors.length]);
    r.strokeWeight(map(mass, 0, initialMass, 0, initialMass % 50));
    r.beginShape(POINTS);
    for (int i = 0; i < fidelity + 1; i++) {
      float step = TWO_PI/fidelity;
      if (life > 4 && life < 95 && life % 30 < 10) {
        r.point(pos.x + rad * cos(step * i + offset ), pos.y + rad * sin(step * i + offset));
        //prevPos = pos.copy();
      }
      if (step * i > 4 * TWO_PI) {
        //r.beginContour();
        r.vertex(pos.x, pos.y);
        r.vertex(pos.x + prevMass/2 * cos(step * (i-1)), pos.y + prevMass/2 * sin(step * (i-1)));
        //r.endContour();
      }
    }
    r.endShape();

    // Add crosshatching or other pattern style
    r.beginShape();
    r.stroke(colors[(int)map(mass, 0, initialMass, 0, colors.length)%colors.length]);
    r.strokeWeight(map(mass, 0, initialMass, 1, 50));
    r.noFill();
    if (life <85 && life > 10 && life % 20 < 15) {
      this.drawCrosshatch(r);
      println("test");
    }
    r.endShape();
  }

  // Draw an end cap on shapes
  void drawEndCap(PGraphics r) {
    float capRad = prevMass/2; // radius for the start & end cap
    float offset = vel.heading() + life/100;

    // Add an end cap to the segment
    float step = TWO_PI/fidelity;
    for (int i = 0; i < fidelity+1; i++) {
      r.vertex(pos.x, pos.y);
      r.vertex(pos.x + capRad * cos(step * i) + offset, pos.y + capRad * sin(step * i) + offset);
    }
  }

  void drawCrosshatch(PGraphics r) {
    float rad = mass;
    float capRad = prevMass; // radius for the start & end cap
    float offset = vel.heading() + life/100;

    //r.noFill();
    //r.stroke(colors[(int)map(mass, 0, initialMass, 0, colors.length*2+3)%colors.length]);
    //r.strokeWeight(map(mass, 0, initialMass, 0, 5));
    // Add an end cap to the segment
    float step = TWO_PI/fidelity;
    float scl = map(offset, 0, 100, 1, 10);

    for (int i = 0; i < (fidelity+1); i++) {
      if (i%2 == 0) {
        r.point(pos.x + rad * cos(step * scl * i ), pos.y + rad * sin(step * scl * i));
        //r.vertex(pos.x, pos.y);
        r.point(prevPos.x + capRad * cos(step * scl * (i-1)), prevPos.y + capRad * sin(step * scl * (i-1)));
      }
      if (i%5 == 0) {
        //r.vertex(prevPos.x + capRad * cos(step * scl * (i-1)), prevPos.y + capRad * sin(step * scl * (i-1)));
        r.point(pos.x, pos.y);
        r.point(pos.x + rad * cos(step * scl * (i-2) ), pos.y + rad * sin(step * scl * (i-2)));
      } else {
        r.point(prevPos.x + capRad * cos(step * scl * (i-1)), prevPos.y + capRad * sin(step * scl * (i-1)));
        //r.vertex(pos.x + rad * cos(step * scl * i ), pos.y + rad * sin(step * scl * i));
        r.point(pos.x, pos.y);
      }
    }
  }


  // Change characteristics of the agent life their influence (mass) and their life span.
  void age() {
    if (life > 0) {
      prevMass = mass;
      mass = initialMass * sin(life/100) * sin(life/100);
      life -= 0.055;
    } else {
      mass = 0;
    }
  }

  // Apply force to the agent.
  void applyForce(PVector force) {
    force.div(mass);
    acc.add(force);
  }

  // Store previous values for next iteration
  void updatePrev() {
    prevPos.x = pos.x;
    prevPos.y = pos.y;
    prevMass = mass;
  }

  // Check for an edge of the render space
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

  // Control and apply a force to the agent
  void follow() {
    noiseDetail(1); // # of octaves for the Perlin noise which correlate to character & detail.
    float midX = renderWidth / 2;
    float midY = renderHeight / 2;
    PVector centerForce = new PVector(pos.x-midX, pos.y-midY).mult(mass / pow(dist(pos.x, pos.y, midX, midY),2));
    float dampen = pow(3, 6);
    PVector force = PVector.fromAngle(noise(pos.x/dampen, pos.y/dampen, counter/dampen) * maxNoiseAngle);
    force.sub(centerForce); // bring to center
    force.setMag(.1);
    this.applyForce(force);
  }
}
