class Agent {
  PVector pos, vel, acc;
  PVector initPos, prevPos;
  float mass, life;
  float xMod, yMod;
  float prevMass, initialMass;
  float h, s, b; // colors
  color[] colors;
  float colorRange;
  float dampen, soften;

  boolean active; // is the agent being drawn

  int packCount, packAttempts;

  Agent(float x, float y, float l, float m, color[] c) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    initPos = pos.copy();
    prevPos = pos.copy();

    life = l;
    mass = m;
    initialMass = mass;

    packCount = 0;
    packAttempts = 1000; // don't push this too hard
    this.pack();

    xMod = random(.5, 1.5);
    yMod = random(.5, 1.5);
    dampen = random(0.000001, 0.000005);
    soften = random(0.00001, 0.00005);


    colors = c;
    colorRange = abs(initialMass % 5);


    active = true;
  }

  void pack() {
    int maxIter = maxAgents;
    for (Agent agent : agents) {
      initialMass = mass;

      /*
      Everything here is with the agent position as the center point for reference.
       Shapes are drawn from center with width and height equalling mass
       */
      float otherX1 = agent.pos.x - agent.initialMass/2;
      float otherX2 = agent.pos.x + agent.initialMass/2;
      float otherY1 = agent.pos.y - agent.initialMass/2;
      float otherY2 = agent.pos.y + agent.initialMass/2;

      for (int i =0; i < maxIter; i++) {


        float thisX1 = pos.x - xMod*mass/2;
        float thisX2 = pos.x + xMod*mass/2;

        float thisY1 = pos.y - yMod*mass/2;
        float thisY2 = pos.y + yMod*mass/2;


        if (thisX1 > otherX2 || thisX2 < otherX1 || thisY1 > otherY2 || thisY2 < otherY1) {
          i=maxIter; // if the agents are proved not touching, set index to end.
        } else {
          mass = mass * 0.9;
          //mass = initialMass * (maxIter-i);//mass * 0.5; // decrease agent's mass if it can't be proven to be not touching
          life -= life * 0.03;
          //pos.x = random(initialMass, mW * 2 - initialMass);
          //pos.y = random(initialMass, mH * 2 - initialMass);
        }

        if (i == maxIter && mass != initialMass || mass < 10) {
          //add recursion to select new x & y and recall pack()
          if (packCount < packAttempts) {
            life = 100;
            mass = random(20, scl/2);
            pos = new PVector(abs(randomGaussian() * (mW * 2 - mass)), abs(randomGaussian() * (mW * 2 - mass)));

            //initialMass = mass;
            packCount++;
            pack();
          } else {
            life = 0;
            mass = 0;
            initialMass = 0;
          }
        }
      }
    }
  }

  void run(PGraphics r) {
    //this.follow();
    this.update();
    //this.edges();
    this.display(r);
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
    //colorRange = abs(life/(initialMass % 20));
    //print(colorRange);
    int fillColor = ceil(lerp(1, colors.length*colorRange, 100/life))%(colors.length);
    r.rectMode(CENTER);

    //r.noFill();
    r.noStroke();

    r.beginShape();

    if (fidelity < 3) {
      r.strokeWeight(200);
      r.stroke(colors[ceil(xMod * abs(pow(sin(xMod*yMod*life/20), 2)) * (colors.length)) % (colors.length-1)]);
    }

    pushMatrix();

    r.translate(mW, mH);
    noiseDetail(1);
    r.rotate(noise(mW, mH, life*soften) * maxNoiseAngle);

    r.fill(colors[max(0, fillColor)]);
    //r.rect(pos.x, pos.y, (xMod*mass/2), (yMod*mass/2));


    for (int i = 0; i <= fidelity; i++) {
      r.vertex(pos.x + xMod*mass/2 * cos(TAU * i / fidelity), pos.y + yMod*mass/2 * sin(TAU * i / fidelity));
    }
    popMatrix();

    r.endShape();



    //r.fill(colors[fillColor]);
    //r.stroke(0);
    ////r.fill(colors[ceil(xMod * abs(pow(sin(xMod*yMod*colorRange), 2)) * (colors.length)) % (colors.length-1)]);
    //r.rect(pos.x, pos.y, (xMod*mass/2), (yMod*mass/2));
    ////r.rect(pos.x, pos.y, (xMod*mass) + mass * pow(sin(life/initialMass), 2), (yMod*mass) + mass * pow(sin(life/initialMass), 2));
  }




  // Change characteristics of the agent life their influence (mass) and their life span.
  void age() {
    if (life > 1) {
      life -= 0.2;//.5; //0.0001 + mass % 0.05;
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
