
private Simulator sim;
void settings()
{
  size(800, 800, P2D);
}

void setup()
{
  sim = new Simulator();
  sim.Setup();
  
}

void draw()
{
  sim.Update();
  
}



void mousePressed()
{
}

void mouseDragged()
{
  sim.OnMouseDragged();
}

void keyPressed()
{
  sim.OnKeyPressed();
}
