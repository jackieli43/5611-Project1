//You will only be turning in this file
//Your solution will be graded based on it's runtime (smaller is better), 
//the optimality of the path you return (shorter is better), and the
//number of collisions along the path (it should be 0 in all cases).

//You must provide a function with the following prototype:
// ArrayList<Integer> planPath(PVector startPos, PVector goalPos, PVector[] centers, float[] radii, int numObstacles, PVector[] nodePos, int numNodes);
// Where: 
//    -startPos and goalPos are 2D start and goal positions
//    -centers and radii are arrays specifying the center and radius of obstacles
//    -numObstacles specifies the number of obstacles
//    -nodePos is an array specifying the 2D position of roadmap nodes
//    -numNodes specifies the number of nodes in the PRM
// The function should return an ArrayList of node IDs (indexes into the nodePos array).
// This should provide a collision-free chain of direct paths from the start position
// to the position of each node, and finally to the goal position.
// If there is no collision-free path between the start and goal, return an ArrayList with
// the 0'th element of "-1".

// Your code can safely make the following assumptions:
//   - The function connectNeighbors() will always be called before planPath()
//   - The variable maxNumNodes has been defined as a large static int, and it will
//     always be bigger than the numNodes variable passed into planPath()
//   - None of the positions in the nodePos array will ever be inside an obstacle
//   - The start and the goal position will never be inside an obstacle


// Here we provide a simple PRM implementation to get you started.
// Be warned, this version has several important limitations.
// For example, it uses BFS which will not provide the shortest path.
// Also, it (wrongly) assumes the nodes closest to the start and goal
// are the best nodes to start/end on your path on. Be sure to fix 
// these and other issues as you work on this assignment. This file is
// intended to illustrate the basic set-up for the assignmtent, don't assume 
// this example funcationality is correct and end up copying it's mistakes!).



//Here, we represent our graph structure as a neighbor list
//You can use any graph representation you like
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(PVector[] centers, float[] radii, int numObstacles, PVector[] nodePos, int numNodes){
  for (int i = 0; i < numNodes; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      PVector dir = PVector.sub(nodePos[j],nodePos[i]).normalize();
      float distBetween = nodePos[i].dist(nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, distBetween);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
      }
    }
  }
  
}


float huerDist(PVector startNode, PVector goalNode) {
  return goalNode.dist(startNode);
}

ArrayList<Integer> planPath(PVector startPos, PVector goalPos, PVector[] centers, float[] radii, int numObstacles, PVector[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  boolean temp1 = pointInCircleList(centers,radii,numObstacles,startPos,3);
  boolean temp2 = pointInCircleList(centers,radii,numObstacles,goalPos,3);
  PVector dir = PVector.sub(goalPos,startPos).normalize();
  float distBetween = goalPos.dist(startPos);
  //connectNeighbors(centers, radii, numObstacles, nodePos, numNodes);
  //path = UCS(nodePos, numNodes, centers, radii, startPos, goalPos);
  hitInfo temp3 = rayCircleListIntersect(centers, radii, numObstacles, startPos, dir, distBetween);
  if (!temp3.hit) {
    return path;
  }
  else if (temp1 || temp2) {
     path.add(0, -1);
   }
   else {
    connectNeighbors(centers, radii, numObstacles, nodePos, numNodes);
    path = UCS(nodePos, numNodes, centers, radii, startPos, goalPos);
   }
  //System.out.println("AfterPath: "+path);
  return path;
}

ArrayList<Integer> UCS(PVector[] nodePos, int numNodes, PVector[] centers, float[] radii, PVector startPos, PVector goalPos) {
  ArrayList<Integer> path = new ArrayList();
  ArrayList<Integer> open = new ArrayList();
  Float[] g = new Float[numNodes];
  
  for (int i = 0; i < numNodes; i++) {
      visited[i] = false;
      parent[i] = -1; 
      PVector dir = PVector.sub(nodePos[i],startPos).normalize();

      float distBetween = nodePos[i].dist(startPos);
      hitInfo temp4 = rayCircleListIntersect(centers, radii, numObstacles, startPos, dir, distBetween);
      if (!temp4.hit) {
        open.add(i);
        g[i] = huerDist(startPos,nodePos[i]);
      }
      else {
          g[i] = 999.0;// inf
      }
  }
  int curr = -1;
  int lastNode = 0;
  float lastNodeG = 9999;
  while (open.size() > 0 ) {
    float max = 9999;
    for (int i : open) {
      if (g[i] < max) {
        max = g[i];
        curr = i;
      }
    }
    
    open.remove(Integer.valueOf(curr));
    visited[curr] = true;
    
    for (int m : neighbors[curr]) {
      if (!visited[m] && !open.contains(m)) {
              PVector dir = PVector.sub(nodePos[m],nodePos[curr]).normalize();
              float distBetween = nodePos[m].dist(nodePos[curr]);
            hitInfo temp4 = rayCircleListIntersect(centers, radii, numObstacles, nodePos[curr], dir, distBetween);
            if (!temp4.hit) {
              open.add(open.size(),m);
              parent[m] = curr;
              g[m] = g[curr] + huerDist(nodePos[m], nodePos[curr]);
            }
      }
      else {
        float temp = g[curr] + huerDist(nodePos[m], nodePos[curr]);
        if (temp < g[m]) {
          PVector dir = PVector.sub(nodePos[m],nodePos[curr]).normalize();
          float distBetween = nodePos[m].dist(nodePos[curr]);
          hitInfo temp4 = rayCircleListIntersect(centers, radii, numObstacles, nodePos[curr], dir, distBetween);
          if (!temp4.hit) {
          parent[m] = curr;
          g[m] = temp;
          }

        }
      }
    }
    
    for( int n : open) {
      PVector dir = PVector.sub(nodePos[n],goalPos).normalize();
      float distBetween = nodePos[n].dist(goalPos);
      hitInfo temp4 = rayCircleListIntersect(centers, radii, numObstacles, goalPos, dir, distBetween);
      if (!temp4.hit) {
        if (g[n] < lastNodeG) {
          lastNodeG = g[n];
          lastNode = n;
        }
      }
    }
  }
  
  int prevNode = parent[lastNode];
  path.add(0,lastNode);
  //print(goalID, " ");
  while (prevNode >= 0){
    //print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  return path;
}
