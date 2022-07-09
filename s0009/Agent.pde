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
    vel = new PVector(0, 0); //PVector.fromAngle(noise(pos.x, pos.y)).setMag(random(5));//PVector.fromAngle(noise(pos.x, pos.y)).rotate(PI/2).setMag(randomGaussian() * 5);
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
    //this.edges();
    if (life>0) {
      this.display(r);
    }
  }

  void update() {
    this.age();
    prevPos = pos.copy();
    pos.add(vel);
    vel.add(acc);
    vel.limit(5);
    acc.mult(0);
  }

  void display(PGraphics r) {
    push();
    float rad = mass; // radius
    PVector noiseV = PVector.fromAngle(noise(vel.x, vel.y, counter/mass) * maxNoiseAngle).setMag(2);
    float step = TWO_PI/fidelity;

    float offset = pow(sin(initialMass/mass/200), 3)%TAU; //vel.heading()

    // Create the body of a shape by iterating over 2pi based on the fidelity parameter.
    // 3 - 10 can be used for most shapes
    // 10+ will increase the fidelity of the circle
    if (life > 3) {
      r.beginShape(LINES);
      r.strokeWeight(mass/1000);
      r.stroke(colors[(int)map(mass, 0, initialMass, 0, colors.length)]);
      r.fill(colors[(int)map(life, 0, 100, 0, colors.length)]);
      for (int i = 0; i <= fidelity; i++) {
        r.vertex(pos.x + mass * cos(step*i+offset), pos.y + mass * sin(step*i+offset));
      }
      r.endShape();
    }

    // Draw end caps
    //if (life>5) {
    //  active = !active;
    //  this.drawEndCap(r);
    //}

    // Create a stoke at each point of the shape
    if (life > 4) {
      r.stroke(colors[(int)map(mass, 0, initialMass, 0, colors.length-1)]);
      r.strokeWeight(map(mass, 0, initialMass, 0, initialMass % 20));
      r.noFill();

      for (int i = 0; i < fidelity; i++) {
        r.point(pos.x + rad * cos(step * i + offset ), pos.y + rad * sin(step * i + offset));
        //prevPos = pos.copy();
        //if (step * i > 4 * TWO_PI) {
        //  r.line(pos.x, pos.y, pos.x + prevMass/2 * cos(step * (i-1)), pos.y + prevMass/2 * sin(step * (i-1)));
        //}
      }
    }

    // Add crosshatching or other pattern style
    //if (life>1) {
    //  this.drawCrosshatch(r);
    //}
    pop();
  }

  // Draw an end cap on shapes
  void drawEndCap(PGraphics r) {
    float capRad = prevMass * .95; // radius for the start & end cap
    float offset = vel.heading();
    float step = TWO_PI/fidelity;
    r.stroke(colors[(int)map(mass, 0, initialMass, 0, colors.length)]);
    r.strokeWeight(map(mass, 0, initialMass/2, 1, 10));
    r.noFill();

    r.beginShape();

    for (int i = 0; i < fidelity; i++) {
      r.vertex(pos.x, pos.y);
      r.vertex(pos.x + capRad * cos(step * i) + offset, pos.y + capRad * sin(step * i) + offset);
    }
    r.endShape();
  }

  void drawCrosshatch(PGraphics r) {
    float rad = mass;
    float capRad = prevMass; // radius for the start & end cap
    float offset = vel.heading() + cos(life/100);

    r.stroke(colors[(int)map(mass, 0, initialMass, 0, colors.length)]);
    r.strokeWeight(map(mass, 0, initialMass/2, 1, 10));
    r.noFill();

    //r.noFill();
    //r.stroke(colors[(int)map(mass, 0, initialMass, 0, colors.length*2+3)%colors.length]);
    //r.strokeWeight(map(mass, 0, initialMass, 0, 5));
    // Add an end cap to the segment
    float step = TWO_PI/fidelity;
    float scl = map(offset, 0, 100, 1, 10);

    r.beginShape(POINTS);

    for (int i = 0; i < (fidelity); i++) {
      if ((i*fidelity)%3 == 0) {
        r.vertex(pos.x + rad * cos(step * scl * i ), pos.y + rad * sin(step * scl * i));
        //r.vertex(pos.x, pos.y);
        r.vertex(prevPos.x + capRad * cos(step * scl * (i-1)), prevPos.y + capRad * sin(step * scl * (i-1)));
      }
      if ((i*fidelity)%5 == 0) {
        //r.vertex(prevPos.x + capRad * cos(step * scl * (i-1)), prevPos.y + capRad * sin(step * scl * (i-1)));
        r.vertex(pos.x, pos.y);
        r.vertex(pos.x + rad * cos(step * scl * (i-2) ), pos.y + rad * sin(step * scl * (i-2)));
      } else {
        r.vertex(prevPos.x + capRad * cos(step * scl * (i-1)), prevPos.y + capRad * sin(step * scl * (i-1)));
        //r.vertex(pos.x + rad * cos(step * scl * i ), pos.y + rad * sin(step * scl * i));
        r.vertex(pos.x, pos.y);
      }
    }
    r.endShape();
  }


  // Change characteristics of the agent life their influence (mass) and their life span.
  void age() {
    if (life > 0) {
      prevMass = mass;
      mass = initialMass * sin(life/100) * sin(life/100);
      life -= 50/mass;
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
    PVector centerForce = new PVector(pos.x-midX, pos.y-midY).setMag(pow(dist(pos.x, pos.y, midX, midY), .9));
    //centerForce.rotate(PI / 4);
    float dampen = pow(3, 6);
    PVector force = PVector.fromAngle(noise(pos.x/dampen, pos.y/dampen, counter/dampen) * maxNoiseAngle);
    force.setMag(initialMass/100);
    force.sub(centerForce); // bring to center
    this.applyForce(force);
  }
}
