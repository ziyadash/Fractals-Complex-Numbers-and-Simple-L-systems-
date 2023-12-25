// julia set

String imageName = "exampleJulia";

void setup() {
  size(800, 600);
  colorMode(RGB, 255);  // Set color mode to use values between 0 and 255
}

void draw() {
  background(255);
  
  // the constant c in the recurrence relation z_n = z_(n - 1)^2 + c. let c = a + ib
  float ca = map(mouseX, 0, width, -1, 1);
  float cb = map(mouseY, 0, height, -1, 1);

  float w = 5;
  float h = (w * height) / width;
  
  // start at negative half the width and height
  float xmin = -w / 2;
  float ymin = -h / 2;
  
  // write to the pixels array
  loadPixels();
  
  int maxIterations = 100;
  
  float xmax = xmin + w;
  float ymax = ymin + h;
  
  float dx = (xmax - xmin) / width;
  float dy = (ymax - ymin) / height; 
  
  float y = ymin;
  for (int j = 0; j < height; j++) {
    float x = xmin;
    for (int i = 0; i < width; i++) {
      // z = a + ib
      float a = x;
      float b = y;
      int n = 0;
      while (n < maxIterations) {
        float aa = a * a;
        float bb = b * b;
        float twoab = 2 * a * b;
        if (aa + bb > 4) {
          break;
        }
        a = aa - bb + ca;
        b = twoab + cb;
        n++;
      }
      // colour each pixel based on how long it takes to escape (diverge)
      if (n == maxIterations) {
        pixels[i + j * width] = color(0); // we never reached this pixel
      } else {
        // Map the value to the range [0, 255]
        float bright = map(sqrt(float(n) / maxIterations), 0, 1, 0, 255);
        pixels[i + j * width] = color(bright);
      }
      x += dx;
    }
    y += dy;
  }
  
  updatePixels();

  // Display the c-value for this Julia set in the bottom right corner
  fill(255); // make text white
  textSize(14);
  textAlign(LEFT, BOTTOM);
  text("c = " + nf(ca, 1, 2) + " + " + nf(cb, 1, 2) + "i", width - 120, height - 10);  
  
  saveImage();
}

void saveImage() {
  if (key == 's') {
    save(imageName + ".jpg");
  }
}
