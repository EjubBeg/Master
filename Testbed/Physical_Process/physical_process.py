import RPi.GPIO as GPIO
import time
from threading import Thread
from pyModbusTCP.server import DataBank, ModbusServer
import logging
import random

NORMAL_MIN = 100
NORMAL_MAX = 130
ELEVATED_NORMAL_MAX = 150
INCREASE_MAX = 200
DECREASE_MIN = NORMAL_MIN

temperature = NORMAL_MIN
mode = 'normal'  
running = True  
# Setup GPIO pins
GPIO.setmode(GPIO.BCM)

btn_increase = 25
btn_decrease = 15

GPIO.setup(btn_increase, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(btn_decrease, GPIO.IN, pull_up_down=GPIO.PUD_UP)

blue_led = 16
orange_led = 17
red_led = 18

GPIO.setup(blue_led, GPIO.OUT)
GPIO.setup(orange_led, GPIO.OUT)
GPIO.setup(red_led, GPIO.OUT)

logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.DEBUG)

modbus_server = ModbusServer(host="0.0.0.0", port=502, no_block=True)
modbus_server.start()
logging.info("Modbus Server started")

def update_temperature():
    global temperature, mode, running
    while running:
        if mode == 'increasing' and temperature < INCREASE_MAX:
            temperature += 1
        elif mode == 'decreasing' and temperature > DECREASE_MIN:
            temperature -= 1
        print("Temperature:", temperature)
        update_leds()
        time.sleep(0.5)

def update_leds():
    if temperature <= NORMAL_MAX:
        GPIO.output(blue_led, GPIO.HIGH)
        GPIO.output(orange_led, GPIO.LOW)
        GPIO.output(red_led, GPIO.LOW)
    elif temperature <= ELEVATED_NORMAL_MAX:
        GPIO.output(blue_led, GPIO.LOW)
        GPIO.output(orange_led, GPIO.HIGH)
        GPIO.output(red_led, GPIO.LOW)
    else:
        GPIO.output(blue_led, GPIO.LOW)
        GPIO.output(orange_led, GPIO.LOW)
        GPIO.output(red_led, GPIO.HIGH)

def check_buttons():
    global mode, running
    while running:
        if GPIO.input(btn_increase) == GPIO.LOW:  # Button pressed (active-low logic)
            mode = 'increasing'
            time.sleep(0.2)
        elif GPIO.input(btn_decrease) == GPIO.LOW:  # Button pressed (active-low logic)
            mode = 'decreasing'
            time.sleep(0.2)  
        time.sleep(0.1)

def update_modbus_registers():
    global running, temperature, mode
    while running:

        register_values = [temperature + random.randint(-5, 5) for _ in range(5)]


        modbus_server.data_bank.set_holding_registers(0, register_values)


        current_registers = modbus_server.data_bank.get_holding_registers(0, 5)
        logging.info(f"Current holding registers: {current_registers}")


        command_register = modbus_server.data_bank.get_holding_registers(10, 1)[0]
        print("Command Register is : " + str(command_register))
        if command_register == 1:
            mode = 'decreasing'
            modbus_server.data_bank.set_holding_registers(10, [0]) 

        elif command_register == 2:
            temperature = 100
            modbus_server.data_bank.set_holding_registers(10, [0])


        time.sleep(5)

try:

    temp_thread = Thread(target=update_temperature)
    temp_thread.start()


    button_thread = Thread(target=check_buttons)
    button_thread.start()


    modbus_update_thread = Thread(target=update_modbus_registers)
    modbus_update_thread.start()


    temp_thread.join()
    button_thread.join()
    modbus_update_thread.join()

except KeyboardInterrupt:
    print("Program stopped")
    running = False
    temp_thread.join()
    button_thread.join()
    modbus_update_thread.join()

finally:
    modbus_server.stop()
    logging.info("Modbus Server stopped")
    GPIO.cleanup()