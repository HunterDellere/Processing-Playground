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

    this.pack();
  }

  void pack() {
    int maxIter = 500 + agents.size();
    for (Agent agent : agents) {
      initialMass = mass;
      float otherX1 = agent.pos.x - agent.initialMass/2;
      float otherX2 = agent.pos.x + agent.initialMass/2;
      float otherY1 = agent.pos.y - agent.initialMass/2;
      float otherY2 = agent.pos.y + agent.initialMass/2;

      for (int i =0; i < maxIter; i++) {


        float thisX1 = pos.x - mass/2;
        float thisX2 = pos.x + mass/2;

        float thisY1 = pos.y - mass/2;
        float thisY2 = pos.y + mass/2;


        if (thisX1 > otherX2 || thisX2 < otherX1 || thisY1 > otherY2 || thisY2 < otherY1) {
          i=maxIter; // if the agents are proved not touching, set index to end.
        } else {
          mass -= (initialMass * 0.02); // decrease agent's mass if it can't be proven to be not touching
          life -= life * 0.03;
          //pos.x = random(initialMass, mW * 2 - initialMass);
          //pos.y = random(initialMass, mH * 2 - initialMass);
        }

        if (i == maxIter && mass != initialMass || mass < 5) {
          life = 0;
          mass = 0;
          initialMass = 0;
        }
      }
    }
  }

  void run(PGraphics r) {
    //this.follow();
    this.update();
    //this.edges();
    if (life>=1) {
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
    r.rectMode(CENTER);
    if (life == 100) {
      r.fill(0);
      r.rect(pos.x, pos.y, initialMass, initialMass);
    }
    r.strokeWeight(2);
    r.stroke(colors[ceil(abs(pow(sin(mass*life/initialMass), 2)) * (colors.length-1))]);
    r.fill(colors[ceil(abs(pow(sin(mass*life), 3)) * (colors.length-1))]);
    r.noFill();
    //r.noStroke();
    r.rect(pos.x, pos.y, mass-20, mass-20);
  }




  // Change characteristics of the agent life their influence (mass) and their life span.
  void age() {
    if (life > 1) {
      life -= 1;//.5; //0.0001 + mass % 0.05;
      mass = initialMass * (life/100);
    } else {
      mass = 0;
      life = 0;
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
    PVector centerForce = new PVector(pos.x-mW, pos.y-mH).setMag(pow(dist(pos.x, pos.y, mW, mH), 10));
    //centerForce.rotate(PI / 4);
    float dampen = pow(3, 1);
    PVector force = PVector.fromAngle(noise(vel.x/dampen, vel.y/dampen, counter/dampen) * maxNoiseAngle);
    force.setMag(initialMass/10);
    force.sub(centerForce); // bring to center
    this.applyForce(centerForce);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (life <= 0.1) {
      return true;
    } else {
      return false;
    }
  }
}
