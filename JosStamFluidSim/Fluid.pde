public class Fluid 
{
  private int size;
  private float dt;
  float diff;
  float visc;

  float[] sources;
  float[] densitys;

  float[] VelX;
  float[] VelY;
  //float[] VelZ;

  float[] VelX0;
  float[] VelY0;
  //float[] VelZ0;

  PGraphics pg;

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
    pg= createGraphics(N, N, P2D);
    pg.noStroke();
    pg.noSmooth();
  }

  public void Step(int _iter) {

    diffuse(1, VelX0, VelX, visc, dt, _iter);
    diffuse(2, VelY0, VelY, visc, dt, _iter);

    project(VelX0, VelY0, VelX, VelY, _iter);

    advect(1, VelX, VelX0, VelX0, VelY0, dt);
    advect(2, VelY, VelY0, VelX0, VelY0, dt);

    project(VelX, VelY, VelX0, VelY0, _iter);

    diffuse(0, sources, densitys, diff, dt, _iter);
    advect(0, densitys, sources, VelX, VelY, dt);
  }

  public void AddDensity(float _x, float _y, float _amount)
  {
    AddDensity((int)_x, (int)_y, _amount);
  }
  public void AddDensity(int _x, int _y, float _amount)
  {
    densitys[index(_x, _y)] += _amount;
  }

  public void AddVelocity(float _x, float _y, float _amountX, float _amountY)
  {
    AddVelocity((int)_x, (int)_y, _amountX, _amountY);
  } 
  public void AddVelocity(int _x, int _y, float _amountX, float _amountY)
  {
    int index = index(_x, _y);
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
    for (int x =0; x<N; x++)
    {
      for (int y = 0; y<N; y++)
      {
        index = index(x, y);
        VelX[index] += _force.x*dt;
        VelY[index] += _force.y*dt;
      }
    }
  }

  public void RenderD()
  {
    colorMode(HSB, 255);
    pg.loadPixels();
    for (int i = 0; i < N; i++)
    {
      for (int j = 0; j < N; j++)
      {
        float d = densitys[index(i, j)];
        pg.pixels[index(i, j)] = color((d + 50) % 255, 200, d);
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
}

void diffuse(int _b, float[] _x, float[] _x0, float _diff, float _dt, int _iter)
{
  float a = _dt * _diff * (N-2) * (N-2);
  linearSolve(_b, _x, _x0, a, 1+6*a, _iter);
}

void advect(int b, float[] d, float[] d0, float[] velocX, float[] velocY, float dt) 
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
      tmp1 = dtx * velocX[index(i, j)];
      tmp2 = dty * velocY[index(i, j)];
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
      d[index(i, j)] = 
        s0 * (t0 * d0[index(i0i, j0i)] + t1 * d0[index(i0i, j1i)]) +
        s1 * (t0 * d0[index(i1i, j0i)] + t1 * d0[index(i1i, j1i)]);
    }
  }

  setBound(b, d);
}

void project(float[] velocX, float[] velocY, float[] p, float[] div, int _iter) {
  for (int j = 1; j < N - 1; j++) {
    for (int i = 1; i < N - 1; i++) {
      div[index(i, j)] = -0.5f*(
        velocX[index(i+1, j)]
        -velocX[index(i-1, j)]
        +velocY[index(i, j+1)]
        -velocY[index(i, j-1)]
        )/N;
      p[index(i, j)] = 0;
    }
  }

  setBound(0, div); 
  setBound(0, p);
  linearSolve(0, p, div, 1, 4, _iter);

  for (int j = 1; j < N - 1; j++) {
    for (int i = 1; i < N - 1; i++) {
      velocX[index(i, j)] -= 0.5f * (  p[index(i+1, j)]
        -p[index(i-1, j)]) * N;
      velocY[index(i, j)] -= 0.5f * (  p[index(i, j+1)]
        -p[index(i, j-1)]) * N;
    }
  }
  setBound(1, velocX);
  setBound(2, velocY);
}

void linearSolve(int _b, float[] _x, float[] _x0, float _a, float _c, int _iter)
{
  float cReciprocal = 1f/_c;
  for (int k =0; k<_iter; k++)//Gauss Seidal Relaxation
  {
    for (int j = 1; j<N-1; j++)
    {
      for (int i =1; i<N-1; i++)
      {
        _x[index(i, j)] = (_x0[index(i, j)] 
          + _a*(_x[index(i+1, j  ) ] 
          +     _x[index(i-1, j  ) ]
          +     _x[index(i, j+1) ]
          +     _x[index(i, j-1) ]))*cReciprocal;
      }
    }
  }
  setBound(_b, _x);
}

void setBound(int _b, float[] _x)
{
  for (int i = 1; i < N - 1; i++) {
    _x[index(i, 0  )] = _b == 2 ? -_x[index(i, 1  )] : _x[index(i, 1 )];
    _x[index(i, N-1)] = _b == 2 ? -_x[index(i, N-2)] : _x[index(i, N-2)];
  }
  for (int j = 1; j < N - 1; j++) {
    _x[index(0, j)] = _b == 1 ? -_x[index(1, j)] : _x[index(1, j)];
    _x[index(N-1, j)] = _b == 1 ? -_x[index(N-2, j)] : _x[index(N-2, j)];
  }

  _x[index(0, 0)] = 0.5f * (_x[index(1, 0)] + _x[index(0, 1)]);
  _x[index(0, N-1)] = 0.5f * (_x[index(1, N-1)] + _x[index(0, N-2)]);
  _x[index(N-1, 0)] = 0.5f * (_x[index(N-2, 0)] + _x[index(N-1, 1)]);
  _x[index(N-1, N-1)] = 0.5f * (_x[index(N-2, N-1)] + _x[index(N-1, N-2)]);
}
