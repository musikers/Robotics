section[] sections;
color couleurEnCours;
import processing.serial.*;
Serial myPort2;  // Create object from Serial class
String val;     // Data received from the serial port
int px=330, py=331, pz=406, x, y, z;
float x2, y2, r, g, b, radius;
  int Hit=0;
  int limit=300;
int timer;
import ddf.minim.*;
import ddf.minim.spi.*; // for AudioRecordingStream
import ddf.minim.ugens.*;

// declare everything we need to play our file and control the playback rate
Minim minim;
TickRate rateControl;
FilePlayer filePlayer;
AudioOutput out;

AudioSample breakglass;

//// you can use your own file by putting it in the data directory of this sketch
//// and changing the value assigned to fileName here.

String fileName = "p.mp3";
boolean breaking = false;

void setup() {

  //fullScreen();
  size(680, 720);
  smooth();
  sections = new section[0];
  couleurEnCours = color(random(255), random(255), random(255)); 
  stroke(255);
  String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
  myPort2 = new Serial(this, portName, 9600);
  // create our Minim object for loading audio
  minim = new Minim(this);
  breakglass = minim.loadSample( "breakglass.mp3", 512);

  // this opens the file and puts it in the "play" state.                           
  filePlayer = new FilePlayer( minim.loadFileStream(fileName) );
  // and then we'll tell the recording to loop indefinitely
  filePlayer.loop();

  // this creates a TickRate UGen with the default playback speed of 1.
  // ie, it will sound as if the file is patched directly to the output
  rateControl = new TickRate(1.f);

  // get a line out from Minim. It's important that the file is the same audio format 
  // as our output (i.e. same sample rate, number of channels, etc).
  out = minim.getLineOut();

  // patch the file player through the TickRate to the output.
  filePlayer.patch(rateControl).patch(out);

  //breakglass.trigger();
}

void draw() {
  background(couleurEnCours);
  /*
   *********************
   *********************
   *********************
   *********************
   *********************
   */

  noStroke();
  // use frameCount to move x, use modulo to keep it within bounds
  x2 = frameCount % width;

  // use millis() and a timer to change the y every 2 seconds
  if (millis() - timer >= 2000) {
    y2 = random(height);
    timer = millis();
  }

  // use frameCount and noise to change the red color component
  r = noise(frameCount * 0.01) * 255;

  // use frameCount and modulo to change the green color component
  g = frameCount % 255;

  // use frameCount and noise to change the blue color component
  b = 255 - noise(1 + frameCount * 0.025) * 255;

  // use frameCount and noise to change the radius
  //radius = noise(frameCount * 0.01) * 100;
  if(Hit<50)
  radius = 50;
  else
  radius = Hit * 2-limit+300;

  color d = color(r, g, b);
  fill(d);
  ellipse(x2, y2, radius, radius);
  /*
   *********************
   *********************
   *********************
   *********************
   *********************
   */


  if ( myPort2.available() > 0) 
  {  // If data is available,
    val = myPort2.readStringUntil('\n');         // read it and store it in val
    if (val != null && val.length()>9) {
      String[] c=split(val, ',');
      println("x"+c[0] +"/ y"+c[1]+"/ z"+c[2]);

      x=int (c[0]);
      y=int (c[1]);
      z=int (c[2]);
      int xHit = abs(x-px);
      int yHit = abs(y-py);
      int zHit = abs(z-pz);

      if (xHit>=yHit && xHit>=zHit)
        Hit=xHit;
      if (yHit>=xHit && yHit>=zHit)
        Hit=yHit;
      else
        Hit=zHit;

      println("Hit= "+Hit+"Limit= "+limit);



      //fill(0,255,0);
      //rect(0, 50, Hit, 20);

      //if(Hit > 150)
      //  background(255,0,0);

      px =x;
      py =y;
      pz =z;
    }
  }

  for (int a=sections.length-1; a>0; a--) {
    sections[a].dessine();
  }
  section[] newsections = new section[0];
  for (int a=0; a<sections.length; a++) {
    if (sections[a].tokill==false) {
      newsections = (section[]) append(newsections, sections[a]);
    }
  }
  sections = newsections;
  /*
   *********************
   *********************
   *********************
   *********************
   *********************
   */
  if (Hit>limit && !breaking) {
    breakglass.trigger();
    breakMirror();
    breaking = true;
    noStroke();
    limit+=50;
  } else {
    stroke(255);
    strokeWeight(10);
  }
  /*
  *********************
   *********************
   *********************
   *********************
   */

  if (breaking && frameCount%30==0)
    breaking = false;

  // change the rate control value based on mouse position
  float rate = map(Hit, 0, 400, 1.0f, 1.7f);
  rateControl.value.setLastValue(rate);

  // draw the waveforms
  for (int i = 0; i < out.bufferSize() - 1; i++)
  {
    line( i, 350 + out.left.get(i)*50, i+1, 350 + out.left.get(i+1)*50 );
    line( i, 550 + out.right.get(i)*50, i+1, 550 + out.right.get(i+1)*50 );
  }
}




//void mousePressed(){
void breakMirror() {
  //float[] centre = {mouseX, mouseY};
  float[] centre = {width/2, height/2};
  float[] p1 = {0, 0};
  float[] p2 = {width, 0};
  float[] p3 = {width, height};
  float[] p4 = {0, height};
  decoupe(10, p1, p2, p3, p4, centre, couleurEnCours );
  couleurEnCours = color(random(255), random(255), random(255));
}


void  decoupe (int fois, float[] a, float[] b, float[] c, float[] d, float[] centre, color coul ) {
  float t1=random(0.1, 0.9);
  float t2=random(0.1, 0.9);
  float[] p1={
    a[0]+(b[0]-a[0])*t1, a[1]+(b[1]-a[1])*t1        };
  float[] p2={
    d[0]+(c[0]-d[0])*t2, d[1]+(c[1]-d[1])*t2        }; 
  fois--;
  if (fois>0) {
    decoupe(fois, p1, p2, d, a, centre, coul );
    decoupe(fois, b, c, p2, p1, centre, coul );
  } else {
    sections = (section[]) append(sections, new section(a, b, c, d, centre, coul));
  }
}

class section {
  float vx, vy, an, van;
  float[] pos =new float[2];
  boolean tokill=false;
  coord[] coords;
  color col;
  section(float[] _a, float[] _b, float[] _c, float[]  _d, float[] centre, color coul) {
    col=coul;
    /// créer la vitesse en fonction du centre
    float ang = random(TWO_PI);
    an=0;
    //  col=color(random(255),random(255),random(255));
    float vitz = random(1, 20);
    pos[0]= (_a[0]+_b[0]+_c[0]+_d[0])/4;
    pos[1]= (_a[1]+_b[1]+_c[1]+_d[1])/4;
    float aaan = atan2(pos[1]-centre[1], pos[0]-(centre[0]));
    aaan+=radians(random(-5, 5));
    vx=cos(aaan)*vitz;
    vy=sin(aaan)*vitz;
    van=radians(random(-10, 10));
    coords = new coord[4];
    coords[0] = new coord(pos[0], pos[1], _a[0], _a[1]);
    coords[1] = new coord(pos[0], pos[1], _b[0], _b[1]);
    coords[2] = new coord(pos[0], pos[1], _c[0], _c[1]);
    coords[3] = new coord(pos[0], pos[1], _d[0], _d[1]);
  }
  void dessine() {
    if (!tokill) {
      an+=van;
      vx*=1.035;
      vy*=1.0351;
      vy+=0.01;
      pos[0]+=vx;
      pos[1]+=vy;
      fill(col);
      beginShape(); // ,pos[1]
      float[] a=coords[0].affiche(an);
      vertex(pos[0]+a[0], pos[1]+a[1]);
      float[] b=coords[1].affiche(an);
      vertex(pos[0]+b[0], pos[1]+b[1]);
      float[] c=coords[2].affiche(an);
      vertex(pos[0]+c[0], pos[1]+c[1]);
      float[] d=coords[3].affiche(an);
      vertex(pos[0]+d[0], pos[1]+d[1]);
      endShape(CLOSE);   
      if (vy>height+30 || vy<-30 || vx<-30 || vx> width+30) {
        tokill=true;
      }
    }
  }
}

class coord {
  float an, ray;
  coord(float cx, float  cy, float  _x, float  _y) {
    an= atan2(_y-cy, _x-cx);
    ray=getDistance(cx, cy, _x, _y);
  }
  float[] affiche(float _an) {
    _an+=an;
    float[] toreturn=new float[2];
    toreturn[0]= cos(_an)*ray;
    toreturn[1]= sin(_an)*ray;
    return toreturn;
  }
}

float getDistance(float x1, float y1, float x2, float y2) {
  return sqrt(pow(x2-x1, 2)+pow(y2-y1, 2));
}