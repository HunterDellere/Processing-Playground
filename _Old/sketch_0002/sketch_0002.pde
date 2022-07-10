import processing.javafx.*;

PGraphics render;

boolean renderHighRes = false;
boolean firstFrame = true;

int printWidth = 10;
int printHeight = 10;
int printDpi = 300;
int previewDpi = 72;

int renderWidth;
int renderHeight;

float scaleFactor;

int seed = (int)random(99999999);

// PARAMETERS
float _maxForce = .2; // Maximum steering force
float _maxSpeed = 5; // Maximum speed
float _desiredSeparation = random(10,20);
float _separationCohesionRation = 1.1;
float _maxEdgeLen = random(5,20);

DifferentialLine _diff_line;

void setup() {
  size(1024, 1024, P2D);
  doReset();
}

void doReset() {
  int dpi = renderHighRes ? printDpi : previewDpi;
  scaleFactor = dpi / (float)previewDpi;
  renderWidth = printWidth * dpi;
  renderHeight = printHeight * dpi;

  render = createGraphics(renderWidth, renderHeight, P2D);
  firstFrame = true;
  randomSeed(seed);

  _diff_line = new DifferentialLine(_maxForce, _maxSpeed, _desiredSeparation, _separationCohesionRation, _maxEdgeLen);

  float nodesStart = random(1,30);
  float angInc = TWO_PI/nodesStart;
  //float rayStart = random(0,10);
  for (float a=0; a<TWO_PI; a+=angInc) {
    float x = random(renderWidth/8, renderWidth*7/8);// + cos(a) * rayStart;
    float y = random(renderHeight/8, renderHeight*7/8);// + sin(a) * rayStart;
    _diff_line.addNode(new Node(x, y, _diff_line.maxForce, _diff_line.maxSpeed));
  }
}

void keyPressed() {
  switch (key) {
  case 's':
    String dateString = String.format("outputs/%d-%02d-%02d %02d.%02d.%02d", year(), month(), day(), hour(), minute(), second());
    render.background(0);
    //saveFrame(dateString + ".scr.png");
    render.save(dateString + ".TIFF");
    break;

  case 'r':
    seed = (int)System.currentTimeMillis();
    println(seed);
    doReset();
    break;

  case 'h':
    renderHighRes = !renderHighRes;
    println(renderHighRes ? "High Resolution" : "Low Resolution");
    doReset();
    break;

  case 'f':
    println(frameRate);
    break;
  }
}

void draw() {
  render.beginDraw();

  if (firstFrame) {
    firstFrame = false;
    render.background(0);
  }

  magic(render);
  render.endDraw();

  int outWidth, outHeight;

  float ratio = renderWidth / (float)renderHeight;
  if (ratio > 1) {
    outWidth = 1024;
    outHeight = (int)(outWidth / ratio);
  } else {
    outHeight = 1024;
    outWidth = (int)(outHeight * ratio);
  }

  image(render, (1024 - outWidth) / 2, (1024 - outHeight) / 2, outWidth, outHeight);
}

void magic(PGraphics r) {
  r.background(0, 5, 10);
  r.stroke(255, 250, 220);

  _diff_line.run();
  _diff_line.renderLine(r);
}

class DifferentialLine {
  ArrayList<Node> nodes;
  float maxForce;
  float maxSpeed;
  float desiredSeparation;
  float sq_desiredSeparation;
  float separationCohesionRation;
  float maxEdgeLen;
  DifferentialLine(float mF, float mS, float dS, float sCr, float eL) {
    nodes = new ArrayList<Node>();
    maxForce = mF;
    maxSpeed = mS;
    desiredSeparation = dS;
    sq_desiredSeparation = sq(desiredSeparation);
    separationCohesionRation = sCr;
    maxEdgeLen = eL;
  }
  void addNode(Node n) {
    nodes.add(n);
  }
  void addNodeAt(Node n, int index) {
    nodes.add(index, n);
  }
  void run() {
    differentiate();
    growth();
  }
  void growth() {
    for (int i=0; i<nodes.size()-1; i++) {
      Node n1 = nodes.get(i);
      Node n2 = nodes.get(i+1);
      float d = PVector.dist(n1.position, n2.position) + noise(n1.position.x, n1.position.y);
      if (d>maxEdgeLen) { // Can add more rules for inserting nodes
        int index = nodes.indexOf(n2);
        PVector middleNode = PVector.add(n1.position, n2.position).div(2);
        addNodeAt(new Node(middleNode.x, middleNode.y, maxForce, maxSpeed), index);
      }
    }
  }
  void differentiate() {
    PVector[] separationForces = getSeparationForces();
    PVector[] cohesionForces = getEdgeCohesionForces();
    for (int i=0; i<nodes.size(); i++) {
      PVector separation = separationForces[i];
      PVector cohesion = cohesionForces[i];
      separation.mult(separationCohesionRation);
      nodes.get(i).applyForce(separation);
      nodes.get(i).applyForce(cohesion);
      nodes.get(i).update();
    }
  }
  PVector[] getSeparationForces() {
    int n = nodes.size();
    PVector[] separateForces=new PVector[n];
    int[] nearNodes = new int[n];
    Node nodei;
    Node nodej;
    for (int i=0; i<n; i++) {
      separateForces[i]=new PVector();
    }
    for (int i=0; i<n; i++) {
      nodei=nodes.get(i);
      for (int j=i+1; j<n; j++) {
        nodej=nodes.get(j);
        PVector forceij = getSeparationForce(nodei, nodej);
        if (forceij.mag()>0) {
          separateForces[i].add(forceij);
          separateForces[j].sub(forceij);
          nearNodes[i]++;
          nearNodes[j]++;
        }
      }
      if (nearNodes[i]>0) {
        separateForces[i].div((float)nearNodes[i]);
      }
      if (separateForces[i].mag() >0) {
        separateForces[i].setMag(maxSpeed);
        separateForces[i].sub(nodes.get(i).velocity);
        separateForces[i].limit(maxForce);
      }
    }
    return separateForces;
  }
  PVector getSeparationForce(Node n1, Node n2) {
    PVector steer = new PVector(0, 0);
    float sq_d = sq(n2.position.x-n1.position.x)+sq(n2.position.y-n1.position.y);
    if (sq_d>0 && sq_d<sq_desiredSeparation) {
      PVector diff = PVector.sub(n1.position, n2.position);
      diff.normalize();
      diff.div(sqrt(sq_d)); //Weight by distacne
      steer.add(diff);
    }
    return steer;
  }
  PVector[] getEdgeCohesionForces() {
    int n = nodes.size();
    PVector[] cohesionForces=new PVector[n];
    for (int i=0; i<nodes.size(); i++) {
      PVector sum = new PVector(0, 0);
      if (i!=0 && i!=nodes.size()-1) {
        sum.add(nodes.get(i-1).position).add(nodes.get(i+1).position);
      } else if (i == 0) {
        sum.add(nodes.get(nodes.size()-1).position).add(nodes.get(i+1).position);
      } else if (i == nodes.size()-1) {
        sum.add(nodes.get(i-1).position).add(nodes.get(0).position);
      }
      sum.div(2);
      cohesionForces[i] = nodes.get(i).seek(sum);
    }
    return cohesionForces;
  }
  void renderShape() {
    beginShape();
    for (int i=0; i<nodes.size(); i++) {
      vertex(nodes.get(i).position.x, nodes.get(i).position.y);
    }
    endShape(CLOSE);
  }
  void renderLine(PGraphics r) {
    for (int i=0; i<nodes.size()-1; i++) {
      PVector p1 = nodes.get(i).position;
      PVector p2 = nodes.get(i+1).position;
      float alpha = 255;
      r.strokeWeight(4);
      r.stroke(p1.x/renderWidth/2*255, p2.x/renderWidth/2*255, p2.y/renderHeight*255, map(alpha, 0, 255, 0, renderWidth));
      r.line(p1.x, p1.y, p2.x, p2.y);
      //if (i==nodes.size()-2) {
      //  r.line(p2.x, p2.y, nodes.get(0).position.x, nodes.get(0).position.y);
      //}
    }
  }
}

class Node {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float maxForce;
  float maxSpeed;
  Node(float x, float y, float mF, float mS) {
    acceleration = new PVector(0, 0);
    velocity =PVector.random2D();
    position = new PVector(x, y);
    maxSpeed = mF;
    maxForce = mS;
  }
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  void update() {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    acceleration.mult(0);
  }
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);
    desired.setMag(maxSpeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    return steer;
  }
}
