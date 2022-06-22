class Node {
  PVector pos;
  PVector vel;
  PVector acc;
  PVector prevPos;
  float mass, life, m1;
  color _color;

  float h, s, b; // colors

  Node(float x, float y, float z, float l, float m, color c) {
    pos = new PVector(x, y, z);
    vel = new PVector(0, 0, 0);
    acc = new PVector(0, 0, 0);
    prevPos = pos.copy();
    life = l;
    mass = m;
    m1 = mass;
    _color = c;
  }

  void run(PGraphics r) {
    //this.follow();
    this.update();
    this.edges();
    this.display(r);
  }

  void update() {
    this.age();
    pos.add(vel);
    vel.add(acc);
    vel.limit(mass/2);
    acc.mult(0);
  }

  void display(PGraphics r) {
    //float alpha = alpha(_color);
    //println(hex(_color));
    //r.fill(_color);
    //r.strokeWeight(20);
    //r.circle(pos.x, pos.y, mass);
    
    //int phase = (int)map(life, 0, 100, 0, 100);
    
    //println(hex(_color, 6));
    //println(hex(phase).substring(6, 8));
    //_color = unhex(hex(_color, 6) + hex(phase).substring(6, 8));
    //println(hex(_color));
    //println();
    r.noStroke();
    r.fill(_color);
    //r.strokeWeight(20);
    r.rect(pos.x, pos.y, mass, life);
  }

  void age() {
    if (life > 0) {
      float dampen = pow(3, 2);
      float resolve = pow(3, 5);
      //rotateZ(life);
      mass -= 0;
      life -= 1/resolve;
    } else {
      mass = 0;
    }
  }

  void applyForce(PVector force) {
    acc.add(force.div(mass/2));
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
    float dampen = pow(2, 3);
    PVector force = PVector.fromAngle(noise(pos.x/dampen, pos.y/dampen) * TWO_PI * random(0, 3));
    //PVector force = new PVector(0,0);
    force.setMag(20);//sin(life)*sin(life));
    force.rotate(centerForce.rotate(-PI/4).heading());
    this.applyForce(force);
  }
}
