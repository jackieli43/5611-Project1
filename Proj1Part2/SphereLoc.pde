
class SphereLoc {

  float x, y, z, r;
  color col=color(random(255), random(255), random(255));

  // constr 
  SphereLoc(float x, float y, float z, float r) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.r = r;
  }// constr

  void render() {
    translate(x, y, z);
    fill(col); 
    sphere(r);
    translate(-x, -y, -z);
  }
  
  void render(color newColor) {
    translate(x, y, z);
    noStroke();
    fill(newColor); 
    sphere(r);
    translate(-x, -y, -z);
  }
  
  //
}//class
