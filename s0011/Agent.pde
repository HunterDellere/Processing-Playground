class Agent {
  PVector pos, vel, acc;
  PVector initPos, prevPos;
  float mass, life;
  float prevMass, initialMass;
  color[] colors;
  boolean active; // is the agent being drawn

  float h, s, b; // colors

  Agent(float x, float y, float l, float m, color[] c) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    initPos = pos.copy();
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
    vel.limit(3);
    acc.mult(0);
  }

  void display(PGraphics r) {
    float rad = mass; // radius
    PVector noiseV = PVector.fromAngle(noise(life/1000, life/1000, mass/1000) * maxNoiseAngle).setMag(2);
    float offset = noiseV.heading()%TAU; //vel.heading()
    float step = TWO_PI/fidelity;


    // Create the body of a shape by iterating over 2pi based on the fidelity parameter.
    // 3 - 10 can be used for most shapes
    // 10+ will increase the fidelity of the circle
    if (life > 10) {
      r.beginShape(TRIANGLES);
      r.strokeWeight(mW * 0.4 / mass);
      r.stroke(colors[(int)map(mass, 0, initialMass, 0, colors.length-1)]);
      r.fill(colors[(int)map(life, 0, life, 0, colors.length-1)]);
      //r.noFill();
      for (int i = 0; i <= fidelity; i++) {
        r.vertex(pos.x + mass * cos(step*i+offset), pos.y + mass * sin(step*i+offset));
      }
      r.endShape();
    }
  }




  // Change characteristics of the agent life their influence (mass) and their life span.
  void age() {
    if (life > 0) {
      prevMass = mass;
      mass = initialMass * sin(life/100) * sin(life/100);
      life -= (life * 0.8)/mass;
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
    PVector centerForce = new PVector(pos.x-mW, pos.y-mH).setMag(pow(dist(pos.x, pos.y, mW, mH), 0.8));
    //centerForce.rotate(PI / 4);
    float dampen = pow(3, 6);
    PVector force = PVector.fromAngle(noise(pos.x/dampen, pos.y/dampen, counter/dampen) * maxNoiseAngle).setMag(life/2);
    //force.setMag(initialMass/100);
    force.sub(centerForce); // bring to center
    this.applyForce(centerForce);
  }
}
