Upload this to your micro:bit device:

```python
from microbit import *
import utime

while True:
    x = accelerometer.get_x()
    y = accelerometer.get_y()
    z = accelerometer.get_z()

    print("{},{},{}".format(x, y, z))
    utime.sleep_ms(50)
```

Swift dependencies:

1. In Xcode → File > Add Packages…
2. Enter URL: https://github.com/armadsen/ORSSerialPort
3. Add it to app target

