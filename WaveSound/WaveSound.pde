import ddf.minim.*;

Minim minim;
AudioInput in;

int Nmax = 1500 ; 
float M = 50 ; 
float H = 0.93 ; 
float HH = 0.01 ;

float X[] = new float[Nmax+1];
float Y[] = new float[Nmax+1];
float Z[] = new float[Nmax+1];
float dX[] = new float[Nmax+1];
float dY[] = new float[Nmax+1];

float V[] = new float[Nmax+1];
float dV[] = new float[Nmax+1]; 
float L ; 
float R = 2*sqrt((4*PI*(200*200)/Nmax)/(2*sqrt(3))) ;
float Lmin ; 
int N ; 
int NN ; 
float KX ; 
float KY ; 
float KZ ; 
float KV ; 
float KdV ; 
int K ;

int objectX = 0;
int objectY = 0;

boolean isDragged = false;
float timePrev;

int camera_x = 0;
int camera_y = 0;


void setup() {

  fullScreen(P3D);
  //size(1000, 900);
  background(0, 0, 0) ;
  noSmooth() ;
  stroke(255, 255, 255) ;
  fill(50, 50, 50) ;
  for ( N = 0; N <= Nmax; N++ ) {
    X[N] = random(-300,+300) ;
    //X[N] = 0 ;
    Y[N] = random(-300,+300) ;
    //Y[N] = 0 ;
    Z[N] = random(-300, +300) ;
    //Z[N] = random(-10, 10);
    dX[N] = 0;
    dY[N] = 0;
  }
  objectX = width/2;
  objectY = height/2;

  minim = new Minim(this);

  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();
  in.disableMonitoring();
}

void drawingSphere(float X[], float Y[], float Z[], int xLoc, int yLoc, float dX[], float dY[]) {
  for ( N = 0; N <= Nmax; N++ ) {
    for ( NN = N+1; NN <= Nmax; NN++ ) {
      L = sqrt(((X[N]-X[NN])*(X[N]-X[NN]))+((Y[N]-Y[NN])*(Y[N]-Y[NN]))) ;
      L = sqrt(((Z[N]-Z[NN])*(Z[N]-Z[NN]))+(L*L)) ;
      if ( L < R ) {
        X[N] = X[N] - ((X[NN]-X[N])*((R-L)/(2*L))) ;
        Y[N] = Y[N] - ((Y[NN]-Y[N])*((R-L)/(2*L))) ;
        Z[N] = Z[N] - ((Z[NN]-Z[N])*((R-L)/(2*L))) ;
        X[NN] = X[NN] + ((X[NN]-X[N])*((R-L)/(2*L))) ;
        Y[NN] = Y[NN] + ((Y[NN]-Y[N])*((R-L)/(2*L))) ;
        Z[NN] = Z[NN] + ((Z[NN]-Z[N])*((R-L)/(2*L))) ;
        dV[N] = dV[N] + ((V[NN]-V[N])/M) ;
        dV[NN] = dV[NN] - ((V[NN]-V[N])/M) ;
        stroke(125+(Z[N]/2), 125+(Z[N]/2), 125+(Z[N]/2)) ; 
        line(X[N]*1.2*(200+V[N])/200+xLoc+dX[N], Y[N]*1.2*(200+V[N])/200+yLoc+dY[N], X[NN]*1.2*(200+V[NN])/200+xLoc+dX[N], Y[NN]*1.2*(200+V[NN])/200+yLoc+dY[N]) ;
      }
      if ( Z[N] > Z[NN] ) {
        KX = X[N] ; 
        KY = Y[N] ; 
        KZ = Z[N] ; 
        KV = V[N] ; 
        KdV = dV[N] ; 
        X[N] = X[NN] ; 
        Y[N] = Y[NN] ; 
        Z[N] = Z[NN] ; 
        V[N] = V[NN] ; 
        dV[N] = dV[NN] ;  
        X[NN] = KX ; 
        Y[NN] = KY ; 
        Z[NN] = KZ ; 
        V[NN] = KV ; 
        dV[NN] = KdV ;
      }
    }
    L = sqrt((X[N]*X[N])+(Y[N]*Y[N])) ;
    L = sqrt((Z[N]*Z[N])+(L*L)) ;
    X[N] = X[N] + (X[N]*(200-L)/(2*L)) ;
    Y[N] = Y[N] + (Y[N]*(200-L)/(2*L)) ;
    Z[N] = Z[N] + (Z[N]*(200-L)/(2*L)) ;
    KZ = Z[N] ; 
    KX = X[N] ;
    Z[N] = (KZ*cos(float(100)/10000))-(KX*sin(float(100)/10000)) ;
    X[N] = (KZ*sin(float(100)/10000))+(KX*cos(float(100)/10000)) ;
    KZ = Z[N] ; 
    KY = Y[N] ;
    Z[N] = (KZ*cos(float(100)/10000))-(KY*sin(float(100)/10000)) ;
    Y[N] = (KZ*sin(float(100)/10000))+(KY*cos(float(100)/10000)) ;
    dV[N] = dV[N] - (V[N]*HH) ; 
    V[N] = V[N] + dV[N] ; 
    dV[N] = dV[N] * H ;
  }
  float volumn = abs(in.right.get(0));
  println(volumn);
  if (volumn > 0.01) {
    camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0) - (volumn * 100), width/2.0, height/2.0, 0, 0, 1, 0);
    int ranX = int(random(width/2-200, width/2+200));
    int ranY = int(random(height/2-200, height/2+200));
    Lmin = 1000 ; 
    NN = 0 ;
    for ( N = 0; N <= Nmax; N++ ) {
      L = sqrt(((ranX-(xLoc+X[N]))*(ranX-(xLoc+X[N])))+((ranY-(yLoc+Y[N]))*(ranY-(yLoc+Y[N])))) ;
      if ( Z[N] > 0 && L < Lmin ) { 
        NN = N ; 
        Lmin = L ;
      }
    }

    if ( K == 0 ) { 
      dV[NN] = +volumn * 100 ; 
      K = 1 ;
    } else { 
      dV[NN] = +volumn * 100 ; 
      K = 0 ;
    }
  }
  if (volumn > 0.5) {
    camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0) - (volumn * 150), width/2.0 + random(-50, 50), height/2.0 + random(-50, 50), 0, 0, 1, 0);
  } else {
    //camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0) - (volumn * 100), width/2.0, height/2.0, 0, 0, 1, 0);
  }
}



void draw() {  
  background(0);
  drawingSphere(X, Y, Z, objectX, objectY, dX, dY);
  timePrev=millis();
}
