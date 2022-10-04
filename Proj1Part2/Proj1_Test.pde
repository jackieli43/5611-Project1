//CSCI 5611 - Graph Search & Planning
//PRM Sample Code [Proj 1]
//Instructor: Stephen J. Guy <sjguy@umn.edu>

//This is a test harness designed to help you test & debug your PRM.

//USAGE:
// On start-up your PRM will be tested on a random scene and the results printed
// Left clicking will set a red goal, right clicking the blue start
// The arrow keys will move the circular obstacle with the heavy outline
// Pressing 'r' will randomize the obstacles and re-run the tests

//Change the below parameters to change the scenario/roadmap size
Camera camera;
ObjMesh circleMesh; //Obsticles
ObjMesh rabbitMesh; // Agent/user// active agent that moves smoothly through the path to the target Tiger, avoiding the circle obstacles

PShape square;
PVector nextNode;
PVector facingDirection;
boolean arrivedGoal = false;
boolean insideNode = false;
float t = 0.91;
boolean startGood = true;
PVector colors[] = new PVector[10]; 

//CROWD SIM, will slow down game drastically,     //UNCOMMENT FOR CROWD SIM!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
int movers = 5;


int numObstacles = 100;
int numNodes  = 300;

//A list of Sphere obstacles
static int maxNumObstacles = 1000;
PVector circlePos[] = new PVector[maxNumObstacles]; //Sphere positions

float circleRad[] = new float[maxNumObstacles];  //sphere radii

PVector startPos = new PVector(-150, -150, 0);
PVector goalPos = new PVector(150,150,0);
PVector pos = new PVector(startPos.x, startPos.y, startPos.z);
PVector vel = new PVector(0,0,0);

//Particles
int maxP= 100;
ArrayList<PVector> pPos = new ArrayList<PVector>(maxP);
ArrayList<PVector> pVel = new ArrayList<PVector>(maxP);
ArrayList<PVector> pCol = new ArrayList<PVector>(maxP);
ArrayList<Float> pLife = new ArrayList<Float>(maxP);
int numParticles = 0;

PVector startColor = new PVector(254, 240, 1);
PVector endColor = new PVector(240, 5, 5);
PVector smoke = new PVector(50, 50, 50);
float genRate = 200;
float coneRad = radians(10);
float maxLife = 0.5;



ArrayList<ObjMesh> moversMesh = new ArrayList<ObjMesh>(movers);

ArrayList<Integer> moversIndex = new ArrayList<Integer>(movers);
ArrayList<Boolean> moversInside = new ArrayList<Boolean>(movers);
ArrayList<Boolean> moversArrive = new ArrayList<Boolean>(movers);
ArrayList<PVector> moversPos = new ArrayList<PVector>(movers);
ArrayList<PVector> moversVel = new ArrayList<PVector>(movers);
ArrayList<PVector> startsTaken = new ArrayList<PVector>(movers);
ArrayList<PVector> goalsTaken = new ArrayList<PVector>(movers);


ArrayList<Integer> curPath;
ArrayList<ArrayList<Integer>> moversPath = new ArrayList<ArrayList<Integer>>();
ArrayList<SphereLoc> spheres = new ArrayList<SphereLoc>();
ArrayList<SphereLoc> PRMnodes = new ArrayList<SphereLoc>();

//PVector agentPos = startPos;
PVector currentPos = startPos;
static int maxNumNodes = 1000;
PVector[] nodePos = new PVector[maxNumNodes]; // monkeys
boolean startProgram = false;
int windowWidth = 500;
int windowHeight = 500;
int indexPath = 0;

// Maybe one monkey as the start/the user

//Generate non-colliding PRM nodes
void generateRandomNodes(int numNodes, PVector[] circleCenters, float[] circleRadii){
  for (int i = 0; i < numNodes; i++){
    //PVector randPos = new PVector(random(width),random(height), random(-10.0, 10.0) - 5.0)
    float x = random(-200,200);
    float y = random(-200,200);
    PVector randPos = new PVector(x,y,0);
    boolean insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,5);
    
    while (insideAnyCircle){
      //randPos = new PVector(random(width),random(height), random(-10.0, 10.0) - 5.0);
     x = random(-200,200);
     y = random(-200,200);
      randPos = new PVector(x,y,0);
      insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,10);
    }
    PRMnodes.add(new SphereLoc(randPos.x, randPos.y, 0, 1));
    nodePos[i] = new PVector(x,y,0);
    //System.out.println(nodePos[i]);
  }
}


int strokeWidth = 2;
void setup(){
  //size(1024,768, P3D);
  size(500, 500, P3D);
  //size(displayWidth, displayHeight, P3D);
  //fullScreen(P3D);
  
  for (int i=0; i < numObstacles; i++) {
    float x = random(-200,200);
    float y = random(-200,200);
    float r = random(5,15);
    spheres.add(new SphereLoc(x,y, 0, r));
    circlePos[i] = new PVector(x,y,0);
    circleRad[i] = r;
  }
  noStroke();
  
  camera = new Camera();
  
  testPRM();
  
}

PVector sampleFreePos(){
  //PVector randPos = new PVector(random(width),random(height), random(-10.0, 10.0) - 5.0);
    float x = random(-200,200);
    float y = random(-200,200);
    PVector randPos = new PVector(x,y,0);
    boolean insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos,20);
    
    while (insideAnyCircle){
      //randPos = new PVector(random(width),random(height), random(-10.0, 10.0) - 5.0);
     x = random(-200,200);
     y = random(-200,200);
      randPos = new PVector(x,y,0);
      insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos,20);
    }
  
  return randPos;
}
boolean temper = false;
void testPRM(){
  startProgram = false;
  generateRandomNodes(numNodes, circlePos, circleRad);
  
  startPos = sampleFreePos(); 
  goalPos = sampleFreePos();
  pos = new PVector(startPos.x, startPos.y, startPos.z);

  nextNode = goalPos;
  rabbitMesh = new ObjMesh("bunny.obj");
  rabbitMesh.position = startPos;
  rabbitMesh.scale = 20;
  
  
  for( int i = 0 ; i < numNodes; i++) {
      if (!startsTaken.contains(nodePos[i]) && startsTaken.size() < movers) {
        startsTaken.add(nodePos[i]);
      }
  }
  
  for (int i = numNodes - 1; i >= 0; i--) {
      if (!goalsTaken.contains(nodePos[i]) && goalsTaken.size() < movers) {
        goalsTaken.add(nodePos[i]);
      }
  }
  for(int i = 0; i < movers; i++) {
    moversPos.add(startsTaken.get(i));
    moversIndex.add(0);
    moversVel.add(new PVector(0,0,0));
    moversArrive.add(false);
    moversInside.add(false);
    moversMesh.add(new ObjMesh("tigre_sumatra_sketchfab.obj"));
    moversMesh.get(i).position = startsTaken.get(i);
    moversMesh.get(i).scale = 20;
  }
  
  for( int i = 0; i < maxP; i++) {
    pCol.add(new PVector());
    pVel.add(new PVector());
    pLife.add(0.0);
    pPos.add(new PVector());
  }
  
  

  connectNeighbors(circlePos, circleRad, numObstacles, nodePos, numNodes); 
  moversPath();
  
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);

}
  
  
void moversPath() {
    moversPath = new ArrayList<ArrayList<Integer>>();

   for (int i = 0; i < movers; i++) {
  
    PVector dir = PVector.sub(goalsTaken.get(i),startsTaken.get(i)).normalize();
  
    float distBetween = goalsTaken.get(i).dist(startsTaken.get(i));
    hitInfo temp4 = rayCircleListIntersect(circlePos, circleRad, numObstacles, startsTaken.get(i), dir, distBetween);
    if (!temp4.hit) {
       startGood = true;
    }
    
    if (startGood) moversPath.add(planPath(startsTaken.get(i), goalsTaken.get(i), circlePos, circleRad, numObstacles, nodePos, numNodes));
    temper = true;
  } 
}


void update() {
    float distance = pos.dist(goalPos);
    if (distance < 1 ) { 
        //System.out.println("home");
        pos = goalPos;
    }
    else {
      //System.out.println(indexPath);
      //System.out.println(curPath.size());
      if (curPath.size() == 0) {
         vel = PVector.sub(goalPos,startPos).normalize().mult(2);
         pos.add(vel);
      }
      
      else if(indexPath != curPath.size()){
        nextNode = nodePos[curPath.get(indexPath)];
        distance = pos.dist(nextNode);
        if (distance < 1 && !insideNode) {
          indexPath += 1;
          insideNode = true;
          System.out.println(3);
        }
        else {
         insideNode = false;
         vel = PVector.sub(nextNode,pos).normalize().mult(2);
         pos.add(vel);
        }
      }
      else if (indexPath + 1> curPath.size()) {
        //System.out.println("GO HOME");
         vel = PVector.sub(goalPos,pos).normalize().mult(2);
         pos.add(vel);      
       }   
    }
    if (pos == goalPos) {
      if(numParticles < maxP) {
        for (int i = 0; i < maxP; i++) {
          PVector temp = new PVector(goalPos.x,goalPos.y,goalPos.z);
          System.out.println(temp);
          pPos.set(i,temp);
          pVel.set(i,new PVector(random(-.5,.5),random(-.5,.5),random(-.5,.5)).normalize().mult(.1));
          pCol.set(i,startColor);
          numParticles ++;
        }
      }
    }
    for(int i = 0; i < numParticles; i++) {
          PVector pos1 = pPos.get(i);
          pos1.add(pVel.get(i).mult(1.1));
          pPos.set(i, pos1);
    }
    
    
    //UNCOMMENT FOR CROWD SIM!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //for (int i = 0; i < moversPath.size(); i++) {

    //  distance = moversPos.get(i).dist(goalsTaken.get(i));
    //  if (distance < 1 ) { 
    //    //System.out.println("home");
    //    moversPos.set(i,goalsTaken.get(i));
    //    moversArrive.set(i,true);
    //  }
    //  else {

    //    if (moversPath.get(i).size() == 0) {
    //       moversVel.set(i,PVector.sub(goalsTaken.get(i),startsTaken.get(i)).normalize().mult(2));
    //       moversPos.get(i).add(moversVel.get(i));
    //    }
        
    //    else if(moversIndex.get(i) != moversPath.get(i).size()){
    //      nextNode = nodePos[moversPath.get(i).get(moversIndex.get(i))];
    //      //nextNode = nodePos[curPath.get(indexPath)];
    //      distance = moversPos.get(i).dist(nextNode);
    //      if (distance < 1 && !moversInside.get(i)) {
    //        moversIndex.set(i, moversIndex.get(i) + 1);
    //        moversInside.set(i,true);
    //      }
    //      else {
    //       moversInside.set(i,false);
    //       moversVel.set(i,PVector.sub(nextNode,moversPos.get(i)).normalize().mult(2));
    //       moversPos.get(i).add(moversVel.get(i));
    //      }
    //    }
    //    else if (moversIndex.get(i) + 1 > moversPath.get(i).size()) {
    //      //System.out.println("GO HOME");
    //       moversVel.set(i,PVector.sub(goalsTaken.get(i),moversPos.get(i)).normalize().mult(2));
    //       moversPos.get(i).add(moversVel.get(i));      
    //     }   
    //  }
    //}
    
    //for (int i = 0; i < moversPath.size(); i++) {
    //  for (int j = 0; j < moversPath.size(); j++) {
    //    if (i != j) {
    //      float temp = computeTTC(moversPos.get(i), moversVel.get(i), 20, moversPos.get(j),moversVel.get(j), 20);
    //      if (temp > 0) {
    //        moversPath.set(i,planPath(moversPos.get(i),goalsTaken.get(i), circlePos, circleRad, numObstacles, nodePos, numNodes));
    //        moversVel.set(i,moversVel.get(i).div(2));
    //        moversIndex.set(i,0);
    //      }
          
    //      temp = computeTTC(pos, vel, 10, moversPos.get(j),moversVel.get(j),20);
    //      if (temp > 0) {
    //        vel = vel.div(2);
    //        curPath = planPath(pos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
    //        indexPath = 0;
    //      }
    //    } 
    //  }
    //}
    
}

float computeTTC( PVector pos1, PVector vel1, float radius1, PVector pos2, PVector vel2, float radius2) {
  float combinedRadius = radius1 + radius2;
  PVector rVel = PVector.sub(vel1,vel2);
  float ttc = rayCircleIntersectTime(pos2,combinedRadius,pos1,rVel);
  return ttc;
}

void draw(){
  if (startProgram) update();

  camera.Update(1/frameRate);
  lights();
  directionalLight(256, 256, 256, 1, 0, 0);

  //Draw the circle obstacles
  background(128);
  sphereDetail(20);
  for (SphereLoc currentSphere : spheres) {
    currentSphere.render(150);
  }
  
  //for (SphereLoc currentNodes : PRMnodes) {
  //  currentNodes.render();
  //} 
  
  //Draw graph
  //stroke(200,200,200);
  //strokeWeight(1);
  //for (int i = 0; i < numNodes; i++){
  //  for (int j : neighbors[i]){
  //    //System.out.println(nodePos[i]);
  //    line(nodePos[i].x,nodePos[i].y,0, nodePos[j].x,nodePos[j].y,0);
  //  }
  //}
  
  //Start and end spheres
  //SphereLoc start = new SphereLoc(startPos.x,startPos.y,0,5);
  //SphereLoc end = new SphereLoc(goalPos.x,goalPos.y,0,5);

  //color startColor = color(205, 14, 14);
  //color endColor = color(11, 100, 11);
  //start.render(startColor);
  //end.render(endColor);  
  
  sphereDetail(10);
  for (int i = 0; i < numParticles; i++) {
      PVector p = pPos.get(i);
      //System.out.println(p);
      PVector col = pCol.get(i);
      fill(col.x, col.y, col.z);
      pushMatrix();
          translate(p.x, p.y, p.z);
          sphere(3);
      popMatrix();
  }
  
  
  //for (PVector start : startsTaken) {
  //  SphereLoc starts = new SphereLoc(start.x,start.y,0,5);
  //  starts.render(startColor);
  //}
  
  // for (PVector goal : goalsTaken) {
  //  SphereLoc goals = new SphereLoc(goal.x,goal.y,0,5);
  //  goals.render(endColor);
  //

  rabbitMesh.drawWithTransform(pos,new PVector(90, -75, 0),5.0);
  for(int i = 0; i < moversMesh.size(); i++){
    moversMesh.get(i).drawWithTransform(moversPos.get(i),new PVector(90, -75, 0),5.0);
  }

  if (curPath.size() >0 && curPath.get(0) == -1) return; //No path found
  
  //Draw Planned Path
  //stroke(20,255,40);
  //strokeWeight(5);
  //if (curPath.size() == 0){
  //  line(startPos.x,startPos.y,goalPos.x,goalPos.y);
  //}
  //else {
  //    line(startPos.x,startPos.y,nodePos[curPath.get(0)].x,nodePos[curPath.get(0)].y);
    
  //  for (int i = 0; i < curPath.size()-1; i++){
  //    int curNode = curPath.get(i);
  //    int nextNode = curPath.get(i+1);
  //    line(nodePos[curNode].x,nodePos[curNode].y,nodePos[nextNode].x,nodePos[nextNode].y);
  //  }
  //   line(nodePos[curPath.get(curPath.size() - 1)].x,nodePos[curPath.get(curPath.size() - 1)].y,goalPos.x,goalPos.y);
  //}

  
  //if (temper) {
  //      stroke(random(24),random(200),random(50));
  //   strokeWeight(5);
  //  for(int i = 0; i < movers; i++) {
  //    if (moversPath.get(i).size() == 0) {
  //       line(startsTaken.get(i).x,startsTaken.get(i).y,goalsTaken.get(i).x,goalsTaken.get(i).y);
  //    }
  //    else {
  //        line(startsTaken.get(i).x,startsTaken.get(i).y,nodePos[moversPath.get(i).get(0)].x,nodePos[moversPath.get(i).get(0)].y);
  //        for(int j = 0; j < moversPath.get(i).size() - 1; j++) {
  //          int curNode = moversPath.get(i).get(j);
  //          int nextNode = moversPath.get(i).get(j + 1);
  //          line(nodePos[curNode].x,nodePos[curNode].y,nodePos[nextNode].x,nodePos[nextNode].y);
  //        }
  //         line(goalsTaken.get(i).x,goalsTaken.get(i).y,nodePos[moversPath.get(i).get(moversPath.get(i).size()-1)].x,nodePos[moversPath.get(i).get(moversPath.get(i).size()-1)].y);
  //    }  
  //  }
  //}
  
  

}

void checkPaths() {
    connectNeighbors(circlePos, circleRad, numObstacles, nodePos, numNodes); 
    pos = new PVector(startPos.x, startPos.y, startPos.z);
    moversPath();
    curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
}

void reset() {
  moversIndex = new ArrayList<Integer>(movers);
  moversArrive = new ArrayList<Boolean>(movers);
  moversInside = new ArrayList<Boolean>(movers);
  moversPos = new ArrayList<PVector>(movers);
  moversVel = new ArrayList<PVector>(movers);
  moversMesh = new ArrayList<ObjMesh>(movers);
  startProgram = false;
  indexPath = 0;
  PRMnodes = new ArrayList<SphereLoc>();
  temper = false;
  moversPath = new ArrayList<ArrayList<Integer>>(movers);
  startsTaken = new ArrayList<PVector>(movers);
  goalsTaken = new ArrayList<PVector>(movers);
  pPos = new ArrayList<PVector>(movers);
  pVel = new ArrayList<PVector>(movers);
  pCol = new ArrayList<PVector>(movers);
  pLife = new ArrayList<Float>(movers);
  numParticles = 0;
 
}


void keyPressed(){
  camera.HandleKeyPressed();
  if (key == 'r'){
    reset();
    
    testPRM();
    return;
  }
  
  // only one action is allowed at a time
  // only can be done before initiating the code for agent to run from stat to end
  if(startProgram == false){
    int newX = 0;
    int newY = 0;
    
    if(mouseX == (windowWidth/2)){
      newX = 0;
      checkPaths();
    }else if(mouseX < (windowWidth/2) || mouseX > (windowWidth/2)){
      newX = mouseX - (windowWidth/2);
      checkPaths();

    }
    
    if(mouseY == (windowHeight/2)){
      newY = 0;
    checkPaths();

    }
    else if(mouseY < (windowHeight/2) || mouseY > (windowHeight/2)){
      newY = mouseY - (windowHeight/2); 
    checkPaths();

    }

    if (key == 'o') { // allows user to set new start and move the agent goal
    //for 0,0,0 mousePos is windowWidth/2,windowHeight/2
      startPos = new PVector(newX,newY,0);
      rabbitMesh.position = new PVector(newX, newY, 0);
    checkPaths();

    }
    else if (key == 'p') {
      goalPos = new PVector(newX,newY,0);  // allows user to set new end goal
    checkPaths();

    }
    else if(key == 'n'){
      SphereLoc newSphere = new SphereLoc(newX,newY,0,5);
      circlePos[numObstacles] = new PVector(newSphere.x, newSphere.y, newSphere.z);
      circleRad[numObstacles] = newSphere.r;
      numObstacles += 1;
      spheres.add(newSphere);
      newSphere.render(); 
        
      checkPaths();

      //Appears then disappears, why?
      //System.out.println("Pressed n"); //Allows user to add more obsticles at mosePos
    }else if(key == ' '){ 
      startProgram = true;//when user hits space bar they can no longer change the scene
    checkPaths();

    }
    //else if(key == 'm'){ //does same thing as moving start goal
    //  rabbitMesh.position = new PVector(newX, newY, 0);
    //  startPos = new PVector(newX,newY,0);
    //  //System.out.println("Pressed m"); //Allows user to move agents to mosePos
    //}
  if (curPath.size() >0 && curPath.get(0) == -1) return; //No path found

  }
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

float rayCircleIntersectTime(PVector center, float r, PVector l_start, PVector l_dir){
  //Compute displacement vector pointing from the start of the line segment to the center of the circle
  PVector toCircle = PVector.sub(center,l_start);
  
  //Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
  float a = l_dir.mag()*l_dir.mag(); 
  float b = -2* PVector.dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
  float c = toCircle.magSq() - (r*r); //different of squared distances
  
  float d = b*b - 4*a*c; //discriminant 
  
  if (d >=0 ){ 
    //If d is positive we know the line is colliding
    float t = (-b - sqrt(d))/(2*a); //Optimization: we typically only need the first collision! 
    if (t >= 0) return t;
    return -1;
  }
  
  return -1; //We are not colliding, so there is no good t to return 
}
