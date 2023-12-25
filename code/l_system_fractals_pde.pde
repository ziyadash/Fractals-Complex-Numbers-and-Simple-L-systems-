import javax.swing.*;
import java.util.Stack;

class Rule {
  private char input = ' ';
  private String output = "";

  public Rule(char input, String output) {
    this.input = input;
    this.output = output;
  }

  public char getInput() {
    return input;
  }

  public String getOutput() {
    return output;
  }
}

class LSystem {
  private char variable1 = ' ';
  private char variable2 = ' ';
  private Rule grammarRule1;
  private Rule grammarRule2;
  private float angle;
  private float lineLength = 15;
  private int maxGenerations;
  private int currentGeneration;
  private String axiom;
  private float zoomFactor = 1.0;
  private float panX = 0.0;
  private float panY = 0.0;
  private float lastMouseX;
  private float lastMouseY;
  private Stack<TurtleState> stateStack;

  public void init() {
    variable1 = JOptionPane.showInputDialog(null, "Enter variable 1 (leave blank for empty):").trim().charAt(0);

    String inputVariable2 = JOptionPane.showInputDialog(null, "Enter variable 2 (leave blank for empty):").trim();
    variable2 = inputVariable2.isEmpty() ? ' ' : inputVariable2.charAt(0);

    axiom = JOptionPane.showInputDialog(null, "Enter axiom:");
    angle = radians(Float.parseFloat(JOptionPane.showInputDialog(null, "Enter angle in degrees:")));
    maxGenerations = Integer.parseInt(JOptionPane.showInputDialog(null, "Enter max generations:"));

    grammarRule1 = createRule("Enter rule 1 input (or leave blank for none):");
    grammarRule2 = createRule("Enter rule 2 input (or leave blank for none):");

    currentGeneration = 1;
    stateStack = new Stack<>();
  }

  private Rule createRule(String prompt) {
    String ruleInput = JOptionPane.showInputDialog(null, prompt);
    return ruleInput.equals("") ? null : new Rule(ruleInput.charAt(0), JOptionPane.showInputDialog(null, "Enter output:"));
  }

  private String expand(String s) {
    StringBuilder newAxiom = new StringBuilder();
    for (int i = 0; i < s.length(); i++) {
      char currentChar = s.charAt(i);

      if (grammarRule1 != null && currentChar == grammarRule1.getInput()) {
        newAxiom.append(grammarRule1.getOutput());
      } else if (grammarRule2 != null && currentChar == grammarRule2.getInput()) {
        newAxiom.append(grammarRule2.getOutput());
      } else {
        newAxiom.append(currentChar);
      }
    }

    return newAxiom.toString();
  }

  public void render() {
    pushMatrix();
    translate(width / 2 + panX, height / 2 + panY); // Center the drawing and apply panning
    scale(zoomFactor);

    for (int i = 0; i < axiom.length(); i++) {
      char currentVariable = axiom.charAt(i);

      // Draw a line or handle '[' and ']'
      if (currentVariable == variable1 || currentVariable == variable2) {
        line(0, 0, lineLength, 0);
        translate(lineLength, 0);
      } else if (currentVariable == '[') {
        stateStack.push(new TurtleState(0, 0, 0)); // Push current state onto stack
      } else if (currentVariable == ']') {
        if (!stateStack.isEmpty()) {
          TurtleState state = stateStack.pop();
          translate(state.x, state.y);
          rotate(state.heading);
        }
      }

      // Handle rotations
      if (currentVariable == '+') {
        rotate(-angle);
      } else if (currentVariable == '-') {
        rotate(angle);
      }
    }

    popMatrix();

    if (currentGeneration <= maxGenerations) {
      println(axiom);
      axiom = expand(axiom);
      currentGeneration++;
    }
  }

  private void pan(float deltaX, float deltaY) {
    // adjust pan based on mouse movement
    panX += deltaX;
    panY += deltaY;
  }

  public void updateMouse() {
    float deltaX = mouseX - lastMouseX;
    float deltaY = mouseY - lastMouseY;
    pan(deltaX, deltaY);
    lastMouseX = mouseX;
    lastMouseY = mouseY;
  }

  private class TurtleState {
    float x, y, heading;

    TurtleState(float x, float y, float heading) {
      this.x = x;
      this.y = y;
      this.heading = heading;
    }
  }
}

LSystem lSystem;

void setup() {
    JOptionPane.showMessageDialog(null,
    "You will be prompted to initialize an L-system and then shown the results.\n" +
    "The L-system may have two variables at most, and 2 grammar rules at most.\n" +
    "The constants + and - may be used, which cause a rotation by some specified angle of your choice in the anticlockwise and clockwise directions respectively.\n" +
    "If the number of iterations is too high, the image may take a very long time to generate.\n" +
    "Pressing + and - when viewing the image allows you to zoom in, and you can click and drag to pan around the canvas.\n" +
    "Pressing 's' saves a screenshot in the same directory as the file.",
    "L-System Instructions",
    JOptionPane.INFORMATION_MESSAGE);
  
  lSystem = new LSystem();
  lSystem.init();
  size(800, 600);
}

void draw() {
  background(255);
  lSystem.render();
}

void keyPressed() {
  if (key == '+' || key == '=') {
    // Zoom in
    lSystem.zoomFactor *= 1.1;
  } else if (key == '-' || key == '_') {
    // Zoom out
    lSystem.zoomFactor /= 1.1;
  } else if (key == 's') {
    save("fractal.jpg");
  }
}

void mousePressed() {
  lSystem.lastMouseX = mouseX;
  lSystem.lastMouseY = mouseY;
}

void mouseDragged() {
  lSystem.updateMouse();
}
