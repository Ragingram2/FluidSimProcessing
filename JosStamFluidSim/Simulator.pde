public class Simulator
{
    private final int N = 512;
    
    //Source Size & Amount
    private int sourceWidth = 10;
    private int sourceHeight = 10;
    
    //SourcePosition
    private int posx;
    private int posy;
    private int mousePosX;
    private int mousePosY;
    
    //FluidResolution
    private float widthRes;
    private float heightRes;
    
    //MouseStuffDragging
    private PVector pMouse;
    private PVector mouse;
    private PVector difference;
    
    //Gravity
    private PVector gravForce;
    private boolean useGravity = true;
    
    private Fluid fluid;
    
    private int mode = 0;
    private String directionString = "";
    
    private ArrayList<Source> sources = new ArrayList();
    
    
    public void Setup()
    {
        fluid = new Fluid(N,.002f, 0.000001, 0.0000001);
        widthRes = (N / (float)width);
        heightRes = ((N / (float)height));
        gravForce = new PVector(0, 9);
        posx = (int)((width *.5) * widthRes);
        posy = (int)((height *.7) * heightRes);
    }
    
    public void Update()
    {
        background(0);
        inputUpdate();
        if (useGravity)
            {
            fluid.AddGlobalForce(gravForce);
        }
        
        for (int i = 0; i < sources.size(); i++)
            {
            sources.get(i).Draw();
        }
        
        fluid.FadeD(4);
        fluid.Step(4);
        fluid.RenderD();
        
        stroke(255);
        text(frameRate, 15, 15);
        text(directionString, 10, height - 10);
    }
    
    void inputUpdate()
    {
        switch(mode)
            {
            case 0:
            fluid.Clear();
            directionString = "Select a tool: Dye Placer(1) or Candle Placer(2)";
            break;
            case 1:
            Source(100);
            directionString = "Left-click to place dye. Right-clicking and dragging will add force in the direction of your drag";
            break;
            case 2:
            Candle(20, 15);
            directionString = "Left-click to place candle source. Right-clicking and dragging will add force in the direction of your drag";
            break;
            case - 1:
            println("This is not a valid mode");
            mode = 0;
            return;
        }
    }
    
    public void OnKeyPressed()
    {
        if (key == 'g')
        {
            useGravity = !useGravity;
            println("Gravity Toggled");
        } 
        mode= CheckMode();
    }
    
    public void OnMousePressed()
    {
        
    }
    
    public void OnMouseDragged()
    {
        if (mousePressed)
            {
            if (mouseButton == RIGHT)
            {
                mousePosX = (int)(mouseX * widthRes);
                mousePosY = (int)(mouseY * heightRes);
                //angle = noise(t) * TWO_PI * 2;
                pMouse = new PVector(pmouseX, pmouseY);
                mouse = new PVector(mouseX, mouseY);
                difference = mouse.sub(pMouse).normalize();
                PVector v = difference.normalize();
                v.mult(100);
                fluid.AddVelocity(mousePosX, mousePosY, v.x, v.y);
            }
        }
    }
    
    void Source(float _sourceAmount)
    {
        mousePosX = (int)(mouseX * widthRes);
        mousePosY = (int)(mouseY * heightRes);
        if (mousePressed)
            {
            if (mouseButton == LEFT)
            {
                for (int i = - sourceWidth; i <= sourceHeight; i++)
                {
                    for (int j =- sourceHeight; j <= sourceHeight; j++) 
                    {
                        fluid.AddDensity((int)(mousePosX + (i * widthRes)),(int)(mousePosY + (j * heightRes)), _sourceAmount);
                    }
                }
            }
        }
    }
    
    void Candle(int _radius, int _sourceAmount)
    {
        if (mousePressed)
            {
            if (mouseButton == LEFT)
            {
                sources.add(new CandleSource(fluid, new PVector(mouseX * widthRes, mouseY * heightRes)));
            }
        }
    }
    
    
    
    public int index(int _x, int _y)
    {
        _x = constrain(_x, 0, N - 1);
        _y = constrain(_y, 0, N - 1);
        return_x + (_y * N);
    }
    
    int CheckMode()
    {
        if (key >= 48 && key <= 57)
            {
            mode = key % 48;
            println(mode);
        }
        returnmode;
    }

}