
import processing.serial.*;

Serial myPort;

int s1 = 0;
int s2 = 0;
int s3 = 0;

boolean ctrlPressed = false;

// Simulated signal visibility
boolean s2Visible = true;
boolean s3Visible = true;

// Changing positions of simulated signals
float s2Angle = 75;
float s3Angle = 25;

// Flicker timers
int lastFlicker2 = 0;
int lastFlicker3 = 0;

int flickerInterval2 = 600;
int flickerInterval3 = 900;

void setup()
{
  size(800, 500);

  printArray(Serial.list());

  myPort = new Serial(this, "COM9", 9600);
  myPort.bufferUntil('\n');
}

void draw()
{
  background(0);

  if (ctrlPressed)
  {
    // S2: Slow flicker and random position
    if (millis() - lastFlicker2 >= flickerInterval2)
    {
      s2Visible = !s2Visible;
      lastFlicker2 = millis();

      flickerInterval2 = (int)random(500, 1000);

      // Change position when the signal reappears
      if (s2Visible)
      {
        s2Angle = random(10, 170);
      }
    }

    // S3: Slow flicker and random position
    if (millis() - lastFlicker3 >= flickerInterval3)
    {
      s3Visible = !s3Visible;
      lastFlicker3 = millis();

      flickerInterval3 = (int)random(700, 1300);

      // Change position when the signal reappears
      if (s3Visible)
      {
        s3Angle = random(10, 170);
      }
    }
  }
  else
  {
    s2Visible = false;
    s3Visible = false;
  }

  // Radar origin
  translate(width / 2, height);

  stroke(0, 255, 0);
  strokeWeight(2);
  noFill();

  // Radar semicircle
  arc(0, 0, 700, 700, PI, TWO_PI);

  // Radar angle lines
  line(0, 0,
       -350 * cos(radians(45)),
       -350 * sin(radians(45)));

  line(0, 0, 0, -350);

  line(0, 0,
       350 * cos(radians(45)),
       -350 * sin(radians(45)));

  // S1: Real sensor in both modes
  if (s1 == 1)
  {
    drawDot(135);
  }

  // S2: Moving simulated signal
  if (ctrlPressed && s2Visible)
  {
    drawDot(s2Angle);
  }

  // S3: Moving simulated signal
  if (ctrlPressed && s3Visible)
  {
    drawDot(s3Angle);
  }

  // Status text
  resetMatrix();

  fill(0, 255, 0);
  textSize(18);

  if (ctrlPressed)
  {
    text("CTRL MODE: S1 REAL + S2/S3 MOVING", 20, 30);
  }
  else
  {
    text("", 20, 30);
  }
}

void drawDot(float angle)
{
  float r = 250;

  float x = r * cos(radians(angle));
  float y = -r * sin(radians(angle));

  fill(0, 255, 0);
  noStroke();

  ellipse(x, y, 15, 15);
}

void serialEvent(Serial p)
{
  String data = p.readStringUntil('\n');

  if (data != null)
  {
    data = trim(data);

    int values[] = int(split(data, ','));

    if (values.length == 3)
    {
      s1 = values[0];
      s2 = values[1];
      s3 = values[2];
    }
  }
}

void keyPressed()
{
  if (key == CODED &&
      keyCode == CONTROL &&
      !ctrlPressed)
  {
    ctrlPressed = true;

    s2Visible = true;
    s3Visible = true;

    // Start at different random positions
    s2Angle = random(10, 170);
    s3Angle = random(10, 170);

    lastFlicker2 = millis();
    lastFlicker3 = millis();

    flickerInterval2 = (int)random(500, 1000);
    flickerInterval3 = (int)random(700, 1300);

    myPort.write('1');
  }
}

void keyReleased()
{
  if (key == CODED && keyCode == CONTROL)
  {
    ctrlPressed = false;

    s2Visible = false;
    s3Visible = false;

    myPort.write('0');
  }
}

//just now 11-1026
