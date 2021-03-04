public class Fluid 
{
  private int size;
  private float dt;
  private float diff;
  private float visc;

  private float[] sources;
  private float[] densitys;

  private float[] VelX;
  private float[] VelY;
  //float[] VelZ;

  private float[] VelX0;
  private float[] VelY0;
  //float[] VelZ0;

  private PGraphics pg;

  Fluid(int _size, float _dt, float _diff, float _visc)
  {
    size = _size;
    dt = _dt;
    diff = _diff;
    visc = _visc;
    sources = new float[size*size];
    densitys = new float[size*size];
    VelX = new float[size*size];
    VelY = new float[size*size];
    VelX0 = new float[size*size];
    VelY0 = new float[size*size];

    pg= createGraphics(size, size,P2D);
    pg.noStroke();
    pg.noSmooth();
  }

  public void Step(int _iter) {

    diffuse(size, 1, VelX0, VelX, visc, dt, _iter);
    diffuse(size, 2, VelY0, VelY, visc, dt, _iter);

    project(size, VelX0, VelY0, VelX, VelY, _iter);

    advect(size, 1, VelX, VelX0, VelX0, VelY0, dt);
    advect(size, 2, VelY, VelY0, VelX0, VelY0, dt);

    project(size, VelX, VelY, VelX0, VelY0, _iter);

    diffuse(size, 0, sources, densitys, diff, dt, _iter);
    advect(size, 0, densitys, sources, VelX, VelY, dt);
  }

  public void AddDensity(float _x, float _y, float _amount)
  {
    AddDensity((int)_x, (int)_y, _amount);
  }
  public void AddDensity(int _x, int _y, float _amount)
  {
    densitys[sim.index(_x, _y)] += _amount;
  }

  public void AddVelocity(float _x, float _y, float _amountX, float _amountY)
  {
    AddVelocity((int)_x, (int)_y, _amountX, _amountY);
  } 
  public void AddVelocity(int _x, int _y, float _amountX, float _amountY)
  {
    int index = sim.index(_x, _y);
    VelX[index] += _amountX;
    VelY[index] += _amountY;
  } 

  public void AddGlobalForce(float _amountX, float _amountY)
  {
    AddGlobalForce(new PVector(_amountX, _amountY));
  }

  public void AddGlobalForce(PVector _force)
  {
    int index = 0;
    for (int x =0; x<size; x++)
    {
      for (int y = 0; y<size; y++)
      {
        index = sim.index(x, y);
        VelX[index] += _force.x*dt;
        VelY[index] += _force.y*dt;
      }
    }
  }

  public void RenderD()
  {
    colorMode(HSB, 255);
    pg.loadPixels();
    for (int i = 0; i < size; i++)
    {
      for (int j = 0; j < size; j++)
      {
        float d = densitys[sim.index(i, j)];
        pg.pixels[sim.index(i, j)] = color((d + 50) % 255, 200, d);
      }
    }
    pg.updatePixels();
    image(pg, 0, 0, width, height);
  }

  public void FadeD(float _fadeFactor) {
    for (int i = 0; i < densitys.length; i++) {
      float d = densitys[i];
      densitys[i] = constrain(d-_fadeFactor, 0, 255);
    }
  }

  public void Clear()
  {
    for (int i= 0; i< densitys.length; i++)
    {
      densitys[i] = 0;
      sources[i] = 0;
      VelX[i] = 0;
      VelY[i] = 0;
      VelX0[i] = 0;
      VelY0[i] = 0;
    }
  }
  
  public int GetSize()
  {
    return size;
  }
 
}

void diffuse(int N, int _b, float[] _x, float[] _x0, float _diff, float _dt, int _iter)
{
  float a = _dt * _diff * (N-2) * (N-2);
  linearSolve(N, _b, _x, _x0, a, 1+6*a, _iter);
}

void advect(int N, int b, float[] d, float[] d0, float[] velocX, float[] velocY, float dt) 
{
  float i0, i1, j0, j1;

  float dtx = dt * (N - 2);
  float dty = dt * (N - 2);

  float s0, s1, t0, t1;
  float tmp1, tmp2, x, y;

  float Nfloat = N;
  float ifloat, jfloat;
  int i, j;

  for (j = 1, jfloat = 1; j < N - 1; j++, jfloat++) { 
    for (i = 1, ifloat = 1; i < N - 1; i++, ifloat++) {
      tmp1 = dtx * velocX[sim.index(i, j)];
      tmp2 = dty * velocY[sim.index(i, j)];
      x    = ifloat - tmp1; 
      y    = jfloat - tmp2;

      if (x < 0.5f) x = 0.5f; 
      if (x > Nfloat + 0.5f) x = Nfloat + 0.5f; 
      i0 = floor(x); 
      i1 = i0 + 1.0f;
      if (y < 0.5f) y = 0.5f; 
      if (y > Nfloat + 0.5f) y = Nfloat + 0.5f; 
      j0 = floor(y);
      j1 = j0 + 1.0f; 

      s1 = x - i0; 
      s0 = 1.0f - s1; 
      t1 = y - j0; 
      t0 = 1.0f - t1;

      int i0i = int(i0);
      int i1i = int(i1);
      int j0i = int(j0);
      int j1i = int(j1);

      // DOUBLE CHECK THIS!!!
      d[sim.index(i, j)] = 
        s0 * (t0 * d0[sim.index(i0i, j0i)] + t1 * d0[sim.index(i0i, j1i)]) +
        s1 * (t0 * d0[sim.index(i1i, j0i)] + t1 * d0[sim.index(i1i, j1i)]);
    }
  }

  setBound(N, b, d);
}

void project(int N, float[] velocX, float[] velocY, float[] p, float[] div, int _iter) {
  for (int j = 1; j < N - 1; j++) {
    for (int i = 1; i < N - 1; i++) {
      div[sim.index(i, j)] = -0.5f*(
        velocX[sim.index(i+1, j)]
        -velocX[sim.index(i-1, j)]
        +velocY[sim.index(i, j+1)]
        -velocY[sim.index(i, j-1)]
        )/N;
      p[sim.index(i, j)] = 0;
    }
  }

  setBound(N, 0, div); 
  setBound(N, 0, p);
  linearSolve(N, 0, p, div, 1, 4, _iter);

  for (int j = 1; j < N - 1; j++) {
    for (int i = 1; i < N - 1; i++) {
      velocX[sim.index(i, j)] -= 0.5f * (  p[sim.index(i+1, j)]
        -p[sim.index(i-1, j)]) * N;
      velocY[sim.index(i, j)] -= 0.5f * (  p[sim.index(i, j+1)]
        -p[sim.index(i, j-1)]) * N;
    }
  }
  setBound(N, 1, velocX);
  setBound(N, 2, velocY);
}

void linearSolve(int N, int _b, float[] _x, float[] _x0, float _a, float _c, int _iter)
{
  float cReciprocal = 1f/_c;
  for (int k =0; k<_iter; k++)//Gauss Seidal Relaxation
  {
    for (int j = 1; j<N-1; j++)
    {
      for (int i =1; i<N-1; i++)
      {
        _x[sim.index(i, j)] = (_x0[sim.index(i, j)] 
          + _a*(_x[sim.index(i+1, j  ) ] 
          +     _x[sim.index(i-1, j  ) ]
          +     _x[sim.index(i, j+1) ]
          +     _x[sim.index(i, j-1) ]))*cReciprocal;
      }
    }
  }
  setBound(N, _b, _x);
}

void setBound(int N, int _b, float[] _x)
{
  for (int i = 1; i < N - 1; i++) {
    _x[sim.index(i, 0  )] = _b == 2 ? -_x[sim.index(i, 1  )] : _x[sim.index(i, 1 )];
    _x[sim.index(i, N-1)] = _b == 2 ? -_x[sim.index(i, N-2)] : _x[sim.index(i, N-2)];
  }
  for (int j = 1; j < N - 1; j++) {
    _x[sim.index(0, j)] = _b == 1 ? -_x[sim.index(1, j)] : _x[sim.index(1, j)];
    _x[sim.index(N-1, j)] = _b == 1 ? -_x[sim.index(N-2, j)] : _x[sim.index(N-2, j)];
  }

  _x[sim.index(0, 0)] = 0.5f * (_x[sim.index(1, 0)] + _x[sim.index(0, 1)]);
  _x[sim.index(0, N-1)] = 0.5f * (_x[sim.index(1, N-1)] + _x[sim.index(0, N-2)]);
  _x[sim.index(N-1, 0)] = 0.5f * (_x[sim.index(N-2, 0)] + _x[sim.index(N-1, 1)]);
  _x[sim.index(N-1, N-1)] = 0.5f * (_x[sim.index(N-2, N-1)] + _x[sim.index(N-1, N-2)]);
}
