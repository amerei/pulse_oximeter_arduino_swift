#include <SparkFun_Bio_Sensor_Hub_Library.h>
#include <Wire.h>
#include <ArduinoBLE.h> 

// Reset pin, MFIO pin
int resPin = 4;
int mfioPin = 5;

SparkFun_Bio_Sensor_Hub bioHub(resPin, mfioPin); 

bioData sensorData;  


BLEService pulseService("18B10000-E8F2-537E-4F6C-D104768A1214"); // BLE WIFI Service

// BLE Pulse Characteristic - custom 128-bit UUID, read and writable by central
BLECharacteristic statCharacteristic("18B10001-E8F2-537E-4F6C-D104768A1214", BLENotify ,64);
BLECharacteristic confCharacteristic("18B10001-E8F2-537E-4F6C-D104768A1215", BLENotify ,64);
BLECharacteristic pulseCharacteristic("18B10001-E8F2-537E-4F6C-D104768A1216", BLENotify ,64);
BLEUnsignedIntCharacteristic oxygenCharacteristic("18B10001-E8F2-537E-4F6C-D104768A1217", BLENotify);



void setup(){

  Serial.begin(115200);

  Wire.begin();
  int result = bioHub.begin();
  if (result == 0) 
    Serial.println("Stared Sensor");
  else
    Serial.println("Communication Error");
 
  Serial.println("Configure Sensor"); 
  int error = bioHub.configBpm(MODE_TWO); // Set to Mode two to get more status 
  if(error == 0){ 
    Serial.println("Sensor successfuly configured");
  }
  else {
    Serial.print("Error: "); 
    Serial.println(error); 
  }

   // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");

    while (1);
  }
 
  Serial.println("Starting up in 5 seconds");
  delay(5000); 

  BLE.setLocalName("Pulse");
  BLE.setAdvertisedService(pulseService);

  pulseService.addCharacteristic(statCharacteristic);
  pulseService.addCharacteristic(confCharacteristic);
  pulseService.addCharacteristic(pulseCharacteristic);
  pulseService.addCharacteristic(oxygenCharacteristic);
  
  BLE.addService(pulseService);

  BLE.advertise();

  
}

void loop(){


    BLEDevice central = BLE.central();
    sensorData = bioHub.readBpm();
    
     
    
    Serial.print("Status: ");
    Serial.println(sensorData.extStatus * -1); 
    
    if (sensorData.extStatus == 1)
    {
      statCharacteristic.writeValue((byte)(sensorData.extStatus * -1 + 6)); 
    }
    else
    {
      statCharacteristic.writeValue((byte)(sensorData.extStatus * -1)); 
    }

    Serial.print("Confidence Level: ");
    Serial.println(sensorData.confidence);
    confCharacteristic.writeValue(sensorData.confidence); 

    Serial.print("BPM: ");
    Serial.println(sensorData.heartRate);
    pulseCharacteristic.writeValue(sensorData.heartRate); 

    Serial.print("Blood Oxygen Percentage: ");
    Serial.println(sensorData.oxygen); 
    oxygenCharacteristic.writeValue(sensorData.oxygen); 
     
    delay(300); 
}
