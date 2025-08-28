from appium import webdriver
import time

caps = {
    "platformName": "Android",
    "deviceName": "Android Emulator",  # Or your real device
    "app": "/absolute/path/to/build/app/outputs/flutter-apk/app-debug.apk",
    "automationName": "Flutter"
}

driver = webdriver.Remote("http://localhost:4723/wd/hub", caps)

time.sleep(5)

# Example: tap the counter button by its key


driver.quit()
