# :pushpin: 졸음 운전 방지 스마트 핸들
>이산화탄소 농도 감지를 통한 졸음 운전 방지 스마트 핸들  
>[구현영상](https://youtu.be/GPuEISN3gjA) 

</br>

## 1. 제작 기간 & 참여 인원
- 2022년 2월 26일 ~ 3월 14일
- 팀 프로젝트(5명)

</br>

## 2. 사용 기술
#### `Back-end`
  - Java 8
  - Jsp / Servlet
  - Oracle Database 11g
  - Arduino
#### `Front-end`
  - HTML / CSS
  - JavaScript

</br>

## 3. ERD
![](https://user-images.githubusercontent.com/90882199/159430575-1eede29c-4d17-462f-a311-f52c36ad54e8.png)


## 4. 핵심 기능
이 서비스의 핵심 기능은 이산화탄소 농도 수치가 2000ppm 이상이면 졸음운전 방지 음성을 출력합니다.  
또한 핸들에 부착되어있는 산소포화도, 체온 센서로 이상 수치 감지 시 서버로 값을 전송하고 웹에서 시각화된 그래프로 볼 수 있습니다.  
운전자가 응급 및 위급 상황 시 현재 위치를 기준으로 위도, 경도 값을 서버로 전송합니다.  

<details>
<summary><b>기능 설명 펼치기</b></summary>
<div markdown="1">

### 4.1. 전체 흐름
<p align="center">
    <img src="https://user-images.githubusercontent.com/90882199/159431688-5d6b3689-db14-493d-9808-53d48d01009d.png">
</p>
<p align="center">서비스 흐름도 입니다.</p>
<p align="center">
    <img src="https://user-images.githubusercontent.com/90882199/159434996-68f5ca65-cbf3-4c79-9ac3-0ae7221a5bbf.png">
</p>
<p align="center">제품 회로도 입니다.</p>
<p align="center">
    <img src="https://user-images.githubusercontent.com/90882199/159435519-5946f46a-f8d7-441c-81c6-8f9fd00c5e08.png">
</p>
<p align="center">제품 사진 입니다.</p>
핸들 뒤편 좌측과 우측 부분에서 산소포화도 체온을 측정 할 수 있습니다. GPS 모듈은 핸들 내부에 부착되어있습니다. 이산화탄소 센서와, MP3 모듈을 분리한 이유는 실제 차량의 스피커와 연동된 모습을 연출하기 위해서 분리시켜놓았습니다. 실제 차량으로 제품을 만든다면 MP3 모듈을 차량의 스피커와 블루투스 연결을 할 생각입니다.

<details>
<summary><b>아두이노 코드</b></summary>
<div markdown="1">

~~~c++
#include <WiFi.h>
#include <HTTPClient.h>
#include <SoftwareSerial.h>

//체온
#include <Adafruit_MLX90614.h>
Adafruit_MLX90614 mlx = Adafruit_MLX90614();

//산소포화도
#include <Wire.h>
#include "MAX30100_PulseOximeter.h"
#define REPORTING_PERIOD_MS     1000
PulseOximeter pox;
uint32_t tsLastReport = 0;

//gps
#include <TinyGPS.h>
TinyGPS gps;
SoftwareSerial ss(5, 16); // 18tx 19rx
int cnt;
int btn = 2;
boolean check;
int buttonState;

const char* ssid = "KT_GiGA_8403";
const char* password = "6az42bd158";

const char* serverName = "http://59.0.236.167:8081/27.8Hz/getValuesTest.jsp";

unsigned long lastTime = 0;
unsigned long timerDelay = 6000;
long prev_time;

void setup() {
  Serial.begin(9600);

  WiFi.begin(ssid, password);
  Serial.println("Connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to WiFi network with IP Address: ");
  Serial.println(WiFi.localIP());

  pox.begin();
  Wire1.setPins(26, 27);
  mlx.begin(MLX90614_I2CADDR, &Wire1);

  //gps
  ss.begin(9600);
  pinMode(2, INPUT);
  cnt = 0;
}

void loop() {
  //산소포화도, 심박수 출력 코드
  pox.update();
  Serial.print("심박수:");
  Serial.print(pox.getHeartRate());
  Serial.print("bpm / 산소포화도:");
  Serial.print(pox.getSpO2());
  Serial.print("%");
  Serial.print(" 체온 = ");
  Serial.print(mlx.readObjectTempC());
  Serial.print("*C");

  //버튼
  buttonState = digitalRead(btn);

  bool newData = false;
  unsigned long chars;
  unsigned short sentences, failed;

  float flat, flon;
  unsigned long age;
  double x, y;
  int result_lat, result_lon;

  if (buttonState == 1) {
    if (check == true) {
      cnt++;
      check = false;
    }
  } else {
    check = true;
  }

  Serial.print(" cnt : ");
  Serial.println(cnt);
  delay(100);

  //Send an HTTP POST request every 10 minutes
  String httpRequestData = "";
  if ((millis() - lastTime) > timerDelay) {
    //Check WiFi connection status
    if (WiFi.status() == WL_CONNECTED) {
      WiFiClient client;
      HTTPClient http;

      // Your Domain name with URL path or IP address with path
      http.begin(client, serverName);

      // Specify content-type header
      http.addHeader("Content-Type", "application/x-www-form-urlencoded");
      // Data to send with HTTP POST

      //---------------------------------------------------------------------------
      //---------------------------------------------------------------------------
      //---------------------------------------------------------------------------
      //서버에 산소포화도,심박수,체온값 전송
      if (pox.getHeartRate() >= 45 && pox.getSpO2() > 90 && pox.getSpO2() <= 100) {
        httpRequestData = "hr=" + (String)pox.getHeartRate() + "&o2=" + (String)pox.getSpO2() + "&temp=" + (String)mlx.readObjectTempC();
      }
      //---------------------------------------------------------------------------
      //---------------------------------------------------------------------------
      //---------------------------------------------------------------------------

      // Send HTTP POST request
      int httpResponseCode = http.POST(httpRequestData);

      Serial.print("HTTP Response code: ");
      Serial.println(httpResponseCode);

      if (millis() - prev_time > 1000) {
        pox = PulseOximeter();
        pox.begin();
      }
      prev_time = millis();

      // Free resources
      http.end();
    }
    else {
      Serial.println("WiFi Disconnected");
    }

    // 버튼 3번 누르면 gps 값 보내기
    if (cnt > 0) {
      for (unsigned long start = millis(); millis() - start < 1000;)
      {
        while (ss.available())
        {
          char c = ss.read();
          // Serial.write(c); // uncomment this line if you want to see the GPS data flowing
          if (gps.encode(c)) // Did a new valid sentence come in?
            newData = true;
        }
      }

      if (newData)
      {
        gps.f_get_position(&flat, &flon, &age);
        Serial.print("LAT=");
        Serial.print(flat == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flat, 6);
        x = (flat == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flat);
        result_lat = x * 1000000;
        Serial.print(" ");
        Serial.print("LON=");
        Serial.println(flon == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flon, 6);
        y = (flon == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : flon);
        result_lon = y * 1000000;

        //서버에 GPS값 전송
        httpRequestData += "&LAT=" + (String)result_lat + "&LON=" + (String)result_lon;
      }
    }

    lastTime = millis();
  }
}
~~~                                                                      
</div>
</details>

### 4.2. GPS 값을 전송 받아 지도에 위치 표시 
![image](https://user-images.githubusercontent.com/90882199/160229587-17521393-4827-4724-bf27-0195655af922.png)
- **Kakao Maps API 활용한 위치 표시** :pushpin:[코드 확인](https://github.com/HeonchanKim/smhrd_coreProject/blob/master/src/main/webapp/kakaoMap_gps.jsp#L21)
  - GPS 모듈을 통해 운전자의 경도, 위도 값을 알아냅니다.
  - 값을 서버로 전송시켜 API를 활용해 지도에 위치를 표시해줍니다.

### 4.3. 운전자 측정 데이터 그래프 표시 
![image](https://user-images.githubusercontent.com/90882199/160228814-98c08252-0ee7-4009-b2b8-5611da092a39.png)
- **chart JS 사용해 그래프 구현** :pushpin:[코드 확인](https://github.com/HeonchanKim/smhrd_coreProject/blob/master/src/main/webapp/278board/HealthData.jsp#L151)
  - 건강 데이터를 측정하고 데이터를 서버로 전송받아 DB에 저장합니다.
  - Chart.js Open source를 
  - 활용해 사용자에게 그래프로 저장된 데이터를 보여줍니다.

</div>
</details>

</br>

## 5. 핵심 트러블 슈팅
### 5.1. 
