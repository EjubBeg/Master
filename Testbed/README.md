The testbed consists of two main components: the Application layer and the Physical Process simulation.

In the Application directory, two separate applications are provided—one for each PLC (PLC1 and PLC2). These applications control and monitor the simulated process.

The Physical Process is simulated using a Raspberry Pi, which runs the corresponding Python code. This simulation mimics real-world physical behavior and provides input/output signals to the PLCs.

To set up and run the testbed, follow this order:

Start the Raspberry Pi code

Run the PLC1 application then the PLC2 Application.
